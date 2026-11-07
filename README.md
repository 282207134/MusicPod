# MusicPod

基于 Pixso「MusicPod」设计稿开发的 Flutter 音乐与播客 App。通过 MCP 读取文件中的全部页面分类，确认当前文件只有 `Page 1`，共 26 个界面，已逐一实现。采用原稿的深色背景、橙色渐变、图片资源、Roboto 字体、圆形艺人卡片和常驻迷你播放器。

## 主要界面

以下图片为 **Android 模拟器中的 App 实际运行截图**；Pixso 原稿另存于 `docs/reference/`。

| 首页 | 搜索 | 播放器 |
| --- | --- | --- |
| ![首页](docs/screenshots/04-home.png) | ![搜索](docs/screenshots/10-search.png) | ![播放器](docs/screenshots/07-player.png) |

| 播客详情 | 资料库 | 设置 |
| --- | --- | --- |
| ![播客详情](docs/screenshots/13-podcast-detail.png) | ![资料库](docs/screenshots/14-library-playlists.png) | ![设置](docs/screenshots/20-settings.png) |

[查看全部 26 个界面及滚动补充截图](docs/GALLERY.md) · [查看设计稿节点与代码对应表](docs/DESIGN_MAP.md)

[下载 Android ARM64 演示安装包（26.5 MB）](dist/musicpod-android-arm64.apk) · [查看验证记录](docs/VALIDATION.md)

## 功能与演示方式

- **注册**：手机号校验、4 位 PIN 校验、重新提示 PIN、跳过注册。演示 PIN 为 **1234**，不发送短信。完成后会保存登录引导状态。
- **音乐发现**：最近播放、新发行、排行榜、推荐横向列表、专辑详情、专辑内搜索及排序。
- **播放器**：本地音频真实播放/暂停、拖动进度、上一首/下一首、随机、单曲重复、收藏、隐藏当前歌曲、添加队列和添加歌单。
- **队列**：点选播放、拖动排序、多选删除，与迷你播放器共享播放状态。
- **搜索与播客**：按歌曲或歌手实时搜索、空结果提示、分类浏览、播客详情、单集播放和本地保存标记。
- **资料库**：歌单、歌手、专辑、播客单集、已保存内容；支持创建歌单、添加歌曲及选择喜欢的歌手。
- **设置**：编辑用户名和邮箱、音乐语言偏好、流量节省、社交、播放设置、均衡器开关及预设曲线。
- **本地保存**：引导状态、资料、收藏、自建歌单及曲目、歌手和语言偏好、播客保存标记、设置项及均衡器预设。

### 演示范围

本项目交付可运行的 UI 和本地交互，不依赖服务端。设计稿中的歌手、曲名和封面用于还原界面，所有播放入口共用项目内的 **24 秒原创合成器试听音频**，不包含对应商业歌曲或真实播客录音。

“Downloads”展示本地保存标记，试听文件已随 App 打包，不执行远程下载。语言选项属于音乐内容偏好，界面文字沿用英文原稿。流量节省、社交、音频标准化、单声道和均衡器等设置保存本地状态；当前未连接内容服务、社交服务或 DSP 音效引擎。自动播放、随机和重复会实际影响试听播放。设备页显示当前设备，订阅页提供演示说明，不进行购买。

## 项目结构与架构

