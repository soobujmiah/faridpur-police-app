#!/usr/bin/env python3
"""Derive the splash logo and launcher icon from the real source artwork.

Runs only inside the CI build (see .github/workflows/build-apk.yml) so no
resized binary is hand-authored or committed to the repository. The single
source of truth is assets_source/logo_source.png (the department-provided
logo); this script never modifies that file.

Produces:
  assets/logo.png  - splash-screen logo, capped to 512px on the long edge,
                      background/transparency left exactly as provided.
  assets/icon.png  - 1024x1024 square launcher icon: the source logo
                      letterboxed (contain-fit) onto a brand-colored
                      (#0A3D91) square, since launcher icons must be square
                      and the source artwork's aspect ratio isn't guaranteed
                      to be 1:1.
"""
from __future__ import annotations

import os

from PIL import Image

PRIMARY = (10, 61, 145, 255)  # #0A3D91

ROOT = os.path.join(os.path.dirname(__file__), "..")
SOURCE = os.path.join(ROOT, "assets_source", "logo_source.png")
OUT_DIR = os.path.join(ROOT, "assets")

LOGO_MAX_EDGE = 512
ICON_SIZE = 1024
ICON_PADDING_RATIO = 0.12  # keep the logo off the icon's edges


def load_source() -> Image.Image:
    img = Image.open(SOURCE)
    img = img.convert("RGBA")
    print(f"Source logo: {SOURCE} size={img.size} mode={img.mode}")
    return img


def build_logo(source: Image.Image, path: str) -> None:
    img = source.copy()
    w, h = img.size
    scale = LOGO_MAX_EDGE / max(w, h)
    if scale < 1:
        img = img.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    img.save(path)
    print(f"Wrote {path} size={img.size}")


def build_icon(source: Image.Image, path: str) -> None:
    canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), PRIMARY)
    usable = ICON_SIZE * (1 - ICON_PADDING_RATIO * 2)
    w, h = source.size
    scale = usable / max(w, h)
    fitted = source.resize((round(w * scale), round(h * scale)), Image.LANCZOS)
    offset = (
        (ICON_SIZE - fitted.width) // 2,
        (ICON_SIZE - fitted.height) // 2,
    )
    canvas.alpha_composite(fitted, dest=offset)
    canvas.save(path)
    print(f"Wrote {path} size={canvas.size}")


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    source = load_source()
    build_logo(source, os.path.join(OUT_DIR, "logo.png"))
    build_icon(source, os.path.join(OUT_DIR, "icon.png"))


if __name__ == "__main__":
    main()
