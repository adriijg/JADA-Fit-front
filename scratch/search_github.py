import urllib.request
import json

def get_repos(query):
    url = f"https://api.github.com/search/repositories?q={urllib.parse.quote(query)}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        return [r['full_name'] for r in data.get('items', [])[:5]]
    except Exception as e:
        print("Search failed:", e)
        return []

def get_files(repo_name):
    # Get tree
    url = f"https://api.github.com/repos/{repo_name}/git/trees/master?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        files = []
        for file in data.get('tree', []):
            path = file.get('path', '')
            if path.endswith('.mp4'):
                files.append(f"https://raw.githubusercontent.com/{repo_name}/master/{path}")
        return files
    except:
        pass
    
    # Try main instead of master
    url = f"https://api.github.com/repos/{repo_name}/git/trees/main?recursive=1"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        files = []
        for file in data.get('tree', []):
            path = file.get('path', '')
            if path.endswith('.mp4'):
                files.append(f"https://raw.githubusercontent.com/{repo_name}/main/{path}")
        return files
    except:
        pass
        
    return []

repos = get_repos("AI Fitness Trainer")
repos.extend(get_repos("AI Workout Manager"))
repos.extend(get_repos("pose estimation exercise"))

print("Found repos:", repos)
for repo in repos:
    mp4s = get_files(repo)
    if mp4s:
        print(f"Repo: {repo}")
        for m in mp4s:
            print("  ", m)
