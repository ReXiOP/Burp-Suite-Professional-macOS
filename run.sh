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
echo "☕ Found Java: $JAVA_VERSION"

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

# ── Download (curl — ships with macOS) ──────────────────
LINK="https://portswigger-cdn.net/burp/releases/download?product=pro&version=$VERSION&type=jar"
JAR_FILE="Burp_Suite_Pro_${VERSION}.jar"

echo "⬇️  Downloading Burp Suite Professional v$VERSION ..."
curl -L "$LINK" -o "$JAR_FILE" --progress-bar

# Symlink latest jar
ln -sf "$JAR_FILE" Burp_Suite_Pro.jar

sleep 2

# ── Keygenerator ────────────────────────────────────────
echo "🚀 Starting Keygenerator..."
(java -jar keygen.jar) &
sleep 3

# ── Create launcher script ──────────────────────────────
INSTALL_DIR="$(pwd)"
LAUNCHER="burp"

echo "🚀 Setting up Burp Suite Pro launcher..."
cat > "$LAUNCHER" <<EOF
#!/bin/bash
java \\
  --add-opens=java.desktop/javax.swing=ALL-UNNAMED \\
  --add-opens=java.base/java.lang=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED \\
  --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED \\
  -Dfile.encoding=utf-8 \\
  -javaagent:${INSTALL_DIR}/loader.jar \\
  -noverify \\
  -jar ${INSTALL_DIR}/Burp_Suite_Pro.jar &
EOF

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
