# **`ms` Command: Modern File Listing Tool**
**User Manual & Reference Guide**
- Version/Edition: Second

---

## **1. Introduction**
`ms` is a **modern, Python-based replacement** for the classic Unix `ls` command. It provides **colorized output**, **tree views**, **human-readable file sizes**, **zebra-styled long listings**, and **sorting options** for better file management.

---

## **2. Features**
| Feature                     | Flag          | Description                                                                 |
|-----------------------------|---------------|-----------------------------------------------------------------------------|
| **Colorized Output**        | N/A           | Directories (blue), executables (green), symlinks (cyan), and files (default). |
| **Long Format**             | `-l`          | Shows permissions, size, and modification time.                           |
| **Zebra-Styled Long Format**| `-L`          | Long format with alternating row colors for readability.                   |
| **Human-Readable Sizes**    | `-H`          | Displays file sizes in KB, MB, or GB (two rows, colorized by type).         |
| **Tree View (Full)**        | `-t`          | Recursively lists all files and directories in a tree structure.            |
| **Tree View (Folders Only)**| `-T`          | Recursively lists only directories in a tree structure.                    |
| **Tree View (Metadata)**     | `-M`          | Recursively lists files and directories with metadata (size, date).          |
| **Show Hidden Files**       | `-a`          | Includes hidden files (starting with `.`).                                 |
| **Sorting**                 | `--sort`      | Sorts by `name` (default), `type`, or `date`.                               |

---

## **3. Installation**

### **Prerequisites**
- Python 3.x (pre-installed on most Linux systems).
- Root/sudo access for installation.

### **Steps**
1. **Download the Scripts**
   Save the following files in the same directory:
   - [`ms`](https://example.com/ms) (main script)
   - [`ms.1`](https://example.com/ms.1) (man page)
   - [`install_ms.sh`](https://example.com/install_ms.sh) (installation script)

2. **Make the Installer Executable**
   ```bash
   chmod +x install_ms.sh
   ```

3. **Run the Installer**
   ```bash
   ./install_ms.sh
   ```

4. **Verify Installation**
   ```bash
   ms --help
   man ms
   ```

---

## **4. Usage Examples**

### **Basic Listing**
```bash
ms
```
Lists files in the current directory with colorized output.

---

### **Long Format**
```bash
ms -l
```
Displays files with permissions, size, and modification time.

**Example Output:**
```
755 dir1          4.0 KB  Dec 15 10:00
644 file1.txt     1.0 KB  Dec 14 09:30
```

---

### **Zebra-Styled Long Format**
```bash
ms -L
```
Displays files in long format with alternating row colors.

**Example Output:**
```
755 dir1          4.0 KB  Dec 15 10:00
644 file1.txt     1.0 KB  Dec 14 09:30
```

---

### **Human-Readable Sizes**
```bash
ms -H
```
Displays file sizes in KB, MB, or GB, with types colorized.

**Example Output:**
```
dir1             4.0 KB
file1.txt        1.0 KB
```

---

### **Tree View (Full)**
```bash
ms -t
```
Recursively lists all files and directories in a tree structure.

**Example Output:**
```
.
├── dir1
│   ├── file1.txt
│   └── file2.txt
└── dir2
    └── file3.txt
```

---

### **Tree View (Folders Only)**
```bash
ms -T
```
Recursively lists only directories in a tree structure.

**Example Output:**
```
.
└── dir1
```

---

### **Tree View (With Metadata)**
```bash
ms -M
```
Recursively lists files and directories with metadata (size, modification time).

**Example Output:**
```
.
├── dir1 (4.0 KB, Dec 15 10:00)
│   ├── file1.txt (1.0 KB, Dec 14 09:30)
│   └── file2.txt (2.0 KB, Dec 13 08:00)
└── dir2 (0.5 KB, Dec 12 11:45)
    └── file3.txt (0.5 KB, Dec 12 11:45)
```

---

### **Show Hidden Files**
```bash
ms -a
```
Lists all files, including hidden ones.

---

### **Sorting**
```bash
ms --sort type
```
Sorts files by type (directories first, then executables, symlinks, and files).

**Other Sorting Options:**
- `ms --sort name` (default)
- `ms --sort date` (by modification time)

---

## **5. Advanced Usage**

### **Combine Flags**
```bash
ms -a -L --sort date
```
Lists all files (including hidden) in zebra-styled long format, sorted by date.

---

### **Specify a Directory**
```bash
ms -t /path/to/dir
```
Displays a tree view of the specified directory.

---

## **6. Troubleshooting**

### **Permission Denied**
If you encounter `Permission denied`:
```bash
sudo chmod +x /usr/local/bin/ms
```

---

### **Man Page Not Found**
Update the man page database:
```bash
sudo mandb
```

---

## **7. Uninstallation**
To remove `ms`:
```bash
sudo rm /usr/local/bin/ms
sudo rm /usr/local/man/man1/ms.1
sudo mandb
```

---

## **8. License**
`ms` is **free software** under the MIT License. Modify and redistribute as needed.

---

## **9. Contact**
For bugs or suggestions, contact:
**mosi-sol**  :)


