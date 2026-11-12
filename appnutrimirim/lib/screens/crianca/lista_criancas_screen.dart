import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/common.dart';

/// TELA 12 — Cadastro de Crianças (lista com busca e filtro).
class ListaCriancasScreen extends StatefulWidget {
  const ListaCriancasScreen({super.key});

  @override
  State<ListaCriancasScreen> createState() => _ListaCriancasScreenState();
}

class _ListaCriancasScreenState extends State<ListaCriancasScreen> {
  String _busca = '';
  Sexo? _sexo;

  String _normalizarTexto(String texto) {
    const caracteresAcentuados = {
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'í': 'i',
      'ì': 'i',
      'î': 'i',
      'ï': 'i',
      'ó': 'o',
      'ò': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ú': 'u',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'ñ': 'n',
    };

    return texto.toLowerCase().replaceAllMapped(
      RegExp('[${caracteresAcentuados.keys.join()}]'),
      (match) => caracteresAcentuados[match[0]] ?? match[0]!,
    );
  }

  Future<void> _filtrar() async {
    final escolha = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Filtrar por sexo',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            ListTile(
              title: const Text('Todos'),
              onTap: () => Navigator.pop(ctx, 'todos'),
            ),
            ListTile(
              leading: const Icon(Icons.female),
              title: const Text('Feminino'),
              onTap: () => Navigator.pop(ctx, Sexo.feminino),
            ),
            ListTile(
              leading: const Icon(Icons.male),
              title: const Text('Masculino'),
              onTap: () => Navigator.pop(ctx, Sexo.masculino),
            ),
          ],
        ),
      ),
    );
    if (escolha == null) return;
    setState(() => _sexo = escolha is Sexo ? escolha : null);
  }

  @override
  Widget build(BuildContext context) {
    final lista = MockData.criancas
        .where(
          (c) =>
              _normalizarTexto(c.nome).contains(_normalizarTexto(_busca)) &&
              (_sexo == null || c.sexo == _sexo),
        )
        .toList();

    return Scaffold(
      appBar: const BackAppBar(title: 'Cadastro de Crianças'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        children: [
          Row(
            children: [
              Expanded(
                flex: 7,
                child: TextField(
                  onChanged: (v) => setState(() => _busca = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar nome',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(112, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  foregroundColor: AppColors.textDark,
                  side: BorderSide(
                    color: _sexo == null ? AppColors.border : AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _filtrar,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Filtrar'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (lista.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Nenhuma criança encontrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          for (final c in lista)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.dadosCrianca,
                  arguments: c,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Cadastrado(a) em : ${c.cadastradoEm}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Bairro: ${c.bairro}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      c.sexo == Sexo.feminino ? Icons.female : Icons.male,
                      color: AppColors.textMuted,
                      size: 24,
                      semanticLabel: c.sexo == Sexo.feminino
                          ? 'Feminino'
                          : 'Masculino',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}
