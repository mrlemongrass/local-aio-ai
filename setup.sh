#!/bin/zsh

# --- COLORING & BRANDING ---
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=================================================="
echo -e "       ULTIMATE ALL-IN-ONE LOCAL AI LAB INSTALLER"
echo -e "==================================================${NC}"

# --- FUNCTION: SYSTEM CHECKS ---
check_tool() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}⚠️  $1 is not installed.${NC}"
        return 1
    else
        echo -e "✅ $1 is ready."
        return 0
    fi
}

# --- 1. PRE-CHECKS ---
echo -e "\n${BLUE}[1/5] Checking System Prerequisites...${NC}"

if ! check_tool "brew"; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

check_tool "docker" || (echo -e "${RED}Please install Docker Desktop from https://www.docker.com/products/docker-desktop/ and restart this script.${NC}" && exit 1)
check_tool "python3" || brew install python
check_tool "git" || brew install git

# --- 2. HARDWARE DETECTION ---
echo -e "\n${BLUE}[2/5] Analyzing Hardware for AI Capability...${NC}"
CHIP=$(sysctl -n machdep.cpu.brand_string)
RAM=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))

echo -e "Found: ${GREEN}$CHIP with $RAM GB RAM${NC}"

# Logic for Model Recommendations
if [[ $RAM -ge 120 ]]; then
    SUGGESTION="Gemma 4 31B (F16 Precision) - Absolute Peak Quality"
    MODEL_HF="ggml-org/gemma-4-31B-it-GGUF:F16"
elif [[ $RAM -ge 64 ]]; then
    SUGGESTION="Gemma 4 31B (Q8_0) - Pro Performance"
    MODEL_HF="ggml-org/gemma-4-31B-it-GGUF:Q8_0"
elif [[ $RAM -ge 32 ]]; then
    SUGGESTION="Gemma 4 31B (Q4_K_M) - Fast & Smart"
    MODEL_HF="ggml-org/gemma-4-31B-it-GGUF:Q4_K_M"
else
    SUGGESTION="Llama 3.1 8B - Lightweight & Efficient"
    MODEL_HF="bartowski/Llama-3.1-8B-Instruct-GGUF:Q8_0"
fi

echo -e "\n${YELLOW}PRO-TIP:${NC} Based on your $CHIP, I recommend: ${GREEN}$SUGGESTION${NC}"
read "CONFIRM_MODEL?Install this model? [y/N]: "
if [[ $CONFIRM_MODEL != "y" ]]; then echo "Aborted."; exit 1; fi

# --- 3. STORAGE SETUP ---
echo -e "\n${BLUE}[3/5] Configuring Storage...${NC}"
DEFAULT_STORAGE="$HOME/ai-lab-data"
echo -e "Where should we store models and research (60GB+ recommended)?"
echo -e "Default: ${GREEN}$DEFAULT_STORAGE${NC}"
read "USER_STORAGE?Enter path (or press Enter for default): "
DATA_DIR=${USER_STORAGE:-$DEFAULT_STORAGE}

mkdir -p "$DATA_DIR/models" "$DATA_DIR/webui-data" "$DATA_DIR/library"
echo -e "✅ Data hub created at $DATA_DIR"

# --- 4. PYTHON SANDBOX (VENV) ---
echo -e "\n${BLUE}[4/5] Setting up Isolated Python Sandbox...${NC}"
VENV_PATH="$HOME/.ai-lab-venv"
python3 -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"
pip install -r requirements.txt

# Create .env template for the watcher script
ENV_FILE="$VENV_PATH/.env"
echo "WEBUI_API_KEY=YOUR_API_KEY_HERE" > "$ENV_FILE"
echo "KNOWLEDGE_ID=YOUR_KNOWLEDGE_ID_HERE" >> "$ENV_FILE"

echo -e "✅ Sandbox created at $VENV_PATH"
echo -e "✅ Watcher configuration file created at $ENV_FILE"

# --- 5. DOCKER LAUNCH ---
echo -e "\n${BLUE}[5/5] Launching UI and PDF Vision Engine...${NC}"
export DATA_PATH="$DATA_DIR"
docker compose up -d

# --- 6. REMOTE ACCESS CONFIGURATION ---
echo -e "\n${BLUE}[6/6] Configuring Remote Access (Optional)...${NC}"
echo -e "How would you like to access your AI Lab remotely?"
echo -e "1) ${GREEN}Tailscale${NC} (Easiest - Works behind firewalls/NAT)"
echo -e "2) ${GREEN}WireGuard${NC} (Highest Performance - Requires Port Forwarding)"
echo -e "3) ${YELLOW}Skip${NC} (Local Access Only)"
read "REMOTE_CHOICE?Select an option [1-3]: "

case $REMOTE_CHOICE in
    1)
        echo -e "Installing Tailscale..."
        brew install --cask tailscale
        echo -e "${YELLOW}Next Step:${NC} Open Tailscale from Applications and sign in to join your mesh network."
        ;;
    2)
        echo -e "Installing WireGuard Tools..."
        brew install wireguard-tools
        echo -e "${YELLOW}Pro Tip:${NC} You will need to manage your own keys and open UDP port 51820 on your router."
        echo -e "Check ${BLUE}https://www.wireguard.com/install/${NC} for advanced macOS server config."
        ;;
    3)
        echo -e "Skipping remote access setup."
        ;;
    *)
        echo -e "${RED}Invalid selection. Skipping.${NC}"
        ;;
esac

echo -e "\n${GREEN}=================================================="
echo -e "       SETUP SUCCESSFUL!"
echo -e "==================================================${NC}"
echo -e "1. UI is running at: http://localhost:3000"
echo -e "2. Run this command to start your AI Brain:"
echo -e "${YELLOW}   llama-server -hf $MODEL_HF --port 8080 -ngl 99 -c 131072 --flash-attn on${NC}"
echo -e "3. Drop PDFs into: $DATA_DIR/library"
echo -e "4. Edit $ENV_FILE with your WebUI keys to activate the Watcher script."
