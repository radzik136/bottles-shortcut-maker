# Bottles Shortcut Creator (AppImage) 🍾🚀

A portable utility with a graphical interface (Zenity) designed to automate the creation of desktop shortcuts (`.desktop` files) for programs and games installed within **Bottles** (Flatpak version).

## 🌟 Why AppImage?
This tool is distributed as an **AppImage**, which means:
* **Zero Installation:** No need to install dependencies like `yq` or extra libraries.
* **Portable:** One single file that works across different Linux distributions.
* **Steam Deck & Bazzite Friendly:** Perfect for immutable systems where you want to keep your root filesystem clean.

## 🚀 Key Features
* **Bundled Dependencies:** Includes an internal `yq` binary to parse `bottle.yml` without system-wide installation.
* **Graphical Workflow:** Simple Zenity-based dialogs for selecting bottles, programs, and icons.
* **Smart Icon Picker:** * Manually choose PNG/ICO icons.
    * The picker **automatically opens in the directory where the program's .exe is located**.
    * Automatic fallback to the icon specified in Bottles' configuration.
* **Flexible Location:** Create shortcuts directly on your **Desktop** or in the **Applications Menu**.

## 🛠 Requirements
* **Bottles** installed via Flatpak.
* **Zenity** (standard on most Linux desktops like GNOME, KDE Plasma, or Bazzite).

## 📋 How to Use

### 1. Preparation
Before the first run, make sure the file has permission to execute:
* Right-click the `.AppImage` file -> **Properties** -> **Permissions** -> Check **"Allow executing file as program"**.
* **OR** use the terminal:
    ```bash
    chmod +x Bottles_Shortcut_Creator-x86_64.AppImage
    ```

### 2. Step-by-Step Guide
1. **Choose Mode:** Select "Create shortcut from bottle program (recommended)".
2. **Select Bottle:** Pick the bottle containing your app.
3. **Select Program:** Choose the application from the list found in your `bottle.yml`.
4. **Choose Icon:** * The file picker will open in your app's folder. 
    * Select an icon or click **"Skip" (Pomiń)** to use the default one.
5. **Shortcut Location:** Choose between "Desktop" or "Applications menu".

## 🏗️ Technical Structure
The AppImage is built using the following structure:
* `AppRun`: The entry point that executes the main script.
* `usr/bin/yq`: Bundled YAML processor (MIT License).
* `bottles-shortcut.sh`: The core logic of the application.
* `bottles.desktop` & `bottles.png`: Metadata for the AppImage itself.

## ⚖️ License
This project is licensed under the **GNU GPL v3**. It is free software and will always remain free. Commercial use is not permitted.

**Third-party software:** This project bundles `yq` by Mike Farah, licensed under the **MIT License**.

---
*Developed to simplify the Linux gaming experience on Bazzite, Steam Deck, and beyond.*
