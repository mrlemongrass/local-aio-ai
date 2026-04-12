import time, os, requests, sys
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# These will be prompted for or read from a .env file
API_KEY = os.getenv("WEBUI_API_KEY", "YOUR_API_KEY_HERE")
KNOWLEDGE_ID = os.getenv("KNOWLEDGE_ID", "YOUR_KNOWLEDGE_ID_HERE")
WATCH_PATH = sys.argv[1] if len(sys.argv) > 1 else "./library"

class NewFileHandler(FileSystemEventHandler):
    def on_created(self, event):
        if not event.is_directory and event.src_path.lower().endswith(".pdf"):
            print(f"📄 Processing: {os.path.basename(event.src_path)}")
            self.sync(event.src_path)

    def sync(self, path):
        try:
            # 1. Upload
            with open(path, 'rb') as f:
                r = requests.post("http://localhost:3000/api/v1/files/", 
                                 files={'file': f}, 
                                 headers={"Authorization": f"Bearer {API_KEY}"})
            f_id = r.json().get('id')
            # 2. Assign to Knowledge
            requests.post(f"http://localhost:3000/api/v1/knowledge/{KNOWLEDGE_ID}/file/add", 
                         json={"file_id": f_id}, 
                         headers={"Authorization": f"Bearer {API_KEY}"})
            print(f"✅ Context Synced!")
        except Exception as e:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    observer = Observer()
    observer.schedule(NewFileHandler(), WATCH_PATH, recursive=True)
    observer.start()
    print(f"👀 Watching for PDFs in {WATCH_PATH}...")
    try:
        while True: time.sleep(1)
    except KeyboardInterrupt: observer.stop()
