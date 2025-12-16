# **LSH (Linux Simple Shell) – Documentation**
**Version 1.0**
*A Custom Bash-Based Shell for Linux*

---

## **1. Introduction**
**LSH (Linux Simple Shell)** is a lightweight, customizable shell built on top of Bash. It provides a simple yet powerful command-line interface with built-in commands, job control, environment variable support, and shell scripting capabilities. Nice for educational purposes.

This document explains how to **install**, **use**, and **extend** LSH.

---

## **2. Features**
LSH includes the following features:

### **Built-in Commands**
| Command  | Description |
|----------|-------------|
| `help`   | Display help message. |
| `echo`   | Print arguments. |
| `type`   | Check if a command is built-in or external. |
| `alias`  | Create or list command aliases. |
| `set`    | Set or display environment variables. |
| `export` | Export environment variables. |
| `source` | Execute a script in the current shell. |
| `history`| Display command history. |
| `jobs`   | List background jobs. |
| `fg`     | Bring a job to the foreground. |
| `bg`     | Send a job to the background. |
| `cd`     | Change directory. |
| `exit`   | Exit the shell. |

### **External Command Support**
- Runs any Linux command (`ls`, `grep`, `cat`, etc.).
- Supports **pipes (`|`)** and **redirection (`>`, `>>`, `<`)**.

### **Job Control**
- Supports background jobs (`&`), `jobs`, `fg`, and `bg`.

### **Shell Scripting**
- Supports `if`, `for`, `while`, and other Bash scripting features.

### **Tab Completion**
- Auto-completes built-in commands.

---

## **3. Installation**

### **Prerequisites**
- Linux (or macOS with Bash).
- Bash (usually pre-installed).

### **Steps**
1. **Download the `lsh` script** and save it as `lsh`.
2. **Make it executable**:
   ```bash
   chmod +x lsh
   ```
3. **Run the installer**:
   ```bash
   ./install_lsh.sh
   ```
   This will:
   - Copy `lsh` to `/usr/local/bin/`.
   - Set up tab completion in `~/.bashrc`.
   - Make `lsh` available globally.

4. **Verify installation**:
   ```bash
   which lsh
   ```
   Should output:
   ```
   /usr/local/bin/lsh
   ```

---

## **4. Usage**

### **Starting LSH**
Run:
```bash
lsh
```
You’ll see the `lsh>` prompt.

### **Running Commands**
- **Built-in commands**:
  ```bash
  lsh> help
  lsh> echo Hello, LSH!
  lsh> alias ll="ls -l"
  lsh> export MY_VAR=123
  ```
- **External commands**:
  ```bash
  lsh> ls -l
  lsh> grep "pattern" file.txt
  ```
- **Job control**:
  ```bash
  lsh> sleep 10 &
  lsh> jobs
  lsh> fg %1
  ```

### **Shell Scripting**
LSH supports Bash scripting:
```bash
lsh> if [ -f file.txt ]; then echo "File exists"; fi
lsh> for i in {1..5}; do echo $i; done
```

### **Exiting LSH**
```bash
lsh> exit
```

---

## **5. Customization**

### **Adding New Built-in Commands**
Edit the `lsh` script and add new functions under the **Built-in Commands** section. For example:
```bash
mycommand() {
    echo "This is my custom command!"
}
```
Then add it to the `case` statement in the main loop.

### **Modifying the Prompt**
Change the `read -e -p "lsh> "` line to customize the prompt:
```bash
read -e -p "my_shell> " cmd
```

---

## **6. Uninstallation**
To remove LSH:
```bash
sudo rm /usr/local/bin/lsh
sed -i '/_lsh_completion/d' ~/.bashrc
source ~/.bashrc
```

---

## **7. Limitations**
- **No advanced scripting** (e.g., functions, arrays).
- **Tab completion** only works for built-in commands.
- **Security**: Avoid running untrusted scripts with `eval`.

---

## **8. Future Improvements**
- Add support for **functions** and **arrays**.
- Improve **tab completion** for external commands.
- Add **command-line arguments** for scripting.
- Add **man** documentation.

---

## **9. License**
LSH is released under the **MIT License**. Feel free to modify and distribute it.

---

## **10. Support**
For issues or suggestions, open an issue on the this *GitHub repository* or contact the maintainer.

---

**Enjoy using LSH!** 🚀
*Happy shell scripting!*
