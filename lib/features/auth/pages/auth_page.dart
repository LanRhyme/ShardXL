import 'package:dartcraft/dartcraft.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/glass_card.dart';

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
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      authState.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
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
    return GlassCard(
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
              '认证方式: ${authState.authMethod == AuthMethod.microsoft ? "Microsoft" : "Ely.by"}',
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

  Widget _buildMicrosoftAuth() {
    return GlassCard(
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
              '使用 Microsoft 账户登录 Minecraft Java Edition。\n请先在 Azure Portal 注册应用程序获取 Client ID。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _showMicrosoftConfigDialog(),
              child: const Text('配置 Microsoft 认证'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElyByAuth() {
    return GlassCard(
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
              onPressed: () => _loginWithElyBy(false),
              child: const Text('登录'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMicrosoftConfigDialog() {
    final clientIdController = TextEditingController();
    final redirectUriController = TextEditingController(
      text: 'http://localhost:8080/callback',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microsoft 认证配置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: clientIdController,
              decoration: const InputDecoration(
                labelText: 'Client ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: redirectUriController,
              decoration: const InputDecoration(
                labelText: 'Redirect URI',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (clientIdController.text.isNotEmpty) {
                MicrosoftAuth.configure(
                  clientId: clientIdController.text,
                  redirectUri: redirectUriController.text,
                );
                _showMicrosoftAuthCodeDialog();
              }
            },
            child: const Text('下一步'),
          ),
        ],
      ),
    );
  }

  void _showMicrosoftAuthCodeDialog() {
    final authCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入授权码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请打开浏览器访问授权 URL，完成授权后将显示的代码粘贴到下方。',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: authCodeController,
              decoration: const InputDecoration(
                labelText: '授权码',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (authCodeController.text.isNotEmpty) {
                Navigator.pop(context);
                ref
                    .read(authProvider.notifier)
                    .authenticateWithMicrosoft(authCodeController.text);
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _loginWithElyBy(bool isTwoFactor) {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码')),
      );
      return;
    }

    if (isTwoFactor || _showTotpField) {
      final totp = _totpController.text;
      if (totp.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入 TOTP 验证码')),
        );
        return;
      }
      ref.read(authProvider.notifier).authenticateWithElyByTwoFactor(
            username,
            password,
            totp,
          );
    } else {
      ref.read(authProvider.notifier).authenticateWithElyBy(
            username,
            password,
          );
    }
  }
}
