# 🔍 Find Your Local IP Address

## ❌ Wrong IP

`115.98.185.213` is your **public/external IP** (from internet provider)

We need your **local/private IP** (from your WiFi router)

---

## ✅ How to Find Local IP

### Method 1: Command Prompt

1. Open **Command Prompt** (CMD)
2. Type:
   ```bash
   ipconfig
   ```
3. Look for **"Wireless LAN adapter Wi-Fi"** or **"Ethernet adapter"**
4. Find **"IPv4 Address"**

**It will look like ONE of these:**
- `192.168.x.x` (most common)
- `10.x.x.x`
- `172.16.x.x` to `172.31.x.x`

### Example Output:

```
Wireless LAN adapter Wi-Fi:

   Connection-specific DNS Suffix  . :
   Link-local IPv6 Address . . . . . : fe80::xxxx
   IPv4 Address. . . . . . . . . . . : 192.168.1.100  ← THIS ONE!
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.1.1
```

**Your local IP is**: `192.168.1.100` (in this example)

---

## Method 2: Windows Settings

1. Open **Settings**
2. Go to **Network & Internet**
3. Click **Wi-Fi** (or Ethernet)
4. Click **Properties**
5. Scroll down to find **IPv4 address**

---

## Method 3: Quick Command

Run this in CMD:

```bash
ipconfig | findstr /i "IPv4"
```

You'll see something like:
```
   IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

---

## 🎯 What to Look For

Your local IP will be:
- ✅ `192.168.x.x` (most common for home WiFi)
- ✅ `10.x.x.x` (some routers)
- ✅ `172.16.x.x` to `172.31.x.x` (less common)

NOT:
- ❌ `115.98.185.213` (public IP)
- ❌ `127.0.0.1` (localhost)
- ❌ `169.254.x.x` (no network)

---

## 📱 Important

Make sure:
- ✅ Your **phone** is connected to the **same WiFi** as your computer
- ✅ Not using mobile data on phone
- ✅ Both on same network

---

## ⚡ Quick Check

Run this command and send me the output:

```bash
ipconfig | findstr /i "IPv4"
```

Or just tell me the number that starts with `192.168.` or `10.`

---

**Once you give me the correct local IP, I'll update the app!** 🚀
