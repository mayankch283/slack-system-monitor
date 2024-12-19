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
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
if [[ -z "$CPU_USAGE" ]]; then
    CPU_USAGE=0
fi

# Get memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100}')
if [[ -z "$MEMORY_USAGE" ]]; then
    MEMORY_USAGE=0
fi

# Get disk usage
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
if [[ -z "$DISK_USAGE" ]]; then
    DISK_USAGE=0
fi

# Check CPU threshold
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    send_slack_notification "High CPU usage: ${CPU_USAGE}%"
fi

# Check Memory threshold
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    send_slack_notification "High Memory usage: ${MEMORY_USAGE}%"
fi

# Check Disk threshold
if (( DISK_USAGE > DISK_THRESHOLD )); then
    send_slack_notification "High Disk usage: ${DISK_USAGE}%"
fi