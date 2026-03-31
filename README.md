# ShardXL

ShardXL - Minecraft Java Edition Launcher for Desktop & Android

## 项目结构

```
lib/
├── main.dart          # 应用入口点
assets/                # 资源文件
├── icons/            # 图标
├── images/           # 图片
android/              # Android平台文件
macos/                # macOS平台文件
windows/              # Windows平台文件
```

## 构建Windows应用

### 前置要求

1. 安装Flutter SDK (版本3.41.6+)
2. 安装Visual Studio 2022+，选择"Desktop development with C++"工作负载

### 构建步骤

1. 获取依赖：
   ```bash
   flutter pub get
   ```

2. 构建Windows应用：
   ```bash
   flutter build windows
   ```

3. 运行应用：
   ```bash
   flutter run -d windows
   ```

## 开发说明

- 使用Material Design 3主题
- 支持窗口管理 (window_manager)
- 支持多平台 (Android, macOS, Windows, 未来支持Linux)