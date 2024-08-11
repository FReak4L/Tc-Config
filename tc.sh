#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to calculate optimal values with enhanced allocation to CLASS_100, CLASS_200, and CLASS_300
calculate_optimal_values() {
    local bandwidth=$1
    local unit=${bandwidth##*[0-9]}
    local value=${bandwidth%%[a-zA-Z]*}

    # Convert bandwidth to megabits per second (Mbps)
    case $unit in
        gbit|gbps) value=$((value * 1024)) ;;
        mbit|mbps) value=$value ;;
        *) echo "Invalid bandwidth unit"; return 1 ;;
    esac

    # Dynamic allocation based on bandwidth
    local low_priority_percent=$((15 + value / 1000))
    local medium_priority_percent=$((20 + value / 500))
    local high_priority_percent=$((30 + value / 250))
    
    # Ensure percentages don't exceed 100%
    local total_percent=$((low_priority_percent + medium_priority_percent + high_priority_percent))
    if [ $total_percent -gt 95 ]; then
        local scale_factor=$((95 * 100 / total_percent))
        low_priority_percent=$((low_priority_percent * scale_factor / 100))
        medium_priority_percent=$((medium_priority_percent * scale_factor / 100))
        high_priority_percent=$((high_priority_percent * scale_factor / 100))
    fi

    # Calculate class rates
    echo "MAX_RATE=${value}mbit"
    echo "CLASS_100=$((value * low_priority_percent / 100))mbit"
    echo "CLASS_200=$((value * medium_priority_percent / 100))mbit"
    echo "CLASS_300=$((value * high_priority_percent / 100))mbit"
    echo "CLASS_400=$((value * 20 / 100))mbit"
    echo "CLASS_999=$((value * 95 / 100))mbit"
    echo "HTB_CLASS_RATE=$((value * 90 / 100))mbit"

    # Advanced Classes with dynamic allocation
    echo "ADV_CLASS_10=$((value * 40 / 100))mbit"
    echo "ADV_CLASS_20=$((value * 30 / 100))mbit"
    echo "ADV_CLASS_30=$((value * 20 / 100))mbit"
    echo "ADV_CLASS_100=$((value * 10 / 100))mbit"
    echo "CAKE_BANDWIDTH=${value}mbit"

    # Dynamic FQ_CODEL and FQ_PIE settings
    local base_quantum=300
    local quantum_factor=$((value / 100))
    echo "FQ_CODEL_QUANTUM=$((base_quantum + quantum_factor * 100))"
    echo "FQ_PIE_TARGET=$((20 - quantum_factor))ms"
    echo "FQ_CODEL_TARGET=$((10 - quantum_factor / 2))ms"
    
    if [ $value -le 100 ]; then
        echo "ECN_THRESHOLD=ecn"
    elif [ $value -le 1000 ]; then
        echo "ECN_THRESHOLD=ecn"
    elif [ $value -le 5000 ]; then
        echo "ECN_THRESHOLD=ecn"
    else
        echo "ECN_THRESHOLD=noecn"
    fi

    # Dynamic flow configuration
    local flow_factor=$((value / 100))
    echo "FQ_PIE_FLOWS=$((1000 + flow_factor * 100))"
    echo "FQ_CODEL_FLOWS=$((500 + flow_factor * 50))"
    
    # Dynamic interval and buffer size calculation
    local interval_ms=$((100 - value / 100))
    [ $interval_ms -lt 10 ] && interval_ms=10
    echo "FQ_CODEL_INTERVAL=${interval_ms}ms"
    
    local buffer_factor=$((value / 250))
    echo "BUFFER_SIZE=$((1024 + buffer_factor * 256))kb"
    
    
    echo "MAX_RATE=${value}mbit"
    echo "CLASS_100=${CLASS_100}mbit"
    echo "CLASS_200=${CLASS_200}mbit"
    echo "CLASS_300=${CLASS_300}mbit"
    echo "CLASS_400=${CLASS_400}mbit"
    echo "CLASS_999=${CLASS_999}mbit"
    echo "HTB_CLASS_RATE=${HTB_CLASS_RATE}mbit"
    echo "ADV_CLASS_10=${ADV_CLASS_10}mbit"
    echo "ADV_CLASS_20=${ADV_CLASS_20}mbit"
    echo "ADV_CLASS_30=${ADV_CLASS_30}mbit"
    echo "ADV_CLASS_100=${ADV_CLASS_100}mbit"
    echo "CAKE_BANDWIDTH=${CAKE_BANDWIDTH}mbit"
    echo "FQ_CODEL_QUANTUM=$FQ_CODEL_QUANTUM"
    echo "FQ_PIE_TARGET=${FQ_PIE_TARGET}ms"
    echo "FQ_CODEL_TARGET=${FQ_CODEL_TARGET}ms"
    echo "FQ_PIE_FLOWS=$FQ_PIE_FLOWS"
    echo "FQ_CODEL_FLOWS=$FQ_CODEL_FLOWS"
    echo "FQ_CODEL_INTERVAL=${FQ_CODEL_INTERVAL}ms"
    echo "ECN_THRESHOLD=$ECN_THRESHOLD"
    echo "BUFFER_SIZE=${BUFFER_SIZE}kb"
}

