# pyrefly: ignore [missing-import]
import cv2
import os

os.makedirs("scratch/videos", exist_ok=True)

for i in range(1, 6):
    video_path = f"scratch/videos/bench{i}.mp4"
    if os.path.exists(video_path):
        cap = cv2.VideoCapture(video_path)
        # Try to read the 10th frame to get a better visual (the 1st frame might be black)
        ret = False
        for _ in range(10):
            ret, frame = cap.read()
            if not ret:
                break
        if ret:
            img_path = f"scratch/videos/bench{i}.png"
            cv2.imwrite(img_path, frame)
            print(f"Extracted frame for bench{i} to {img_path}")
        else:
            # Try reading first frame just in case
            cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            ret, frame = cap.read()
            if ret:
                img_path = f"scratch/videos/bench{i}.png"
                cv2.imwrite(img_path, frame)
                print(f"Extracted first frame for bench{i} to {img_path}")
            else:
                print(f"Failed to read any frame for bench{i}")
        cap.release()
