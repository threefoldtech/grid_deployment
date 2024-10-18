import requests
import os
import time
import sys

class KernelSync:
    def __init__(self, baseurl, targetdir):
        self.baseurl = baseurl
        self.targetdir = targetdir

    def fetchlist(self):
        data = requests.get(f"{self.baseurl}/api/images")
        klist = data.json()

        return klist

    def download(self, source, sourcetime):
        url = f"{self.baseurl}/kernel/{source}"
        local = f"{self.targetdir}/{source}"

        with requests.get(url, stream=True) as r:
            r.raise_for_status()

            size = int(r.raw.headers.get("Content-Length"))
            sizemb = size / (1024 * 1024)
            downloaded = 0

            with open(local, 'wb') as f:
                for chunk in r.iter_content(chunk_size=1684):
                    progress = (downloaded / size) * 100

                    downmb = downloaded / (1024 * 1024)

                    sys.stdout.write(f"\r[+] downloading: {progress:.0f}% [{downmb:.0f} / {sizemb:.0f} MB]")
                    sys.stdout.flush()

                    f.write(chunk)

                    downloaded += len(chunk)

            os.utime(local, (sourcetime, sourcetime))

            print(f"\r[+] downloaded: {source} [{sizemb:.0f} MB]")

        return local

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <source-baseurl> <output-directory>")
        print(f"Example: {sys.argv[0]} https://bootstrap.grid.tf /tmp/kernel")
        sys.exit(1)

    baseurl = sys.argv[1]
    targetdir = sys.argv[2]

    print(f"[+] source   : {baseurl}")
    print(f"[+] directory: {targetdir}")

    syncer = KernelSync(baseurl, targetdir)
    klist = syncer.fetchlist()

    # only fetch kernel not older than 1 year
    today = int(time.time())
    timelimit = today - (86400 * 365)

    for kernel in klist:
        # kernel list is time sorted
        if kernel['timestamp'] < timelimit:
            break

        if os.path.exists(f"{targetdir}/{kernel['name']}"):
            print(f"[+] skipping: already exists: {kernel['name']}")
            continue

        syncer.download(kernel['name'], kernel['timestamp'])

        print(f"[+] syncing: {kernel['name']}")
