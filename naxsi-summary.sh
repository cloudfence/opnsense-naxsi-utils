#!/bin/sh
#    Copyright (C) 2024 Cloudfence
#    All rights reserved.
#
#    Redistribution and use in source and binary forms, with or without
#    modification, are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.#
#
#    2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#    THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
#    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
#    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#    AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
#    OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#    POSSIBILITY OF SUCH DAMAGE.

# Directory containing log files
log_dir="$1"

# Path to naxsi_core.rules
naxsi_rules_file="/usr/local/etc/nginx/naxsi_core.rules"

# Check if directory is provided
if [ -z "$log_dir" ]; then
    echo "Usage: $0 <log_directory>"
    exit 1
fi

# Check if naxsi_core.rules file exists
if [ ! -f "$naxsi_rules_file" ]; then
    echo "Error: NAXSI core rules file not found at $naxsi_rules_file"
    exit 1
fi

# Temporary files
temp_file="/tmp/logs_extracted.txt"
temp_rules="/tmp/naxsi_rules_parsed.txt"
> "$temp_file"  # Clear the temporary file
> "$temp_rules"  # Clear the temporary rules file

# Parse naxsi_core.rules to map IDs to types
while IFS= read -r line; do
    if echo "$line" | grep -q "## .* IDs:"; then
        # Extract the rule type and clean the range
        type=$(echo "$line" | sed -n 's/^## \(.*\) IDs:.*$/\1/p')
        range=$(echo "$line" | sed -n 's/^## .* IDs:\(.*\)$/\1/p' | tr -d ' #')

        # Extract start and end IDs and map each ID to its type
        start_id=$(echo "$range" | cut -d'-' -f1)
        end_id=$(echo "$range" | cut -d'-' -f2)
        for id in $(seq "$start_id" "$end_id"); do
            echo "$id $type" >> "$temp_rules"
        done
    fi
done < "$naxsi_rules_file"

# Process files matching the pattern "<domain>.error.log" or "<domain>.error.log.gz"
find "$log_dir" -type f \( -name "*.error.log" -o -name "*.error.log.gz" \) | while IFS= read -r file; do
    echo "Processing: $file"
    if echo "$file" | grep -q "\.gz$"; then
        zcat "$file" >> "$temp_file" 2>/dev/null
    else
        cat "$file" >> "$temp_file"
    fi
done

# Summarize and correlate IDs with IPs, Domains, and Types
awk -F'[ ,=&]' '
BEGIN {
    # Load ID types from the parsed rules file
    while ((getline < "'"$temp_rules"'") > 0) {
        id_types[$1] = $2
    }
}
{
    # Extract client IP
    client_ip = ""
    for (i = 1; i <= NF; i++) {
        if ($i == "client:") {
            client_ip = $(i+1)
            break
        }
    }

    # Extract domain (server)
    domain = ""
    for (i = 1; i <= NF; i++) {
        if ($i == "server:") {
            domain = $(i+1)
            break
        }
    }

    # Extract id fields and associate with client IP, domain, and type
    if (client_ip != "" && domain != "") {
        for (i = 1; i <= NF; i++) {
            if ($i ~ /^id[0-9]+$/) {
                id_value = $(i+1)
                ids[id_value]++
                ids_to_ips_domains_types[id_value ":" client_ip ":" domain]++
                ips[client_ip]++
                domains[domain]++
            }
        }
    }
}
END {
    print "Summary of IDs, their associated IPs, Domains, and Types:"
    for (key in ids_to_ips_domains_types) {
        split(key, arr, ":")
        id = arr[1]
        ip = arr[2]
        domain = arr[3]
        type = (id in id_types ? id_types[id] : "Unknown")
        id_counts[id] += ids_to_ips_domains_types[key]
    }
    for (id in id_counts) {
        type = (id in id_types ? id_types[id] : "Unknown")
        printf "ID %s (%s): Triggered %d times by IPs and Domains:\n", id, type, id_counts[id]
        for (key in ids_to_ips_domains_types) {
            split(key, arr, ":")
            if (arr[1] == id) {
                printf "  - IP: %s, Domain: %s (%d occurrences)\n", arr[2], arr[3], ids_to_ips_domains_types[key]
            }
        }
    }

    print "\nSummary of Source IPs and the IDs they triggered by Domain and Type:"
    for (ip in ips) {
        printf "IP %s: Triggered the following IDs by Domain and Type:\n", ip
        for (key in ids_to_ips_domains_types) {
            split(key, arr, ":")
            if (arr[2] == ip) {
                type = (arr[1] in id_types ? id_types[arr[1]] : "Unknown")
                printf "  - ID: %s (%s), Domain: %s (%d occurrences)\n", arr[1], type, arr[3], ids_to_ips_domains_types[key]
            }
        }
    }
}' "$temp_file"

# Clean up
rm -f "$temp_file" "$temp_rules"
