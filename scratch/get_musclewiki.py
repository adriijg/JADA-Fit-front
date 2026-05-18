import urllib.request
import re

def get_mp4(url):
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        html = urllib.request.urlopen(req).read().decode('utf-8')
        matches = re.findall(r'src="(https://[^"]+\.mp4)"', html)
        if matches:
            return matches[0]
    except:
        pass
    return "Not found"

print("Squat:", get_mp4("https://musclewiki.com/exercises/male/quads/barbell-squat"))
print("Pushup:", get_mp4("https://musclewiki.com/exercises/male/chest/push-up"))
print("Bench Press:", get_mp4("https://musclewiki.com/exercises/male/chest/barbell-bench-press"))
print("Pullup:", get_mp4("https://musclewiki.com/exercises/male/lats/pull-up"))
print("Deadlift:", get_mp4("https://musclewiki.com/exercises/male/lower-back/barbell-deadlift"))
