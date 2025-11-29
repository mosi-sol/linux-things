### 🛡️ Security Tools Sorted by Matter

| Matter | Tool & Purpose | Debian Installation & Key Usage |
| :--- | :--- | :--- |
| **Audit** | **Lynis**: A system auditor that checks for hundreds of security warnings, misconfigurations, and vulnerabilities. | **Install:** `sudo apt install lynis` <br> **Audit:** `sudo lynis audit system` |
| **Hardening** | **Fail2Ban**: Automatically scans log files for malicious patterns (e.g., repeated failed login attempts) and permanently or temporarily bans the offending IP addresses using firewall rules. | **Install:** `sudo apt install fail2ban` <br> **Check SSH Status:** `sudo fail2ban-client status sshd` |
| **Hardening** | **AppArmor**: A Linux Security Module (LSM) that enforces Mandatory Access Control (MAC). It limits what applications can do by confining them to a set of resources (files, network) defined by their profile. | **Install:** `sudo apt install apparmor apparmor-profiles` <br> **Enforce Profile:** `sudo aa-enforce /path/to/binary` |
| **Detection** | **RKHunter (Rootkit Hunter)**: Scans for rootkits, backdoors, hidden files, and local exploits by comparing system files against known good values and scanning for suspicious strings. | **Install:** `sudo apt install rkhunter` <br> **Check System:** `sudo rkhunter --check` |
| **Detection** | **ClamAV (Clam AntiVirus)**: An open-source antivirus engine used for detecting malware, viruses, and trojans, often used on mail gateways or file servers. | **Install:** `sudo apt install clamav` <br> **Scan Home Directory:** `clamscan -r /home/user` |
| **Debugging** | **strace**: A diagnostic tool that monitors the system calls and signals used by a process. It is vital for seeing what a program is doing behind the scenes, such as file access or network activity. | **Install:** `sudo apt install strace` <br> **Trace a Process (by PID):** `sudo strace -p <PID>` |
| **Encryption** | **eCryptfs**: A built-in Linux tool that allows you to create an encrypted folder (a private mount point). Files are encrypted on disk but appear normal when the folder is mounted. | **Install:** `sudo apt install ecryptfs-utils` <br> **Mount/Encrypt (e.g., Vault):** `sudo mount -t ecryptfs <source_dir> <mount_point>` |
| **Cleanup** | **shred** (Secure Deletion): A utility that securely deletes files by overwriting their contents multiple times with random data, making forensic recovery impossible. | **Install:** (Usually included in `coreutils`) <br> **Securely Delete:** `shred -u <file_name>` |
| **Network Visibility** | **ss (Socket Statistics)**: A modern, faster tool to display network sockets, showing active connections, listening ports, and the associated processes. | **Install:** (Built-in, part of `iproute2`) <br> **Show Listening Ports (TCP, UDP, Process ID):** `ss -tulpn` |
| **Network Visibility** | **lsof (List Open Files)**: Shows which processes have specific files (including network sockets) open. It is useful for quickly identifying which process is using a certain port. | **Install:** `sudo apt install lsof` <br> **Find Process Using Port 22:** `sudo lsof -i :22` |

> debian base commands
