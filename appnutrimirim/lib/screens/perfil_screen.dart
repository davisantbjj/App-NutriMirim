import 'package:flutter/material.dart';

import '../app_state.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../repositories/repositorios.dart';
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

  @override
  Widget build(BuildContext context) {
    final sessao = Repositorios.sessao;
    final cores = context.cores;
    final nome = sessao?.nome ?? 'Sessão não disponível';
    final papel = sessao?.nomePapel ?? 'Não informado';
    final ubsAtual = sessao?.nomesUbs[sessao.ubsAtualId] ??
        (sessao?.ubsAtualId.isNotEmpty == true ? sessao!.ubsAtualId : 'Não informado');
    final microarea = sessao?.microarea?.trim();
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
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          Text(
            papel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cores.textoSecundario,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Suas Informações',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          InfoRow('ID Funcional', sessao?.uid ?? 'Não informado'),
          InfoRow('UBS Vinculada', ubsAtual),
          InfoRow(
            'Microárea',
            microarea == null || microarea.isEmpty
                ? 'Não informada'
                : microarea,
          ),
          if (sessao?.papel == PapelProfissional.medico &&
              sessao!.ubsIds.length > 1) ...[
            const SizedBox(height: 8),
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'UBS atual',
                      style: TextStyle(
                        color: cores.texto,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  DropdownButton<String>(
                    value: sessao.ubsAtualId,
                    items: [
                      for (final id in sessao.ubsIds)
                        DropdownMenuItem(
                          value: id,
                          child: Text(sessao.nomesUbs[id] ?? id),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        setState(() => Repositorios.trocarUbsAtual(id));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
          if (sessao?.master == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Administrador: acesso a todas as UBS.',
                style: TextStyle(
                  color: cores.textoSecundario,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Center(
            child: TextButton(
              onPressed: null,
              child: const Text('Editar dados (em breve)'),
            ),
          ),
          const SizedBox(height: 20),
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
                onPressed: () async {
                  await authService.sair();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.login,
                    (_) => false,
                  );
                },
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
    final cores = context.cores;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: cores.icone, size: 24),
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
