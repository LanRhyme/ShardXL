# lib/features/ — 功能模块

## OVERVIEW
Feature-based 架构，每个功能模块独立 `pages/`, `providers/`, `widgets/`。

## STRUCTURE
```
features/
├── auth/              # 认证模块 (登录、账号管理)
│   ├── pages/auth_page.dart
│   └── providers/auth_provider.dart
├── download/          # 下载模块 (游戏版本、资源下载)
│   ├── pages/download_page.dart
│   ├── pages/game_version_list_page.dart
│   └── pages/version_download_detail_page.dart
├── game_instance/     # 游戏实例管理
│   ├── pages/game_instance_page.dart
│   ├── pages/instance_config_page.dart
│   └── providers/ (game_instances, game, instance_config)
├── home/              # 主页
│   └── pages/home_page.dart
├── network/           # 碎片网络
│   └── pages/network_page.dart
└── settings/          # 设置模块
    ├── pages/ (settings, theme, game, launcher, about, other)
    ├── providers/theme_provider.dart
    └── widgets/developer_options_dialog.dart
```

## CONVENTIONS
- 每个 feature 包含: `pages/` (页面), `providers/` (状态), `widgets/` (局部组件)
- 状态管理: 统一使用 Riverpod
- 页面导航: 通过 `main.dart` 的底部导航切换

## WHERE TO LOOK
| 功能 | 入口文件 |
|------|----------|
| 用户认证 | `auth/pages/auth_page.dart` |
| 版本下载 | `download/pages/download_page.dart` |
| 实例管理 | `game_instance/pages/game_instance_page.dart` |
| 应用主页 | `home/pages/home_page.dart` |
| 全局设置 | `settings/pages/settings_page.dart` |
