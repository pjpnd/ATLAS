Overview
========
ATLAS, short for Automated Telemetry and Log Acquisition System, is a deployable, lightweight shell script designed to collect system data for diagnostics, monitoring, or audit logging. 
The script captures key system details and writes them to a structured output file. From there, typical data parsing tools can be applied to quickly ascertain an overview of your environment.

Features 📋
-----------
Standard features include data for: 

- UTC Timestamp of data collection
- Hostname and OS version
- Kernel version and architecture
- System uptime and last boot time
- CPU and GPU model
- Memory and disk usage
- IP address of the host
- Logged-in user count
- Running services count
- NTP synchronization status
- System load averages

Dependencies 🛠
---------------
The script relies on standard *nix utilities:

- date, hostname, uname, uptime, who, df, free, ip, awk, grep, cut, xargs

- lscpu, lspci (optional, for CPU/GPU info)

- timedatectl, systemctl (for system services and NTP status)

Ensure these tools are available in your environment.

Configuration 📦
----------------
I strongly recommend configuring ATLAS to your environment before running the install script on any machines. Standard configuration is written to `atlas.conf` - as of the current release, the only option of critical importance is the `output_dir` variable.
If no output directory is specified, no data can be saved. While data can be stored locally on the machine, if you plan on using the service on several machines, I recommend using a network share with appropriate permissions to store data.

Adding additional data metrics is rather simple as well, just adjust the `atlas.sh` script to include whatever else you may need, and redeploy.

Installation 🚀
--------------
For standard installations, on a single machine:

```
# git clone https://github.com/pjpnd/ATLAS.git
# cd ATLAS
# ./install.sh
```

For multiple machines, I strongly recommend creating an Ansible task that performs the above instructions. At some point I may write said task, maybe.

Contributing 🤝
---------------
Pull requests and suggestions are welcome. For major changes, please open an issue first to discuss your proposed updates.
