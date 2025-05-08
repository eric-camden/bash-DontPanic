# dontpanic.sh

`dontpanic.sh` is a lightweight Linux system diagnostics script designed to gather key health and performance information, output it to the terminal, and log everything to a file. It helps sysadmins quickly review system health without needing to remember a series of commands.

---

## Features

* ✅ ASCII art banner for a touch of whimsy
* 🖥  Basic system info: date, hostname, OS release
* 👥  Uptime, logged-in users, boot & login history
* 💾 Disk, memory, and CPU usage summaries
* 📈 Top processes by memory and CPU
* 📤 I/O stats via `iostat`
* 📄 Last hour of `/var/log/messages` and other logs
* 🔍 Recursive scan of all `.log` files for `warning` and `error` lines
* 🌐 Open ports and recent kernel messages (`dmesg`)
* 💡 Output is shown on screen **and** saved to `output.txt`

---

## Requirements

Ensure the following tools are available (most are pre-installed):

```
bash date hostname cat w last sar ps free vmstat iostat df netstat dmesg awk tail grep tee head find
```

To enable full functionality (especially `sar`):

* **RHEL/CentOS**:

  ```bash
  sudo yum install -y sysstat
  sudo systemctl enable --now sysstat
  ```
* **Debian/Ubuntu**:

  ```bash
  sudo apt install -y sysstat
  sudo systemctl enable --now sysstat
  ```

---

## Usage

Make the script executable:

```bash
chmod +x dontpanic.sh
```

Then run it:

```bash
./dontpanic.sh
```

A file named `output.txt` will be created in the same directory, containing all the output.

---

## Example Output Snippet

```text
######## Uptime & Current Users ########
 15:02:34 up 1 day,  4:22,  2 users,  load average: 0.18, 0.21, 0.24
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
alice    pts/0    192.168.1.22     13:45    0.00s  0.03s  0.00s bash
```

---

## Customization

You can comment out any section from the `main()` function to reduce output, or change the log scan patterns in `scan_logs_for_issues()` to look for different keywords.

---

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---

Enjoy your diagnostics. And remember: **Don't Panic.** 🌌
