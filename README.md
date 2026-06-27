# 🔄 AnyDesk Free License Reset

A script to **reset AnyDesk's free license**, clearing the lockout that blocks connections to other devices after extended use.

> ⚠️ **Note:** this is **not a crack**. It simply restores AnyDesk's free-tier functionality within the app's own limits — it won't permanently unlock anything. It just lets you keep using the free version without interruptions.
>
> 💡 If you use AnyDesk frequently or professionally, we strongly recommend purchasing an official license.
>
> Prefer to self-host instead? Check out [Rustdesk Server](https://rustdesk.com/docs/en/self-host/) — open source and fully self-hosted.

---

## ⚙️ Requirements

- AnyDesk must be installed on the machine.
- Administrator privileges (Windows) or `sudo` (Linux), if required.

---

## 💻 Windows

### Automatic (PowerShell)

Run the command below in PowerShell (as administrator):

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/pratinha10/anydesk-reset-session/main/Anydesk-Reset.cmd" -OutFile "Anydesk_reset.cmd"; Start-Process "Anydesk_reset.cmd"
```

### Manual

1. Download [`Anydesk-Reset.cmd`](https://raw.githubusercontent.com/pratinha10/anydesk-reset-session/main/Anydesk-Reset.cmd)
2. Right-click it and select **"Run as administrator"**.
3. Wait for the script to finish.
4. If AnyDesk doesn't start automatically, **restart your computer manually**.

---

## 🐧 Linux

```bash
wget https://raw.githubusercontent.com/pratinha10/anydesk-reset-session/main/anydesk_licenca.sh
chmod +x anydesk_licenca.sh
./anydesk_licenca.sh
```

---

## 🍎 macOS

```bash
curl -s https://raw.githubusercontent.com/pratinha10/anydesk-reset-session/refs/heads/main/reset_licenca_macos.sh | bash
```
