#!/usr/bin/env python3
import subprocess

import requests
import sys
import hashlib
import datetime

# https://stackoverflow.com/questions/9084442/wikipedia-api-cannot-query-picture-of-the-day-url
# https://commons.wikimedia.org/w/api.php?action=expandtemplates&text={{Potd/2021-02-07}}
# https://commons.wikimedia.org/w/api.php?iiprop=url&action=query&prop=imageinfo&titles=Image:Sunlight%20through%20clouds%20and%20view%20of%20Ginkaku-ji%20Temple%20from%20above,%20Kyoto,%20Japan.jpg

SESSION = requests.Session()
ENDPOINT = "https://commons.wikipedia.org/w/api.php"
WALLPAPER_DIR = "/home/timbe/Pictures/wallpapers/"


def get_alphacoders_wallpaper_url():
    wallpaper_api_key = "d89af92710ae3eee0bc0130a4d02d032"
    wallpaper_service_url = f"https://wall.alphacoders.com/api2.0/get.php?auth={wallpaper_api_key}&method=random&count=1"

    r = requests.get(wallpaper_service_url)
    data = r.json()
    print(data)
    if not data["success"]:
        sys.exit(1)

    url = data["wallpapers"][0]["url_image"]
    return url


def get_wiki_en_today_wallpaper_url():
    date_iso = datetime.date.today().isoformat()
    title = "{{Potd/" + date_iso + "}}"

    params = {
        "action": "expandtemplates",
        "format": "json",
        "formatversion": "2",
        "text": title
    }

    response = SESSION.get(url=ENDPOINT, params=params)
    data = response.json()
    # print(data)
    filename = data["expandtemplates"]["wikitext"]
    # print(filename)
    params = {
        "action": "query",
        "prop": "imageinfo",
        "iiprop": "url",
        "format": "json",
        "formatversion": "2",
        "titles": "Image:" + filename
    }
    response = SESSION.get(url=ENDPOINT, params=params)
    data = response.json()
    # print(data)
    url = data["query"]["pages"][0]["imageinfo"][0]["url"]
    # print(url)

    return filename, url


def download_image(file_name, url):
    r = requests.get(url, allow_redirects=True)
    path = WALLPAPER_DIR + file_name
    open(path, 'wb').write(r.content)

    return path


def set_desktop_wallpaper(filepath):
    args = ['feh', '--bg-fill', filepath]
    subprocess.call(args)


if __name__ == "__main__":
    # wallpaper_url = get_alphacoders_wallpaper_url()
    filename, wallpaper_url = get_wiki_en_today_wallpaper_url()
    # print(filename)
    # print(wallpaper_url)
    # sys.exit(1)

    wallpaper_path = download_image(filename, wallpaper_url)
    set_desktop_wallpaper(wallpaper_path)
