<div align="center">

```
██████╗ ██╗  ██╗███████╗███╗   ███╗███████╗
██╔══██╗██║  ██║██╔════╝████╗ ████║██╔════╝
██████╔╝███████║█████╗  ██╔████╔██║█████╗
██╔═══╝ ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝
██║     ██║  ██║███████╗██║ ╚═╝ ██║███████╗
╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝
```

**Self-hosted radio — no Docker, no overhead, bare metal.**

[![Ubuntu 22.04](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?style=flat-square&logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![Based on AzuraCast](https://img.shields.io/badge/Based_on-AzuraCast_0.19.1-4A90D9?style=flat-square)](https://github.com/AzuraCast/AzuraCast)
[![License](https://img.shields.io/badge/License-GPL_3.0-green?style=flat-square)](LICENSE)
[![Runs on 1vCPU / 2GB](https://img.shields.io/badge/Runs_on-1_vCPU_%2F_2GB_RAM-yellow?style=flat-square)](#minimum-requirements)

*Named after Pheme — goddess of voice, rumor, and renown in ancient Greece.*

</div>

---

## What is Pheme?

Pheme is a **bare-metal web radio platform** forked from [AzuraCast](https://github.com/AzuraCast/AzuraCast), stripped of Docker and designed to run directly on the host system — the old-school way.

No container orchestration. No image layers. No daemon overhead.  
Just nginx, PHP, MariaDB, Redis, Liquidsoap and Icecast — all on one machine, all under your control.

It's built for people who want to run a fully functional, production-ready internet radio station on modest hardware: a cheap VPS, a repurposed server, or a machine that would choke under Docker's weight.

---

## Why bare metal?

| | Docker (AzuraCast default) | Pheme (bare metal) |
|---|---|---|
| RAM usage at idle | ~600 MB+ | ~250 MB |
| Storage footprint | ~3–4 GB (images) | ~800 MB |
| Cold start time | 30–90s | < 5s |
| Old VPS compatible | ⚠️ Limited | ✅ Yes |
| Full stack visibility | Partial | Complete |
| Custom config | Through volumes | Direct file access |

If you have a machine with **1 vCPU and 2 GB of RAM**, Pheme runs on it. Tested and confirmed.

---

## Stack

All services run natively on the host, managed by **Supervisord**:

```
nginx          ← Web server & reverse proxy
php-fpm 8.2    ← Application runtime
MariaDB 11.5   ← Database
Redis          ← Cache & session store
Liquidsoap     ← AutoDJ engine
Icecast KH     ← Stream output (HLS + Shoutcast-compatible)
SFTPGo         ← File management over SFTP
Beanstalkd     ← Job queue
Centrifugo     ← WebSocket real-time updates
```

---

## Minimum requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 1 vCPU | 2 vCPU |
| RAM | 2 GB | 4 GB |
| Disk | 20 GB | 40 GB+ |
| OS | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| Network | 10 Mbps | 100 Mbps+ |

> Pheme runs without issues on entry-level VPS instances at OVH, Hetzner and DigitalOcean.

---

## Installation

```bash
mkdir /root/pheme_installer \
  && cd /root/pheme_installer \
  && git clone https://github.com/ashd0wn/pheme-installer.git . \
  && chmod +x install.sh \
  && ./install.sh -i
```

> ⚠️ **A reboot is required after installation.**  
> Without a reboot, you will get a 500 error on first access.

Installation takes **approximately 20 to 30 minutes** depending on your connection and machine.  
You can follow the logs in real time in a second terminal:

```bash
tail -f /root/pheme_installer/pheme_installer.log
```

---

## Available commands

```
./install.sh [option]
```

**Installation**

| Option | Description |
|--------|-------------|
| `-i`, `--install` | Install Pheme |

**Maintenance**

| Option | Description |
|--------|-------------|
| `-c`, `--clean` | Clear Pheme's `www_tmp` directory |
| `-o`, `--changeports` | Change the ports the Pheme panel runs on |

**Info**

| Option | Description |
|--------|-------------|
| `-v`, `--version` | Display version information |
| `-h`, `--help` | Display help |

---

## After installation

At the end of the installation, your login credentials are saved to:

```
/root/pheme_installer/pheme_details.txt
```

Make sure to **delete this folder** once you have noted your credentials:

```bash
rm -rf /root/pheme_installer
```

The panel is accessible at: `http://<your-ip-or-domain>`

---

## PHP customization

The `php.ini` included in this repository is a modified version of the original, optimized for lightweight setups. Several profiles are available depending on your machine:

```
web/php/www.conf           ← Base configuration (2 vCPU / 4 GB)
web/php/www_1v_4gb.conf    ← 1 vCPU / 4 GB
web/php/www_2v_2gb.conf    ← 2 vCPU / 2 GB
web/php/www_2v_8gb.conf    ← 2 vCPU / 8 GB
web/php/www_4v_4gb.conf    ← 4 vCPU / 4 GB
web/php/www_4v_8gb.conf    ← 4 vCPU / 8 GB
web/php/www_4v_16gb.conf   ← 4 vCPU / 16 GB
```

To use a profile, copy it as a replacement for `www.conf` before installation, or replace it manually at `/etc/php/8.2/fpm/pool.d/www.conf` afterwards.

---

## Tested on

- **OVH** — VPS SSD (1 vCPU / 2 GB)
- **Hetzner** — CX11 / CX21
- **DigitalOcean** — Droplet Basic

---

## Important notes

- This installer is independent from the official AzuraCast project. **Do not contact the AzuraCast team for issues related to this installer.**
- The official team only supports the Docker version.
- This fork is maintained for personal use with targeted modifications (primarily the AutoDJ).
- Pheme is based on AzuraCast — for panel documentation, refer to [docs.azuracast.com](https://docs.azuracast.com).

---

## License

GPL-3.0 — see [LICENSE](LICENSE)

---

<div align="center">

*"φήμη — the voice that spreads, the word the wind carries."*

**[Report a bug](https://github.com/ashd0wn/pheme-installer/issues)** · **[AzuraCast upstream](https://github.com/AzuraCast/AzuraCast)**

</div>
