import urllib.request
import json

def get_all_mp4s(repo_name):
    # Try master
    url = f"https://api.github.com/repos/{repo_name}/git/trees/master?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [f"https://raw.githubusercontent.com/{repo_name}/master/{f['path']}" for f in data.get('tree', []) if f['path'].endswith('.mp4')]
    except:
        pass
    
    # Try main
    url = f"https://api.github.com/repos/{repo_name}/git/trees/main?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [f"https://raw.githubusercontent.com/{repo_name}/main/{f['path']}" for f in data.get('tree', []) if f['path'].endswith('.mp4')]
    except:
        pass
    return []

# Search specifically for benchpress (no space)
url = "https://api.github.com/search/repositories?q=benchpress"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    res = urllib.request.urlopen(req)
    repos = [r['full_name'] for r in json.loads(res.read()).get('items', [])[:5]]
    print("Benchpress repos found:", repos)
    for repo in repos:
        for f in get_all_mp4s(repo):
            print("  Video found:", f)
except Exception as e:
    print(e)
