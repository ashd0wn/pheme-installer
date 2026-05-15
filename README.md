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
[![Runs on 1vCPU / 2GB](https://img.shields.io/badge/Runs_on-1_vCPU_%2F_2GB_RAM-yellow?style=flat-square)](#configuration-minimale)

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

## Configuration minimale

| Ressource | Minimum | Recommandé |
|-----------|---------|------------|
| CPU | 1 vCPU | 2 vCPU |
| RAM | 2 GB | 4 GB |
| Disque | 20 GB | 40 GB+ |
| OS | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| Réseau | 10 Mbps | 100 Mbps+ |

> Pheme tourne sans erreur sur des VPS d'entrée de gamme chez OVH, Hetzner et DigitalOcean.

---

## Installation

### Stable (0.19.1)

```bash
mkdir /root/pheme_installer \
  && cd /root/pheme_installer \
  && git clone https://github.com/ashd0wn/Pheme-Installer.git . \
  && git checkout 0.19.1 \
  && chmod -R +x ./* \
  && ./install.sh -i
```

> ⚠️ **Un redémarrage est obligatoire après l'installation.**  
> Sans reboot, vous obtiendrez une erreur 500 au premier accès.

L'installation prend **environ 20 à 30 minutes** selon votre connexion et votre machine.  
Les logs sont disponibles en temps réel dans un second terminal :

```bash
tail -f /root/pheme_installer/pheme_installer.log
```

---

### Rolling Release (dernière version en cours)

```bash
mkdir /root/pheme_installer \
  && cd /root/pheme_installer \
  && git clone https://github.com/ashd0wn/Pheme-Installer.git . \
  && git checkout main \
  && chmod +x install.sh \
  && ./install.sh --install_rrc
```

> ⚠️ Non recommandé en production. La rolling release peut introduire des dépendances cassantes.

---

## Mise à jour

### De 0.18.6 vers 0.19.1

```bash
rm -rf /root/pheme_installer \
  && mkdir -p /root/pheme_installer \
  && cd /root/pheme_installer \
  && git clone https://github.com/ashd0wn/Pheme-Installer.git . \
  && git checkout 0.19.1 \
  && chmod -R +x ./* \
  && ./install.sh --upgrade
```

### Rolling Release

```bash
rm -rf /root/pheme_installer \
  && mkdir -p /root/pheme_installer \
  && cd /root/pheme_installer \
  && git clone https://github.com/ashd0wn/Pheme-Installer.git . \
  && git checkout rolling \
  && chmod +x install.sh \
  && ./install.sh --upgrade_rrc
```

> Les mises à jour rolling ne sont pas garanties si de nouvelles dépendances système sont introduites. Si vous n'êtes pas à l'aise en CLI, restez sur la version stable.

---

## Commandes disponibles

```
./install.sh [option]
```

**Installation / Mise à jour**

| Option | Description |
|--------|-------------|
| `-i`, `--install` | Installer la dernière version stable |
| `-u`, `--upgrade` | Mettre à jour vers la dernière version stable |
| `-r`, `--install_rrc` | Installer la dernière Rolling Release |
| `-p`, `--upgrade_rrc` | Mettre à jour vers la dernière Rolling Release |

**Gestion de Pheme**

| Option | Description |
|--------|-------------|
| `-c`, `--clean` | Vider le dossier `www_tmp` de Pheme |
| `-o`, `--changeports` | Modifier les ports du panel Pheme |

**Icecast KH**

| Option | Description |
|--------|-------------|
| `-w`, `--icecastkh18` | Installer / mettre à jour vers Icecast KH 18 |
| `-t`, `--icecastkhlatest` | Installer / mettre à jour vers la dernière build GitHub |
| `-s`, `--icecastkhmaster` | Installer depuis la branche master |

**Liquidsoap**

> Pour Pheme ≥ 0.18.5 : Liquidsoap **2.2.x ou supérieur**.  
> Pour Pheme < 0.18.5 : Liquidsoap **< 2.2.x** (dernière version compatible : 2.1.4).

| Option | Description |
|--------|-------------|
| `-n`, `--liquidsoaplatest` | Installer / mettre à jour vers la dernière version |
| `-m`, `--liquidsoapcustom` | Installer une version spécifique |

**Divers**

| Option | Description |
|--------|-------------|
| `-z`, `--upgrade_installer` | Mettre à jour l'installeur lui-même |
| `-v`, `--version` | Afficher les informations de version |
| `-h`, `--help` | Afficher l'aide |

---

## Après l'installation

À la fin de l'installation, les identifiants de connexion sont affichés dans le terminal **et sauvegardés** dans :

```
/root/pheme_installer/pheme_details.txt
```

Pensez à **supprimer ce dossier** une fois vos credentials notés :

```bash
rm -rf /root/pheme_installer
```

Le panel est accessible à l'adresse : `http://<votre-ip-ou-domaine>`

---

## Personnalisation PHP

Le fichier `php.ini` embarqué dans ce dépôt est une version modifiée de celui d'origine, optimisée pour des configs légères. Plusieurs profils sont disponibles selon votre machine :

```
web/php/www.conf           ← Configuration de base (2 vCPU / 4 GB)
web/php/www_1v_4gb.conf    ← 1 vCPU / 4 GB
web/php/www_2v_2gb.conf    ← 2 vCPU / 2 GB
web/php/www_2v_8gb.conf    ← 2 vCPU / 8 GB
web/php/www_4v_4gb.conf    ← 4 vCPU / 4 GB
web/php/www_4v_8gb.conf    ← 4 vCPU / 8 GB
web/php/www_4v_16gb.conf   ← 4 vCPU / 16 GB
```

Pour utiliser un profil, copiez-le en remplacement de `www.conf` avant l'installation, ou remplacez-le manuellement à `/etc/php/8.2/fpm/pool.d/www.conf` après.

---

## Testé avec

- **OVH** — VPS SSD (1 vCPU / 2 GB)
- **Hetzner** — CX11 / CX21
- **DigitalOcean** — Droplet Basic

Un test automatisé est effectué sur ces trois hébergeurs à chaque version. Les images Ubuntu de base varient selon les providers — si vous rencontrez une erreur, ouvrez une issue avec les logs.

---

## Notes importantes

- Cet installeur est indépendant du projet AzuraCast officiel. **Ne contactez pas l'équipe AzuraCast pour des problèmes liés à cet installeur.**
- L'équipe officielle supporte uniquement la version Docker.
- Ce fork est maintenu pour un usage personnel avec des modifications ciblées (principalement l'AutoDJ).
- Pheme est basé sur AzuraCast — pour la documentation fonctionnelle du panel, référez-vous à [docs.azuracast.com](https://docs.azuracast.com).

---

## Licence

GPL-3.0 — voir [LICENSE](LICENSE)

---

<div align="center">

*"φήμη — la voix qui se répand, la parole que le vent porte."*

**[Signaler un bug](https://github.com/ashd0wn/Pheme-Installer/issues)** · **[AzuraCast upstream](https://github.com/AzuraCast/AzuraCast)**

</div>
