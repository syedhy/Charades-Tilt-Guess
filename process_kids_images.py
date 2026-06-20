import os
import glob
from PIL import Image

src_dir = "/Users/hyder/.gemini/antigravity/brain/d68e3b18-0d8b-43ae-93b0-2b1b5149e54c"
dest_dir = "CharadesTiltGuess/Assets.xcassets/KidsMode"

if not os.path.exists(dest_dir):
    os.makedirs(dest_dir)

def make_transparent_and_crop(img):
    img = img.convert("RGBA")
    datas = img.getdata()

    newData = []
    for item in datas:
        # Check if the pixel is white or near-white
        if item[0] > 230 and item[1] > 230 and item[2] > 230:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)

    img.putdata(newData)

    # Get bounding box of non-transparent pixels
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)

    return img

images = glob.glob(os.path.join(src_dir, "kids_animals_*.png"))

for img_path in images:
    filename = os.path.basename(img_path)
    # File name looks like "kids_animals_bear_1781911456371.png"
    # we want "kids_animals_bear"
    base_name = "_".join(filename.split("_")[:-1])
    if not base_name: # fallback
        base_name = filename.replace(".png", "")

    img = Image.open(img_path)
    img = make_transparent_and_crop(img)

    # Resize to max dimension 256px to keep app size very small
    img.thumbnail((256, 256), Image.Resampling.LANCZOS)

    imageset_dir = os.path.join(dest_dir, f"{base_name}.imageset")
    if not os.path.exists(imageset_dir):
        os.makedirs(imageset_dir)

    out_path = os.path.join(imageset_dir, f"{base_name}.png")
    img.save(out_path, "PNG")

    # Create Contents.json
    contents = f"""{{
  "images" : [
    {{
      "filename" : "{base_name}.png",
      "idiom" : "universal",
      "scale" : "1x"
    }}
  ],
  "info" : {{
    "author" : "xcode",
    "version" : 1
  }}
}}"""
    with open(os.path.join(imageset_dir, "Contents.json"), "w") as f:
        f.write(contents)

    print(f"Processed {base_name}")
