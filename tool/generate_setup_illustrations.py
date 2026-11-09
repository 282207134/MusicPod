"""Render labeled setup diagrams. These are illustrations, not dashboard screenshots."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/images/setup"
OUT.mkdir(parents=True, exist_ok=True)
(ROOT / "build_temp").mkdir(exist_ok=True)
REGULAR = "C:/Windows/Fonts/msyh.ttc"
BOLD = "C:/Windows/Fonts/msyhbd.ttc"
INK, MUTED, ORANGE, LINE = "#17202a", "#5e6872", "#db6328", "#d8dce0"

def font(size=28, bold=False):
    return ImageFont.truetype(BOLD if bold else REGULAR, size)

def text(x, y, value, size=28, color=INK, bold=False):
    d.text((x, y), value, font=font(size, bold), fill=color)

def panel(x, y, w, h, title):
    d.rounded_rectangle((x, y, x+w, y+h), 18, fill="white", outline=LINE, width=2)
    text(x+28, y+24, title, 29, bold=True)
    d.line((x+28, y+79, x+w-28, y+79), fill=LINE, width=2)

def field(x, y, w, label, value, highlight=True, value_size=24):
    text(x, y, label, 25, bold=True)
    d.rounded_rectangle((x, y+42, x+w, y+108), 10,
        fill="#fff6ef" if highlight else "#f3f5f7",
        outline=ORANGE if highlight else LINE, width=2)
    text(x+18, y+60, value, value_size, color=INK)

def base(number, title, subtitle):
    global im, d
    im = Image.new("RGB", (1600, 950), "#f4f3ef")
    d = ImageDraw.Draw(im)
    d.rounded_rectangle((60, 52, 146, 98), 12, fill=ORANGE)
    text(77, 57, number, 26, "white", True)
    text(172, 46, title, 42, bold=True)
    text(64, 125, subtitle, 26, MUTED)
    d.line((60, 873, 1540, 873), fill=LINE, width=2)
    text(64, 894, "MusicPod  ·  操作示意图，非后台截图  ·  不含真实密钥  ·  2026-11-09", 22, MUTED)

def save(name):
    im.save(OUT / name, optimize=True)

base("01", "先分清：账号服务、音乐内容和登录授权", "只有下方三个值需要放进 App；后台密钥留在服务后台。")
panel(60, 205, 470, 360, "Supabase  /  账号与资料库")
text(90, 310, "① Project URL", 29)
text(90, 375, "② Publishable key", 29)
text(90, 457, "提供登录、收藏、歌单同步", 25, MUTED)
panel(565, 205, 470, 360, "Jamendo  /  独立音乐")
text(595, 310, "③ 应用 Client ID", 29)
text(595, 375, "Read only · 非商业", 29)
text(595, 457, "音乐直接从内容源播放", 25, MUTED)
panel(1070, 205, 470, 360, "GitHub  /  用户授权")
text(1100, 310, "OAuth Client ID", 27)
text(1100, 375, "OAuth Client secret", 27)
text(1100, 457, "这两个值只填 Supabase", 25, ORANGE, True)
panel(60, 610, 1480, 220, "App 本地配置  /  config/local.json")
text(90, 718, "SUPABASE_URL  +  SUPABASE_PUBLISHABLE_KEY  +  JAMENDO_CLIENT_ID", 29)
save("01-overview.png")

base("02", "Supabase：复制项目地址和公开密钥", "先确认组织套餐为 Free，再创建 MusicPod 项目。")
panel(60, 205, 400, 625, "控制台入口")
for y, label in [(320, "项目顶部  →  Connect"), (415, "Settings  →  API Keys"), (510, "SQL Editor  →  Run"), (605, "Authentication")]:
    text(90, y, label, 26, ORANGE if y < 500 else MUTED)
text(90, 738, "不要复制数据库密码", 25, MUTED)
panel(500, 205, 1040, 625, "Connect / Settings → API Keys")
field(535, 310, 970, "① Project URL → SUPABASE_URL", "https://YOUR_PROJECT.supabase.co")
field(535, 465, 970, "② Publishable key → SUPABASE_PUBLISHABLE_KEY", "sb_publishable_…")
field(535, 620, 970, "Secret key / service_role", "不填入 App，也不要发到聊天", highlight=False)
save("02-supabase.png")

base("03", "GitHub：创建 OAuth App，再填回 Supabase", "打开 github.com/settings/applications/new。这里不是创建 Personal Access Token。")
panel(60, 205, 880, 625, "GitHub · Register a new OAuth application")
field(90, 310, 820, "Application name", "MusicPod Dev", False)
field(90, 445, 820, "Homepage URL", "http://localhost:7357", False)
field(90, 580, 820, "Authorization callback URL", "https://YOUR_PROJECT.supabase.co/auth/v1/callback", value_size=23)
text(90, 746, "填 Supabase 的 HTTPS Callback", 27, ORANGE, True)
panel(980, 205, 560, 625, "注册后 → 应用详情")
text(1012, 316, "复制 Client ID", 30, bold=True)
text(1012, 398, "Generate a new client secret", 24)
text(1012, 492, "两个值都填到：", 28)
text(1012, 552, "Supabase → Authentication", 24)
text(1012, 600, "→ Sign In / Providers → GitHub", 23)
text(1012, 710, "启用并保存", 30, ORANGE, True)
text(1012, 763, "Client secret 不写入 local.json", 23, MUTED)
save("03-github.png")

base("04", "最容易混淆的两种回调地址", "GitHub 先回到 Supabase；Supabase 再把用户送回网页或手机 App。")
panel(60, 205, 1480, 260, "第一站：GitHub → Supabase")
field(90, 310, 1420, "填在 GitHub：Authorization callback URL", "https://YOUR_PROJECT.supabase.co/auth/v1/callback", value_size=28)
panel(60, 505, 1480, 325, "第二站：Supabase → MusicPod")
text(90, 610, "填在 Supabase：Authentication → URL Configuration → Redirect URLs", 27, bold=True)
text(90, 675, "手机 App：com.musicpod.musicpod://login-callback/", 30, ORANGE)
text(90, 741, "本地网页：http://localhost:7357  （启动时固定 7357 端口）", 28)
save("04-redirects.png")

base("05", "Jamendo：只拿应用 Client ID，填入本地配置", "在 devportal.jamendo.com 注册并创建自己的应用；不使用文档中的公共测试 ID。")
panel(60, 205, 675, 625, "Applications → Create an application")
field(90, 310, 615, "应用名称", "MusicPod Personal Demo", False)
field(90, 450, 615, "应用方案", "Read only · 非商业", False)
field(90, 590, 615, "应用详情中的 Client ID", "复制你自己的应用标识")
text(90, 752, "不需要 Client secret 或 Read & Write", 24, MUTED)
panel(775, 205, 765, 625, "App → config/local.json")
text(805, 315, '"SUPABASE_URL": "https://…",', 27)
text(805, 387, '"SUPABASE_PUBLISHABLE_KEY":', 26)
text(838, 439, '"sb_publishable_…",', 27)
d.rounded_rectangle((798, 521, 1510, 650), 12, fill="#fff6ef", outline=ORANGE, width=2)
text(820, 543, '"JAMENDO_CLIENT_ID":', 30, bold=True)
text(850, 590, '"你自己的应用标识"', 28, ORANGE)
text(805, 725, "修改配置后，停止 App 并重新运行", 27, MUTED)
save("05-jamendo.png")

thumbs = []
for path in sorted(OUT.glob("0*.png")):
    image = Image.open(path)
    image.thumbnail((800, 475))
    thumbs.append(image.copy())
contact = Image.new("RGB", (1600, 475 * 3), "#e6e6e6")
for i, thumb in enumerate(thumbs):
    contact.paste(thumb, ((i % 2) * 800, (i // 2) * 475))
contact.save(ROOT / "build_temp/setup-contact.png")
print(f"Rendered {len(thumbs)} setup diagrams to {OUT}")
