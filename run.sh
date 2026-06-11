#!/bin/bash

# ─────────────────────────────────────────────────────────
#  Burp Suite Professional — macOS Installer & Launcher
# ─────────────────────────────────────────────────────────

set -euo pipefail

echo -e "\e[1;36m"
echo " ┌──────────────────────────────────────────────┐ "
echo " │  ____                  ____        _ _       │ "
echo " │ | __ ) _   _ _ __ _ __/ ___| _   _(_) |_ ___ │ "
echo " │ |  _ \| | | | '__| '_ \___ \| | | | | __/ _ \│ "
echo " │ | |_) | |_| | |  | |_) |__) | |_| | | ||  __/│ "
echo " │ |____/ \__,_|_|  | .__/____/ \__,_|_|\__\___|│ "
echo " │                  |_|                         │ "
echo " │            P R O F E S S I O N A L           │ "
echo " ├──────────────────────────────────────────────┤ "
echo " │           ✨ macOS Installer ✨            │ "
echo " │        Developed by Muhammad Sajid           │ "
echo " │                 (@ReXiOP)                    │ "
echo " └──────────────────────────────────────────────┘ "
echo -e "\e[0m"

echo "⚠️  IMPORTANT NOTE:"
echo "   The automatic downloader is currently NOT WORKING due to PortSwigger changes."
echo "   Please download the JAR file manually from:"
echo "   👉 https://portswigger.net/burp/releases"
echo "   Then select option 7 in the menu below to provide the local file path."
echo "─────────────────────────────────────────────────────────"
echo ""

if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "⚠️  This script is designed for macOS."
    echo "   Detected OS: $(uname -s)"
    read -rp "Continue anyway? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script with sudo."
    exit 1
fi

if ! command -v java &>/dev/null; then
    echo "❌ Java is not installed."
    echo ""
    echo "   Install it with Homebrew:"
    echo "     brew install --cask temurin"
    echo ""
    echo "   Or download from: https://adoptium.net"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 | awk -F '"' '{print $2}')
JAVA_MAJOR=$(echo "$JAVA_VERSION" | awk -F'.' '{print $1}')
echo "☕ Found Java: $JAVA_VERSION"

if [[ "$JAVA_MAJOR" -lt 21 ]]; then
    echo ""
    echo "❌ Java 21 or higher is required (you have Java $JAVA_MAJOR)."
    echo "   Burp Suite 2025.x is compiled for Java 21 (class file v65)."
    echo ""
    echo "   Upgrade with Homebrew:"
    echo "     brew install --cask temurin"
    echo ""
    echo "   Or download from: https://adoptium.net"
    exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    echo "🍎 Running on Apple Silicon (arm64)"
    BIN_DIR="/opt/homebrew/bin"
else
    echo "💻 Running on Intel Mac (x86_64)"
    BIN_DIR="/usr/local/bin"
fi
mkdir -p "$BIN_DIR"

echo "🔍 Fetching latest Burp Suite versions..."

VERSIONS=()
RAW=$(curl -sL "https://portswigger.net/burp/releases" 2>/dev/null \
    | grep -oE '[0-9]{4}\.[0-9]+\.[0-9]+' \
    | sort -t. -k1,1nr -k2,2nr -k3,3nr \
    | awk '!seen[$0]++' \
    | head -5)

if [[ -n "$RAW" ]]; then
    while IFS= read -r v; do
        VERSIONS+=("$v")
    done <<< "$RAW"
    echo "✅ Fetched ${#VERSIONS[@]} versions from portswigger.net"
else
    echo "⚠️  Could not fetch versions online — using fallback list."
    VERSIONS=("2025.5.6" "2025.5.5" "2025.4.2" "2025.3.1" "2024.12.2")
fi

echo ""
echo "Available Burp Suite Pro Versions:"
for i in "${!VERSIONS[@]}"; do
    label="${VERSIONS[$i]}"
    if [[ $i -eq 0 ]]; then label="$label  (latest)"; fi
    echo "  $((i+1))) $label"
done
echo "  $((${#VERSIONS[@]}+1))) Custom version (download manually)"
echo "  $((${#VERSIONS[@]}+2))) Use local JAR file (enter path manually)"
echo ""

read -rp "Select option [1-$((${#VERSIONS[@]}+2))]: " choice

LOCAL_JAR_MODE=false
VERSION="Custom"

