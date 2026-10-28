#!/usr/bin/env python3
"""Export the rectangle-only SVG source to PNG and Apple's ten-slot ICNS set."""

import argparse
import math
from pathlib import Path
import re
import struct
import xml.etree.ElementTree as ET
import zlib

ROOT = Path(__file__).resolve().parent.parent
SVG = "{http://www.w3.org/2000/svg}"
SAMPLES = 4


def read_shapes():
    root = ET.parse(ROOT / "artwork/app-icon.svg").getroot()
    if root.tag != SVG + "svg" or root.attrib != {
        "width": "1024", "height": "1024", "viewBox": "0 0 1024 1024"
    }:
        raise ValueError("The master must have a 1024-square viewBox.")
    shapes = []
    for element in root:
        if element.tag in (SVG + "title", SVG + "desc"):
            continue
        if element.tag != SVG + "rect" or set(element.attrib) - {"x", "y", "width", "height", "rx", "fill"} or len(element):
            raise ValueError("Only solid rounded rectangles are supported.")
        geometry = tuple(float(element.get(key, "0")) for key in ("x", "y", "width", "height", "rx"))
        x, y, width, height, radius = geometry
        if not all(math.isfinite(value) for value in geometry) or not (0 <= x < x + width <= 1024 and 0 <= y < y + height <= 1024):
            raise ValueError("Shapes must fit completely within the square canvas.")
        if not 0 <= radius <= min(width, height) / 2:
            raise ValueError("Invalid corner radius.")
        fill = element.get("fill", "")
        if not re.fullmatch(r"#[0-9a-fA-F]{6}", fill):
            raise ValueError("Fills must be opaque RGB hex colors.")
        color = tuple(int(fill[index:index + 2], 16) for index in (1, 3, 5))
        shapes.append((geometry, color))
    if not 1 <= len(shapes) <= 32:
        raise ValueError("Expected a small set of icon shapes.")
    return shapes


def chunk(kind, data):
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)


def render(shapes, size):
    pixels = bytearray(size * size * 4)
    for geometry, color in shapes:
        x, y, width, height, radius = (value * size / 1024 for value in geometry)
        for row in range(math.floor(y), math.ceil(y + height)):
            for column in range(math.floor(x), math.ceil(x + width)):
                full = x <= column and column + 1 <= x + width and y <= row and row + 1 <= y + height
                middle = x + radius <= column and column + 1 <= x + width - radius or y + radius <= row and row + 1 <= y + height - radius
                coverage = SAMPLES * SAMPLES if full and middle else 0
                if not coverage:
                    for sy in range(SAMPLES):
                        py = row + (sy + 0.5) / SAMPLES
                        dy = max(y + radius - py, 0, py - (y + height - radius))
                        for sx in range(SAMPLES):
                            px = column + (sx + 0.5) / SAMPLES
                            dx = max(x + radius - px, 0, px - (x + width - radius))
                            if x <= px < x + width and y <= py < y + height and dx * dx + dy * dy <= radius * radius:
                                coverage += 1
                if not coverage:
                    continue
                offset = (row * size + column) * 4
                alpha = (coverage * 255 + 8) // 16
                previous_alpha = pixels[offset + 3]
                combined = alpha + (previous_alpha * (255 - alpha) + 127) // 255
                for channel in range(3):
                    premultiplied = color[channel] * alpha + (pixels[offset + channel] * previous_alpha * (255 - alpha) + 127) // 255
                    pixels[offset + channel] = min(255, (premultiplied + combined // 2) // combined)
                pixels[offset + 3] = combined
    scanlines = b"".join(b"\0" + pixels[row * size * 4:(row + 1) * size * 4] for row in range(size))
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0)) + chunk(b"sRGB", b"\0") + chunk(b"IDAT", zlib.compress(scanlines, 9)) + chunk(b"IEND", b"")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="compare fresh deterministic PNG/ICNS exports")
    args = parser.parse_args()
    shapes = read_shapes()
    images = {size: render(shapes, size) for size in (16, 32, 64, 128, 256, 512, 1024)}
    # ICNS records and lengths are big-endian. Repeated resolutions retain
    # distinct point-size/scale identities, matching Apple's ten iconset slots.
    representations = ((b"icp4", 16), (b"ic11", 32), (b"icp5", 32), (b"ic12", 64),
                       (b"ic07", 128), (b"ic13", 256), (b"ic08", 256), (b"ic14", 512),
                       (b"ic09", 512), (b"ic10", 1024))
    records = b"".join(kind + struct.pack(">I", len(images[size]) + 8) + images[size] for kind, size in representations)
    icns = b"icns" + struct.pack(">I", len(records) + 8) + records
    exports = {ROOT / "artwork/app-icon.png": images[1024], ROOT / "Resources/AppIcon.icns": icns}
    for path, data in exports.items():
        if args.check:
            if not path.is_file() or path.read_bytes() != data:
                raise SystemExit(f"{path.relative_to(ROOT)} differs from its SVG export.")
        else:
            path.write_bytes(data)
    print("Roomlet PNG and ICNS match their SVG exports." if args.check else "Exported Roomlet artwork PNG and app icon ICNS.")


if __name__ == "__main__":
    main()
