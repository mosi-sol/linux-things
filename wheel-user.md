> security concerns

**Steps to Build and Use the "wheel" Group in Debian:**

1.  **Create the "wheel" group:**
    ```bash
    sudo groupadd wheel
    ```

2.  **Add users to the "wheel" group:**
    ```bash
    sudo usermod -aG wheel <username>
    ```
    *(Repeat for each user)*

3.  **Configure PAM to restrict `su` access:**
    ```bash
    sudo nano /etc/pam.d/su
    ```
    Uncomment this line:
    ```
    auth required pam_wheel.so
    ```
    Save and close the file.

**How to Use:**

* Log in as a user who is a member of the "wheel" group.
* Execute the `su` command:
    ```bash
    su
    ```
* Enter the root password when prompted. You will then become the root user.
