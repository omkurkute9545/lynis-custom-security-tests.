#!/bin/sh
# ==============================================================================
# Lynis Custom Test: Enhanced Password Expiry & Account Hardening (CUST-1011)
# Course: Cyber Security | VIT Chennai (SCOPE)
# Faculty: Dr. T. Subbulakshmi
# ==============================================================================
# Enhancement Option 2: Multi-Parameter Password Aging & Shadow Account Audit
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

        # 1. Maximum Password Age Check (<= 90 days)
        if [ -n "${MAX_DAYS}" ] && [ "${MAX_DAYS}" -le 90 ]; then
            Display --indent 4 --text "Password Max Age (${MAX_DAYS} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Max Age (${MAX_DAYS:-unset} days)" --result "${STATUS_WARNING}" --color RED
            ReportWarning "CUST-1011" "PASS_MAX_DAYS is either unset or exceeds 90 days in /etc/login.defs"
        fi

        # 2. Minimum Password Age Check (>= 1 day)
        if [ -n "${MIN_DAYS}" ] && [ "${MIN_DAYS}" -ge 1 ]; then
            Display --indent 4 --text "Password Min Age (${MIN_DAYS} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Min Age (${MIN_DAYS:-unset} days)" --result "${STATUS_WARNING}" --color RED
            ReportWarning "CUST-1011" "PASS_MIN_DAYS is not enforced (should be at least 1 day)"
        fi

        # 3. Password Expiration Warning Period (>= 7 days)
        if [ -n "${WARN_AGE}" ] && [ "${WARN_AGE}" -ge 7 ]; then
            Display --indent 4 --text "Password Expiry Warning (${WARN_AGE} days)" --result "${STATUS_OK}" --color GREEN
        else
            Display --indent 4 --text "Password Expiry Warning (${WARN_AGE:-unset} days)" --result "${STATUS_SUGGESTION}" --color YELLOW
            ReportSuggestion "CUST-1011" "Configure PASS_WARN_AGE to at least 7 days in /etc/login.defs"
        fi

        # 4. Empty Password Hash Audit in /etc/shadow
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
