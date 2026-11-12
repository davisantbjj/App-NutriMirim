import 'package:flutter/material.dart';

import '../app_state.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';

/// TELA 11 — Perfil Profissional.
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificacoes = true;
  String _ultimaSync = '28/09/2026 às 08:42';

  void _sincronizar() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    setState(
      () => _ultimaSync =
          '${two(n.day)}/${two(n.month)}/${n.year} às ${two(n.hour)}:${two(n.minute)}',
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dados sincronizados.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackAppBar(title: 'Perfil Profissional'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 44, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ana Souza de Oliveira',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Text(
            'Agente Comunitária de Saúde',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 22),
          const Text(
            'Suas Informações',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const InfoRow('ID Funcional', 'ACS-482910'),
          const InfoRow('UBS Vinculada', 'UBS Jardim das Flores'),
          const InfoRow('Telefone', '(79) 12345-6789'),
          Center(
            child: TextButton(
              onPressed: null,
              child: const Text('Editar dados (em breve)'),
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_done_outlined,
                  color: AppColors.textMuted,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última sincronização',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _ultimaSync,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _sincronizar,
                  child: const Text(
                    'Sincronizar',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preferências',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _SwitchTile(
            icon: Icons.notifications_none,
            label: 'Notificações',
            value: _notificacoes,
            onChanged: (v) => setState(() => _notificacoes = v),
          ),
          const SizedBox(height: 5),
          ValueListenableBuilder<bool>(
            valueListenable: highContrast,
            builder: (_, hc, _) => _SwitchTile(
              icon: Icons.contrast,
              label: 'Alto Contraste',
              value: hc,
              onChanged: (v) => highContrast.value = v,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 170,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  // Texto em tom escuro (contraste AA); borda mantém o vermelho.
                  foregroundColor: AppColors.statusBadText,
                  side: const BorderSide(color: AppColors.red),
                  textStyle: const TextStyle(
                    fontFamily: 'Almarai',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.login,
                  (_) => false,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(current: NavTab.perfil),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: AppColors.textMuted, size: 24),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
