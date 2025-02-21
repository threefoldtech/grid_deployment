import os
import stat
import sys
import time
import requests
import subprocess
import sqlite3
import tempfile
import json

class HubFlistSyncer:
    def __init__(self, baseurl, localdir, newhost):
        self.baseurl = baseurl
        self.localdir = localdir

        self.officials = []

        self.root = os.getcwd()
        self.downloaded = 0
        self.files = 0

        self.backhost = newhost
        self.backport = 9900
        self.backname = "default"

    #
    # remote helpers
    #
    def remote_repositories(self):
        r = requests.get(f"{self.baseurl}/api/repositories")
        repositories = r.json()

        return repositories

    def remote_repository(self, username):
        sys.stdout.write(f"\r[+] fetching user informations: {username} \033\x5bK")

        r = requests.get(f"{self.baseurl}/api/flist/{username}")
        entries = r.json()

        return entries

    #
    # local helpers
    #
    def local_sync_repositories(self, repositories):
        updated = []

        for repo in repositories:
            userpath = f"{self.localdir}/{repo['name']}"

            if repo['official']:
                self.officials.append(repo['name'])

            if not os.path.exists(userpath):
                os.mkdir(userpath)
                os.utime(userpath, (int(time.time()), repo['updated']))
                updated.append(repo)
                continue

            dirstat = os.stat(userpath)
            if repo['updated'] > int(dirstat.st_mtime):
                updated.append(repo)

        print(f"[+] {len(updated)} / {len(repositories)} local repositories to update")

        return updated

    def local_sync_repository(self, username, entries, updated):
        userpath = f"{self.localdir}/{username}"

        for entry in entries:
            targetfile = f"{self.localdir}/{username}/{entry['name']}"
            self.local_sync_entryfile(username, entry, targetfile)

        # update last modification time
        os.utime(userpath, (int(time.time()), updated))

    def local_sync_entryfile(self, username, entry, targetfile):
        # FIXME: support deleted entries
        # (need to compare extra local entries)

        if entry['type'] == 'regular':
            return self.local_sync_regular_file(username, entry, targetfile)

        if entry['type'] == 'symlink':
            return self.local_sync_symlink(username, entry, targetfile)

        if entry['type'] == 'tag':
            return self.local_sync_tag(username, entry, targetfile)

        if entry['type'] == 'taglink':
            return self.local_sync_taglink(username, entry, targetfile)

        raise RuntimeError(f"Unexpected entry type: {entry['type']}")

    #
    # entry type specific handlers
    #
    def local_sync_regular_file(self, username, entry, targetfile):
        now = int(time.time())

        if os.path.lexists(targetfile):
            filestat = os.lstat(targetfile)

            # checking if local is a regular file as well
            if stat.S_ISREG(filestat.st_mode):
                # checking if remote file is newer
                if entry['updated'] <= int(filestat.st_mtime):
                    return None

            else:
                # local file is not a regular file and remote
                # file is a regular file, removing local file and
                # updating it
                os.remove(targetfile)

        url = f"{self.baseurl}/{username}/{entry['name']}"
        print(f"\r[+] downloading: {url} \033\x5bK")

        r = requests.get(url)
        with open(targetfile, "wb") as f:
            f.write(r.content)

        # apply metadata transformation for our local settings
        # saving current cwd and restoring cwd after-call
        cwd = os.getcwd()
        self.metadata_update(targetfile)
        os.chdir(cwd)

        # apply same modification time on symlink than remote host
        os.utime(targetfile, (now, entry['updated']))

        self.downloaded += len(r.content)
        self.files += 1

        return True

    def local_sync_symlink(self, username, entry, targetfile):
        now = int(time.time())

        if os.path.lexists(targetfile):
            filestat = os.lstat(targetfile)

            # checking if local is a symlink as well
            if stat.S_ISLNK(filestat.st_mode):
                # checking if symlink is newer
                if entry['linktime'] <= int(filestat.st_mtime):
                    return None

                # update required, removing local file
                os.remove(targetfile)

            else:
                # local file is not a symlink and remote file
                # is a symlink, updating
                os.remove(targetfile)

        os.chdir(f"{self.localdir}/{username}")
        target = entry['target']

        # checking for crosslink
        if "/" in entry['target']:
            target = f"../{entry['target']}"

        os.symlink(target, entry['name'])
        os.chdir(self.root)

        # apply same modification time on the tag directory than remote host
        os.utime(targetfile, (now, entry['linktime']), follow_symlinks=False)

        return True

    def local_sync_tag(self, username, entry, targetfile):
        now = int(time.time())

        # update targetfile with tag syntax
        targetfile = f"{self.localdir}/{username}/.tag-{entry['name']}"

        # ignoring last modification time and updating anyway
        if not os.path.exists(targetfile):
            os.mkdir(targetfile)

        # apply same modification time than remote host
        os.utime(targetfile, (now, entry['updated']))

        return True

    def local_sync_taglink(self, username, entry, targetfile):
        now = int(time.time())
        items = entry['target'].split("/")

        if os.path.lexists(targetfile):
            os.remove(targetfile)

        # ignoring last modification time and updating anyway
        os.chdir(f"{self.localdir}/{username}")
        os.symlink(f"../{items[0]}/.tag-{items[2]}", entry['name'])
        os.chdir(self.root)

        # apply same modification on the symlink time than remote host
        os.utime(targetfile, (now, entry['linktime']), follow_symlinks=False)

        return True

    #
    # sync statistics
    #
    def statistics(self):
        print("[+]")
        print("[+] remote official repositories configuration:")
        print("[+] ------------------------------------------")
        print(f"[+] {self.officials}")
        print("[+] ------------------------------------------")

        mbsize = self.downloaded / (1024 * 1024)
        print(f"[+] downloaded: {mbsize:.2f} MB ({self.files} files)")

    #
    # metadata manipulation
    #
    def metadata_update(self, target):
        print("[+] updating low-level metadata")

        # we are not using 'import tarfile' and native python module
        # which is really slow compare to plain raw tar command (nearly 10x slower).

        with tempfile.TemporaryDirectory() as workspace:
            os.chdir(workspace)

            args = ["tar", "-xf", target, "-C", workspace]
            p = subprocess.Popen(args)
            p.wait()

            db = sqlite3.connect("flistdb.sqlite3")
            cursor = db.cursor()

            try:
                cursor.execute("SELECT key FROM metadata LIMIT 1")
                row = cursor.fetchone()
                # print(row)

            except sqlite3.OperationalError:
                # old flist files don't have metadata table at all, that feature
                # wasn't existing at that time, let's create it by the way

                print("[-] legacy flist, no metadata records found, initializing")
                cursor.execute("CREATE TABLE metadata (key VARCHAR(64) PRIMARY KEY, value TEXT);")

            backend = json.dumps({"namespace": self.backname, "host": self.backhost, "port": self.backport})

            cursor.execute("REPLACE INTO metadata (key, value) VALUES ('backend', ?)", (backend,))
            db.commit()
            db.close()

            updated = f"{target}.updated.tar.gz"

            args = ["tar", "-czf", updated, "flistdb.sqlite3"]
            p = subprocess.Popen(args)
            p.wait()

            # overwrite source file with updated version
            os.rename(updated, target)

        return True

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("")
        print(f"  Usage: {sys.argv[0]} [remote-host] [local-directory] [local-host]")
        print("")
        print("  Example:")
        print(f"    {sys.argv[0]} https://hub.grid.tf /tmp/users mirror.hub.grid.tf")
        print("")

        sys.exit(1)

    host = sys.argv[1]
    target = sys.argv[2]
    newhost = sys.argv[3]

    sync = HubFlistSyncer(host, target, newhost)

    repositories = sync.remote_repositories()
    updating = sync.local_sync_repositories(repositories)

    if len(updating) == 0:
        print("[+] nothing to update")

    for repo in updating:
        username = repo['name']

        userdata = sync.remote_repository(username)
        sync.local_sync_repository(username, userdata, repo['updated'])

    sync.statistics()
