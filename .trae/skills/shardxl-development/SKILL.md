---
name: "shardxl-development"
description: "ShardXL cross-platform Minecraft Java launcher development assistant. Invoke when developing Flutter UI, Rust backend, FFI bindings, or Android platform features for ShardXL project."
---

# ShardXL Development Skill

ShardXL 跨平台 Minecraft Java 版启动器开发辅助技能。

## 能力范围

### Flutter UI 开发
- shadcn-ui 设计风格实现
- Material 3 主题系统
- Riverpod 状态管理
- 毛玻璃效果组件
- 响应式布局

### Rust 后端开发
- FFI 绑定编写
- 游戏启动逻辑
- 版本管理
- 模组加载器集成
- 认证系统

### Android 平台开发
- PojavLauncher 集成
- JNI 原生层开发
- OpenGL ES/Vulkan 渲染

## 上下文感知

### 项目类型
type: cross_platform_app
framework: flutter
backend: rust
state_management: riverpod
theme_system: material3_shadcn

### 目标平台
platforms:
  - windows
  - macos
  - linux
  - android

### 核心目录
directories:
  flutter_ui: lib/
  rust_core: external/ShardXL-Lib/
  android_core: external/ShardXL-AndroidCore/
  ffi_bindings: lib/frb/shardxl_ffi_bindings.dart

### 技术约束
constraints:
  - UI 使用 shadcn-ui 设计风格
  - 游戏逻辑使用 Rust 实现
  - 默认深色模式
  - 支持毛玻璃效果
  - UTF-8 字符串编码 (FFI)

## 代码生成规则

### Flutter 组件生成
生成组件时：
1. 优先复用 `core/widgets/` 已有组件
2. 使用 ConsumerWidget 或 ConsumerStatefulWidget
3. 通过 ref 访问 Provider
4. 使用 Theme.of(context) 获取主题
5. 添加 const 构造函数
6. 遵循 shadcn-ui 设计规范

### Provider 生成
生成 Provider 时：
1. 使用 Notifier 处理复杂状态
2. 提供 copyWith 方法
3. 实现持久化逻辑
4. 添加错误处理

### Rust FFI 函数生成
添加新 FFI 函数时：
1. 在 Rust 侧实现并导出
2. 在 shardxl_ffi_bindings.dart 添加绑定
3. 使用 `utf8.decode` 处理字符串
4. 添加内存释放函数
5. Dart 侧捕获异常

## 已有组件库

### UI 组件 (core/widgets/)
| 组件 | 用途 |
|------|------|
| GlassCard | 毛玻璃卡片容器 |
| ShadcnButton | shadcn 风格按钮 |
| ShadcnInput | 输入框 |
| ShadcnBadge | 标签徽章 |
| ShadcnTabs | 选项卡 |
| ShadcnProgress | 进度条 |
| ShadcnSwitch | 开关 |
| ShadcnTooltip | 提示框 |
| ShardBottomNavBar | 底部导航栏 |
| ShardBackground | 背景效果 |

### Rust 模块 (external/ShardXL-Lib/crates/)
| Crate | 职责 |
|-------|------|
| auth | 微软/离线/Azuriom 认证 |
| core | 应用状态、下载、解压、哈希 |
| event | 事件系统，跨模块通信 |
| java | Java 发行版管理、下载、安装 |
| launch | 游戏启动、实例管理、参数构建 |
| loaders | 模组加载器 (Fabric/Forge/NeoForge/Quilt/OptiFine) |
| version | 版本构建、元数据处理 |

## shadcn-ui 设计规范

### 核心原则
1. 简洁克制 - 避免过度装饰
2. 一致性 - 统一圆角、间距、阴影
3. 微妙动效 - 平滑过渡，不过于花哨
4. 深色优先 - 默认深色主题

### 尺寸规范
- 圆角: 默认 6px，卡片 16px，按钮 8px
- 边框: 1px，透明度 5-10%
- 阴影: 悬停时显示，primary 色调
- 间距: 8px 基准单位

### 颜色使用
```dart
// 正确: 使用 ColorScheme
final colorScheme = Theme.of(context).colorScheme;
Container(color: colorScheme.primaryContainer);

// 错误: 硬编码颜色
Container(color: Color(0xFF7C4DFF));
```

## FFI 绑定示例

### 字符串处理
```dart
// Rust 返回 UTF-8 字符串
String _fromCString(Pointer<Int8> ptr) {
  if (ptr == nullptr) return '';
  final bytes = <int>[];
  var i = 0;
  while (true) {
    final b = ptr.elementAt(i).value;
    if (b == 0) break;
    bytes.add(b & 0xFF);
    i++;
  }
  return utf8.decode(bytes);
}
```

### 调用 Rust 函数
```dart
List<String> getInstalledVersions(String gameDirectory) {
  final gameDirPtr = _toCString(gameDirectory);
  final countPtr = calloc<Int64>();
  try {
    final resultPtr = shardxlFfi.getInstalledVersionsFunc(gameDirPtr, countPtr);
    // 处理结果...
    shardxlFfi.freeStringArrayFunc(resultPtr, count);
    return versions;
  } finally {
    calloc.free(gameDirPtr);
    calloc.free(countPtr);
  }
}
```

## 调试技能

### 常见问题
1. **版本列表不显示**: 检查 FFI 字符串编码，确保使用 utf8.decode
2. **玻璃效果不显示**: 检查 enableGlassEffect 和 cardOpacity
3. **点击事件无效**: 检查 Stack 中的 Positioned.fill 是否阻挡事件
4. **颜色不正确**: 检查 ColorScheme.fromSeed 参数

### 性能优化
1. 使用 const 构造函数
2. 避免不必要的 rebuild
3. 使用 Selector 精确监听
4. Rust 侧避免频繁内存分配

## 开发工作流

### 添加新功能
1. 在 Rust 侧实现核心逻辑 (ShardXL-Lib)
2. 添加 FFI 绑定 (shardxl_ffi_bindings.dart)
3. 创建 Provider 封装 (features/[name]/providers/)
4. 实现 UI 页面 (features/[name]/pages/)
5. 复用已有组件 (core/widgets/)

### 添加新 UI 组件
1. 检查 core/widgets/ 是否已有类似组件
2. 遵循 shadcn-ui 设计规范
3. 支持深色/浅色主题
4. 添加 hoverable 等交互属性

## Git 提交规范
| 前缀 | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复 bug |
| refactor | 重构代码 |
| docs | 文档更新 |
| style | 样式调整 |
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具 |
