#!/bin/sh
# ==============================================================================
# Lynis Custom Security Tests: /usr/share/lynis/include/tests_custom
# Course: Cyber Security | VIT Chennai (SCOPE)
# Faculty: Dr. T. Subbulakshmi
# ==============================================================================

#################################################################################
# SCRIPT 1: Enhanced UFW Firewall Audit (CUST-1010)
# Checks:
#  1. UFW installation & active service state
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


#################################################################################
# SCRIPT 2: Enhanced Password Expiry & Account Hardening Audit (CUST-1011)
# Checks:
#  1. Maximum password age (PASS_MAX_DAYS <= 90)
#  2. Minimum password age (PASS_MIN_DAYS >= 1)
#  3. Password warning window (PASS_WARN_AGE >= 7)
#  4. Shadow file audit for blank/empty password accounts
#################################################################################

Register --test-no CUST-1011 --weight M --network NO --category security --description "Comprehensive password aging policies and empty shadow password audit"

if [ ${SKIPTEST} -eq 0 ]; then

    Display --indent 2 --text "- Checking Password Expiry and Authentication Policies..."
    LOGIN_DEFS="/etc/login.defs"

    if [ -f "${LOGIN_DEFS}" ]; then

        MAX_DAYS=$(grep "^PASS_MAX_DAYS" "${LOGIN_DEFS}" 2>/dev/null | awk '{print $2}')
        MIN_DAYS=$(grep "^PASS_MIN_DAYS" "${LOGIN_DEFS}" 2>/dev/null | awk '{print $2}')
        WARN_AGE=$(grep "^PASS_WARN_AGE" "${LOGIN_DEFS}" 2>/dev/null | awk '{print $2}')

        # 1. Check PASS_MAX_DAYS (<= 90 days)
        if [ -n "${MAX_DAYS}" ] && [ "${MAX_DAYS}" -le 90 ]; then
            Display --indent 4 --text "Password Max Age (${MAX_DAYS} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Max Age (${MAX_DAYS:-unset} days)" --result "${STATUS_WARNING}" --color RED
            ReportWarning "CUST-1011" "PASS_MAX_DAYS is either unset or exceeds 90 days in /etc/login.defs"
        fi

        # 2. Check PASS_MIN_DAYS (>= 1 day, prevents immediate cycling back)
        if [ -n "${MIN_DAYS}" ] && [ "${MIN_DAYS}" -ge 1 ]; then
            Display --indent 4 --text "Password Min Age (${MIN_DAYS} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Min Age (${MIN_DAYS:-unset} days)" --result "${STATUS_WARNING}" --color RED
            ReportWarning "CUST-1011" "PASS_MIN_DAYS is not enforced (should be at least 1 day)"
        fi

        # 3. Check PASS_WARN_AGE (>= 7 days advance notice)
        if [ -n "${WARN_AGE}" ] && [ "${WARN_AGE}" -ge 7 ]; then
            Display --indent 4 --text "Password Expiry Warning (${WARN_AGE} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Expiry Warning (${WARN_AGE:-unset} days)" --result "${STATUS_SUGGESTION}" --color YELLOW
            ReportSuggestion "CUST-1011" "Configure PASS_WARN_AGE to at least 7 days in /etc/login.defs"
        fi

        # 4. Check /etc/shadow for any accounts with blank passwords
        if [ -r /etc/shadow ]; then
            BLANK_ACCOUNTS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
            if [ -z "${BLANK_ACCOUNTS}" ]; then
                Display --indent 4 --text "Empty Password Check" --result "${STATUS_OK}" --color GREEN
            else
                Display --indent 4 --text "Empty Password Check" --result "${STATUS_WARNING}" --color RED
                ReportWarning "CUST-1011" "Account(s) with blank passwords detected in /etc/shadow: ${BLANK_ACCOUNTS}"
            fi
        fi

    else
        Display --indent 4 --text "Configuration file ${LOGIN_DEFS}" --result "${STATUS_NOTFOUND}" --color RED
        ReportWarning "CUST-1011" "File /etc/login.defs was not found on this system"
    fi

fi
