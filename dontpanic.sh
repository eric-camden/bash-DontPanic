#!/usr/bin/env bash
# dontpanic_cleaned.sh - A friendly system diagnostics script with clear commentary

# Exit immediately on errors and catch failures in pipelines
set -e
set -o pipefail

# List of commands and utilities the script depends on
REQUIRED_CMDS=(
  date hostname cat w last sar ps free vmstat iostat df netstat dmesg awk tail grep tee head find
)

# Function: Check for required commands and warn if missing
check_dependencies() {
  echo "Checking for required commands..."
  for cmd in "${REQUIRED_CMDS[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Warning: '$cmd' not found; related sections may be skipped."
    fi
  done
  echo
}

# Function: Display ASCII art banner
print_banner() {
  cat << 'EOF'
                  nnnmmm                    
   \||\       ;;;;%%%@@@@@@       \ //,     
    V|/     %;;%%%%%@@@@@@@@@@  ===Y//      
    68=== ;;;;%%%%%%@@@@@@@@@@@@    @Y      
    ;Y   ;;%;%%%%%%@@@@@@@@@@@@@@    Y      
    ;Y  ;;;+;%%%%%%@@@@@@@@@@@@@@@    Y     
    ;Y__;;;+;%%%%%%@@@@@@@@@@@@@@i;;__Y     
   iiY"";;   "uu%@@@@@@@@@@uu"   @"";;;>    
          Y     "UUUUUUUUU"     @@          
          `;       ___ _       @            
            `;.  ,====\\=.  .;"             
              ``""""`==\\=="                
                     `;===== WT             
                        ===                 
                                            
      DON'T PANIC !!!!!!!!!!!!!!!!!!!!!     
                                            
EOF
}

# Function: Basic host information
display_basic_info() {
  echo
  date +"Date: %Y-%m-%d %H:%M:%S"
  echo "Host: $(hostname)"
  echo -n "Release: " && cat /etc/redhat-release
}

# Function: Show uptime and current users
show_uptime_and_users() {
  echo -e "\n***********************************************************************************"
  echo "######## Uptime & Current Users ########"
  w
}

# Function: Display last boot and recent sessions
show_last_boot_info() {
  echo -e "\n######## Last Boot & Logins ########"
  echo "Recent login sessions (last 10):"
  last | head -n 10
  echo -e "\nAll runlevel and system events (last 10):"
  last -x | head -n 10
  echo -e "\nRunlevel changes (last 10):"
  last -x | grep runlevel | head -n 10
}

# Function: Disk usage statistics
show_disk_usage() {
  echo -e "\n***********************************************************************************"
  echo "######## Overall Disk Utilization ########"
  df -h
}

# Function: CPU and process load information
show_cpu_info() {
  echo -e "\n***********************************************************************************"
  echo "######## Process and CPU Information ########"
  echo -n "Number of CPUs: "
  grep -c ^processor /proc/cpuinfo

  echo -e "\nCollective CPU load summary (past hour):"
  if command -v sar &>/dev/null; then
    sar -q | tail -n 6 2>/dev/null || echo "sar data unavailable; ensure sysstat is configured."
  else
    echo "sar command not found; skipping CPU load summary."
  fi

  echo -e "\nTop 5 CPU-consuming processes:"
  ps aux --sort=-%cpu | head -n 6
}

# Function: Memory usage statistics
show_memory_info() {
  echo -e "\n***********************************************************************************"
  echo "######## RAM Utilization ########"

  echo -e "\nCollective RAM usage summary (past hour):"
  if command -v sar &>/dev/null; then
    sar -r | tail -n 6 2>/dev/null || echo "sar data unavailable; ensure sysstat is configured."
  else
    echo "sar command not found; skipping RAM usage summary."
  fi

  echo -e "\nTotal and free memory (MB):"
  free -m
  echo -e "\nVirtual memory stats:"
  vmstat
  echo -e "\nTop 5 memory-consuming processes:"
  ps aux --sort=-%mem | head -n 6
}

# Function: I/O statistics
show_io_stats() {
  echo -e "\n***********************************************************************************"
  echo "######## Input/Output Statistics ########"
  iostat
}

# Function: Tail relevant logs
show_logs() {
  echo -e "\n***********************************************************************************"
  echo "######## Various Logs ########"
  echo -e "\nLast hour of /var/log/messages:"
  awk -v d1="$(date --date='-60 min' '+%b %_d %H:%M')" -v d2="$(date '+%b %_d %H:%M')" \
    '$0 > d1 && $0 <= d2' /var/log/messages || echo "No log entries in the last hour."

  echo -e "\nEntries from /var/log/yum.log (past 2 days):"
  awk -v p1="^$(date -d '2 days ago' '+%b %_d')" -v p2="^$(date -d 'yesterday' '+%b %_d')" -v p3="^$(date '+%b %_d')" \
    '$0 ~ p1 || $0 ~ p2 || $0 ~ p3' /var/log/yum.log || echo "No recent yum activity."

  echo -e "\nFull /var/log/boot.log:"
  cat /var/log/boot.log || echo "boot.log not found."

  echo -e "\nLast 10 lines of /var/log/secure:"
  tail -n 10 /var/log/secure || echo "secure log not found."
}

# Function: Scan all log files for warnings or errors
scan_logs_for_issues() {
  echo -e "\n***********************************************************************************"
  echo "######## Scanning All Logs for Warnings/Errors ########"
  find / -type f -name "*.log" 2>/dev/null | while read -r file; do
    echo -e "\nLog File: $file"
    grep -Ei "warning|error" "$file" || echo "  (No matches)"
    echo "----------------------------"
  done
}

# Function: Network and kernel messages
show_network_and_dmesg() {
  echo -e "\n***********************************************************************************"
  echo "######## Network and Kernel Messages ########"
  echo -e "\nOpen ports (netstat -a):"
  netstat -a
  echo -e "\nSaving dmesg to /tmp/dmesg.log$(date +%Y%m%d)"
  dmesg > /tmp/dmesg.log$(date +%Y%m%d)
  echo "Done."
}

# Main execution sequence
main() {
  check_dependencies
  print_banner
  display_basic_info
  show_uptime_and_users
  show_last_boot_info
  show_disk_usage
  show_cpu_info
  show_memory_info
  show_io_stats
  show_logs
  scan_logs_for_issues
  show_network_and_dmesg
}

# Run main and tee output to both terminal and output.txt in script directory
main 2>&1 | tee "$(dirname "$0")/output.txt"
