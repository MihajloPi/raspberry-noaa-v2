#!/usr/bin/env python3

import os
import sys
import facebook as fb
import requests

def parse_facebook_config(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    access_token = None
    page_id = None
    for line in lines:
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        key, value = line.split('=', 1)
        key = key.strip()
        value = value.strip()
        if key == 'FACEBOOK_ACCESS_TOKEN':
            access_token = value.strip('\'"')
            break
        elif key == 'FACEBOOK_PAGE_ID':
            page_id = value.strip('\'"')

    return access_token, page_id

config_path = os.path.expanduser("~/.facebook.conf")
ACCESS_TOKEN_KEY, PAGE_ID = parse_facebook_config(config_path)

bot = fb.GraphAPI(ACCESS_TOKEN_KEY)

annotation = sys.argv[1]
images = sys.argv[2]
img_list = images.split()

SerbianFlag = u'\U0001F1F7' + u'\U0001F1F8'
message = SerbianFlag + " " + annotation

imgs_id = []
#for img in img_list:
#    photo = open(img, "rb")
#    response = bot.put_photo(image=photo, published=False)
#    imgs_id.append(response['id'])
#    photo.close()

for img in img_list:
    photo = open(img, "rb")
    response = bot.put_photo(image=photo.read(), published=False)
    imgs_id.append(response['id'])
    photo.close()

upload_url = f'https://graph.facebook.com/v22.0/{PAGE_ID}/photos'

#for img in img_list:
#    params = {
#       'access_token': ACCESS_TOKEN_KEY,
#       'published': 'false',
#       'url': img,
#    }
#
#try:
#        response = requests.post(upload_url, params=params)
#        result = response.json()
#
#        if 'id' in result:
#           img_id.append(result['id'])
#        else:
#           print(f"Error uploading photo: {result}")
#
#except requests.exceptions.RequestException as e:
#    print(f"Request error: {e}")

# Prepare the payload for posting all images
args = dict()
args["message"] = message
for img_id in imgs_id:
    key = f"attached_media[{imgs_id.index(img_id)}]"
    args[key] = f"{{'media_fbid': '{img_id}'}}"

bot.request(path='/me/feed', args=None, post_args=args, method='POST')

print(f"Uploaded {len(imgs_id)} photos successfully!")
