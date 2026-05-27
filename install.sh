#!/bin/sh
# IP Hunter Pro - Installer for OpenWrt
# Usage:
#   ./install.sh                    # Local install (files in current dir)
#   curl -sL URL/install.sh | sh    # Remote install (download from GitHub)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# GitHub repo (change this to your repo)
GITHUB_REPO=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --github)
            GITHUB_REPO="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

echo ""
echo "=========================================="
echo -e "  ${CYAN}🎯 IP Hunter Pro Installer${NC}"
echo "     Auto IP Switcher for OpenWrt"
echo "=========================================="
echo ""

# Detect if running from remote or local
REMOTE_MODE=false
if [ -n "$GITHUB_REPO" ]; then
    REMOTE_MODE=true
    echo -e "${YELLOW}📡 Remote install mode${NC}"
    echo -e "   Repo: ${CYAN}https://github.com/${GITHUB_REPO}${NC}"
    echo ""

    # Create temp directory
    WORK_DIR="/tmp/iphunter-install"
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"

    echo -e "${YELLOW}⬇️  Downloading files from GitHub...${NC}"

    # Download all required files
    FILES="iphunter iphunter-core iphunter-ctl iphunter.lua iphunter_view.htm install.sh"

    for file in $FILES; do
        echo -n "   Downloading $file... "
        URL="https://raw.githubusercontent.com/${GITHUB_REPO}/main/${file}"
        if curl -sL "$URL" -o "$file"; then
            echo -e "${GREEN}OK${NC}"
        else
            # Try master branch
            URL="https://raw.githubusercontent.com/${GITHUB_REPO}/master/${file}"
            if curl -sL "$URL" -o "$file"; then
                echo -e "${GREEN}OK${NC}"
            else
                echo -e "${RED}FAILED${NC}"
                echo -e "${RED}❌ Failed to download $file${NC}"
                exit 1
            fi
        fi
    done

    echo ""
elif [ ! -f "./iphunter" ] || [ ! -f "./iphunter-core" ]; then
    echo -e "${RED}❌ Error: Required files not found!${NC}"
    echo ""
    echo "Please run one of these commands:"
    echo ""
    echo -e "  ${CYAN}# Option 1: One-line install${NC}"
    echo "  curl -sL https://raw.githubusercontent.com/YOUR_USER/luci-iphunter-droid/main/install.sh | sh"
    echo ""
    echo -e "  ${CYAN}# Option 2: Clone repository first${NC}"
    echo "  git clone https://github.com/YOUR_USER/luci-iphunter-droid.git"
    echo "  cd luci-iphunter-droid && ./install.sh"
    echo ""
    exit 1
fi

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}❌ ERROR: Please run as root (sudo)${NC}"
    echo "   sudo ./install.sh"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
echo -e "${YELLOW}📦 Detected architecture: $ARCH${NC}"
echo ""

# Required packages
REQUIRED_PKGS="curl"

echo -e "${YELLOW}🔍 Checking dependencies...${NC}"
MISSING_PKGS=""
for pkg in $REQUIRED_PKGS; do
    if ! command -v $pkg &> /dev/null; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    else
        echo -e "   ${GREEN}✓${NC} $pkg installed"
    fi
done

if [ -n "$MISSING_PKGS" ]; then
    echo -e "   ${YELLOW}⚠${NC} Installing missing packages:$MISSING_PKGS"
    opkg update 2>/dev/null
    for pkg in $MISSING_PKGS; do
        opkg install $pkg 2>/dev/null && echo -e "   ${GREEN}✓${NC} $pkg installed" || echo -e "   ${RED}✗${NC} $pkg failed"
    done
fi
echo ""

# Installation paths
INSTALL_DIR="/usr/share/luci/iphunter"
INIT_DIR="/etc/init.d"
WWW_DIR="/www/luci-static/iphunter"
LUA_CONTROLLER="/usr/lib/lua/luci/controller/iphunter.lua"
LUA_VIEW="/usr/lib/lua/luci/view/iphunter_view.htm"

echo -e "${YELLOW}📂 Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$INIT_DIR"
mkdir -p "$WWW_DIR"
echo -e "   ${GREEN}✓${NC} Directories created"
echo ""

