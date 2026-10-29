#!/bin/sh
# ==============================================================================
# Lynis Base Reference Custom Tests
# Course: Cyber Security | VIT Chennai (SCOPE)
# Faculty: Dr. T. Subbulakshmi
# ==============================================================================

#################################################################################
# Base Custom Test 1: Check UFW Firewall Status
#################################################################################

Register --test-no CUST-1010 --weight L --network NO --category security --description "Check if UFW firewall is enabled"

if [ ${SKIPTEST} -eq 0 ]; then
    if [ -x /usr/sbin/ufw ] || [ -x /usr/bin/ufw ]; then
        FIREWALL_STATUS=$(ufw status 2>/dev/null | head -1)
        case "${FIREWALL_STATUS}" in
            *active*)
                Display --indent 2 --text "- UFW Firewall" --result "${STATUS_OK}" --color GREEN
                ;;
            *)
                Display --indent 2 --text "- UFW Firewall" --result "${STATUS_WARNING}" --color RED
                ReportWarning "${TEST_NO}" "UFW firewall is disabled"
                ;;
        esac
    else
        Display --indent 2 --text "- UFW Firewall" --result "${STATUS_NOTFOUND}" --color YELLOW
    fi
fi

#################################################################################
# Base Custom Test 2: Check Password Expiry Policy
#################################################################################

Display --text ""
Display --text "Checking Password Expiry Policy..."

MAX_DAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs 2>/dev/null | awk '{print $2}')
if [ -z "$MAX_DAYS" ]; then
    Display --indent 2 --text "Password Expiry" --result "${STATUS_WARNING}"
    ReportWarning "CUST-1011" "Password expiry policy not configured"
elif [ "$MAX_DAYS" -le 90 ]; then
    Display --indent 2 --text "Password Expiry" --result "${STATUS_OK}"
else
    Display --indent 2 --text "Password Expiry" --result "${STATUS_WARNING}"
    ReportWarning "CUST-1011" "Password expiry is greater than 90 days"
fi