# Function to display help menu
display_help() {
    echo -e "${GREEN}Usage: tc.sh [OPTION]${NC}"
    echo -e "Options:"
    echo -e "  ${YELLOW}-s, --start${NC}    Run script TC configuration"
    echo -e "  ${YELLOW}-p, --premium${NC}  For premium configuration DM telegram to: @Freak_4L"
    echo -e "  ${YELLOW}-c, --channel${NC}  Channel in telegram: @FreakXray"
    echo -e "  ${YELLOW}-h, --help${NC}     Display this help message"
    echo -e "  ${YELLOW}-d, --delete${NC}   Delete TC configuration"
}

# Function to run the main script
run_script() {
    # Log file
    LOG_FILE="/var/log/tc-freak.log"

    # Function to log messages
    log_message() {
        echo "$(date): $1" >> "$LOG_FILE"
    }

    # Function to execute commands silently and log errors
    execute_command() {
        if ! "$@" >> "$LOG_FILE" 2>&1; then
            log_message "Error executing command: $*"
            return 1
        fi
        return 0
    }

    echo -e "${GREEN}
     ██████╗██████╗ ███████╗ █████╗ ██╗  ██╗    ██╗  ██╗██████╗  █████╗ ██╗   ██╗
     ██╔═══╝██╔══██╗██╔════╝██╔══██╗██║ ██╔╝    ╚██╗██╔╝██╔══██╗██╔══██╗╚██╗ ██╔╝
     ██████╗██████╔╝█████╗  ███████║█████╔╝      ╚███╔╝ ██████╔╝███████║ ╚████╔╝ 
     ██╔═══╝██╔══██╗██╔══╝  ██╔══██║██╔═██╗      ██╔██╗ ██╔══██╗██╔══██║  ╚██╔╝  
     ██║    ██║  ██║███████╗██║  ██║██║  ██╗    ██╔╝ ██╗██║  ██║██║  ██║   ██║   
     ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
                  
                                                                    
                ╔═══════ FreakXray TC Configuration - Standard Edition ═══════╗
                ║                                                         ║
                ║  ${LIGHT_PURPLE}• Telegram: @FreakXRAY                               ${GREEN}║
                ║  ${YELLOW}• Premium Configuration: @FReak_4L                    ${GREEN}║
                ║  ${CYAN}• Version: V0.0.5 (Try)                              ${GREEN}║
                ║                                                         ║
                ╚════════════════════════════════════════════════════════╝

    ${NC}"

    # Function to check if the kernel is Xanmod
    check_kernel() {
        if [[ "$(uname -r)" != *"xanmod"* ]]; then
            echo -e "${RED}Error: This script only runs on Xanmod kernel.${NC}"
            log_message "Error: Script execution failed. Xanmod kernel not detected."
            exit 1
        else
            echo -e "${GREEN}Kernel check passed: Xanmod kernel detected.${NC}"
            log_message "Kernel check passed: Xanmod kernel detected."
        fi
    }

    # Function to install necessary packages and update the system
    install_requirements() {
        echo -e "${GREEN}Updating and upgrading the system...${NC}"
        if ! execute_command sudo apt update -y && execute_command sudo apt upgrade -y; then
            echo -e "${RED}Error: Failed to update and upgrade the system.${NC}"
            exit 1
        fi
        log_message "System updated and upgraded successfully."

        echo -e "${GREEN}Installing required packages...${NC}"
        if ! execute_command sudo apt install -y iproute2 iptables; then
            echo -e "${RED}Error: Failed to install required packages.${NC}"
            exit 1
        fi
        log_message "Required packages installed successfully."
    }
    
    # Get user input with two additional options
    echo -e "${GREEN}Enter the network interface (e.g., ens3): ${NC}"
    read -p "1) eth0 (default)
    2) ens3
    3) custom
    Choose your option [1-3]: " IFACE_OPTION

    case $IFACE_OPTION in
        1) IFACE="eth0" ;;
        2) IFACE="ens3" ;;
        3) read -p "Enter custom interface: " IFACE ;;
        *) echo -e "${RED}Invalid option, defaulting to eth0.${NC}"; IFACE="eth0" ;;
    esac
    log_message "Network interface selected: $IFACE"

    echo -e "${GREEN}Enter the uplink/downlink bandwidth: ${NC}"
    read -p "Enter bandwidth (e.g., 1gbit, 5gbit, 10gbit): " BANDWIDTH

    # Calculate and set optimal values
    eval $(calculate_optimal_values $BANDWIDTH)

    # Log the selected bandwidth and calculated values
     log_message "Bandwidth selected: $BANDWIDTH"
     log_message "Calculated optimal values:"
     log_message "$(calculate_optimal_values $BANDWIDTH)"


    # Call the function to check the kernel
    check_kernel

    # Call the function to install requirements
    install_requirements

    # Function to execute tc commands and handle errors
    execute_tc_command() {
        if ! execute_command $1; then
            log_message "Error executing command: $1"
            return 1
        fi
        return 0
    }

    # Step 1: Setup Qdisc
    echo -e "${YELLOW}Step 1:${LIGHT_PURPLE} Setting up Qdisc${NC}"
    execute_tc_command "tc qdisc del dev $IFACE root 2>/dev/null"
    execute_tc_command "tc qdisc add dev $IFACE root handle 1: htb default 999"
    execute_tc_command "tc class add dev $IFACE parent 1: classid 1:1 htb rate $MAX_RATE ceil $MAX_RATE"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Qdisc setup completed."

    # Step 2: Adding Classes
    echo -e "${YELLOW}Step 2:${LIGHT_PURPLE} Adding classes${NC}"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:100 htb rate $CLASS_100 ceil $MAX_RATE prio 0"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:200 htb rate $CLASS_200 ceil $MAX_RATE prio 1"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:300 htb rate $CLASS_300 ceil $MAX_RATE prio 2"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:400 htb rate $CLASS_400 ceil $MAX_RATE prio 3"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:999 htb rate $CLASS_999 ceil $MAX_RATE prio 4"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Classes added successfully."

    # Step 3: Adding Qdiscs
    echo -e "${YELLOW}Step 3:${LIGHT_PURPLE} Adding Qdiscs${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:100 handle 100: cake bandwidth $CAKE_BANDWIDTH rtt 15ms diffserv4 flowblind triple-isolate nat wash ingress ack-filter fwmark 0x1 noatm ethernet mpu 64 overhead 32 conservative"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:200 handle 200: fq_codel flows $FQ_CODEL_FLOWS quantum $FQ_CODEL_QUANTUM target ${FQ_CODEL_TARGET}ms interval ${FQ_CODEL_INTERVAL}ms $ECN_THRESHOLD"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:300 handle 300: fq_pie flows $FQ_PIE_FLOWS target ${FQ_PIE_TARGET}ms tupdate 30ms alpha 2 beta 20 $ECN_THRESHOLD"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:400 handle 400: fq_codel flows $FQ_CODEL_FLOWS quantum $FQ_CODEL_QUANTUM target ${FQ_CODEL_TARGET}ms interval ${FQ_CODEL_INTERVAL}ms $ECN_THRESHOLD"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Qdiscs added successfully."

    # Step 4: Adding HTB Classes
    echo -e "${YELLOW}Step 4:${LIGHT_PURPLE} Adding HTB classes${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:999 handle 999: htb default 10"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:10 htb rate $HTB_CLASS_RATE ceil $MAX_RATE"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:20 htb rate $HTB_CLASS_RATE ceil $MAX_RATE"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:30 htb rate $HTB_CLASS_RATE ceil $MAX_RATE"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:40 htb rate $HTB_CLASS_RATE ceil $MAX_RATE"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - HTB classes added successfully."

    # Step 5: Adding final Qdiscs
    echo -e "${YELLOW}Step 5:${LIGHT_PURPLE} Adding final Qdiscs${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 999:10 handle 910: fq_pie flows $FQ_PIE_FLOWS target ${FQ_PIE_TARGET}ms tupdate 30ms alpha 2 beta 20 $ECN_THRESHOLD"
    execute_tc_command "tc qdisc add dev $IFACE parent 999:20 handle 920: fq_codel flows $FQ_CODEL_FLOWS quantum $FQ_CODEL_QUANTUM target ${FQ_CODEL_TARGET}ms interval ${FQ_CODEL_INTERVAL}ms $ECN_THRESHOLD"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. All tasks finished.${NC}"
    log_message "Done [✓]: - Final Qdiscs added successfully. All tasks completed."

    # Step 6: Advanced Traffic Optimization with Adaptive Shaping and Intelligent Queue Management
    echo -e "${YELLOW}Step 6:${LIGHT_PURPLE} Implementing advanced traffic optimization${NC}"
    log_message "Starting Step 6: Advanced traffic optimization"

    # Create a sophisticated qdisc structure
    execute_tc_command "tc qdisc add dev $IFACE root handle 1: htb default 100"
    execute_tc_command "tc class add dev $IFACE parent 1: classid 1:1 htb rate 950mbit ceil 1gbit"

    # Define traffic classes with adaptive rates
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:10 htb rate $ADV_CLASS_10 ceil $MAX_RATE prio 1"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:20 htb rate $ADV_CLASS_20 ceil $MAX_RATE prio 2"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:30 htb rate $ADV_CLASS_30 ceil $MAX_RATE prio 3"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:100 htb rate $ADV_CLASS_100 ceil $MAX_RATE prio 4"

    # Apply advanced qdiscs to each class
    execute_tc_command "tc qdisc add dev $IFACE parent 1:10 handle 10: cake bandwidth $ADV_CLASS_10 diffserv4 flowblind triple-isolate nat wash ingress ack-filter"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:20 handle 20: fq_pie limit 2000 target ${FQ_PIE_TARGET}ms tupdate 30ms alpha 2 beta 20 $ECN_THRESHOLD"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:30 handle 30: fq_codel limit 10240 flows $FQ_CODEL_FLOWS quantum $FQ_CODEL_QUANTUM target ${FQ_CODEL_TARGET}ms interval ${FQ_CODEL_INTERVAL}ms $ECN_THRESHOLD"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:100 handle 100: sfq perturb 10 quantum 1514 limit 2000"
    #Sysctl 
    sysctl -w net.ipv4.tcp_congestion_control=bbr
    sysctl -w net.core.default_qdisc=fq_codel
    sysctl -w net.ipv4.tcp_rmem="4096 87380 16777216"
    sysctl -w net.ipv4.tcp_wmem="4096 65536 16777216"
    sysctl -w net.core.rmem_max=16777216
    sysctl -w net.core.wmem_max=16777216
    sysctl -w net.core.netdev_max_backlog=32768
    sysctl -w net.core.somaxconn=65536
    sysctl -w net.ipv4.tcp_keepalive_time=300
    sysctl -w net.ipv4.tcp_keepalive_intvl=30
    sysctl -w net.ipv4.tcp_keepalive_probes=5
    sysctl -w net.ipv4.tcp_fastopen=3
    sysctl -w net.ipv4.tcp_timestamps=1
    sysctl -w net.ipv4.tcp_ecn=2
    sysctl -w net.ipv4.tcp_fin_timeout=15
    sysctl -w net.ipv4.tcp_window_scaling=1
    sysctl -w net.ipv4.tcp_mtu_probing=1
    sysctl -w net.ipv4.tcp_max_syn_backlog=16384
    sysctl -w net.ipv4.tcp_retries2=6
    sysctl -w net.ipv4.tcp_reordering=3
    sysctl -w net.ipv4.tcp_adv_win_scale=2
    sysctl -w net.ipv4.tcp_syncookies=1
    sysctl -w net.ipv4.tcp_sack=1
    sysctl -w net.ipv4.tcp_low_latency=1
    sysctl -w net.ipv4.tcp_slow_start_after_idle=0
    sysctl -w net.ipv4.tcp_early_retrans=1
    sysctl -w net.ipv4.tcp_tw_reuse=1
    sysctl -w net.ipv4.tcp_ecn_fallback=0
    sysctl -w net.ipv4.tcp_fack=1
    sysctl -w net.core.optmem_max=65536
    sysctl -w net.ipv4.tcp_notsent_lowat=16384
    sysctl -w net.ipv4.ip_local_port_range="1024 65535"
    sysctl -w net.ipv4.tcp_max_tw_buckets=1440000
    sysctl -w net.ipv4.tcp_fastopen_blackhole_timeout_sec=0
    sysctl -w net.ipv4.tcp_autocorking=0
    sysctl -w net.ipv4.tcp_no_metrics_save=1
    sysctl -w net.ipv4.tcp_abort_on_overflow=0
    sysctl -w net.core.busy_poll=50
    sysctl -w net.core.busy_read=50

    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Advanced traffic optimization completed.${NC}"
    log_message "Done [✓]: Advanced traffic optimization implemented successfully."

    echo -e "${GREEN}Script execution completed. Advanced network optimization is now in place.${NC}"
    echo -e "${YELLOW}
            ╔═══════════════ Premium FreakXray TC Optimizer ═══════════════╗
            ║                                                              ║
            ║  ${LIGHT_PURPLE}• Own Custom Config:                                      ${YELLOW}║
            ║    ${GREEN}[${YELLOW}Sysctl${GREEN}]+[${YELLOW} Network${GREEN}]+[${YELLOW}interface${GREEN}]+[${YELLOW} Customization TC${GREEN}]              ${YELLOW}║
            ║                                                              ║
            ║  ${LIGHT_PURPLE}• Dm to Telegram User id:                               ${YELLOW}║
            ║    ${GREEN}t.me/FReak_4L                                           ${YELLOW}║
            ║                                                              ║
            ╚══════════════════════════════════════════════════════════════╝
    ${NC}"
}