if [[ "$choice" -ge 1 && "$choice" -le ${#VERSIONS[@]} ]] 2>/dev/null; then
    VERSION="${VERSIONS[$((choice-1))]}"
elif [[ "$choice" -eq $((${#VERSIONS[@]}+1)) ]] 2>/dev/null; then
    read -rp "Enter the version to download (e.g., 2023.12.1): " VERSION
elif [[ "$choice" -eq $((${#VERSIONS[@]}+2)) ]] 2>/dev/null; then
    LOCAL_JAR_MODE=true
    read -rp "Enter the full path to your Burp Suite JAR file: " LOCAL_JAR_PATH
else
    echo "Invalid option. Exiting."
    exit 1
fi

if [[ "$LOCAL_JAR_MODE" == false ]]; then
    echo "✅ Selected Burp Suite version: $VERSION"
fi

LINK="https://portswigger.net/burp/releases/startdownload?product=pro&version=$VERSION&type=jar"
JAR_FILE="Burp_Suite_Pro_${VERSION}.jar"

if [[ "$LOCAL_JAR_MODE" == true ]]; then
    if [[ -f "$LOCAL_JAR_PATH" ]]; then
        if head -c 2 "$LOCAL_JAR_PATH" | grep -q "PK"; then
            echo "✅ Using local JAR file: $LOCAL_JAR_PATH"
            ln -sf "$LOCAL_JAR_PATH" Burp_Suite_Pro.jar
        else
            echo "❌ The provided file is not a valid JAR/ZIP archive."
            exit 1
        fi
    else
        echo "❌ File not found: $LOCAL_JAR_PATH"
        exit 1
    fi
else
    NEED_DOWNLOAD=true

    if [[ -f "$JAR_FILE" ]]; then
        if head -c 2 "$JAR_FILE" | grep -q "PK"; then
            FILE_SIZE=$(du -h "$JAR_FILE" | awk '{print $1}')
            echo ""
            echo "📦 Found existing JAR: $JAR_FILE ($FILE_SIZE)"
            read -rp "   Re-download? [y/N]: " redownload
            if [[ "$redownload" =~ ^[Yy]$ ]]; then
                NEED_DOWNLOAD=true
            else
                NEED_DOWNLOAD=false
                echo "⏩ Skipping download — using existing JAR."
            fi
        else
            echo "⚠️  Existing file is corrupted. Re-downloading..."
            rm -f "$JAR_FILE"
        fi
    fi

    if [[ "$NEED_DOWNLOAD" == true ]]; then
        echo "⬇️  Downloading Burp Suite Professional v$VERSION ..."
        curl -L "$LINK" -o "$JAR_FILE" --progress-bar

        if ! head -c 2 "$JAR_FILE" | grep -q "PK"; then
            echo ""
            echo "❌ Download failed — version $VERSION does not exist!"
            echo "   PortSwigger returned an HTML page instead of a JAR file."
            echo ""
            echo "   Check available versions at:"
            echo "   https://portswigger.net/burp/releases"
            rm -f "$JAR_FILE"
            exit 1
        fi

        FILE_SIZE=$(du -h "$JAR_FILE" | awk '{print $1}')
        echo "✅ Downloaded successfully ($FILE_SIZE)"
    fi

   
    ln -sf "$JAR_FILE" Burp_Suite_Pro.jar
fi

sleep 1

echo "🚀 Starting Keygenerator..."
(java -jar keygen.jar) &
sleep 3

INSTALL_DIR="$(pwd)"
LAUNCHER="burp"

echo "🚀 Setting up Burp Suite Pro launcher..."
cat > "$LAUNCHER" <<'EOF'
#!/bin/bash
java \
  --add-opens=java.desktop/javax.swing=ALL-UNNAMED \
  --add-opens=java.base/java.lang=ALL-UNNAMED \
  --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \
  --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \
  -Dfile.encoding=utf-8 \
  -javaagent:INSTALL_DIR_PLACEHOLDER/loader.jar \
  -jar INSTALL_DIR_PLACEHOLDER/Burp_Suite_Pro.jar &
EOF

sed -i '' "s|INSTALL_DIR_PLACEHOLDER|${INSTALL_DIR}|g" "$LAUNCHER"

chmod +x "$LAUNCHER"
cp "$LAUNCHER" "$BIN_DIR/burp"
./"$LAUNCHER"

echo ""
echo "✅ Burp Suite Pro v$VERSION launched successfully!"
echo "👉 You can run 'burp' anytime from your terminal."
echo ""
echo "   Launcher installed to: $BIN_DIR/burp"
echo ""
echo "To update later:"
echo "  1. Run this script again and choose a different version."
echo "  2. It will download and link the selected version automatically."
echo ""
