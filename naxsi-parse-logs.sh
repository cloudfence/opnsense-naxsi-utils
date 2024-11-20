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

# Check if a filename is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# File containing log lines
log_file="$1"

# Check if file exists
if [ ! -f "$log_file" ]; then
    echo "Error: File '$log_file' not found!"
    exit 1
fi

# Lines per page
lines_per_page=5
current_line=0

# Function to extract key-value pairs
extract_field() {
    echo "$1" | sed -n "s/^.*$2\([^,]*\).*/\1/p"
}

# Process each log line
while IFS= read -r log_line; do
    # Increment the line count
    current_line=$((current_line + 1))
    
    # Extract fields using `sed`
    naxsi_fmt=$(echo "$log_line" | sed -n 's/^.*NAXSI_FMT: \(.*\), client:.*$/\1/p')
    client=$(extract_field "$log_line" "client: ")
    server=$(extract_field "$log_line" "server: ")
    request=$(echo "$log_line" | sed -n 's/^.*request: "\(.*\)".*$/\1/p')

    # Output the parsed log details
    echo "------------------------------------------------------------"
    echo "Parsed Log Details:"
    echo "Timestamp: $(echo "$log_line" | cut -d' ' -f1,2)"
    echo "Error Level: $(echo "$log_line" | cut -d' ' -f3 | tr -d '[]')"
    echo "Client: $client"
    echo "Server: $server"
    echo "Request: $request"

    echo "NAXSI_FMT Fields:"
    if [ -n "$naxsi_fmt" ]; then
        IFS='&' set -- $naxsi_fmt
        for field in "$@"; do
            key=$(echo "$field" | cut -d= -f1)
            value=$(echo "$field" | cut -d= -f2)
            echo "  $key: $value"
        done
    fi

    # Check for pagination
    if [ $((current_line % lines_per_page)) -eq 0 ]; then
        echo
        echo "Press Enter to continue, or 'q' to quit."
        read choice
        if [ "$choice" = "q" ]; then
            break
        fi
    fi
done < "$log_file"
