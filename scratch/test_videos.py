import urllib.request
import os

urls = {
    "bench1": "https://raw.githubusercontent.com/jeonggyuhyung/YOLOv5-Pose_Estimation/master/YOLO+pose_estimation/sample_files/bench_press.mp4",
    "bench2": "https://raw.githubusercontent.com/jeonggyuhyung/YOLOv5-Pose_Estimation/master/YOLO+pose_estimation/sample_files/bench_press_2.mp4",
    "bench3": "https://raw.githubusercontent.com/jeonggyuhyung/YOLOv5-Pose_Estimation/master/YOLO+pose_estimation/sample_files/bench_press_3.mp4",
    "bench4": "https://raw.githubusercontent.com/DhruvMehta323/GymTrainer/main/videos/benchPress.mp4",
    "bench5": "https://raw.githubusercontent.com/itertius/ai-for-thai/master/sample/benchpress_sample.mp4"
}

os.makedirs("scratch/videos", exist_ok=True)

# Download small parts (first 2MB) or full if small
for name, url in urls.items():
    print(f"Downloading {name}...")
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = response.read(2 * 1024 * 1024) # 2MB
            with open(f"scratch/videos/{name}.mp4", "wb") as f:
                f.write(data)
        print(f"Downloaded {name} successfully.")
    except Exception as e:
        print(f"Failed to download {name}: {e}")

# Check if cv2 is installed
try:
    import cv2
    print("OpenCV is installed! Extracting frames...")
    for name in urls.keys():
        video_path = f"scratch/videos/{name}.mp4"
        if os.path.exists(video_path):
            cap = cv2.VideoCapture(video_path)
            ret, frame = cap.read()
            if ret:
                img_path = f"scratch/videos/{name}.png"
                cv2.imwrite(img_path, frame)
                print(f"Extracted frame for {name} to {img_path}")
            cap.release()
except ImportError:
    print("OpenCV is not installed. Let's try importing other things or print message.")
