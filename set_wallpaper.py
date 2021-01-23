#!/usr/bin/env python3
import subprocess

import requests
import sys
import hashlib

wallpaper_api_key = "d89af92710ae3eee0bc0130a4d02d032"
wallpaper_dir = "/home/timbe/Pictures/wallpapers/"
wallpaper_service_url = f"https://wall.alphacoders.com/api2.0/get.php?auth={wallpaper_api_key}&method=random&count=1"

r = requests.get(wallpaper_service_url)
data = r.json()
print(data)
if not data["success"]:
    sys.exit(1)

wallpaper_url = data["wallpapers"][0]["url_image"]

r = requests.get(wallpaper_url, allow_redirects=True)
hash_object = hashlib.md5(str(wallpaper_url).encode('utf-8'))
wallpaper_path = wallpaper_dir + hash_object.hexdigest() + ".jpg"
open(wallpaper_path, 'wb').write(r.content)

args = ['feh', '--bg-fill', wallpaper_path]
subprocess.call(args)
