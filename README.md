# Lynis Custom Security Auditing Tests

Automated system hardening and compliance audit modules developed for the **Lynis Security Framework**.  
Course: **Cyber Security (Fall Semester 2026-2027)**  
School of Computer Science and Engineering (SCOPE), **Vellore Institute of Technology (VIT), Chennai**.  
Course Faculty: **Dr. T. Subbulakshmi**, Professor, SCOPE, VIT Chennai.

---

## Repository Files & Direct Links

| Script File | Purpose | Description |
| :--- | :--- | :--- |
| **[`reference_script.sh`](reference_script.sh)** | Base Reference Script | Baseline checks for UFW active status and maximum password expiry (`PASS_MAX_DAYS`). |
| **[`enhanced_ufw_firewall.sh`](enhanced_ufw_firewall.sh)** | Enhancement Option 1 | In-depth audit of UFW daemon state, default incoming drop posture, and kernel logging. |
| **[`enhanced_password_policy.sh`](enhanced_password_policy.sh)** | Enhancement Option 2 | Multi-parameter password aging (`MAX_DAYS`, `MIN_DAYS`, `WARN_AGE`) and `/etc/shadow` blank password audit. |

---

## Custom Test Specifications

### 1. Base Reference Script (`reference_script.sh`)
- **CUST-1010 (Base):** Checks if the `ufw` binary exists and runs `ufw status` to verify if the first line reports "active".
- **CUST-1011 (Base):** Parses `/etc/login.defs` for `PASS_MAX_DAYS` to check if password expiration is 90 days or less.

### 2. Enhancement Option 1: Deep Firewall & Logging Audit (`enhanced_ufw_firewall.sh`)
- **CUST-1010 (Enhanced):** 
  - Verifies UFW operational state (`Status: active`).
  - Audits default ingress posture from `ufw status verbose` to ensure default incoming traffic is strictly set to `deny` or `reject` (warns if default is `allow`).
  - Audits kernel event logging to verify packet logging is active (`on`, `low`, `medium`, or `full`). Suggests `sudo ufw logging on` if disabled.

### 3. Enhancement Option 2: Multi-Parameter Password Aging & Shadow Audit (`enhanced_password_policy.sh`)
- **CUST-1011 (Enhanced):**
  - **`PASS_MAX_DAYS`:** Ensures regular rotation of credentials within 90 days.
  - **`PASS_MIN_DAYS`:** Enforces a mandatory minimum interval (at least 1 day) before password change, preventing immediate recycling back to old passwords.
  - **`PASS_WARN_AGE`:** Ensures at least 7 days advance notice before credential expiration.
  - **Empty Password Audit:** Inspects `/etc/shadow` fields to ensure no active system user accounts have an empty password hash.

---

## Installation & Deployment

### 1. Prerequisites
Ensure Lynis is installed on your Linux / Ubuntu system:
```bash
sudo apt update && sudo apt install -y lynis ufw
```

### 2. Deploying Custom Tests
Clone the repository and copy the enhanced scripts into the Lynis include directory:
```bash
git clone https://github.com/omkurkute9545/lynis-custom-security-tests..git
cd lynis-custom-security-tests.

# Deploy Enhanced Tests
sudo cp enhanced_ufw_firewall.sh /usr/share/lynis/include/tests_custom_ufw
sudo cp enhanced_password_policy.sh /usr/share/lynis/include/tests_custom_password
sudo chmod 640 /usr/share/lynis/include/tests_custom_*
```

### 3. Running Custom Audits
Execute Lynis targeting the custom test identifiers:
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

- **Student Name:** Om Kurkute
- **Course:** Cyber Security (Fall Semester 2026-2027)
- **School:** School of Computer Science and Engineering (SCOPE)
- **Institution:** Vellore Institute of Technology (VIT), Chennai
- **Course Faculty:** Dr. T. Subbulakshmi, Professor, SCOPE, VIT Chennai
- **Reference Framework:** Lynis by Michael Boelen ([CISOfy](https://cisofy.com/lynis/))