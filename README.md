# Bottles Shortcut Creator (AppImage) 🍾🚀

A portable utility with a graphical interface (Zenity) designed to automate the creation of desktop shortcuts (`.desktop` files) for programs and games installed within **Bottles** (Flatpak version).

## 🌟 Why AppImage?
This tool is distributed as an **AppImage**, which means:
* **Zero Installation:** No need to install dependencies like `yq` or extra libraries.
* **Portable:** One single file that works across different Linux distributions.
* **Steam Deck & Bazzite Friendly:** Perfect for immutable systems where you want to keep your root filesystem clean.

## 🚀 Key Features
* **Bundled Dependencies:** Includes an internal `yq` binary to parse `bottle.yml` without system-wide installation.
* **Graphical Workflow:** Simple Zenity-based dialogs to select your "Bottle" and application.
* **Smart Icon Picker:** * Manually choose PNG/ICO icons.
    * The picker defaults to the program's executable directory for convenience.
    * Automatic fallback to the icon specified in Bottles' configuration.
* **Flexible Location:** Create shortcuts directly on your **Desktop** or in the **Applications Menu**.

## 🛠 Requirements
* **Bottles** installed via Flatpak.
* **Zenity** (standard on most Linux desktops like GNOME, KDE Plasma, or Bazzite).

## 📋 How to Use
1. Download the latest `.AppImage` from the [Releases](link-to-your-releases) page.
2. Make the file executable:
   ```bash
   chmod +x Bottles_Shortcut_Creator-x86_64.AppImage