# Copy files
echo -e "${YELLOW}📋 Installing files...${NC}"

INSTALL_COUNT=0

# Main scripts
if [ -f "iphunter-core" ]; then
    cp iphunter-core "$INIT_DIR/iphunter-core"
    echo -e "   ${GREEN}✓${NC} iphunter-core"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
fi

if [ -f "iphunter" ]; then
    cp iphunter "$INIT_DIR/iphunter"
    echo -e "   ${GREEN}✓${NC} iphunter"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
fi

if [ -f "iphunter-ctl" ]; then
    cp iphunter-ctl /usr/bin/iphunter-ctl
    echo -e "   ${GREEN}✓${NC} iphunter-ctl"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
fi

# LuCI files
if [ -f "iphunter.lua" ]; then
    cp iphunter.lua "$LUA_CONTROLLER"
    echo -e "   ${GREEN}✓${NC} iphunter.lua (LuCI Controller)"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
fi

if [ -f "iphunter_view.htm" ]; then
    cp iphunter_view.htm "$LUA_VIEW"
    echo -e "   ${GREEN}✓${NC} iphunter_view.htm (Web UI)"
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
fi

echo ""
if [ "$INSTALL_COUNT" -eq 0 ]; then
    echo -e "${RED}❌ No files were installed!${NC}"
    exit 1
fi
echo ""

# Make executables
echo -e "${YELLOW}🔧 Setting permissions...${NC}"
chmod +x "$INIT_DIR/iphunter-core" 2>/dev/null && echo -e "   ${GREEN}✓${NC} iphunter-core executable" || true
chmod +x "$INIT_DIR/iphunter" 2>/dev/null && echo -e "   ${GREEN}✓${NC} iphunter executable" || true
chmod +x /usr/bin/iphunter-ctl 2>/dev/null && echo -e "   ${GREEN}✓${NC} iphunter-ctl executable" || true
echo ""

# Enable service
echo -e "${YELLOW}⚙️  Enabling service...${NC}"
/etc/init.d/iphunter enable 2>/dev/null && echo -e "   ${GREEN}✓${NC} Service enabled on boot" || echo -e "   ${YELLOW}⚠${NC} Service enable skipped"
echo ""

# Create default config if not exists
if [ ! -f "/tmp/ip_hunter_range.conf" ]; then
    echo "0-9 130-159" > /tmp/ip_hunter_range.conf
    echo -e "   ${GREEN}✓${NC} Default config created"
fi

# Create log file
if [ ! -f "/tmp/ip_hunter.log" ]; then
    touch /tmp/ip_hunter.log
    echo -e "   ${GREEN}✓${NC} Log file created"
fi

# Clear LuCI cache
echo ""
echo -e "${YELLOW}🗑️  Clearing LuCI cache...${NC}"
rm -rf /tmp/luci-* 2>/dev/null
echo -e "   ${GREEN}✓${NC} Cache cleared"

# Cleanup temp files if remote install
if [ "$REMOTE_MODE" = true ]; then
    cd /
    rm -rf "$WORK_DIR"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}✅ INSTALLATION COMPLETE!${NC}"
echo "=========================================="
echo ""
echo "📌 Quick Commands:"
echo ""
echo "   ${CYAN}Start:${NC}    /etc/init.d/iphunter start"
echo "   ${CYAN}Stop:${NC}     /etc/init.d/iphunter stop"
echo "   ${CYAN}Status:${NC}   /etc/init.d/iphunter status"
echo "   ${CYAN}Restart:${NC}  /etc/init.d/iphunter restart"
echo "   ${CYAN}Log:${NC}      iphunter-ctl log"
echo "   ${CYAN}Web UI:${NC}   http://<router-ip>/cgi-bin/luci/admin/status/iphunter"
echo ""
echo -e "${YELLOW}⚠️  NEXT STEPS:${NC}"
echo "   1. Setup ADB server on your Android device"
echo "   2. Make sure ADB can connect from router"
echo "   3. Configure IP range via Web UI"
echo "   4. Start the service: /etc/init.d/iphunter start"
echo ""