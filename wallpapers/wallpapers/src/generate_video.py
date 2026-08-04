import sys, os, math, subprocess
from PIL import Image, ImageDraw

FPS = 30
DURATION = 10
TOTAL_FRAMES = FPS * DURATION
CHANGE_SPEED = 0.007

BG_COLOR = (41, 44, 60)       # #292c3c (Catppuccin Frappé Base)
FG_COLOR = (140, 170, 238)    # #8caaee (Catppuccin Frappé Blue)

class SimplexNoise:
    def __init__(self, seed=42):
        self.p = list(range(256))
        import random
        r = random.Random(seed)
        r.shuffle(self.p)
        self.perm = (self.p + self.p)[:512]
        self.permMod12 = [x % 12 for x in self.perm]
        self.grad3 = [
            (1,1,0),(-1,1,0),(1,-1,0),(-1,-1,0),
            (1,0,1),(-1,0,1),(1,0,-1),(-1,0,-1),
            (0,1,1),(0,-1,1),(0,1,-1),(0,-1,-1)
        ]

    def noise3D(self, xin, yin, zin):
        F3 = 1.0 / 3.0
        G3 = 1.0 / 6.0
        s = (xin + yin + zin) * F3
        i = math.floor(xin + s)
        j = math.floor(yin + s)
        k = math.floor(zin + s)
        t = (i + j + k) * G3
        X0 = i - t; Y0 = j - t; Z0 = k - t
        x0 = xin - X0; y0 = yin - Y0; z0 = zin - Z0

        if x0 >= y0:
            if y0 >= z0: i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 1, 0
            elif x0 >= z0: i1, j1, k1, i2, j2, k2 = 1, 0, 0, 1, 0, 1
            else: i1, j1, k1, i2, j2, k2 = 0, 0, 1, 1, 0, 1
        else:
            if y0 < z0: i1, j1, k1, i2, j2, k2 = 0, 0, 1, 0, 1, 1
            elif x0 < z0: i1, j1, k1, i2, j2, k2 = 0, 1, 0, 0, 1, 1
            else: i1, j1, k1, i2, j2, k2 = 0, 1, 0, 1, 1, 0

        x1 = x0 - i1 + G3; y1 = y0 - j1 + G3; z1 = z0 - k1 + G3
        x2 = x0 - i2 + 2.0 * G3; y2 = y0 - j2 + 2.0 * G3; z2 = z0 - k2 + 2.0 * G3
        x3 = x0 - 1.0 + 3.0 * G3; y3 = y0 - 1.0 + 3.0 * G3; z3 = z0 - 1.0 + 3.0 * G3

        ii = i & 255; jj = j & 255; kk = k & 255

        gi0 = self.permMod12[ii + self.perm[jj + self.perm[kk]]]
        gi1 = self.permMod12[ii + i1 + self.perm[jj + j1 + self.perm[kk + k1]]]
        gi2 = self.permMod12[ii + i2 + self.perm[jj + j2 + self.perm[kk + k2]]]
        gi3 = self.permMod12[ii + 1 + self.perm[jj + 1 + self.perm[kk + 1]]]

        n0 = n1 = n2 = n3 = 0.0

        t0 = 0.6 - x0*x0 - y0*y0 - z0*z0
        if t0 >= 0:
            t0 *= t0
            g = self.grad3[gi0]
            n0 = t0 * t0 * (g[0]*x0 + g[1]*y0 + g[2]*z0)

        t1 = 0.6 - x1*x1 - y1*y1 - z1*z1
        if t1 >= 0:
            t1 *= t1
            g = self.grad3[gi1]
            n1 = t1 * t1 * (g[0]*x1 + g[1]*y1 + g[2]*z1)

        t2 = 0.6 - x2*x2 - y2*y2 - z2*z2
        if t2 >= 0:
            t2 *= t2
            g = self.grad3[gi2]
            n2 = t2 * t2 * (g[0]*x2 + g[1]*y2 + g[2]*z2)

        t3 = 0.6 - x3*x3 - y3*y3 - z3*z3
        if t3 >= 0:
            t3 *= t3
            g = self.grad3[gi3]
            n3 = t3 * t3 * (g[0]*x3 + g[1]*y3 + g[2]*z3)

        return 32.0 * (n0 + n1 + n2 + n3)

