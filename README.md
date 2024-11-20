# NAXSI log file parser script

This script processes a log file, extracts and formats key information, and provides a paginated view of the log entries.

## Features

- Extracts and displays key details from log lines.
- Parses fields such as `client`, `server`, `request`, and `NAXSI_FMT`.
- Displays log entries in a human-readable format.
- Supports pagination for large log files.

## Requirements

- OPNsense shell access
- NGINX plugin with NAXSI rules installed
- `sed` command-line utility

## Usage

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
