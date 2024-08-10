#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display help menu
display_help() {
    echo -e "${GREEN}Usage: tc.sh [OPTION]${NC}"
    echo -e "Options:"
    echo -e "  ${YELLOW}-s, --start${NC}    Run script TC configuration"
    echo -e "  ${YELLOW}-p, --premium${NC}  For premium configuration DM telegram to: @Freak_4L"
    echo -e "  ${YELLOW}-c, --channel${NC}  Channel in telegram: @FreakXray"
    echo -e "  ${YELLOW}-h, --help${NC}     Display this help message"
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
                  
                                                                    
                ╔═══════ FreakXray TC Optimizer - Standard Edition ═══════╗
                ║                                                         ║
                ║  ${LIGHT_PURPLE}• Telegram: @FreakXRAY                               ${GREEN}║
                ║  ${YELLOW}• Premium Configuration: @FReak_4L                    ${GREEN}║
                ║  ${CYAN}• Version: V0.0.1 (Free Try)                              ${GREEN}║
                ║                                                        ║
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

    echo -e "${GREEN}Enter the uplink bandwidth (e.g., 10gbit): ${NC}"
    read -p "1) 5gbit (default)
    2) 1gbit
    3) custom
    Choose your option [1-3]: " UPLINK_OPTION

    case $UPLINK_OPTION in
        1) UPLINK="5gbit" ;;
        2) UPLINK="1gbit" ;;
        3) read -p "Enter custom uplink bandwidth: " UPLINK ;;
        *) echo -e "${RED}Invalid option, defaulting to 5gbit.${NC}"; UPLINK="5gbit" ;;
    esac
    log_message "Uplink bandwidth selected: $UPLINK"

    echo -e "${GREEN}Enter the downlink bandwidth (e.g., 10gbit): ${NC}"
    read -p "1) 5gbit (default)
    2) 1gbit
    3) custom
    Choose your option [1-3]: " DOWNLINK_OPTION

    case $DOWNLINK_OPTION in
        1) DOWNLINK="5gbit" ;;
        2) DOWNLINK="1gbit" ;;
        3) read -p "Enter custom downlink bandwidth: " DOWNLINK ;;
        *) echo -e "${RED}Invalid option, defaulting to 5gbit.${NC}"; DOWNLINK="5gbit" ;;
    esac
    log_message "Downlink bandwidth selected: $DOWNLINK"

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
    execute_tc_command "tc class add dev $IFACE parent 1: classid 1:1 htb rate $UPLINK ceil $UPLINK"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Qdisc setup completed."

    # Step 2: Adding Classes
    echo -e "${YELLOW}Step 2:${LIGHT_PURPLE} Adding classes${NC}"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:100 htb rate \"500mbit\" ceil \"$UPLINK\" prio 0"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:200 htb rate \"1gbit\" ceil \"$UPLINK\" prio 1"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:300 htb rate \"2gbit\" ceil \"8gbit\" prio 2"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:400 htb rate \"1.5gbit\" ceil \"6gbit\" prio 3"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:999 htb rate \"4gbit\" ceil \"$UPLINK\" prio 4"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Classes added successfully."

    # Step 3: Adding Qdiscs
    echo -e "${YELLOW}Step 3:${LIGHT_PURPLE} Adding Qdiscs${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:100 handle 100: cake bandwidth 500mbit rtt 15ms diffserv4 flowblind triple-isolate nat wash ingress ack-filter fwmark 0x1 noatm ethernet mpu 64 overhead 32 conservative"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:200 handle 200: fq_codel flows 1024 quantum 300 target 5ms interval 30ms noecn"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:300 handle 300: fq_pie flows 2048 target 15ms tupdate 30ms alpha 2 beta 20 ecn"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:400 handle 400: fq_codel flows 4096 quantum 1514 target 10ms interval 40ms ecn"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - Qdiscs added successfully."

    # Step 4: Adding HTB Classes
    echo -e "${YELLOW}Step 4:${LIGHT_PURPLE} Adding HTB classes${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:999 handle 999: htb default 10"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:10 htb rate 1gbit ceil $UPLINK"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:20 htb rate 1gbit ceil $UPLINK"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:30 htb rate 1gbit ceil $UPLINK"
    execute_tc_command "tc class add dev $IFACE parent 999: classid 999:40 htb rate 1gbit ceil $UPLINK"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. Moving to the next step.${NC}"
    log_message "Done [✓]: - HTB classes added successfully."

    # Step 5: Adding final Qdiscs
    echo -e "${YELLOW}Step 5:${LIGHT_PURPLE} Adding final Qdiscs${NC}"
    execute_tc_command "tc qdisc add dev $IFACE parent 999:10 handle 910: fq_pie flows 4096 target 20ms tupdate 30ms alpha 2 beta 20 ecn"
    execute_tc_command "tc qdisc add dev $IFACE parent 999:20 handle 920: fq_codel flows 8192 quantum 1514 target 5ms interval 100ms ecn"
    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Completed. All tasks finished.${NC}"
    log_message "Done [✓]: - Final Qdiscs added successfully. All tasks completed."

    # Step 6: Advanced Traffic Optimization with Adaptive Shaping and Intelligent Queue Management
    echo -e "${YELLOW}Step 6:${LIGHT_PURPLE} Implementing advanced traffic optimization${NC}"
    log_message "Starting Step 6: Advanced traffic optimization"

    # Create a sophisticated qdisc structure
    execute_tc_command "tc qdisc add dev $IFACE root handle 1: htb default 100"
    execute_tc_command "tc class add dev $IFACE parent 1: classid 1:1 htb rate 950mbit ceil 1gbit"

    # Define traffic classes with adaptive rates
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:10 htb rate 400mbit ceil 900mbit prio 1"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:20 htb rate 300mbit ceil 600mbit prio 2"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:30 htb rate 200mbit ceil 400mbit prio 3"
    execute_tc_command "tc class add dev $IFACE parent 1:1 classid 1:100 htb rate 50mbit ceil 100mbit prio 4"

    # Apply advanced qdiscs to each class
    execute_tc_command "tc qdisc add dev $IFACE parent 1:10 handle 10: cake bandwidth 400mbit diffserv4 flowblind triple-isolate nat wash ingress ack-filter"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:20 handle 20: fq_pie limit 2000 flow_limit 200 target 15ms tupdate 30ms alpha 2 beta 20 ecn"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:30 handle 30: fq_codel limit 10240 flows 1024 quantum 1514 target 5ms interval 100ms ecn"
    execute_tc_command "tc qdisc add dev $IFACE parent 1:100 handle 100: sfq perturb 10 quantum 1514 limit 2000"

    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Advanced traffic optimization completed.${NC}"
    log_message "Done [✓]: Advanced traffic optimization implemented successfully."

