#!/bin/bash

# Slack Webhook URL (replace with your actual webhook URL)
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

# Threshold values
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Function to send a notification to Slack
send_slack_notification() {
    local message="$1"
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${message}\"}" "$SLACK_WEBHOOK_URL"
}

# Get CPU usage
CPU_USAGE=$(wmic cpu get loadpercentage | grep -Eo '[0-9]+')
if [[ -z "$CPU_USAGE" ]]; then
    CPU_USAGE=0
fi

# Get memory usage
MEMORY_INFO=$(wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value | tr -d '\r')
FREE_MEM=$(echo "$MEMORY_INFO" | grep FreePhysicalMemory | awk -F= '{print $2}')
TOTAL_MEM=$(echo "$MEMORY_INFO" | grep TotalVisibleMemorySize | awk -F= '{print $2}')

# Validate memory values
if [[ -z "$FREE_MEM" || -z "$TOTAL_MEM" || "$TOTAL_MEM" -eq 0 ]]; then
    MEMORY_USAGE=0
else
    MEMORY_USED=$((TOTAL_MEM - FREE_MEM))
    MEMORY_USAGE=$(( (MEMORY_USED * 100 ) / TOTAL_MEM ))
fi

# Get disk usage for C:
DISK_INFO=$(wmic logicaldisk where "DeviceID='C:'" get FreeSpace,Size /Value | tr -d '\r')
FREE_DISK=$(echo "$DISK_INFO" | grep FreeSpace | awk -F= '{print $2}')
TOTAL_DISK=$(echo "$DISK_INFO" | grep Size | awk -F= '{print $2}')

# Validate disk values
if [[ -z "$FREE_DISK" || -z "$TOTAL_DISK" || "$TOTAL_DISK" -eq 0 ]]; then
    DISK_USAGE=0
else
    DISK_USED=$((TOTAL_DISK - FREE_DISK))
    DISK_USAGE=$(( (DISK_USED * 100 ) / TOTAL_DISK ))
fi

# Check CPU threshold
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    send_slack_notification "High CPU usage: ${CPU_USAGE}%"
fi

# Check Memory threshold
if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    send_slack_notification "High Memory usage: ${MEMORY_USAGE}%"
fi

# Check Disk threshold
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    send_slack_notification "High Disk usage: ${DISK_USAGE}%"
fi