```text
MusicPod/
├── lib/
│   ├── main.dart               # 初始化、读取本地状态、启动 App
│   ├── app.dart                # 应用外壳、26 个页面入口、返回栈与底部栏
│   ├── core/
│   │   ├── catalog.dart        # 页面枚举、Track 模型、设计稿示例目录
│   │   ├── controller.dart     # 导航、播放、队列、搜索、歌单与本地保存
│   │   └── theme.dart          # 统一颜色、渐变、文字与控件主题
│   ├── features/
│   │   ├── auth.dart           # 启动、手机号注册、验证码
│   │   ├── discover.dart       # 首页、搜索、播客及单集卡片
│   │   ├── playback.dart       # 专辑、排序、播放器、更多选项、队列
│   │   ├── library.dart        # 资料库五类页面、选歌手、歌单操作
│   │   └── settings.dart       # 设置、账户、语言、偏好与均衡器
│   └── widgets/common.dart     # 图片、按钮、标题、搜索、歌曲行与底部栏
├── assets/
│   ├── images/                # 直接从 Pixso MCP 导出的独立图片和 Logo
│   ├── fonts/                 # Roboto 字体及许可证
│   └── audio/preview.wav      # 原创本地试听音频
├── test/                      # 状态逻辑、注册及三种屏宽的全页面检查
├── integration_test/          # Android 真机环境流程、音频和存储验证
├── tool/screenshot_driver.dart # 运行截图保存工具
├── docs/
│   ├── DESIGN_MAP.md          # 26 个设计节点 → 页面代码 → 截图
│   ├── GALLERY.md             # 全界面截图索引与预览
│   ├── VALIDATION.md          # 环境、验证结果与限制
│   ├── assets.json            # 图片资源与 Pixso 来源节点
│   ├── reference/             # 26 张 Pixso 原稿
│   └── screenshots/           # 26 张 App 截图与滚动补充图
├── android/ ios/ macos/ web/   # Flutter 平台工程
└── pubspec.yaml / pubspec.lock # 依赖声明与版本锁定
```

使用 Flutter 自带的 `ChangeNotifier` + `InheritedNotifier` 管理状态，没有引入额外状态管理框架。页面只负责布局及用户操作，`AppController` 统一处理状态与设备能力；目录数据与主题单独维护。

```mermaid
flowchart TD
    A[main.dart 读取本地状态] --> B[MusicPodApp / AppShell]
    B --> C[AppScope 共享状态]
    C --> D[五组功能页面]
    D --> E[AppController]
    E --> F[audioplayers 本地音频]
    E --> G[SharedPreferencesAsync 本地偏好]
    E --> H[catalog.dart 示例目录]
    D --> I[common.dart 公共控件]
```

`AppScreen` 为每张设计稿提供独立入口。底部四栏切换主分类；专辑、播放器和设置子页使用轻量返回栈。底部播放器与完整播放器共享同一个音频实例。排序浮层覆盖专辑页，播放器、队列、验证码和选择歌手等界面采用全屏布局。列表支持滚动，宽屏居中限制最大内容宽度，图片按可用空间适配。

代码按功能合并相近页面，复用歌曲行、播客单集、设置开关、播放器控制栏和公共主题，避免 26 份重复页面。生产依赖仅两个：[audioplayers](https://pub.dev/packages/audioplayers) 与 [shared_preferences](https://pub.dev/packages/shared_preferences)。

## 运行

开发验证环境：Flutter **3.41.6**、Dart **3.11.4**。依赖锁定文件已保留。

```bash
flutter pub get
flutter run -d emulator-5554
```

首次启动显示注册流程，可输入 7–15 位数字手机号，再输入 `1234`，或点击 `Skip`。后续启动进入首页。

其他平台可使用 `flutter run -d macos`、`flutter run -d chrome`，或在配置好签名与设备后运行 iOS 工程。Android 已完成模拟器验证；其他平台的设备能力仍需在目标环境验证。

```bash
# 静态检查和本地测试
flutter analyze
flutter test

# Android 模拟器完整流程及全部截图
flutter drive --driver=tool/screenshot_driver.dart \
  --target=integration_test/app_test.dart -d emulator-5554

# 构建 ARM64 安装包
flutter build apk --release --target-platform android-arm64 --split-per-abi
```

截图命令需要先启动 Android 模拟器，结果写入 `docs/screenshots/`。自动化测试使用独立的内存界面数据，不会把测试歌单加入正常演示目录；存储验证会写入并恢复演示账户的默认用户名与流量设置。

## 后续接入

可在 `catalog.dart` 的模型和 `AppController.play()` 入口替换真实音乐目录与音源，在注册页替换短信服务；内容下载、账号同步、设备投放、订阅与均衡器音效需要独立服务或平台实现。项目未配置生产签名，交付 APK 用于开发演示。