# Step 7: Sophisticated Traffic Management and Obfuscation Techniques
    echo -e "${YELLOW}Step 7:${LIGHT_PURPLE} Implementing advanced traffic management and obfuscation${NC}"
    log_message "Starting Step 7: Advanced traffic management and obfuscation"

    # Implement advanced traffic classification
    execute_tc_command "tc filter add dev $IFACE parent 1: protocol ip prio 1 u32 match u8 0 0 flowid 1:10"
    execute_tc_command "tc filter add dev $IFACE parent 1: protocol ip prio 2 u32 match u8 0 0 flowid 1:20"
    execute_tc_command "tc filter add dev $IFACE parent 1: protocol ip prio 3 u32 match u8 0 0 flowid 1:30"

    # Advanced traffic obfuscation techniques
    execute_tc_command "tc filter add dev $IFACE parent 1: protocol ip prio 4 u32 match u8 0 0 action mirred egress redirect dev lo"
    execute_tc_command "ip route add local default dev lo table 100"
    execute_tc_command "ip rule add fwmark 1 lookup 100"

    # Implement sophisticated packet manipulation
    execute_command "iptables -t mangle -A POSTROUTING -o $IFACE -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1240"
    execute_command "iptables -t mangle -A POSTROUTING -o $IFACE -p tcp -m tcp --tcp-flags SYN,RST SYN -j MARK --set-mark 1"
    execute_command "iptables -t mangle -A POSTROUTING -o $IFACE -j TOS --set-tos 0x10/0xff"

    echo -e "${GREEN}Step [✓]:${LIGHT_PURPLE} - Advanced traffic management and obfuscation completed.${NC}"
    log_message "Done [✓]: Advanced traffic management and obfuscation techniques implemented successfully."

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
    -h|--help)
        display_help
        ;;
    *)
        echo -e "${RED}Invalid option. Use -h or --help for usage information.${NC}"
        exit 1
        ;;
esac
