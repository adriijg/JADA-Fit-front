import urllib.request
import json
import urllib.parse

def search_commons(query):
    query_encoded = urllib.parse.quote(query)
    url = f"https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch={query_encoded}+filetype:video&format=json&srlimit=10"
    
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        res = urllib.request.urlopen(req)
        data = json.loads(res.read())
        
        results = data.get('query', {}).get('search', [])
        for item in results:
            title = item.get('title')
            if title.startswith('File:'):
                # get file info
                file_title = urllib.parse.quote(title)
                info_url = f"https://commons.wikimedia.org/w/api.php?action=query&titles={file_title}&prop=imageinfo&iiprop=url|mime&format=json"
                req_info = urllib.request.Request(info_url, headers={'User-Agent': 'Mozilla/5.0'})
                res_info = urllib.request.urlopen(req_info)
                data_info = json.loads(res_info.read())
                
                pages = data_info.get('query', {}).get('pages', {})
                for page_id, page in pages.items():
                    info = page.get('imageinfo', [])
                    if info:
                        video_url = info[0].get('url')
                        mime = info[0].get('mime')
                        if 'video/mp4' in mime or 'video/webm' in mime or video_url.endswith('.mp4') or video_url.endswith('.webm'):
                            return video_url, mime
    except Exception as e:
        return str(e), ""
    return "Not found", ""

for q in ['Squat exercise', 'Push up exercise', 'Bench press exercise', 'Pull up exercise', 'Deadlift exercise']:
    url, mime = search_commons(q)
    print(f"{q}: {url} ({mime})")
