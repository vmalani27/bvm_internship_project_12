import os
import subprocess
import sys
import time
import re

def activate_venv():
    venv_activate = os.path.join('backend', 'venv', 'Scripts', 'activate')
    if not os.path.exists(venv_activate):
        print("❌ Virtual environment not found. Please create it first.")
        sys.exit(1)
    return venv_activate

def start_flask_api():
    print("[2/4] Starting FastAPI backend in a new terminal...")
    # Use start to open a new terminal window on Windows
    subprocess.Popen(
        ['start', 'cmd', '/k', 'backend\\venv\\Scripts\\activate && python backend\\main.py'],
        shell=True
    )

def start_cloudflare_tunnel():
    print("[3/4] Starting Cloudflare Tunnel and logging to cf.log...")
    subprocess.Popen(
        ['start', 'cmd', '/c', 'backend\\venv\\Scripts\\activate && cloudflared tunnel --url http://localhost:5000 --loglevel info > cf.log'],
        shell=True
    )

def wait_for_tunnel_url(logfile='cf.log', timeout_sec=60):
    print("Waiting for tunnel URL...")
    start_time = time.time()
    url_pattern = re.compile(r'https://[^\s"]+\.trycloudflare\.com')
    while time.time() - start_time < timeout_sec:
        if os.path.exists(logfile):
            with open(logfile, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    match = url_pattern.search(line)
                    if match:
                        return match.group(0)
        time.sleep(5)
    return None

def write_env_file(public_url):
    with open('.env', 'w') as f:
        f.write(f'PUBLIC_URL={public_url}\n')
    print(f"[4/4] ✅ Tunnel URL saved to .env: {public_url}")

if __name__ == "__main__":
    print("[1/4] Activating virtual environment...")
    venv_activate = activate_venv()
    start_flask_api()
    start_cloudflare_tunnel()
    public_url = wait_for_tunnel_url()
    if public_url:
        write_env_file(public_url)
    else:
        print("❌ Failed to extract url.")