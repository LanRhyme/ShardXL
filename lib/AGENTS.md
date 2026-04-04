# lib/ — Flutter UI 层

## OVERVIEW
Dart/Flutter 源码根目录。包含应用入口、共享组件、功能模块、FFI 绑定。

## STRUCTURE
```
lib/
├── main.dart             # 应用入口 (ShardXLApp, HomePage)
├── core/                 # 共享组件
│   ├── theme/            # 主题系统 (ShardThemeExtension)
│   ├── widgets/          # shadcn-ui 风格组件库
│   └── notifications/    # 通知系统
├── features/             # 功能模块 (feature-based)
├── frb/                  # FFI 绑定 (Rust ↔ Dart)
├── examples/             # 示例代码
└── lighty_launcher.dll   # Rust 编译产物 (勿手动编辑)
```

## WHERE TO LOOK
| Task | Location |
|------|----------|
| 应用初始化 | `main.dart` |
| 主题配置 | `core/theme/shard_theme.dart` |
| 通用组件 | `core/widgets/shadcn_components.dart` |
| FFI 结构体定义 | `frb/shardxl_ffi_bindings.dart` |

## CONVENTIONS
- 每个 feature 目录遵循 `pages/`, `providers/`, `widgets/` 结构
- 组件命名: `Shadcn` 前缀 (UI), `Shard` 前缀 (业务)
- Provider 命名: 以 `Provider` 结尾, 使用 `riverpod`

## ANTI-PATTERNS
- 不要在此目录放 Rust 源码
- `lighty_launcher.dll` 是编译产物, 不要手动修改
