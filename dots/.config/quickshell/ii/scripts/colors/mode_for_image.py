#!/usr/bin/env python3
import sys
import cv2
import numpy as np

THRESHOLD = 128

def image_luminance(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return float(np.mean(gray))

def load_and_resize_image(img_path, max_dim=128):
    img = cv2.imread(img_path)
    if img is None:
        return None
    h, w = img.shape[:2]
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        img = cv2.resize(img, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)
    return img

def main():
    luminance_mode = False
    args = sys.argv[1:]
    if '--luminance' in args:
        luminance_mode = True
        args.remove('--luminance')
    if len(args) < 1:
        print("dark")
        sys.exit(1)
    img = load_and_resize_image(args[0])
    if img is None:
        print("dark")
        sys.exit(1)
    luminance = image_luminance(img)
    if luminance_mode:
        print(f"{luminance:.2f}")
    else:
        print("light" if luminance > THRESHOLD else "dark")

if __name__ == "__main__":
    main()
