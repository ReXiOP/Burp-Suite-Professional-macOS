<h1 align="center">🔥 Burp Suite Professional for macOS 🔥</h1>

<p align="center">
  <img src="https://img.shields.io/badge/BurpSuite-Pro%20Installer-orange?style=for-the-badge&logo=burpsuite" />
  <img src="https://img.shields.io/badge/Platform-macOS-blue?style=for-the-badge&logo=apple" />
  <img src="https://img.shields.io/badge/Language-Bash-green?style=for-the-badge&logo=gnu-bash" />
</p>

<p align="center">
  <b>One-click Burp Suite Pro installer for macOS with multi-version support.</b><br/>
  <i>Powered by Bash • Built for speed • Made for security enthusiasts</i>
</p>

---

## 🚀 Features

* ⚡ Multi-Version Support – Pick any Burp Suite Pro version from a menu
* ☕ JDK 21+ Ready – Works with the latest Java runtime
* 🖥️ macOS-Friendly – Tested on macOS Monterey / Ventura / Sonoma
* 🔑 Built-in Keygen & Loader – Automatically configured
* 🟢 Reusable Launcher – Start Burp anytime with `burp` command

---

## 📦 1. Install Java JDK 21+

### Option A: Oracle JDK (Recommended)

1. Download **JDK 21** for macOS:
   👉 [Java SE 21 Downloads – Oracle](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)

2. Open the downloaded `.dmg` file and double-click **`JDK 21.pkg`** to install.

3. Verify installation:

```bash
java -version
```

![Installation GIF](https://example.com/install.gif)

---

### Option B: Homebrew

```bash
brew install openjdk@21
sudo ln -sfn $(brew --prefix openjdk@21)/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
java -version
```

---

## 💻 2. Clone & Prepare the Project

```bash
git clone https://github.com/ReXiOP/Burp-Suite-Professional-macOS
cd Burp-Suite-Professional-macOS
chmod +x *
```

---

## ⚙️ 3. Run the Installer

```bash
sudo ./run.sh
```



---

## ▶️ 4. Launch Burp Suite Anytime

```bash
./burp
```

or (if copied to PATH)

```bash
burp
```

---

## 🔄 5. Update / Switch Version

```bash
sudo ./run.sh
```

---

## 📂 Project Structure

```
Burp-Suite-Professional-macOS/
├── run.sh
├── burp
├── loader.jar
├── keygen.jar
└── Burp_Suite_Pro_*.jar
```

---

## ⚠️ Disclaimer

* For **testing/educational use only**.
* Comply with [PortSwigger’s Licensing](https://portswigger.net/burp/pro).

---

## 👨‍💻 Developer

<p align="center">
  <b>Developed by:</b> <a href="https://github.com/ReXiOP">Muhammad Sajid</a> <br/>
  💻 Full-Stack Developer | Security Enthusiast | Automation Lover
</p>

<p align="center">
  <a href="mailto:youremail@example.com"><img src="https://img.shields.io/badge/Email-Contact%20Me-red?style=flat-square&logo=gmail"></a>
  <a href="https://github.com/ReXiOP"><img src="https://img.shields.io/github/followers/ReXiOP?style=flat-square&logo=github"></a>
</p>

<p align="center">
  ⭐ Star this repo if you find it useful!
</p>
