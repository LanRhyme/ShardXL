// ShardXL 开发者选项弹窗
// lib/features/settings/widgets/developer_options_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_model.dart';
import '../../../core/notifications/notification_manager.dart';
import '../../../core/widgets/shadcn_button.dart';

class DeveloperOptionsDialog extends ConsumerWidget {
  const DeveloperOptionsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const DeveloperOptionsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, colorScheme),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '通知测试',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '发送不同类型的通知以测试通知系统',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.show(
                                AppNotification(
                                  title: '临时通知',
                                  message: '这是一条临时通知，3秒后自动消失。',
                                  type: NotificationType.temporary,
                                ),
                              );
                            },
                            variant: ShadcnButtonVariant.secondary,
                            child: const Text('发送临时通知'),
                          ),
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.show(
                                AppNotification(
                                  title: '普通通知',
                                  message: '这是一条持久化的普通通知。',
                                  type: NotificationType.normal,
                                ),
                              );
                            },
                            child: const Text('发送普通通知'),
                          ),
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.show(
                                AppNotification(
                                  title: '警告通知',
                                  message: '这是一个警告级别的通知。',
                                  type: NotificationType.warning,
                                ),
                              );
                            },
                            variant: ShadcnButtonVariant.outline,
                            child: const Text('发送警告通知'),
                          ),
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.show(
                                AppNotification(
                                  title: '错误通知',
                                  message: '这是一个错误级别的通知。',
                                  type: NotificationType.error,
                                ),
                              );
                            },
                            variant: ShadcnButtonVariant.destructive,
                            child: const Text('发送错误通知'),
                          ),
                          ShadcnButton(
                            onPressed: () {
                              final id = DateTime.now().millisecondsSinceEpoch
                                  .toString();
                              NotificationManager.show(
                                AppNotification(
                                  id: id,
                                  title: '下载进度',
                                  message: 'minecraft-1.20.4.jar',
                                  type: NotificationType.progress,
                                  progress: 0.0,
                                ),
                              );

                              var progress = 0.0;
                              Future.doWhile(() async {
                                await Future.delayed(
                                  const Duration(milliseconds: 200),
                                );
                                progress += 0.05;
                                if (progress <= 1.0) {
                                  NotificationManager.updateProgress(
                                    id,
                                    progress,
                                  );
                                  return true;
                                }

                                NotificationManager.dismiss(id);
                                NotificationManager.show(
                                  AppNotification(
                                    title: '下载完成',
                                    message: 'minecraft-1.20.4.jar 已下载完成。',
                                    type: NotificationType.temporary,
                                  ),
                                );
                                return false;
                              });
                            },
                            child: const Text('发送进度通知'),
                          ),
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.show(
                                AppNotification(
                                  title: '可点击通知',
                                  message: '点击查看详情。',
                                  type: NotificationType.normal,
                                  isClickable: true,
                                ),
                              );
                            },
                            variant: ShadcnButtonVariant.secondary,
                            child: const Text('发送可点击通知'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ShadcnButton(
                            onPressed: () {
                              NotificationManager.clearAll();
                            },
                            variant: ShadcnButtonVariant.destructive,
                            child: const Text('清除所有通知'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.code_outlined,
              size: 22,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开发者选项',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '高级调试和开发设置',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
