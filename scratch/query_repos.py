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

repos = ['lutfihadiCEX/Gym_CV', 'Prasheel-Shetty/BenchPress_ComputerVision', 'maksimlepel/benchPressRepsCounter', 'JoLeaper/bench-press-counter']
for r in repos:
    print(r)
    for f in get_all_mp4s(r):
        print("  ", f)
