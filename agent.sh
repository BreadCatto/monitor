#!/bin/bash

set -e

# Variables
APP_DIR="/etc/dstats"
VENV_DIR="$APP_DIR/venv"
SERVICE_NAME="dstats"
AGENT_URL="https://raw.githubusercontent.com/BreadCatto/monitor/refs/heads/main/agent.py"
REQS_URL="https://raw.githubusercontent.com/BreadCatto/monitor/refs/heads/main/requirements.txt"

# Get user input for config
echo "Enter Agent ID (e.g., IN-01):"
read AGENT_ID

echo "Enter API Key:"
read -s API_KEY

echo "Enter Base API URL (e.g., https://yourdomain.com):"
read BASE_URL

# Normalize the URL (remove trailing slash if present)
BASE_URL="${BASE_URL%/}"
FULL_API_URL="$BASE_URL/update"

# Create app directory
echo "[+] Creating application directory at $APP_DIR"
sudo mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Download agent.py
echo "[+] Downloading agent.py from GitHub"
sudo curl -fsSL "$AGENT_URL" -o agent.py

# Download requirements.txt
echo "[+] Downloading requirements.txt from GitHub"
sudo curl -fsSL "$REQS_URL" -o requirements.txt

# Create config.json
echo "[+] Creating config.json"
sudo tee config.json > /dev/null <<EOF
{
    "id": "$AGENT_ID",
    "API_KEY": "$API_KEY",
    "API_URL": "$FULL_API_URL"
}
EOF

# Set up virtual environment
echo "[+] Creating virtual environment"
python3 -m venv "$VENV_DIR"

echo "[+] Installing dependencies"
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install -r requirements.txt

# Set up systemd service
echo "[+] Creating systemd service"
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=Dstats Python Agent
After=network.target

[Service]
Type=simple
ExecStart=$VENV_DIR/bin/python $APP_DIR/agent.py
WorkingDirectory=$APP_DIR
Restart=always
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start service
echo "[+] Reloading systemd daemon"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "[+] Enabling and starting $SERVICE_NAME"
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "[✓] Installation complete. Check status with: sudo systemctl status $SERVICE_NAME"
