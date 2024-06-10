import os
import sys
import requests

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
officials = []
root = os.getcwd()
download = 0
files = 0

#
# fetching repositories
#

r = requests.get(f"{host}/api/repositories")
repositories = r.json()

for repo in repositories:
    userpath = f"{target}/{repo['name']}"

    if not os.path.exists(userpath):
        os.mkdir(userpath)

    if repo['official']:
        officials.append(repo['name'])

print(f"[+] created: {len(repositories)} repositories")

#
# fetching flist for each repositories
#

for repo in repositories:
    sys.stdout.write(f"\r[+] fetching user informations: {repo['name']} \033[K")

    r = requests.get(f"{host}/api/flist/{repo['name']}")
    entries = r.json()
    for entry in entries:
        targetfile = f"{target}/{repo['name']}/{entry['name']}"

        # skip if local file exists
        # FIXME: should be updated if different
        if os.path.exists(targetfile):
            continue

        if entry['type'] == 'regular':
            url = f"{host}/{repo['name']}/{entry['name']}"
            sys.stdout.write(f"\r[+] downloading: {url} \033[K")

            r = requests.get(url)
            with open(targetfile, "wb") as f:
                f.write(r.content)

            download += len(r.content)
            files += 1

        if entry['type'] == 'symlink':
            os.chdir(f"{target}/{repo['name']}")

            if "/" in entry['target']:
                os.symlink(f"../{entry['target']}", entry['name'])

            else:
                os.symlink(entry['target'], entry['name'])

            os.chdir(root)

        if entry['type'] == 'tag':
            targetfile = f"{target}/{repo['name']}/.tag-{entry['name']}"

            if not os.path.exists(targetfile):
                os.mkdir(targetfile)

        if entry['type'] == 'taglink':
            items = entry['target'].split("/")

            os.chdir(f"{target}/{repo['name']}")
            os.symlink(f"../{items[0]}/.tag-{items[2]}", entry['name'])
            os.chdir(root)

print("")
print(f"[+] official repos: {officials}")
print(f"[+] downloaded: {download / (1024 * 1024)} MB ({files} files)")
