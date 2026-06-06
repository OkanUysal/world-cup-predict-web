import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/error_message.dart';
import '../../core/widgets/responsive_container.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginNameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginChannelController = TextEditingController();

  final _registerNameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerChannelController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _errorMessage = null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginNameController.dispose();
    _loginPasswordController.dispose();
    _loginChannelController.dispose();
    _registerNameController.dispose();
    _registerPasswordController.dispose();
    _registerChannelController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await _submit(() => ref.read(authProvider.notifier).login(
          name: _loginNameController.text.trim(),
          password: _loginPasswordController.text,
          channelCode: _loginChannelController.text.trim().isEmpty
              ? null
              : _loginChannelController.text.trim(),
        ));
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    await _submit(() => ref.read(authProvider.notifier).register(
          name: _registerNameController.text.trim(),
          password: _registerPasswordController.text,
          channelCode: _registerChannelController.text.trim(),
        ));
  }

  Future<void> _submit(Future<void> Function() action) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await action();
      if (mounted) context.go('/events');
    } catch (e) {
      setState(() => _errorMessage = friendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.sports_soccer,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Dünya Kupası Tahmin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Arkadaşlarınla tahmin yap, puan topla!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Giriş'),
                    Tab(text: 'Kayıt'),
                  ],
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildLoginForm()
                        : _buildRegisterForm();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginNameController,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı Adı',
              prefixIcon: Icon(Icons.person),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Kullanıcı adı gerekli' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.isEmpty ? 'Şifre gerekli' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _loginChannelController,
            decoration: const InputDecoration(
              labelText: 'Kanal Kodu (opsiyonel)',
              prefixIcon: Icon(Icons.group),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitLogin(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitLogin,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _registerNameController,
            decoration: const InputDecoration(
              labelText: 'Kullanıcı Adı',
              prefixIcon: Icon(Icons.person),
            ),
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Kullanıcı adı gerekli' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerPasswordController,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              prefixIcon: Icon(Icons.lock),
              helperText: 'En az 6 karakter',
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Şifre gerekli';
              if (v.length < 6) return 'En az 6 karakter olmalı';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _registerChannelController,
            decoration: const InputDecoration(
              labelText: 'Kanal Kodu',
              prefixIcon: Icon(Icons.group),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitRegister(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Kanal kodu gerekli' : null,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submitRegister,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Kayıt Ol'),
          ),
        ],
      ),
    );
  }
}
