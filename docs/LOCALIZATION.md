# 界面语言

MusicPod 支持 English、简体中文、日本語，默认跟随设备语言。不支持的设备语言会回退到英语。

## 在 App 中切换

- 英语界面：**Settings → Languages → App language**。
- 中文界面：**设置 → 语言 → 界面语言**。
- 日语界面：**設定 → 言語 → 表示言語**。
- 未登录时，也可以通过登录页的语言入口切换；游客和登录用户都能使用。

选择后立即生效，重启后保留。这个选择保存在当前设备，不跟随账号切换，也不会被云端资料库覆盖。选择“跟随设备”后，App 会响应设备语言变化。

界面语言与下方的音乐内容语言偏好是两项设置。切换界面不会翻译歌曲、播客标题、艺人名称、节目简介或用户输入的歌单名称；也不会自动翻译音频或按语言筛选曲库。内置播客按照节目语言分组，可继续选择中文、日语或英语节目。

## 更新后首次运行

本次增加了 Flutter 语言支持依赖和翻译资源。如果 App 仍在运行旧版本，先停止后重新运行：

```powershell
flutter pub get
flutter run -d chrome --web-port=7357 --dart-define-from-file=config/local.json
```

以后在 App 内切换语言不需要重启，不需要新的 Key，也不需要重新执行 Supabase SQL 或部署函数。

## 文案维护

- `assets/i18n/ui.json`：以英语界面原文为键，每个值依次为中文和日语翻译。
- `lib/l10n/app_strings.dart`：Flutter 本地化代理，缓存文案并处理参数替换；Material 组件使用 Flutter 官方语言支持。
- 在界面代码中显式使用 `context.tr('Interface copy')`；动态数量和名称使用 `{count}`、`{name}` 等参数。不要把用户或内容服务返回的标题直接当作界面文案翻译。
- 排序、设置、内容偏好的内部状态键保留原值，只翻译展示文本，避免切换语言后改变数据含义。
- 修改翻译时保留两个译文以及全部参数名。新增界面文案需要同时补齐中文和日语。

## 验证

```powershell
flutter analyze --no-pub
flutter test --enable-vmservice --concurrency=1
```

测试覆盖切换、设备语言回退、持久保存、原文名称保留，以及中日文在 320/428 屏宽下的全部页面布局。

当前 Windows / Dart 3.13.5 环境存在已报告的测试分析器崩溃问题（[Dart SDK #64627](https://github.com/dart-lang/sdk/issues/64627)）。`--enable-vmservice` 允许测试启动配置仅在这个环境下关闭测试进程的采样分析器；没有修改 Flutter SDK、App 的构建配置或服务权限。其他系统和版本跳过这项处理。
