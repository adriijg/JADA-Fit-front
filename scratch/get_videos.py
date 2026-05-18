import urllib.request
import json

def search(query):
    url = f'https://archive.org/advancedsearch.php?q={query}+AND+format:mp4&fl[]=identifier&rows=3&output=json'
    try:
        req = urllib.request.urlopen(url)
        res = json.loads(req.read())
        docs = res['response']['docs']
        if docs:
            return f"https://archive.org/download/{docs[0]['identifier']}/{docs[0]['identifier']}.mp4"
    except Exception as e:
        return str(e)
    return "Not found"

print('Squat:', search('squat'))
print('Push-up:', search('pushup'))
print('Bench Press:', search('bench+press'))
print('Pull-up:', search('pullup'))
print('Deadlift:', search('deadlift'))
