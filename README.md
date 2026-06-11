<div align="center">

<!-- Title Block -->
<img src="https://img.shields.io/badge/%E2%9A%A1-BURP%20SUITE%20PRO-FF6633?style=for-the-badge&labelColor=1a1a2e" height="40"/>

# Burp Suite Professional — macOS

**One-command installer & launcher for Burp Suite Professional on macOS**
<br/>
*Supports Apple Silicon (M1/M2/M3/M4) and Intel Macs*

<br/>

[![macOS](https://img.shields.io/badge/macOS-Sonoma%20|%20Ventura%20|%20Monterey-000000?style=for-the-badge&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Java](https://img.shields.io/badge/Java-21+-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)](https://adoptium.net/)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/License-Educational-blue?style=for-the-badge)](LICENSE)

<br/>

<img src="https://img.shields.io/github/stars/ReXiOP/Burp-Suite-Professional-macOS?style=social" />
&nbsp;
<img src="https://img.shields.io/github/forks/ReXiOP/Burp-Suite-Professional-macOS?style=social" />
&nbsp;
<img src="https://img.shields.io/github/watchers/ReXiOP/Burp-Suite-Professional-macOS?style=social" />

</div>

<br/>

---

<br/>

## ✨ Highlights

<table>
<tr>
<td width="50%">

### 🚀 Zero-Config Setup
Single command to download, configure, and launch.
No manual JAR wrangling or classpath headaches.

</td>
<td width="50%">

### 🍎 Native macOS Support
Auto-detects **Apple Silicon** vs **Intel** architecture
and installs the launcher to the correct `bin` directory.

</td>
</tr>
<tr>
<td width="50%">

### ☕ Modern Java Compatibility
Uses `--add-opens` JVM flags instead of the deprecated
`--illegal-access=permit` — works with **JDK 17, 21, 22+**.

</td>
<td width="50%">

### 🔄 Multi-Version Manager
Choose from pre-listed versions or enter any custom version.
Switch versions anytime by re-running the installer.

</td>
</tr>
</table>

<br/>

---

<br/>

## 📋 Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| **macOS** | Monterey 12.0 | Sonoma 15+ |
| **Java JDK** | **21** | 21+ (Temurin / Oracle) |
| **Disk Space** | ~500 MB | 1 GB |
| **Architecture** | Intel x86_64 | Apple Silicon arm64 |

<br/>

---

<br/>

## 🛠️ Installation

### Step 1 — Install Java

<details>
<summary><b>Option A: Homebrew (Recommended)</b></summary>

```bash
# Eclipse Temurin JDK 21+ (open-source, well-maintained)
brew install --cask temurin

# Verify
java -version
```

</details>

<details>
<summary><b>Option B: Oracle JDK</b></summary>

1. Download **JDK 21** for macOS from [Oracle](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)
2. Open the `.dmg` → double-click `JDK 21.pkg`
3. Verify:

```bash
java -version
```

</details>

<br/>

### Step 2 — Clone & Run

```bash
git clone https://github.com/ReXiOP/Burp-Suite-Professional-macOS.git
cd Burp-Suite-Professional-macOS
chmod +x run.sh
sudo ./run.sh
```

You'll see an interactive menu:

```
┌─────────────┐
│┏━┓┏━┓ ┏┓╻╺┳┓│
│┗━┓┣━┫  ┃┃ ┃┃│
│┗━┛╹ ╹┗━┛╹╺┻┛│
└─────────────┘

Available Burp Suite Pro Versions:
1) 2025.5.6  (latest)
2) 2025.5.5
3) 2025.4.2
4) 2025.3.1
5) 2024.12.2
6) Custom version

Select version [1-6]:
```

The script will:
1. ⬇️  Download the selected JAR from PortSwigger CDN
2. 🔑  Launch the keygenerator
3. 🚀  Create and install a global `burp` launcher
4. ▶️  Start Burp Suite Professional

<br/>

### Step 3 — Launch Anytime

```bash
burp
```

> The launcher is installed to `/opt/homebrew/bin/burp` (Apple Silicon) or `/usr/local/bin/burp` (Intel).

<br/>

---

<br/>

## 📂 Project Structure

```
Burp-Suite-Professional-macOS/
│
├── run.sh                      # Main installer & setup script
├── loader.jar                  # Java agent loader
├── keygen.jar                  # License key generator
├── README.md                   # This file
├── _config.yml                 # GitHub Pages config
│
├── assets/
│   └── css/                    # Styling assets
│
└── (generated at runtime)
    ├── Burp_Suite_Pro_*.jar    # Downloaded Burp Suite JAR
    ├── Burp_Suite_Pro.jar      # Symlink → latest version
    └── burp                    # Launcher script
```

<br/>

---

<br/>

## 🔄 Updating / Switching Versions

Simply re-run the installer and pick a different version:

```bash
sudo ./run.sh
```

The script automatically:
- Downloads the new version
- Updates the symlink to point to the latest JAR
- Rebuilds the launcher

> **Tip:** Previous JAR files are kept so you can manually switch back if needed.

<br/>

---

<br/>

## 🐛 Troubleshooting

<details>
<summary><b>❌ "Java is not installed"</b></summary>

```bash
brew install --cask temurin
```

Or download from [adoptium.net](https://adoptium.net/).

</details>

<details>
<summary><b>❌ UnsupportedClassVersionError (class file version 65.0)</b></summary>

This means Burp Suite was compiled for **Java 21** but you're running an older version.

```bash
# Check your current version
java -version

# Upgrade to Java 21+
brew install --cask temurin
```

After upgrading, verify:
```bash
java -version
# Should show: openjdk version "21.x.x" or higher
```

</details>

<details>
<summary><b>❌ "Permission denied"</b></summary>

Make sure you're running with `sudo`:

```bash
sudo ./run.sh
```

</details>

<details>
<summary><b>❌ Burp fails to start on Apple Silicon</b></summary>

Ensure you're running an **arm64-native** JDK, not an x86 one under Rosetta:

```bash
file $(which java)
# Should show: Mach-O 64-bit executable arm64
```

If not, reinstall with Homebrew:

```bash
brew install --cask temurin
```

</details>

<details>
<summary><b>❌ "burp: command not found"</b></summary>

The launcher wasn't added to your PATH. Run:

```bash
# Apple Silicon
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Intel
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

</details>

<br/>

---

<br/>

## ⚙️ How It Works

```
sudo ./run.sh
       │
       ▼
┌──────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Java Check  │────▶│  Download JAR    │────▶│  Keygen      │
│  + Arch Detect│     │  (curl from CDN) │     │  (background)│
└──────────────┘     └─────────────────┘     └──────┬───────┘
                                                     │
                                                     ▼
                     ┌─────────────────┐     ┌──────────────┐
                     │  Install to     │◀────│  Create      │
                     │  /opt/homebrew  │     │  Launcher    │
                     │  or /usr/local  │     │  Script      │
                     └─────────────────┘     └──────────────┘
```



<br/>

---

<br/>

## ⚠️ Disclaimer

> **This project is provided for educational and authorized security testing purposes only.**
>
> By using this software, you agree to comply with all applicable laws and
> [PortSwigger's licensing terms](https://portswigger.net/burp/pro).
> The authors assume no liability for misuse.

<br/>

---

<br/>

<div align="center">

## 👨‍💻 Author

**Muhammad Sajid** — [@ReXiOP](https://github.com/ReXiOP)

💻 Full-Stack Developer &nbsp;·&nbsp; 🔒 Security Enthusiast &nbsp;·&nbsp; ⚡ Automation Lover

<br/>

[![Email](https://img.shields.io/badge/Email-dev.sajid09@gmail.com-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:dev.sajid09@gmail.com)
[![GitHub](https://img.shields.io/badge/GitHub-ReXiOP-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ReXiOP)

<br/>

---

<br/>

**If this project helped you, consider giving it a ⭐**

<br/>

<img src="https://img.shields.io/github/stars/ReXiOP/Burp-Suite-Professional-macOS?style=for-the-badge&color=yellow&logo=github" />

</div>
