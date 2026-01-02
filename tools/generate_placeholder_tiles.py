import os
import struct
import zlib

ROOT = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    "monster-farm-gamefiles",
    "monster-farm",
    "art",
    "tiles",
)

COLORS = {
    "ground_placeholder.png": (96, 168, 104, 255),
    "buildable_placeholder.png": (120, 120, 128, 255),
    "hazard_placeholder.png": (180, 64, 148, 255),
    "farming_placeholder.png": (146, 116, 74, 255),
    "water_placeholder.png": (64, 140, 196, 255),
}


def _chunk(tag: bytes, data: bytes) -> bytes:
    return (
        struct.pack(">I", len(data))
        + tag
        + data
        + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    )


def write_png(path: str, rgba: tuple[int, int, int, int], size: int = 18) -> None:
    w = h = size
    row = bytes([0]) + bytes(rgba) * w  # filter byte 0 + pixels
    data = row * h
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n" + _chunk(b"IHDR", ihdr) + _chunk(
        b"IDAT", zlib.compress(data, 9)
    ) + _chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def main() -> None:
    os.makedirs(ROOT, exist_ok=True)
    for name, color in COLORS.items():
        path = os.path.join(ROOT, name)
        write_png(path, color)
        print(f"wrote {path}")


if __name__ == "__main__":
    main()
