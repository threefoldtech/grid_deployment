import os
import stat
import sys
import time
import requests

class HubFlistSyncer:
    def __init__(self, baseurl, localdir):
        self.baseurl = baseurl
        self.localdir = localdir

        self.officials = []

        self.root = os.getcwd()
        self.downloaded = 0
        self.files = 0

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
        sys.stdout.write(f"\r[+] downloading: {url} \033\x5bK")

        r = requests.get(url)
        with open(targetfile, "wb") as f:
            f.write(r.content)

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


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("")
        print(f"  Usage: {sys.argv[0]} [remote-host] [local-directory]")
        print("")
        print("  Example:")
        print(f"    {sys.argv[0]} https://hub.grid.tf /tmp/users")
        print("")

        sys.exit(1)

    host = sys.argv[1]
    target = sys.argv[2]

    sync = HubFlistSyncer(host, target)

    repositories = sync.remote_repositories()
    updating = sync.local_sync_repositories(repositories)

    if len(updating) == 0:
        print("[+] nothing to update")

    for repo in updating:
        username = repo['name']

        userdata = sync.remote_repository(username)
        sync.local_sync_repository(username, userdata, repo['updated'])

    sync.statistics()
