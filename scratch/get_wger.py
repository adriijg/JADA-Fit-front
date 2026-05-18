import urllib.request
import json

url = 'https://wger.de/api/v2/video/?limit=200'
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    res = urllib.request.urlopen(req)
    data = json.loads(res.read())
    
    mp4s = []
    for item in data.get('results', []):
        video_url = item.get('video')
        if video_url and video_url.endswith('.mp4'):
            mp4s.append(video_url)
            
    print("Found MP4s:", len(mp4s))
    for v in mp4s[:10]:
        print(v)
except Exception as e:
    print("Error:", e)