def draw_shape_tile(shape_index, size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = size / 52.0

    def circle(cx, cy, r):
        draw.ellipse([(cx - r)*s, (cy - r)*s, (cx + r)*s, (cy + r)*s], fill=FG_COLOR + (255,))

    def rect(x0, y0, x1, y1):
        draw.rectangle([x0*s, y0*s, x1*s, y1*s], fill=FG_COLOR + (255,))

    if shape_index == 0: pass
    elif shape_index == 1: circle(26, 26, 4)
    elif shape_index == 2: circle(11, 11, 4); circle(11, 41, 4); circle(41, 41, 4); circle(41, 11, 4)
    elif shape_index == 3: rect(19, 24, 33, 28)
    elif shape_index == 4: rect(24, 18, 28, 34); rect(18, 24, 34, 28)
    elif shape_index == 5: rect(24, 12, 28, 40); rect(12, 24, 40, 28)
    elif shape_index == 6:
        circle(26, 26, 16)
        draw.ellipse([10*s, 10*s, 42*s, 42*s], outline=FG_COLOR + (255,), width=int(3*s))
    elif shape_index == 7: circle(26, 26, 10)
    elif shape_index == 8: circle(26, 26, 6); circle(12, 26, 4); circle(40, 26, 4)
    elif shape_index == 9: rect(16, 16, 36, 36)
    elif shape_index == 10:
        rect(12, 12, 22, 22); rect(30, 12, 40, 22)
        rect(12, 30, 22, 40); rect(30, 30, 40, 40)
    elif shape_index == 11: rect(8, 8, 44, 44); circle(26, 26, 8)
    elif shape_index == 12: circle(26, 26, 14); circle(26, 26, 6)
    elif shape_index == 13: rect(14, 24, 38, 28); rect(24, 14, 28, 38)
    elif shape_index == 14: rect(10, 10, 42, 42)
    elif shape_index == 15: rect(8, 8, 20, 20); rect(32, 32, 44, 44)
    elif shape_index == 16: circle(26, 26, 18)
    elif shape_index == 17: rect(4, 4, 48, 48)

    return img

def render_video(width, height, output_file, seed_offset=0):
    cell_size = 16
    cols = width // cell_size
    rows = height // cell_size
    tiles = [draw_shape_tile(i, cell_size) for i in range(18)]
    noise = SimplexNoise(seed=12345 + seed_offset)

    ffmpeg_cmd = [
        "ffmpeg", "-y",
        "-f", "rawvideo",
        "-pixel_format", "rgb24",
        "-video_size", f"{width}x{height}",
        "-framerate", str(FPS),
        "-i", "-",
        "-c:v", "libx264",
        "-preset", "fast",
        "-crf", "18",
        "-pix_fmt", "yuv420p",
        output_file
    ]

    print(f"Rendering {output_file} ({width}x{height}, {cols}x{rows} grid, {TOTAL_FRAMES} frames)...")
    pipe = subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE)

    z = 0.0
    for frame_idx in range(TOTAL_FRAMES):
        z += CHANGE_SPEED
        frame_img = Image.new("RGB", (width, height), BG_COLOR)

        for y in range(rows):
            y_cell = y * cell_size
            for x in range(cols):
                x_cell = x * cell_size
                noise_val = (
                    noise.noise3D((x - (x % 8)) / 16.0, (y - (y % 8)) / 16.0, z) +
                    noise.noise3D((x - (x % 4)) / 16.0, (y - (y % 4)) / 16.0, -z) +
                    noise.noise3D((x - (x % 2)) / 16.0, (y - (y % 2)) / 16.0, z) +
                    noise.noise3D(x / 16.0, y / 16.0, -z)
                )
                norm_val = max(0.0, min(1.0, (noise_val - 0.0) / 4.0))
                tile_idx = int(norm_val * 17)
                if tile_idx > 0:
                    frame_img.paste(tiles[tile_idx], (x_cell, y_cell), tiles[tile_idx])

        pipe.stdin.write(frame_img.tobytes())

    pipe.stdin.close()
    pipe.wait()
    print(f"Completed {output_file}")

# 1. Horizontal wallpaper for HDMI-A-1 (1920x1080)
render_video(1920, 1080, "/home/michael/wallpapers/my_catppuccin_wallpaper/catppuccin_marathon.mp4", seed_offset=0)

# 2. Vertical wallpaper for DVI-D-1 (1080x1920)
os.makedirs("/home/michael/wallpapers/my_catppuccin_wallpaper_vertical", exist_ok=True)
render_video(1080, 1920, "/home/michael/wallpapers/my_catppuccin_wallpaper_vertical/catppuccin_marathon_vertical.mp4", seed_offset=100)
