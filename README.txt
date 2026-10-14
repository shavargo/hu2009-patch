Hunting Unlimited 2009 — modern PC changes

These files make a stock install launch on a current Windows PC and pick a high graphics setting on a modern GPU. They do not add DLSS.

What the script does
- Lets hu2009.exe and prism3d.exe use 4 GB of memory (large-address-aware flag).
- Replaces specs.settings so the launcher offers 1280x720, 1600x900, and 1920x1080, and so names such as NVIDIA, GeForce RTX, Radeon RX, and Intel Arc rate as High.
- Tells Windows to use the high-performance GPU for both executables.
- Turns off fullscreen optimizations for both executables.
- Saves the original hu2009.exe, prism3d.exe, and specs.settings into modern-backup the first time it runs. Later runs leave that backup alone.

2560x1440 is not in the recommended-mode list. The launcher rejects that size when it is stored there. Pick it from the resolution dropdown instead. The highest recommended mode is 1920x1080 so a fresh High detection still has a valid mode.

How to apply
1. Copy the whole game folder out of Program Files to a place your account can write, for example C:\Users\you\Games\Hunting Unlimited 2009. Program Files itself will refuse the write unless the script is run as administrator.
2. Open PowerShell in this folder and run:

   powershell -ExecutionPolicy Bypass -File .\Apply-Modern.ps1 -GameDir "C:\Users\you\Games\Hunting Unlimited 2009"

3. Start hu2009.exe from that folder. In the launcher, choose the resolution you want and the highest shader path the card can use, then start the game.

The script updates TargetPath under HKCU\Software\ValuSoft\Hunting Unlimited 2009 when that key already exists, so the stored launch path matches the folder you passed in.
