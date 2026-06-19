#!/bin/bash
python3 -m venv venv
source venv/bin/activate
pip install Pillow
python3 process_kids_images.py
