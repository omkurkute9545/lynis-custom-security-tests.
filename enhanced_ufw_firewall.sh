#!/bin/sh
# ==============================================================================
# Lynis Custom Test: Enhanced UFW Firewall Audit (CUST-1010)
# Course: Cyber Security | VIT Chennai (SCOPE)
# Faculty: Dr. T. Subbulakshmi
# ==============================================================================
# Enhancement Option 1: Comprehensive UFW Policy & Logging Audit
# Checks:
#  1. UFW service active state
#  2. Default incoming policy (must be deny or reject)
#  3. Event logging configuration (must be enabled)
#################################################################################

Register --test-no CUST-1010 --weight M --network NO --category security --description "Comprehensive audit of UFW firewall status, default incoming policy, and logging"

if [ ${SKIPTEST} -eq 0 ]; then

    Display --indent 2 --text "- Checking UFW Firewall Configuration..."

    # Check if UFW binary is installed
    if [ -x /usr/sbin/ufw ] || [ -x /usr/bin/ufw ]; then

        UFW_RAW=$(ufw status verbose 2>/dev/null)
        UFW_STATUS=$(echo "${UFW_RAW}" | grep -i "^Status:" | awk '{print $2}')

        # 1. Check if UFW is active
        if [ "${UFW_STATUS}" = "active" ]; then
            Display --indent 4 --text "UFW Service Status: Active" --result "${STATUS_OK}" --color GREEN

            # 2. Check Default Incoming Policy
            DEFAULT_INCOMING=$(echo "${UFW_RAW}" | grep -i "^Default:" | grep -io "incoming ([a-z]*)" | awk '{print $2}' | tr -d '()')
            if [ "${DEFAULT_INCOMING}" = "deny" ] || [ "${DEFAULT_INCOMING}" = "reject" ]; then
                Display --indent 4 --text "Default Incoming Policy: ${DEFAULT_INCOMING}" --result "${STATUS_OK}" --color GREEN
            else
                Display --indent 4 --text "Default Incoming Policy: ${DEFAULT_INCOMING:-allow}" --result "${STATUS_WARNING}" --color RED
                ReportWarning "CUST-1010" "Default incoming firewall traffic policy is not set to deny or reject"
            fi

            # 3. Check Firewall Event Logging
            LOG_STATUS=$(echo "${UFW_RAW}" | grep -i "^Logging:" | awk '{print $2}')
            if [ "${LOG_STATUS}" = "on" ] || [ "${LOG_STATUS}" = "low" ] || [ "${LOG_STATUS}" = "medium" ] || [ "${LOG_STATUS}" = "full" ]; then
                Display --indent 4 --text "Firewall Event Logging: ${LOG_STATUS}" --result "${STATUS_OK}" --color GREEN
            else
                Display --indent 4 --text "Firewall Event Logging: disabled" --result "${STATUS_SUGGESTION}" --color YELLOW
                ReportSuggestion "CUST-1010" "Enable UFW security logging using: sudo ufw logging on"
            fi

        else
            Display --indent 4 --text "UFW Service Status: Inactive" --result "${STATUS_WARNING}" --color RED
            ReportWarning "CUST-1010" "UFW firewall is installed but currently disabled/inactive"
        fi

    else
        Display --indent 4 --text "UFW Binary" --result "${STATUS_NOTFOUND}" --color YELLOW
        ReportSuggestion "CUST-1010" "Install UFW firewall package using: sudo apt install ufw"
    fi

fi