# Main menu logic
if [[ $# -eq 0 ]]; then
    echo -e "${RED}No arguments provided. Use -h or --help for usage information.${NC}"
    exit 1
fi

case "$1" in
    -s|--start)
        run_script
        ;;
    -p|--premium)
        echo -e "${YELLOW}For premium configuration, please DM on Telegram: @Freak_4L${NC}"
        ;;
    -c|--channel)
        echo -e "${YELLOW}Join our Telegram channel: @FreakXray${NC}"
        ;;
    -d|--delete)
        echo -e "${YELLOW}Deleting TC configuration...${NC}"
        read -p "Enter the network interface (e.g., eth0, ens3): " IFACE
        if [ -z "$IFACE" ]; then
            echo -e "${RED}No interface specified. Defaulting to eth0.${NC}"
            IFACE="eth0"
        fi
        if tc qdisc del dev $IFACE root 2>/dev/null; then
            echo -e "${GREEN}TC configuration for $IFACE deleted successfully.${NC}"
        else
            echo -e "${RED}Failed to delete TC configuration for $IFACE. It may not exist or you may need root privileges.${NC}"
        fi
        ;;
    -h|--help)
        display_help
        ;;
    *)
        echo -e "${RED}Invalid option. Use -h or --help for usage information.${NC}"
        exit 1
        ;;
esac
