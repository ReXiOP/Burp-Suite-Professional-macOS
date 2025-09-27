#!/bin/bash


set -euo pipefail

echo "
┌─────────────┐
│┏━┓┏━┓ ┏┓╻╺┳┓│
│┗━┓┣━┫  ┃┃ ┃┃│
│┗━┛╹ ╹┗━┛╹╺┻┛│
└─────────────┘
"


if [[ $EUID -ne 0 ]]; then
    echo "❌ Please run this script with sudo."
    exit 1
fi


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

LINK="https://portswigger-cdn.net/burp/releases/download?product=pro&version=$VERSION&type=jar"
echo "⬇️  Downloading Burp Suite Professional v$VERSION ..."
wget "$LINK" -O "Burp_Suite_Pro_${VERSION}.jar" --quiet --show-progress

# Use latest jar as default
ln -sf "Burp_Suite_Pro_${VERSION}.jar" Burp_Suite_Pro.jar

sleep 2


echo "🚀 Starting Keygenerator..."
(java -jar keygen.jar) &
sleep 3

echo "🚀 Setting up Burp Suite Pro launcher..."
cat > burp <<EOF
#!/bin/bash
java --illegal-access=permit -Dfile.encoding=utf-8 -javaagent:$(pwd)/loader.jar -noverify -jar $(pwd)/Burp_Suite_Pro.jar &
EOF

chmod +x burp
cp burp /usr/local/bin/burp  
./burp

echo -e "\n✅ Burp Suite Pro v$VERSION launched successfully!"
echo "👉 You can run 'burp' anytime to start it."

echo "
To update later:
  1. Run this script again and choose a different version.
  2. It will download and link the selected version automatically.
"
