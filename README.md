# NAXSI Log File Parser Scripts

This repository contains two scripts designed to parse and analyze log files effectively, providing insights into log details and correlating them with specific NAXSI rules.

# NAXSI log file parser script

## Features

- Extracts and displays key details from log lines.
- Parses fields such as `client`, `server`, `request`, and `NAXSI_FMT`.
- Displays log entries in a human-readable format.
- Supports pagination for large log files.

## Requirements

- OPNsense shell access
- NGINX plugin with NAXSI rules installed
- `sed` command-line utility

## Usagex

1. Save the script to a file, e.g., `naxsi-parse-logs.sh`.
2. Make the script executable:
   ```bash
   chmod +x naxsi-parse-logs.sh
   ./naxsi-parse-logs.sh <filename>

## Example 
 ```./naxsi-parse-logs.sh /var/log/nginx/domain.com.error.log ```



## Parameters

    <filename>: The path to the log file to be processed.

Script Logic

    Input Validation:
        Ensures a filename is provided.
        Checks if the file exists.
    Log Line Processing:
        Reads the log file line by line.
        Extracts key fields such as timestamp, error level, client, server, request, and NAXSI_FMT details.
        Formats the extracted details for readability.
    Pagination:
        Displays 5 log entries at a time.
        Pauses and waits for user input before continuing.

## Example Output
 ```
------------------------------------------------------------
Parsed Log Details:
Timestamp: 2024-11-20 12:34:56
Error Level: WARN
Client: 192.168.1.1
Server: example.com
Request: GET /index.html

NAXSI_FMT Fields:
  id: 1001
  score: 8
  zone: BODY
 ```

# NAXSI Log Analyzer Script

## Overview

The NAXSI Log Analyzer script processes NGINX log files containing NAXSI rule violations, maps rule IDs to their types, and correlates them with IP addresses and domains. This script provides a detailed summary and insights into security events captured by NAXSI.

---

## Prerequisites

- **NAXSI Core Rules**: Ensure the `naxsi_core.rules` file is located at `/usr/local/etc/nginx/naxsi_core.rules`.
- **Log Files**: The directory should contain log files in `.log` or `.log.gz` format, matching the patterns `<domain>.error.log` or `<domain>.error.log.gz`.

---

## Usage

### Steps

1. Save the script as `naxsi-summary.sh`.
2. Make the script executable:
   ```bash
   chmod +x naxsi-summary.sh
   ./naxsi-summary.sh /var/log/nginx

# NAXSI Log Analyzer Script

## Overview

The NAXSI Log Analyzer script processes NGINX log files containing NAXSI rule violations, maps rule IDs to their types, and correlates them with IP addresses and domains. This script provides a detailed summary and insights into security events captured by NAXSI.

---

## Prerequisites

- **NAXSI Core Rules**: Ensure the `naxsi_core.rules` file is located at `/usr/local/etc/nginx/naxsi_core.rules`.
- **Log Files**: The directory should contain log files in `.log` or `.log.gz` format, matching the patterns `<domain>.error.log` or `<domain>.error.log.gz`.

---

## Usage

### Steps

1. Save the script as `naxsi-summary.sh`.
2. Make the script executable:
   ```bash
   chmod +x naxsi-summary.sh
   ./naxsi-summary.sh <log_directory>

### Example

 ```./naxsi-summary.sh /var/log/nginx ```

## Features

    Parses naxsi_core.rules to map rule IDs to their respective types.
    Processes both .log and .log.gz files.
    Extracts relevant fields such as:
        client (IP address)
        server (domain)
        id (NAXSI rule ID)
    Correlates rule violations with IPs and domains.
    Provides:
        Summary of IDs and their associated IPs, domains, and types.
        Detailed breakdown of rule triggers by IP, domain, and type.

## Example Output
 ```
Summary of IDs

Summary of IDs, their associated IPs, Domains, and Types:
ID 1001 (SQL Injection): Triggered 8 times by IPs and Domains:
  - IP: 192.168.1.100, Domain: example.com (3 occurrences)
  - IP: 10.0.0.5, Domain: test.com (5 occurrences)

ID 2002 (XSS): Triggered 6 times by IPs and Domains:
  - IP: 192.168.1.100, Domain: example.com (2 occurrences)
  - IP: 10.0.0.5, Domain: test.com (4 occurrences)

Breakdown by IP

Summary of Source IPs and the IDs they triggered by Domain and Type:
IP 192.168.1.100: Triggered the following IDs by Domain and Type:
  - ID: 1001 (SQL Injection), Domain: example.com (3 occurrences)
  - ID: 2002 (XSS), Domain: example.com (2 occurrences)

IP 10.0.0.5: Triggered the following IDs by Domain and Type:
  - ID: 1001 (SQL Injection), Domain: test.com (5 occurrences)
  - ID: 2002 (XSS), Domain: test.com (4 occurrences)
```
