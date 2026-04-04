# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-04
**Branch:** main

## OVERVIEW
ShardXL — 跨平台 Minecraft Java 版启动器。Flutter UI 层 + Rust 核心逻辑 (`external/ShardXL-Lib`) + Android 核心 (`external/ShardXL-AndroidCore`)。支持 Windows/macOS/Android。

## STRUCTURE
```
ShardXL/
├── lib/                    # Flutter/Dart 源码 (UI层)
│   ├── main.dart           # 应用入口
│   ├── core/               # 共享组件 (theme, widgets, notifications)
│   ├── features/           # 功能模块 (auth, download, game_instance, home, network, settings)
│   ├── frb/                # FFI 绑定 (Rust ↔ Dart)
│   └── examples/           # 示例代码
├── external/
│   ├── ShardXL-Lib/        # Rust 核心库 (LightyLauncher)
│   └── ShardXL-AndroidCore/ # Android 核心 (PojavLauncher 移植)
├── android/                # Android 平台集成
├── macos/                  # macOS 平台集成
├── windows/                # Windows 平台集成
├── assets/                 # 静态资源 (fonts, icons, images)
└── pubspec.yaml            # Flutter 依赖配置
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| 应用入口 | `lib/main.dart` | `ShardXLApp` + `HomePage` 底部导航 |
| 主题系统 | `lib/core/theme/shard_theme.dart` | `ShardThemeExtension`, 深色模式优先 |
| UI 组件 | `lib/core/widgets/` | shadcn-ui 风格: ShadcnButton, ShadcnInput, GlassCard 等 |
| 状态管理 | `lib/features/*/providers/` | Riverpod providers |
| FFI 绑定 | `lib/frb/shardxl_ffi_bindings.dart` | Rust ↔ Dart 手动绑定 |
| 通知系统 | `lib/core/notifications/` | NotificationManager, NotificationPanel |
| Rust 核心 | `external/ShardXL-Lib/` | Cargo workspace, 8 crates |
| Android 核心 | `external/ShardXL-AndroidCore/` | Gradle 多模块项目 |

## CONVENTIONS
- **状态管理**: Riverpod (`flutter_riverpod`), providers 放在 `features/*/providers/`
- **UI 风格**: shadcn-ui 设计语言, 深色模式优先, 毛玻璃效果, 默认圆角 6px
- **组件复用**: 优先使用 `core/widgets/` 已有组件
- **目录结构**: feature-based, 每个 feature 包含 `pages/`, `providers/`, `widgets/`
- **FFI**: 手动 Dart FFI 绑定 (非 flutter_rust_bridge 自动生成)
- **Rust 库**: 编译后复制到 `lib/lighty_launcher.dll` (Windows)

## ANTI-PATTERNS
- 不要在 `lib/` 中直接添加 Rust 代码 — 放 `external/ShardXL-Lib/`
- 不要绕过 `core/widgets/` 重复造组件 — 先检查已有实现
- 不要硬编码主题色 — 使用 `ShardThemeExtension`
- 不要混用状态管理方案 — 统一 Riverpod

## COMMANDS
```bash
# 获取依赖
flutter pub get

# 运行 (Windows)
flutter run -d windows

# 构建 (Windows)
flutter build windows

# 构建 Rust 核心
cd external/ShardXL-Lib && cargo build --release
# 复制产物到 lib/
```

## NOTES
- `lib/lighty_launcher.dll` 是编译产物, 不提交源码
- `.rules` 和 `.trae/rules/project_rules.md` 包含详细开发规则
- 窗口管理使用 `window_manager` + `bitsdojo_window` 双方案
- 最低窗口尺寸: 800x600, 默认: 1200x800
