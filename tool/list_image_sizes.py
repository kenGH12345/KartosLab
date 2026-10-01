"""List PNG dimensions in phET projectile-motion images/ and mipmaps/."""
import glob
from PIL import Image

for d in ['images', 'mipmaps']:
    for p in sorted(glob.glob(
            f'phet sourses/projectile-motion-main/projectile-motion-main/{d}/*.png')):
        print(d, p.split('\\')[-1], Image.open(p).size)
