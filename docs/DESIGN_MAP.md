# 设计稿与实现对应表

来源：Pixso 文件 **MusicPod**，页面 **Page 1（0:1）**。MCP 已检查全部页面分类，当前文件共 1 个分类、26 个界面。原稿只读提取，未修改设计文件。

MCP 的 Flutter 自动代码生成接口在批量和单页请求中均超时，最终使用 MCP 读取的图层、文字、尺寸、颜色和导出图片手工编写 Flutter 原生布局。没有使用整张设计截图代替可交互页面。

| 编号 | 界面 | Pixso 节点 | 实现文件 | App 截图 | 原稿 |
| --- | --- | --- | --- | --- | --- |
| 01 | 启动页 | `1:2` | [auth.dart](../lib/features/auth.dart) | [运行截图](screenshots/01-splash.png) | [原稿](reference/01-splash.png) |
| 02 | 手机号注册 | `1:31` | [auth.dart](../lib/features/auth.dart) | [运行截图](screenshots/02-signup.png) | [原稿](reference/02-signup.png) |
| 03 | 验证码 | `1:56` | [auth.dart](../lib/features/auth.dart) | [运行截图](screenshots/03-otp.png) | [原稿](reference/03-otp.png) |
| 04 | 首页 | `1:83` | [discover.dart](../lib/features/discover.dart) | [运行截图](screenshots/04-home.png) | [原稿](reference/04-home.png) |
| 05 | 专辑详情 | `2:2` | [playback.dart](../lib/features/playback.dart) | [运行截图](screenshots/05-album.png) | [原稿](reference/05-album.png) |
| 06 | 专辑排序浮层 | `2:132` | [playback.dart](../lib/features/playback.dart) | [运行截图](screenshots/06-album-filter.png) | [原稿](reference/06-album-filter.png) |
| 07 | 播放器 | `2:801` | [playback.dart](../lib/features/playback.dart) | [运行截图](screenshots/07-player.png) | [原稿](reference/07-player.png) |
| 08 | 歌曲更多选项 | `2:944` | [playback.dart](../lib/features/playback.dart) | [运行截图](screenshots/08-track-options.png) | [原稿](reference/08-track-options.png) |
| 09 | 播放队列 | `3:2` | [playback.dart](../lib/features/playback.dart) | [运行截图](screenshots/09-queue.png) | [原稿](reference/09-queue.png) |
| 10 | 搜索分类 | `3:1127` | [discover.dart](../lib/features/discover.dart) | [运行截图](screenshots/10-search.png) | [原稿](reference/10-search.png) |
| 11 | 关键词搜索 | `3:2149` | [discover.dart](../lib/features/discover.dart) | [运行截图](screenshots/11-search-results.png) | [原稿](reference/11-search-results.png) |
| 12 | 播客分类 | `3:2256` | [discover.dart](../lib/features/discover.dart) | [运行截图](screenshots/12-podcasts.png) | [原稿](reference/12-podcasts.png) |
| 13 | 播客详情 | `3:2401` | [discover.dart](../lib/features/discover.dart) | [运行截图](screenshots/13-podcast-detail.png) | [原稿](reference/13-podcast-detail.png) |
| 14 | 资料库·歌单 | `3:2570` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/14-library-playlists.png) | [原稿](reference/14-library-playlists.png) |
| 15 | 资料库·歌手 | `3:2713` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/15-library-artists.png) | [原稿](reference/15-library-artists.png) |
| 16 | 选择歌手 | `3:2984` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/16-choose-artists.png) | [原稿](reference/16-choose-artists.png) |
| 17 | 资料库·专辑 | `3:3071` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/17-library-albums.png) | [原稿](reference/17-library-albums.png) |
| 18 | 资料库·单集 | `3:3201` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/18-library-episodes.png) | [原稿](reference/18-library-episodes.png) |
| 19 | 资料库·下载 | `3:3355` | [library.dart](../lib/features/library.dart) | [运行截图](screenshots/19-library-downloads.png) | [原稿](reference/19-library-downloads.png) |
| 20 | 设置 | `3:3508` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/20-settings.png) | [原稿](reference/20-settings.png) |
| 21 | 账户 | `3:3635` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/21-account.png) | [原稿](reference/21-account.png) |
| 22 | 语言 | `3:3816` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/22-language.png) | [原稿](reference/22-language.png) |
| 23 | 流量节省 | `3:4009` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/23-data-saver.png) | [原稿](reference/23-data-saver.png) |
| 24 | 社交 | `3:4072` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/24-social.png) | [原稿](reference/24-social.png) |
| 25 | 播放设置 | `3:4141` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/25-playback.png) | [原稿](reference/25-playback.png) |
| 26 | 均衡器 | `3:4222` | [settings.dart](../lib/features/settings.dart) | [运行截图](screenshots/26-equalizer.png) | [原稿](reference/26-equalizer.png) |

原稿以 428px 宽度导出，首页、搜索和播客分类原稿包含超出手机视口的内容。App 中对应为可滚动页面，另有 `-more` 截图记录下半部分。系统状态栏使用运行设备的真实系统区域，没有绘制假键盘或假系统状态栏。
