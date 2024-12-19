#./monitor.sh

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
CPU_USAGE=$(wmic cpu get loadpercentage | awk 'NR==2 {print $1}')
if [[ -z "$CPU_USAGE" ]]; then
    CPU_USAGE=0
fi

# Get memory usage
MEMORY_STATS=$(wmic os get freephysicalmemory,totalvisiblememorysize)
FREE_MEMORY=$(echo "$MEMORY_STATS" | awk 'NR==2 {print $1}')
TOTAL_MEMORY=$(echo "$MEMORY_STATS" | awk 'NR==2 {print $2}')
if [[ -z "$FREE_MEMORY" || -z "$TOTAL_MEMORY" || "$TOTAL_MEMORY" -eq 0 ]]; then
    MEMORY_USAGE=0
else
    MEMORY_USAGE=$((100 - (FREE_MEMORY * 100 / TOTAL_MEMORY)))
fi

# Get disk usage
DISK_STATS=$(wmic logicaldisk where "DeviceID='C:'" get freespace,size)
FREE_DISK=$(echo "$DISK_STATS" | awk 'NR==2 {print $1}')
TOTAL_DISK=$(echo "$DISK_STATS" | awk 'NR==2 {print $2}')
if [[ -z "$FREE_DISK" || -z "$TOTAL_DISK" || "$TOTAL_DISK" -eq 0 ]]; then
    DISK_USAGE=0
else
    DISK_USAGE=$((100 - (FREE_DISK * 100 / TOTAL_DISK)))
fi

# Monitor and send notifications
echo "Monitoring system resources..."

# Monitor CPU Usage
if (( CPU_USAGE > CPU_THRESHOLD )); then
    send_slack_notification "⚠️ High CPU Usage: ${CPU_USAGE}%"
else
    send_slack_notification "✅ CPU Usage is normal: ${CPU_USAGE}%"
fi

# Monitor Memory Usage
if (( MEMORY_USAGE > MEMORY_THRESHOLD )); then
    send_slack_notification "⚠️ High Memory Usage: ${MEMORY_USAGE}%"
else
    send_slack_notification "✅ Memory Usage is normal: ${MEMORY_USAGE}%"
fi

# Monitor Disk Usage
if (( DISK_USAGE > DISK_THRESHOLD )); then
    send_slack_notification "⚠️ High Disk Usage: ${DISK_USAGE}%"
else
    send_slack_notification "✅ Disk Usage is normal: ${DISK_USAGE}%"
fi





# #!/bin/bash

# # Slack Webhook URL (replace with your actual webhook URL)
# SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

# # Threshold values
# CPU_THRESHOLD=80
# MEMORY_THRESHOLD=80
# DISK_THRESHOLD=80

# # Function to send a notification to Slack
# send_slack_notification() {
#     local message="$1"
#     curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"${message}\"}" $SLACK_WEBHOOK_URL
# }

# # Get CPU usage (using top command)
# get_cpu_usage() {
#     CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}')
#     CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)
#     echo "$CPU_USAGE"
# }

# # Get memory usage (using free command)
# get_memory_usage() {
#     MEMORY_STATS=$(free -m | grep Mem)
#     TOTAL_MEMORY=$(echo "$MEMORY_STATS" | awk '{print $2}')
#     USED_MEMORY=$(echo "$MEMORY_STATS" | awk '{print $3}')
#     MEMORY_USAGE=$((USED_MEMORY * 100 / TOTAL_MEMORY))
#     echo "$MEMORY_USAGE"
# }

# # Get disk usage (using df command)
# get_disk_usage() {
#     DISK_STATS=$(df -h / | tail -1)
#     TOTAL_DISK=$(echo "$DISK_STATS" | awk '{print $2}' | sed 's/G//')
#     USED_DISK=$(echo "$DISK_STATS" | awk '{print $3}' | sed 's/G//')
#     DISK_USAGE=$((USED_DISK * 100 / TOTAL_DISK))
#     echo "$DISK_USAGE"
# }

# # Get system uptime (using uptime command)
# get_uptime() {
#     UPTIME=$(uptime -p)
#     echo "$UPTIME"
# }

# # Fetch metrics
# CPU_USAGE=$(get_cpu_usage)
# MEMORY_USAGE=$(get_memory_usage)
# DISK_USAGE=$(get_disk_usage)
# UPTIME=$(get_uptime)

# # Monitor and send notifications
# echo "Monitoring system resources..."

# # CPU Monitoring
# if (( CPU_USAGE > CPU_THRESHOLD )); then
#     send_slack_notification "⚠️ High CPU Usage: ${CPU_USAGE}%"
# else
#     send_slack_notification "✅ CPU Usage is normal: ${CPU_USAGE}%"
# fi

# # Memory Monitoring
# if (( MEMORY_USAGE > MEMORY_THRESHOLD )); then
#     send_slack_notification "⚠️ High Memory Usage: ${MEMORY_USAGE}%"
# else
#     send_slack_notification "✅ Memory Usage is normal: ${MEMORY_USAGE}%"
# fi

# # Disk Monitoring
# if (( DISK_USAGE > DISK_THRESHOLD )); then
#     send_slack_notification "⚠️ High Disk Usage: ${DISK_USAGE}%"
# else
#     send_slack_notification "✅ Disk Usage is normal: ${DISK_USAGE}%"
# fi

# # Log system uptime to Slack
# send_slack_notification "🕒 System Uptime: ${UPTIME}"


