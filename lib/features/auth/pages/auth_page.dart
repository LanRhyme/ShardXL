import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/shard_card.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  bool _showTotpField = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('登录')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (authState.isAuthenticated) ...[
              _buildAuthenticatedCard(authState),
            ] else if (authState.isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else ...[
              if (authState.error != null)
                ShardCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      authState.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _buildOfflineAuth(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildMicrosoftAuth(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildElyByAuth(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedCard(AuthState authState) {
    String methodName = '离线';
    if (authState.authMethod == AuthMethod.microsoft) {
      methodName = 'Microsoft';
    } else if (authState.authMethod == AuthMethod.elyBy) {
      methodName = 'Ely.by';
    }

    return ShardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              '已登录: ${authState.username}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'UUID: ${authState.uuid}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '认证方式: $methodName',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineAuth() {
    return ShardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 32),
                const SizedBox(width: 12),
                Text(
                  '离线模式',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '无需网络连接，直接使用用户名登录。\n适合测试或无法访问在线认证的情况。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
                hintText: '输入用户名 (3-16字符)',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final username = _usernameController.text;
                if (username.isNotEmpty) {
                  ref.read(authProvider.notifier).authenticateOffline(username);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入用户名')),
                  );
                }
              },
              child: const Text('离线登录'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrosoftAuth() {
    return ShardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.desktop_windows),
                ),
                const SizedBox(width: 12),
                Text(
                  'Microsoft 账户',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '使用 Microsoft 账户登录 Minecraft Java Edition。\n（需要 ShardXL-Lib FFI 支持）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Microsoft 认证即将支持')),
                );
              },
              child: const Text('配置 Microsoft 认证'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElyByAuth() {
    return ShardCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Ely.by 账户',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '使用 Ely.by 账户登录。（即将支持）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),
            if (_showTotpField) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _totpController,
                decoration: const InputDecoration(
                  labelText: 'TOTP 验证码',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ely.by 认证即将支持')),
                );
              },
              child: const Text('登录 (即将支持)'),
            ),
          ],
        ),
      ),
    );
  }
}
