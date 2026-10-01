"""Crop debug regions from ORIGINAL/FLUTTER pairs for close inspection."""
import os
import sys
from PIL import Image

state = sys.argv[1] if len(sys.argv) > 1 else '01_Intro_initial'
os.makedirs('tmp_crop', exist_ok=True)
for side in ['ORIGINAL', 'FLUTTER']:
    im = Image.open(
        f'requirements/req-projectile-motion/visual-qa/{side}/{state}.png')
    w, h = im.size
    im.crop((0, h - 170, w, h)).save(f'tmp_crop/{side}_bottom.png')
    im.crop((w - 620, 0, w, 300)).save(f'tmp_crop/{side}_topright.png')
    im.crop((w - 520, h - 130, w, h)).resize((1040, 260)).save(
        f'tmp_crop/{side}_bottomright.png')
print('ok', state)
