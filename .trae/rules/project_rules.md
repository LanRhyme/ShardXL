# ShardXL 项目规则
# .rules

## 项目概述
ShardXL 是一个跨平台 Minecraft Java 版启动器，使用 Flutter 开发 UI 层，Rust 编写核心游戏逻辑。支持桌面（Windows/macOS/Linux）和 Android 平台。

## 项目架构

### 目录结构
```
ShardXL/
├── lib/                          # Flutter Dart 代码
│   ├── core/                     # 核心模块
│   │   ├── theme/                # 主题系统 (shadcn 风格)
│   │   ├── widgets/              # 通用组件
│   │   └── utils/                # 工具类
│   ├── features/                 # 功能模块
│   │   └── [feature]/
│   │       ├── pages/            # 页面
│   │       ├── providers/        # Riverpod Providers
│   │       └── widgets/          # 功能组件
│   ├── frb/                      # Flutter Rust Bridge 绑定
│   │   └── shardxl_ffi_bindings.dart
│   └── main.dart
├── external/
│   ├── ShardXL-Lib/              # Rust 核心库 (跨平台游戏逻辑)
│   │   └── crates/
│   │       ├── auth/             # 认证模块
│   │       ├── core/             # 核心功能
│   │       ├── event/            # 事件系统
│   │       ├── java/             # Java 运行时管理
│   │       ├── launch/           # 游戏启动逻辑
│   │       ├── loaders/          # 模组加载器 (Fabric/Forge/NeoForge/Quilt/OptiFine)
│   │       └── version/          # 版本管理
│   └── ShardXL-AndroidCore/      # Android 平台核心 (PojavLauncher 移植)
│       └── app_pojavlauncher/
│           ├── src/main/java/    # Java 层
│           └── src/main/jni/     # JNI 原生层
└── assets/                       # 静态资源
    ├── icons/                    # 图标资源
    └── fonts/                    # 字体资源
```

### 技术栈
| 层级 | 技术 |
|------|------|
| UI 框架 | Flutter 3.41.6+ |
| 状态管理 | Flutter Riverpod |
| 主题系统 | Material 3 + shadcn-ui 风格 |
| 核心逻辑 | Rust (ShardXL-Lib) |
| FFI 绑定 | Flutter Rust Bridge / 手动 FFI |
| Android 核心 | PojavLauncher 移植 |

## 设计风格 - shadcn-ui

### 核心设计原则
1. **简洁克制** - 避免过度装饰，功能优先
2. **一致性** - 统一的圆角、间距、阴影
3. **微妙动效** - 平滑的过渡动画，不过于花哨
4. **深色优先** - 默认深色主题，浅色主题作为备选

### UI 组件规范
- **圆角**: 默认 6px，卡片 16px，按钮 8px
- **边框**: 细边框 (1px)，低透明度 (5-10%)
- **阴影**: 悬停时显示，使用 primary 色调
- **间距**: 8px 基准单位

### 已有组件 (优先使用)
| 组件 | 文件 | 用途 |
|------|------|------|
| GlassCard | `core/widgets/glass_card.dart` | 毛玻璃卡片容器 |
| ShadcnButton | `core/widgets/shadcn_button.dart` | shadcn 风格按钮 |
| ShadcnInput | `core/widgets/shadcn_components.dart` | 输入框 |
| ShadcnBadge | `core/widgets/shadcn_components.dart` | 标签徽章 |
| ShadcnTabs | `core/widgets/shadcn_components.dart` | 选项卡 |
| ShadcnProgress | `core/widgets/shadcn_components.dart` | 进度条 |
| ShadcnSwitch | `core/widgets/shadcn_components.dart` | 开关 |
| ShadcnTooltip | `core/widgets/shadcn_components.dart` | 提示框 |
| ShardBottomNavBar | `core/widgets/shard_bottom_nav_bar.dart` | 底部导航栏 |
| ShardBackground | `core/widgets/shard_background.dart` | 背景效果 |

### 不要重复造轮子
编写 UI 时：
1. 先检查 `core/widgets/` 是否已有类似组件
2. 复用现有组件，通过参数定制
3. 如需新组件，确保风格与现有组件一致

## Rust 核心库规则 (ShardXL-Lib)

### 模块职责
| Crate | 职责 |
|-------|------|
| auth | 微软/离线/Azuriom 认证 |
| core | 应用状态、下载、解压、哈希 |
| event | 事件系统，跨模块通信 |
| java | Java 发行版管理、下载、安装 |
| launch | 游戏启动、实例管理、参数构建 |
| loaders | 模组加载器查询、安装 (Fabric/Forge/NeoForge/Quilt/OptiFine) |
| version | 版本构建、元数据处理 |

### FFI 绑定规则
- Dart 侧绑定文件: `lib/frb/shardxl_ffi_bindings.dart`
- 字符串传递: UTF-8 编码，使用 `utf8.decode` 处理
- 内存管理: Rust 侧分配，Dart 侧调用释放函数
- 错误处理: 返回 Result 类型，Dart 侧捕获异常

### 添加新 FFI 函数
1. 在 Rust 侧实现函数并导出
2. 在 `shardxl_ffi_bindings.dart` 添加绑定
3. 处理字符串编码 (UTF-8)
4. 添加错误处理和内存释放

## Android 平台规则 (ShardXL-AndroidCore)

### 核心组件
- **PojavLauncher**: Android 上运行 Minecraft Java 版的核心
- **JNI 层**: OpenGL ES/Vulkan 渲染桥接
- **Java 层**: 游戏启动、输入处理、日志

### 注意事项
- Android 特定逻辑放在 `ShardXL-AndroidCore`
- 跨平台逻辑放在 `ShardXL-Lib`
- JNI 函数命名遵循 `Java_net_kdt_pojavlaunch_` 前缀

## 代码规范

### 1. 命名规范
| 类型 | 规范 | 示例 |
|------|------|------|
| 文件名 | snake_case | `game_instance_page.dart` |
| 类名 | PascalCase | `GameInstancePage` |
| 变量/方法 | camelCase | `selectedVersion` |
| 常量 | SCREAMING_SNAKE_CASE | `DEFAULT_BORDER_RADIUS` |
| Provider | xxxProvider | `installedVersionsProvider` |
| Rust 函数 | snake_case | `get_installed_versions` |

### 2. 主题使用规范
```dart
// 正确: 使用 ColorScheme
final colorScheme = Theme.of(context).colorScheme;
Container(color: colorScheme.primaryContainer);

// 错误: 硬编码颜色
Container(color: Color(0xFF7C4DFF));
```

### 3. 状态管理规范
- 使用 Riverpod Notifier 管理复杂状态
- Provider 放在 `features/[name]/providers/` 目录
- 全局 Provider 放在 `core/providers/` 目录

### 4. 注释规范
- 所有文件头部添加中文说明
- 公开 API 添加文档注释 (`///`)
- 复杂逻辑添加行内注释
- Rust 代码添加英文文档注释

### 5. 依赖管理
- 优先使用已有依赖
- 新增依赖需在 `pubspec.yaml` 添加版本约束
- Rust 依赖在 `Cargo.toml` 管理

## 错误处理
- Dart: 使用 try-catch 处理异步操作
- Rust: 使用 Result<T, E> 类型
- FFI: 捕获异常，返回空值或默认值

## 测试规范
- Rust 核心逻辑必须有单元测试
- Flutter UI 组件使用 widget 测试
- 关键路径添加集成测试
