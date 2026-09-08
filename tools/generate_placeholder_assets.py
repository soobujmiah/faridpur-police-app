#!/usr/bin/env python3
"""Generate placeholder brand assets for the Faridpur Police app.

Runs only inside the CI build (see .github/workflows/build-apk.yml) so no
binary image files are hand-authored or committed to the repository. Produces
a simple shield glyph, not the department's real emblem. Replace
assets/icon.png and assets/logo.png with the official artwork whenever it is
available and drop this generator.
"""
from __future__ import annotations

import math
import os

from PIL import Image, ImageDraw

PRIMARY = (10, 61, 145, 255)  # #0A3D91
WHITE = (255, 255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets")


def shield_path(cx: float, cy: float, w: float, h: float) -> list[tuple[float, float]]:
    """Return a simple shield outline centered at (cx, cy)."""
    top = cy - h / 2
    bottom = cy + h / 2
    left = cx - w / 2
    right = cx + w / 2
    mid = cy + h * 0.05
    return [
        (left, top),
        (right, top),
        (right, mid),
        (cx, bottom),
        (left, mid),
    ]


def draw_shield(draw: ImageDraw.ImageDraw, size: int, fill, scale: float = 0.6) -> None:
    cx, cy = size / 2, size / 2
    w, h = size * scale, size * scale
    points = shield_path(cx, cy, w, h)
    draw.polygon(points, fill=fill)
    # Simple five-point star cut-out in the shield centre.
    star_r_outer = size * 0.14
    star_r_inner = star_r_outer * 0.45
    star_points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = star_r_outer if i % 2 == 0 else star_r_inner
        star_points.append((cx + r * math.cos(angle), cy - r * math.sin(angle)))
    star_fill = PRIMARY if fill == WHITE else WHITE
    draw.polygon(star_points, fill=star_fill)


def build_icon(path: str, size: int = 1024) -> None:
    img = Image.new("RGBA", (size, size), PRIMARY)
    draw = ImageDraw.Draw(img)
    draw_shield(draw, size, WHITE, scale=0.62)
    img.save(path)


def build_logo(path: str, size: int = 512) -> None:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    draw_shield(draw, size, WHITE, scale=0.78)
    img.save(path)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    build_icon(os.path.join(OUT_DIR, "icon.png"))
    build_logo(os.path.join(OUT_DIR, "logo.png"))
    print(f"Wrote placeholder icon.png and logo.png to {os.path.abspath(OUT_DIR)}")


if __name__ == "__main__":
    main()
