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
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${message}\"}" $SLACK_WEBHOOK_URL
}

# Get CPU usage
CPU_USAGE=$(wmic cpu get loadpercentage | grep -Eo '[0-9]+')
if [[ -z "$CPU_USAGE" ]]; then
    CPU_USAGE=0
fi

# Get memory usage
MEMORY_INFO=$(wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value)
FREE_MEM=$(echo "$MEMORY_INFO" | grep FreePhysicalMemory | awk -F= '{print $2}')
TOTAL_MEM=$(echo "$MEMORY_INFO" | grep TotalVisibleMemorySize | awk -F= '{print $2}')
MEMORY_USED=$((TOTAL_MEM - FREE_MEM))
MEMORY_USAGE=$(( (MEMORY_USED * 100) / TOTAL_MEM ))

# Get disk usage for C:
DISK_INFO=$(wmic logicaldisk where "DeviceID='C:'" get FreeSpace,Size /Value)
FREE_DISK=$(echo "$DISK_INFO" | grep FreeSpace | awk -F= '{print $2}')
TOTAL_DISK=$(echo "$DISK_INFO" | grep Size | awk -F= '{print $2}')
DISK_USAGE=$(( ( (TOTAL_DISK - FREE_DISK) * 100 ) / TOTAL_DISK ))

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