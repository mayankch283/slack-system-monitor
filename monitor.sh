#!/bin/bash

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
DISK_THRESHOLD=80

# Function to send notification
send_notification() {
    local message=$1
    curl -X POST http://localhost:5000/notify -H "Content-Type: application/json" -d "{\"message\": \"$message\"}"
}

while true; do
    # Get CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Get memory usage
    memory_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    
    # Get disk usage
    disk_usage=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    
    # Check CPU usage
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        send_notification "High CPU Usage Detected: ${cpu_usage}%"
    fi
    
    # Check memory usage
    if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
        send_notification "High Memory Usage Detected: ${memory_usage}%"
    fi
    
    # Check disk usage
    if (( disk_usage > DISK_THRESHOLD )); then
        send_notification "High Disk Usage Detected: ${disk_usage}%"
    fi
    
    # Sleep for a while before checking again
    sleep 60
done