# Cursor AppImage to .deb Converter

🚀 **Automatically convert Cursor AI editor AppImage to .deb package for Ubuntu/Debian with daily auto-updates via GitHub Actions**

[![Build Status](https://github.com/YOUR_USERNAME/cursor-appimage-to-deb/workflows/Build%20Cursor%20.deb%20Package/badge.svg)](https://github.com/YOUR_USERNAME/cursor-appimage-to-deb/actions)
[![Latest Release](https://img.shields.io/github/v/release/YOUR_USERNAME/cursor-appimage-to-deb)](https://github.com/YOUR_USERNAME/cursor-appimage-to-deb/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/cursor-appimage-to-deb/total)](https://github.com/YOUR_USERNAME/cursor-appimage-to-deb/releases)

## 🎯 What This Does

Converts the official **Cursor AI code editor AppImage** to a proper **.deb package** for easy installation on **Ubuntu**, **Debian**, and other Debian-based Linux distributions. Includes automatic daily updates via GitHub Actions.

## ⚡ Quick Install

### Option 1: Download Ready-Made .deb Package (Recommended)

1. **Go to [Releases](../../releases)**
2. **Download the latest `cursor_*.deb` file**
3. **Install with one command:**

```bash
# Download and install (replace with actual version)
wget https://github.com/YOUR_USERNAME/cursor-appimage-to-deb/releases/latest/download/cursor_*_amd64.deb
sudo dpkg -i cursor_*_amd64.deb
sudo apt-get install -f  # Fix any missing dependencies
```

### Option 2: Build Locally

```bash
# Clone and build
git clone https://github.com/YOUR_USERNAME/cursor-appimage-to-deb.git
cd cursor-appimage-to-deb

# One-command build
./build.sh

# Install the generated package
sudo dpkg -i output/cursor_*.deb
sudo apt-get install -f
```

## 🔥 Features

✅ Automatic Updates: Daily checks for new Cursor releases  
✅ Official Source: Downloads from Cursor's official API  
✅ Proper .deb Package: Standards-compliant Debian package  
✅ Desktop Integration: Menu entries, icons, file associations  
✅ Dependency Management: Handles all required dependencies  
✅ GitHub Actions: Fully automated CI/CD pipeline  
✅ Version Tracking: Only builds when new versions available  
✅ Zero Configuration: Works out of the box

## 🛠️ How It Works

### 1. Smart Download (`scripts/download-cursor.sh`)
- Uses Cursor's official API: https://www.cursor.com/api/download
- Intelligent version detection from API, filename, or AppImage contents
- Fallback to date-based versioning
- Automatic file management

### 2. Professional Conversion (`scripts/convert-to-deb.sh`)
- Extracts AppImage contents using `--appimage-extract`
- Creates proper Debian package structure
- Includes all necessary dependencies for Cursor
- Adds desktop integration (.desktop file, icons)
- Generates post-install/remove scripts

### 3. Automated Pipeline (`.github/workflows/build-deb.yml`)
- **Daily Schedule:** Runs at 6 AM UTC every day
- **Version Comparison:** Only builds if new version detected
- **Automatic Releases:** Creates GitHub releases with .deb packages
- **Manual Trigger:** Can be triggered manually anytime

## 📋 System Requirements

- **OS:** Ubuntu 18.04+, Debian 10+, or compatible
- **Architecture:** x86_64 (amd64)
- **RAM:** 4GB+ recommended
- **Disk Space:** ~500MB for installation
- **Dependencies:** Automatically handled by package manager

## 🔧 Local Development

### Prerequisites

```bash
sudo apt-get update
sudo apt-get install -y wget curl jq fuse
```

### Build Process

```bash
# Download latest Cursor AppImage
./scripts/download-cursor.sh

# Convert to .deb package
./scripts/convert-to-deb.sh

# Or run everything at once
./build.sh
```

### Testing

```bash
# Check package info
dpkg-deb --info output/cursor_*.deb

# List package contents
dpkg-deb --contents output/cursor_*.deb

# Test installation (dry run)
sudo dpkg -i --dry-run output/cursor_*.deb
```

## 📁 Project Structure

```
cursor-appimage-to-deb/
├── .github/
│   └── workflows/
│       └── build-deb.yml          # GitHub Actions automation
├── scripts/
│   ├── download-cursor.sh         # Download latest Cursor AppImage
│   └── convert-to-deb.sh          # Convert AppImage to .deb
├── build.sh                       # One-command build script
├── README.md                      # This file
├── SETUP.md                       # Setup instructions
└── .gitignore                     # Git ignore rules
```

## 🤖 Automation Details

### Daily Builds
- **Schedule:** 6:00 AM UTC daily
- **Trigger:** Version change detection
- **Output:** Automatic GitHub release with .deb package
- **Notifications:** Build status in Actions tab

### Manual Builds
- Go to Actions tab in your repository
- Select Build Cursor .deb Package
- Click Run workflow
- Choose branch and click Run workflow

### Version Detection

```bash
# Method 1: Official API
curl -s "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

# Method 2: Filename parsing
echo "cursor-1.2.4-x86_64.AppImage" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'

# Method 3: AppImage contents
./cursor.AppImage --appimage-extract && cat squashfs-root/package.json

# Method 4: Date fallback
date +"%Y%m%d" # → 1.0.20250716
```

## 🐛 Troubleshooting

### Installation Issues

```bash
# Check package info
dpkg-deb --info cursor_*.deb

# Fix broken dependencies
sudo apt-get install -f

# Force reinstall
sudo dpkg -i --force-overwrite cursor_*.deb

# Check installation status
dpkg -l | grep cursor
```

### Build Issues

```bash
# Check dependencies
./build.sh

# Manual dependency install
sudo apt-get install wget curl jq fuse

# Debug download
./scripts/download-cursor.sh

# Debug conversion
./scripts/convert-to-deb.sh
```

### Common Problems

| Problem                        | Solution                          |
|------------------------------- |-----------------------------------|
| dpkg: dependency problems      | Run sudo apt-get install -f        |
| Permission denied              | Run chmod +x scripts/*.sh build.sh |
| AppImage won't extract         | Install sudo apt-get install fuse  |
| No .deb created                | Check build/ directory for errors  |
| GitHub Actions failing         | Check Actions logs for errors      |

## 🔄 Updating Cursor

The package will automatically check for updates daily. You can also:

### Automatic Updates
- Check the Releases section for new versions
- GitHub Actions will build new packages automatically
- Subscribe to releases for notifications

### Manual Updates
- Download the latest .deb from releases
- Install with sudo dpkg -i cursor_*.deb
- Or rebuild locally with ./build.sh

## 📊 Package Details

### What's Included
- Cursor executable in /usr/share/cursor/
- Desktop entry for application menu
- Icons in multiple sizes
- Symlink in /usr/bin/cursor
- Dependencies automatically resolved

### Package Metadata
- **Package:** cursor
- **Architecture:** amd64
- **Section:** editors
- **Priority:** optional
- **Maintainer:** Cursor Team <support@cursor.sh>
- **Homepage:** https://cursor.sh
- **Description:** The AI-first code editor

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test locally: `./build.sh`
5. Submit a pull request

### Development Guidelines
- Follow existing code style
- Test all changes locally
- Update documentation as needed
- Add error handling for new features

## 📜 License

MIT License - see LICENSE file for details.

## ⚠️ Disclaimer

This is an unofficial package converter. Cursor is developed by Anysphere. This project simply repackages the official AppImage releases into .deb format for easier installation on Debian-based systems.

We are not affiliated with Anysphere or the Cursor team.

## 🔗 Related Links
- [Official Cursor Website](https://cursor.com)
- [Cursor Downloads](https://cursor.com/downloads)
- [Cursor Documentation](https://cursor.com/docs)
- [Report Issues](../../issues)
- [GitHub Actions](../../actions)
- [Latest Release](../../releases/latest)

## 🏷️ Keywords
cursor, appimage, deb-package, ubuntu, debian, linux, cursor-ai, code-editor, package-converter, github-actions, automation, vscode, ai-editor, debian-package

## 📈 Stats

⭐ Star this repository if it helped you install Cursor on Ubuntu/Debian!

🐛 Found a bug? [Report it here](../../issues)

💡 Have a suggestion? [Open a discussion](../../discussions)

---

## 🎯 **Key SEO Features in This README:**

1. **🔍 Search Keywords**: cursor, appimage, deb, ubuntu, debian, linux
2. **📊 Badges**: Build status, downloads, version info
3. **📋 Clear Structure**: Easy to scan and understand
4. **🎯 Multiple Install Options**: Covers all user preferences
5. **🛠️ Comprehensive Docs**: Troubleshooting, development, etc.
6. **🔗 Rich Linking**: Internal and external links
7. **📈 Social Proof**: Stars, forks, download counters

## 📝 **Don't Forget:**
Replace `YOUR_USERNAME` with your actual GitHub username in:
- Badge URLs
- Download links
- Repository references

This README will help your repository rank high for searches like:
- "cursor appimage to deb"
- "cursor debian package"
- "cursor ubuntu install"
- "cursor linux deb" 