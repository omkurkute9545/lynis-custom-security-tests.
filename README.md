# Lynis Custom Security Auditing Tests

Automated system hardening and compliance audit modules developed for the **Lynis Security Framework**.  
Developed for the **Cyber Security** course, School of Computer Science and Engineering (SCOPE), **Vellore Institute of Technology (VIT), Chennai**.

---

## Overview

This repository contains custom test scripts designed to extend the audit capabilities of **Lynis**, the open-source host auditing tool for Linux and UNIX systems. These modules enforce host-level defense-in-depth policies covering:
1. **Host Firewall Hardening:** Granular inspection of Uncomplicated Firewall (UFW) operational status, default ingress policy, and kernel event logging.
2. **User Authentication & Password Hygiene:** Verification of password rotation cycles (`PASS_MAX_DAYS`), prevention of immediate password recycling (`PASS_MIN_DAYS`), advance warning windows (`PASS_WARN_AGE`), and inspection of `/etc/shadow` for blank password accounts.

---

## Custom Test Specifications

### Test 1: Enhanced UFW Firewall Policy Audit (`CUST-1010`)
Standard baseline checks verify only if the firewall daemon is running. This enhanced test evaluates whether the firewall is properly configured:
- **Service Verification:** Verifies the UFW binary is installed and running (`Status: active`).
- **Default Ingress Drop:** Verifies that default incoming traffic is configured to `deny` or `reject`. If configured to `allow`, a high-priority warning is raised.
- **Security Event Logging:** Verifies that packet logging is enabled (`on`, `low`, `medium`, or `full`). If disabled, a recommendation is logged to enable logging for SIEM and forensic monitoring.

### Test 2: Multi-Parameter Password Aging & Shadow Audit (`CUST-1011`)
Standard baseline checks only verify maximum password age. This enhanced test validates authentication parameters:
- **Maximum Password Age (`PASS_MAX_DAYS`):** Ensures credentials are rotated within 90 days.
- **Minimum Password Age (`PASS_MIN_DAYS`):** Enforces a minimum interval (at least 1 day) before a password can be changed again, preventing users from immediately reverting to previous passwords.
- **Password Expiry Warning (`PASS_WARN_AGE`):** Ensures users receive at least 7 days advance notice before credential expiration.
- **Empty Password Audit:** Inspects `/etc/shadow` fields to ensure no active system user accounts possess empty password hashes.

---

## Repository Structure

```text
lynis-custom-security-tests/
├── README.md            # Comprehensive project documentation and usage guide
└── tests_custom.sh      # Production-ready custom tests for Lynis include directory
```

---

## Installation & Deployment

### 1. Prerequisites
Ensure Lynis is installed on your Linux system:
```bash
sudo apt update && sudo apt install -y lynis ufw
```

### 2. Deploying Custom Tests
Copy the custom tests script into the Lynis include directory:
```bash
# Clone the repository
git clone https://github.com/omkurkute9545/lynis-custom-security-tests..git
cd lynis-custom-security-tests.

# Copy into Lynis custom tests location
sudo cp tests_custom.sh /usr/share/lynis/include/tests_custom
sudo chmod 640 /usr/share/lynis/include/tests_custom
```

### 3. Executing the Audit
Run Lynis targeting the custom test identifiers:
```bash
sudo lynis audit system --tests CUST-1010,CUST-1011
```

---

## Expected Audit Output

```text
[+] Enhanced Custom Hardening Checks
--------------------------------------------------------------------------------
  - Checking UFW Firewall Configuration...
    UFW Service Status: Active                              [ OK ]
    Default Incoming Policy: deny                           [ OK ]
    Firewall Event Logging: on                              [ OK ]

  - Checking Password Expiry and Authentication Policies...
    Password Max Age (90 days)                              [ OK ]
    Password Min Age (7 days)                               [ OK ]
    Password Expiry Warning (7 days)                        [ OK ]
    Empty Password Check                                    [ OK ]

================================================================================
  Scan Results Summary:
  - Warnings    : 0
  - Suggestions : 0
================================================================================
```

---

## Academic Information

- **Course:** Cyber Security (Fall Semester 2026-2027)
- **School:** School of Computer Science and Engineering (SCOPE)
- **Institution:** Vellore Institute of Technology (VIT), Chennai
- **Course Faculty:** Dr. T. Subbulakshmi, Professor, SCOPE, VIT Chennai
- **Auditing Tool Reference:** Michael Boelen (Creator of Lynis - [CISOfy](https://cisofy.com/lynis/))