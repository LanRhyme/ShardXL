# lib/core/widgets/ — shadcn-ui 组件库

## OVERVIEW
自定义 Flutter 组件集合, 遵循 shadcn-ui 设计语言。所有 UI 组件优先复用此目录。

## STRUCTURE
```
widgets/
├── shadcn_components.dart    # 核心组件: ShadcnBadge, ShadcnInput, ShadcnTabs, ShadcnAlert, ShadcnProgress, ShadcnSwitch, ShadcnTooltip, ShadcnSkeleton, ShadcnAvatar, ShadcnSeparator
├── shadcn_button.dart        # 按钮组件 (多variant)
├── shadcn_color_picker.dart  # 颜色选择器
├── shard_card.dart           # GlassCard 毛玻璃卡片
├── shard_background.dart     # 背景组件
├── shard_bottom_nav_bar.dart # 底部导航栏
├── shard_window_title_bar.dart # 桌面窗口标题栏
└── faded_edge_scroll_view.dart # 渐变边缘滚动视图
```

## CONVENTIONS
- 命名: `Shadcn` 前缀 (通用 UI), `Shard` 前缀 (业务相关)
- 圆角: 默认 6px, 通过 `ShardThemeExtension` 获取
- 深色模式: 所有组件必须支持 `Brightness.dark` 和 `Brightness.light`
- 主题色: 使用 `Theme.of(context).colorScheme` + `ShardThemeExtension`, 不硬编码

## ANTI-PATTERNS
- 不要在其他位置重复实现这些组件
- 不要在组件内硬编码颜色值
- 新增组件需同时支持深色/浅色模式
