import redis
import tempfile
import requests
import subprocess
import json
import os
import sys

class FListRemoteClone:
    def __init__(self, host, port, basehub="https://hub.grid.tf"):
        self.host = host
        self.port = port
        self.basehub = basehub

        self.local = redis.Redis(host, port)
        self.remote = redis.Redis("hub.grid.tf", 9900)

        self.zflist = "/usr/bin/zflist"
        self.workdir = tempfile.mkdtemp(prefix="zflist-cloning")
        self.tempdir = tempfile.mkdtemp(prefix="zflist-source")

        print(self.workdir)
        print(self.tempdir)

        self.environ = dict(
            os.environ,
            ZFLIST_JSON="1",
            ZFLIST_MNT=self.workdir
        )

    def authenticate(self):
        pass

    def download(self, target):
        url = f"{self.basehub}/{target}"

        # Support plain URL as well
        if target.startswith("http"):
            url = target

        destination = f"{self.tempdir}/download.flist"

        print(f"[+] fetching: {url}")

        r = requests.get(url)
        with open(destination, "wb") as f:
            f.write(r.content)

        length = len(r.content) / 1024
        print(f"[+] fetched {length:.2f} KB into {destination}")

        return destination

    def execute(self, args):
        command = [self.zflist] + args

        print(command)
        p = subprocess.Popen(command, env=self.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, err) = p.communicate()

        return json.loads(output)

    def chunks(self, flist):
        self.execute(["open", flist])
        reply = self.execute(["chunks"])

        chunks = reply["response"]["content"]
        bchunks = []

        for chunk in chunks:
            bchunk = bytes.fromhex(chunk)
            bchunks.append(bchunk)

        return bchunks

    def metadata(self):
        pass

    def commit(self, destination):
        self.execute(["commit", destination])

    def sync(self, chunks):
        proceed = 0
        total = len(chunks)

        print("[+] syncing database...")

        for chunk in chunks:
            data = self.remote.get(chunk)
            self.local.execute_command("SETX", chunk, data)

            proceed += 1
            percent = (proceed / total) * 100

            sys.stdout.write(f"\r[+] syncing database: {proceed} / {total} [{percent:.2f} %%]")
            sys.stdout.flush()

        print("")
        print("[+] database synchronized")

    def clone(self, target, output_dir):
        flist = self.download(target)
        chunks = self.chunks(flist)
        self.sync(chunks)
        self.metadata()
        self.commit(output_dir)

if len(sys.argv) < 2:
    print("[-] missing file containing FList URLs")
    sys.exit(1)

urls_file = sys.argv[1]

with open(urls_file, "r") as f:
    urls = [line.strip() for line in f if line.strip()]

for url in urls:
    parsed_url = url.split("/")
    directory = "/public/users/" + "/".join(parsed_url[3:-1])
    file_name = parsed_url[-1]

    os.makedirs(directory, exist_ok=True)

    output_path = os.path.join(directory, file_name)

    print(f"[+] Cloning FList: {url} into {output_path}")

    flist_cloner = FListRemoteClone("0-db", 9900)
    flist_cloner.clone(url, output_path)

