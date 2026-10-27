# 🎙️ Mumble Server (Murmur) on VPS — Production Ready

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04%20%7C%2024.04-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Debian](https://img.shields.io/badge/Debian-11%20%7C%2012-A81D33?logo=debian&logoColor=white)](https://www.debian.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/)

ชุดติดตั้งและปรับแต่ง **Mumble Server (Murmur)** บน VPS แบบสำเร็จรูป สำหรับเปิดใช้งานเซิร์ฟเวอร์สื่อสารด้วยเสียง (Voice Chat) คุณภาพสูง ดีเลย์ต่ำมาก (Ultra-low latency) และกินทรัพยากรเครื่องน้อยมาก 

พร้อมใช้งานทันทีทั้งแบบ **Docker Compose (แนะนำ)** และแบบ **Native Ubuntu/Debian Service**

---

## ✨ จุดเด่น (Features)

- 🚀 **ติดตั้งง่ายใน 2 นาที**: รันคำสั่งเดียวพร้อมใช้งานทันที
- 📦 **รองรับ 2 รูปแบบการติดตั้ง**:
  - **Docker Compose**: แยก Environment ชัดเจน ปลอดภัย ย้ายเซิร์ฟเวอร์ง่าย
  - **Native Script**: ติดตั้งตรงลง OS (Ubuntu/Debian) ควบคุมผ่าน `systemd`
- 🎧 **คุณภาพเสียงสูงสุด**: ปรับแต่งค่า Opus Codec และแบนด์วิดท์มาตรฐานที่ 96 kbps (Studio Quality)
- 🛡️ **ระบบความปลอดภัย & Firewall**: มีสคริปต์เปิดพอร์ต UFW / Firewalld ให้อัตโนมัติ
- 💾 **ระบบสำรองข้อมูล (Backup Script)**: สคริปต์แบ็กอัปฐานข้อมูล SQLite และไฟล์คอนฟิกอัตโนมัติ พร้อมตั้งเวลาลบไฟล์เก่า
- 🌐 **ใช้งานได้กับทุก Cloud VPS**: รองรับ DigitalOcean, Linode/Akamai, AWS Lightsail, Hetzner, Vultr, Oracle Cloud และผู้ให้บริการ VPS ในไทย

---

## 📋 ความต้องการของระบบ (System Requirements)

| รายการ | ขั้นต่ำ (Minimum) | แนะนำ (Recommended) |
| :--- | :--- | :--- |
| **CPU** | 1 vCPU | 1 vCPU |
| **RAM** | 512 MB | 1 GB (รองรับ 100+ คนสบายๆ) |
| **Disk** | 5 GB SSD | 10 GB SSD |
| **OS** | Linux (Ubuntu, Debian, CentOS, AlmaLinux) | Ubuntu 22.04 / 24.04 LTS |
| **Network Ports** | `64738` (ทั้ง **TCP** และ **UDP**) | `64738` (ทั้ง **TCP** และ **UDP**) |

> [!IMPORTANT]
> Mumble จำเป็นต้องเปิดพอร์ต **64738 ทั้งแบบ TCP และ UDP**:
> - **TCP**: ใช้สำหรับ Handshake, ข้อความแช็ต และระบบสิทธิ์
> - **UDP**: ใช้สำหรับสตรีมมิ่งเสียง (หากไม่เปิด UDP เสียงจะไม่ดังหรือเชื่อมต่อไม่ได้)

---

## 🚀 วิธีติดตั้ง (Quick Start)

### วิธีที่ 1: ติดตั้งผ่าน Docker Compose (แนะนำที่สุด ⭐)

#### 1. ติดตั้ง Docker (หาก VPS ยังไม่มี)
หาก VPS ของคุณยังไม่มี Docker สามารถรันสคริปต์นี้เพื่อติดตั้งแบบอัตโนมัติ:
```bash
sudo bash scripts/install-docker.sh
```

#### 2. Clone Repository นี้ลงบน VPS
```bash
git clone https://github.com/mtts6115/mumble-vps.git mumble-server
cd mumble-server
```

#### 3. คัดลอกและตั้งค่า Environment
```bash
cp .env.example .env
nano .env
```
> [!TIP]
> แก้ไขอย่างน้อยหนึ่งจุดคือ `MUMBLE_SUPERUSER_PASSWORD` โดยตั้งรหัสผ่านสำหรับผู้ดูแล (Admin) ให้รัดกุม

#### 4. เริ่มต้นเซิร์ฟเวอร์
```bash
docker compose up -d
```

ตรวจสอบสถานะการทำงาน:
```bash
docker compose ps
docker compose logs -f
```

---

### วิธีที่ 2: ติดตั้งแบบ Native บน Ubuntu / Debian (ไม่ใช้ Docker)

หากต้องการติดตั้งลงบนระบบปฏิบัติการโดยตรงผ่าน `apt`:

```bash
git clone https://github.com/mtts6115/mumble-vps.git mumble-server
cd mumble-server
sudo bash scripts/install-native.sh
```

สคริปต์จะทำการ:
1. ติดตั้ง `mumble-server`
2. ตั้งรหัสผ่าน `SuperUser`
3. ปรับแต่งไฟล์ `/etc/mumble-server.ini`
4. เปิดพอร์ตไฟร์วอลล์ (UFW)
5. เปิดบริการอัตโนมัติผ่าน `systemd`

---

## 🔐 การเข้าสู่ระบบเป็นผู้ดูแล (SuperUser)

เมื่อเซิร์ฟเวอร์รันเรียบร้อยแล้ว ให้เชื่อมต่อจากโปรแกรม **Mumble Client** บนเครื่องคอมพิวเตอร์ของคุณ:

1. เปิดโปรแกรม Mumble -> ไปที่ **Server** -> **Connect** -> **Add New...**
2. กรอกรายละเอียด:
   - **Address**: ใส่หมายเลข IP ของ VPS คุณ (เช่น `203.0.113.10`)
   - **Port**: `64738`
   - **Username**: `SuperUser` *(ตัวพิมพ์ใหญ่-เล็กตรงตามนี้)*
   - **Label**: ตั้งชื่อเซิร์ฟเวอร์ตามต้องการ
3. กด **Connect** จากนั้นโปรแกรมจะถามรหัสผ่าน ให้กรอกรหัสผ่านที่คุณตั้งไว้ใน `.env` (หรือที่สคริปต์แจ้ง)
4. เมื่อล็อกอินสำเร็จ คุณจะมีสิทธิ์เต็มในการ:
   - คลิกขวาที่ชื่อห้องหลักเพื่อ **Add Channel** (สร้างห้องย่อย)
   - ตั้งสิทธิ์กลุ่ม (Groups) และสิทธิ์การเข้าถึง (ACL)
   - ล็อกห้องหรือตั้งรหัสผ่านเฉพาะห้อง

---

## 🛡️ การตั้งค่า Firewall & Cloud Security Groups

นอกจากไฟร์วอลล์ในเครื่อง (UFW) แล้ว หากคุณใช้ Cloud VPS จะต้องเปิดพอร์ตในหน้า Dashboard ของผู้ให้บริการด้วย:

| ผู้ให้บริการ | เมนูที่ต้องไปตั้งค่า | พอร์ตที่ต้องเปิด |
| :--- | :--- | :--- |
| **AWS (EC2 / Lightsail)** | Security Groups / Networking | Custom TCP `64738`, Custom UDP `64738` |
| **Google Cloud (GCP)** | VPC network -> Firewall | TCP `64738`, UDP `64738` |
| **Oracle Cloud (OCI)** | Ingress Rules (Security List) | TCP `64738`, UDP `64738` |
| **DigitalOcean / Vultr / Linode** | Cloud Firewalls (ถ้าเปิดใช้งาน) | TCP & UDP `64738` |

สคริปต์สำหรับเปิด Firewall ภายในเครื่อง Linux (UFW / Firewalld / iptables):
```bash
sudo bash scripts/setup-firewall.sh 64738
```

---

## ⚙️ รายละเอียดการตั้งค่า (.env Reference)

| ตัวแปร | ค่าเริ่มต้น | คำอธิบาย |
| :--- | :--- | :--- |
| `MUMBLE_PORT` | `64738` | พอร์ตหลักที่เซิร์ฟเวอร์รับการเชื่อมต่อ |
| `MUMBLE_SUPERUSER_PASSWORD` | *(ต้องเปลี่ยน)* | รหัสผ่านผู้ดูแลระบบสูงสุด (SuperUser) |
| `MUMBLE_SERVER_PASSWORD` | *(เว้นว่าง)* | รหัสผ่านสำหรับเข้าเซิร์ฟเวอร์ (เว้นว่างเพื่อให้เป็นห้องสาธารณะ) |
| `MUMBLE_SERVER_NAME` | `My Community Mumble Server` | ชื่อห้องหลักที่แสดงเมื่อผู้ใช้เชื่อมต่อ |
| `MUMBLE_WELCOME_TEXT` | `<b>Welcome...</b>` | ข้อความต้อนรับในช่องแช็ต (รองรับแท็ก HTML) |
| `MUMBLE_MAX_USERS` | `100` | จำนวนผู้ใช้สูงสุดที่ออนไลน์พร้อมกันได้ |
| `MUMBLE_BANDWIDTH` | `96000` | บิตเรตเสียง (96 kbps คุณภาพระดับสตูดิโอ) |
| `MUMBLE_OPUS_THRESHOLD` | `100` | อนุญาตให้ใช้ Opus Codec 100% |

---

## 💾 การสำรองข้อมูล (Backup & Restore)

### สำรองข้อมูล
รันสคริปต์สำรองข้อมูล:
```bash
bash scripts/backup.sh
```
ไฟล์แบ็กอัปจะถูกบีบอัดเป็น `.tar.gz` และเก็บไว้ที่โฟลเดอร์ `./backups/` โดยระบบจะเก็บประวัติย้อนหลัง 14 วัน

### ตั้งเวลาสำรองข้อมูลอัตโนมัติ (Cron Job)
สามารถตั้งเวลาให้สำรองข้อมูลทุกเที่ยงคืนได้ด้วย `crontab -e`:
```bash
0 0 * * * cd /path/to/mumble-server && bash scripts/backup.sh >/dev/null 2>&1
```

---

## 📂 โครงสร้างไดเรกทอรี (Project Structure)

```text
mumble-vps/
├── docker-compose.yml       # คอนฟิกหลักสำหรับ Docker Compose
├── .env.example             # เทมเพลตตัวแปรระบบและรหัสผ่าน
├── .gitignore               # ป้องกันการเผลอ push ข้อมูลลับและไฟล์ฐานข้อมูล
├── LICENSE                  # สัญญาอนุญาตแบบ MIT
├── README.md                # คู่มือการใช้งานฉบับสมบูรณ์
├── config/
│   └── mumble-server.ini    # เทมเพลตคอนฟิก Murmur ขั้นสูง
├── scripts/
│   ├── install-docker.sh    # สคริปต์ติดตั้ง Docker บน VPS
│   ├── install-native.sh    # สคริปต์ติดตั้งตรงบน Ubuntu/Debian
│   ├── setup-firewall.sh    # สคริปต์เปิดพอร์ต Firewall (TCP/UDP)
│   └── backup.sh            # สคริปต์สำรองข้อมูล SQLite และ Config
└── certs/
    └── .gitkeep             # โฟลเดอร์สำหรับใส่ใบรับรอง SSL/TLS (ถ้ามี)
```

---

## ❓ คำถามที่พบบ่อย (Troubleshooting & FAQ)

<details>
<summary><b>1. ผู้ใช้เชื่อมต่อเข้ามาได้ แต่ไม่มีเสียงคุยกันไม่ได้ หรือได้ยินอยู่ฝ่ายเดียว?</b></summary>
เกิดจากไม่ได้เปิดพอร์ต <b>UDP 64738</b> ที่ Firewall หรือ Cloud Security Group ของ VPS กรุณาตรวจสอบให้แน่ใจว่าเปิดทั้ง <b>TCP และ UDP</b>
</details>

<details>
<summary><b>2. ลืมรหัสผ่าน SuperUser ทำอย่างไร?</b></summary>

- **กรณีใช้ Docker**: ให้แก้ไขค่า `MUMBLE_SUPERUSER_PASSWORD` ในไฟล์ `.env` แล้วสั่ง:
  ```bash
  docker compose down && docker compose up -d
  ```
- **กรณีติดตั้ง Native**: รันคำสั่งนี้บนเซิร์ฟเวอร์:
  ```bash
  sudo mumble-server -supw "รหัสผ่านใหม่ที่ต้องการ"
  ```
</details>

<details>
<summary><b>3. ต้องการเปลี่ยนพอร์ตหนีการสแกน หรือใช้พอร์ตอื่น?</b></summary>
แก้ไขค่า `MUMBLE_PORT` ในไฟล์ `.env` (เช่น เปลี่ยนเป็น `50000`) จากนั้นสั่ง `docker compose up -d` และอย่าลืมเปิดพอร์ตใหม่ที่ Firewall ด้วย
</details>

---

## 📄 License

แจกจ่ายและใช้งานภายใต้สัญญาอนุญาต **[MIT License](LICENSE)** สามารถนำไปปรับแต่งและใช้งานได้ฟรีทั้งส่วนตัวและเชิงพาณิชย์
