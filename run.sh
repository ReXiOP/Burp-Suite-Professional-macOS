#!/bin/bash

# ─────────────────────────────────────────────────────────
#  Burp Suite Professional — macOS Installer & Launcher
# ─────────────────────────────────────────────────────────

set -euo pipefail

echo "
┌─────────────┐
│┏━┓┏━┓ ┏┓╻╺┳┓│
│┗━┓┣━┫  ┃┃ ┃┃│
│┗━┛╹ ╹┗━┛╹╺┻┛│
└─────────────┘
"

# ── macOS check ──────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo "⚠️  This script is designed for macOS."
    echo "   Detected OS: $(uname -s)"
    read -rp "Continue anyway? [y/N]: " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

# ── Root / sudo check ───────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script with sudo."
    exit 1
fi

# ── Java check ──────────────────────────────────────────
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

# ── Detect architecture ────────────────────────────────
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    echo "🍎 Running on Apple Silicon (arm64)"
    BIN_DIR="/opt/homebrew/bin"
else
    echo "💻 Running on Intel Mac (x86_64)"
    BIN_DIR="/usr/local/bin"
fi
mkdir -p "$BIN_DIR"

# ── Version selection ───────────────────────────────────
show_versions() {
    cat <<EOF

Available Burp Suite Pro Versions:
1) 2025.5.6  (latest as of now)
2) 2025.5.5
3) 2025.4.2
4) 2025.3.1
5) 2024.12.2
6) Custom version (enter manually)

EOF
}

show_versions
read -rp "Select version [1-6]: " choice

case "$choice" in
    1) VERSION="2025.5.6" ;;
    2) VERSION="2025.5.5" ;;
    3) VERSION="2025.4.2" ;;
    4) VERSION="2025.3.1" ;;
    5) VERSION="2024.12.2" ;;
    6) read -rp "Enter the version (e.g., 2023.12.1): " VERSION ;;
    *) echo "Invalid option. Exiting."; exit 1 ;;
esac

echo "✅ Selected Burp Suite version: $VERSION"

# ── Fast download helper ────────────────────────────────
fast_download() {
    local url="$1"
    local output="$2"

    if command -v aria2c &>/dev/null; then
        echo "   ⚡ Using aria2c (multi-connection download)"
        aria2c -x 16 -s 16 -k 1M \
            --file-allocation=none \
            --console-log-level=warn \
            --summary-interval=3 \
            -o "$output" "$url"
    else
        echo "   💡 Tip: Install aria2 for 5-10x faster downloads:"
        echo "      brew install aria2"
        echo ""
        curl -L "$url" -o "$output" --progress-bar \
            --retry 3 --retry-delay 2 --connect-timeout 15
    fi
}

# ── Check for existing JAR / Download ───────────────────
LINK="https://portswigger-cdn.net/burp/releases/download?product=pro&version=$VERSION&type=jar"
JAR_FILE="Burp_Suite_Pro_${VERSION}.jar"

if [[ -f "$JAR_FILE" ]]; then
    FILE_SIZE=$(du -h "$JAR_FILE" | awk '{print $1}')
    echo ""
    echo "📦 Found existing JAR: $JAR_FILE ($FILE_SIZE)"
    read -rp "   Re-download? [y/N]: " redownload
    if [[ "$redownload" =~ ^[Yy]$ ]]; then
        echo "⬇️  Re-downloading Burp Suite Professional v$VERSION ..."
        fast_download "$LINK" "$JAR_FILE"
    else
        echo "⏩ Skipping download — using existing JAR."
    fi
else
    echo "⬇️  Downloading Burp Suite Professional v$VERSION ..."
    fast_download "$LINK" "$JAR_FILE"
fi

# Symlink latest jar
ln -sf "$JAR_FILE" Burp_Suite_Pro.jar

sleep 1

# ── Keygenerator ────────────────────────────────────────
echo "🚀 Starting Keygenerator..."
(java -jar keygen.jar) &
sleep 3

# ── Create launcher script ──────────────────────────────
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

# Replace placeholder with actual install dir
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
