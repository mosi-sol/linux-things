## **Introduction to `ms`**
**`ms`** is a modern, Python-based replacement for the classic Unix `ls` command, designed to enhance your file listing experience. It provides **colorized output**, **human-readable file sizes**, **long format listing**, and a **tree view** for directories—all in a single, lightweight tool.
- Tested on: debian 12,13 & ubuntu 22,24

#### **Why Use `ms`?**
- **Colorized Output**: Directories, executables, and symlinks are highlighted for easy identification.
- **Tree View**: Visualize directory structures recursively with `-t`.
- **Human-Readable Sizes**: Use `-H` to display file sizes in KB, MB, or GB.
- **Hidden Files**: Show hidden files with `-a`.
- **Long Format**: Get detailed file information (permissions, size, modification time) with `-l`.

#### **Basic Usage**
```bash
ms              # List files in the current directory
ms -l           # Long format listing
ms -a           # Show hidden files
ms -t           # Tree view
ms -H           # Human-readable sizes
ms /path/to/dir # List files in a specific directory
```

#### **Example Outputs**
- **Tree View (`-t`)**:
  ```
  .
  ├── dir1
  │   ├── file1.txt
  │   └── file2.txt
  └── dir2
      └── file3.txt
  ```
- **Long Format (`-l`)**:
  ```
  755 dir1   4.0 KB  Dec 15 10:00
  644 file1  1.0 KB  Dec 14 09:30
  ```

#### **Installation**
1. Save the `ms` script to `/usr/local/bin/ms`.
2. Make it executable:
   ```bash
   sudo chmod +x /usr/local/bin/ms
   ```
3. Install the man page (optional):
   ```bash
   sudo cp ms.1 /usr/local/man/man1/
   sudo mandb
   ```

#### **Get Help**
- Run `man ms` for the full manual.
- Use `ms --help` for a quick reference.

---

### **Key Features at a Glance**
| Feature          | Flag  | Example               |
|------------------|-------|-----------------------|
| Colorized Output | N/A   | `ms`                  |
| Long Format      | `-l`  | `ms -l`               |
| Tree View        | `-t`  | `ms -t`               |
| Human-Readable   | `-H`  | `ms -H`               |
| Show Hidden      | `-a`  | `ms -a`               |

---

## newbie!
- copy/extract: `/usr/local/bin`
- then: `chmod +x man_ms_install.sh`
- then: `./man_ms_install.sh`

note:
- if **/usr/local/bin** not exist, `mkdir -p /usr/local/bin`
- some times need *sudo* for *chmod*
