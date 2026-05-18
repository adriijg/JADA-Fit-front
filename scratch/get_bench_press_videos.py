import urllib.request
import json
import urllib.parse

def get_repos(query):
    url = f"https://api.github.com/search/repositories?q={urllib.parse.quote(query)}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [r['full_name'] for r in data.get('items', [])[:15]]
    except Exception as e:
        print("Search failed:", e)
        return []

def get_files(repo_name):
    # Try master tree
    url = f"https://api.github.com/repos/{repo_name}/git/trees/master?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [f"https://raw.githubusercontent.com/{repo_name}/master/{f['path']}" for f in data.get('tree', []) if f['path'].endswith('.mp4')]
    except:
        pass
    
    # Try main tree
    url = f"https://api.github.com/repos/{repo_name}/git/trees/main?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [f"https://raw.githubusercontent.com/{repo_name}/main/{f['path']}" for f in data.get('tree', []) if f['path'].endswith('.mp4')]
    except:
        pass
    return []

repos = get_repos("bench press pose")
repos.extend(get_repos("bench press counter"))
repos.extend(get_repos("benchpress"))

print("Found repos:", len(repos))
found_mp4s = []
for r in set(repos):
    mp4s = get_files(r)
    for m in mp4s:
        if "bench" in m.lower():
            found_mp4s.append(m)
            print(m)

print("Total mp4s containing bench:", len(found_mp4s))
