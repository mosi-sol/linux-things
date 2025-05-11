> security concerns

**Steps to Build and Use `doas` on Debian:**

1.  **Install `doas`:**
    ```bash
    sudo apt update
    sudo apt install doas # or "opendoas"
    ```

2.  **Edit `doas.conf`:**
    ```bash
    sudo nano /etc/doas.conf
    ```

3.  **Grant a user (`your_user`) root privileges without a password:**
    Add this line:
    ```
    permit your_user
    ```

4.  **Grant members of the `wheel` group root privileges without a password:**
    Add this line (if you've created the `wheel` group):
    ```
    permit :wheel
    ```

5.  **Grant a user (`your_user`) specific command privileges as root:**
    Add lines like this:
    ```
    permit your_user cmd apt update
    permit your_user cmd apt upgrade
    ```

6.  **Save and close `/etc/doas.conf`.**

**How to Use:**

* **As a permitted user:**
    ```bash
    doas <command>
    ```
    *(May or may not prompt for a password based on `doas.conf`)*
