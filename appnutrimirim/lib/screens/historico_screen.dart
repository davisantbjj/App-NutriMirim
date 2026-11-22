import 'package:flutter/material.dart';

import '../data/models.dart';
import '../repositories/repositorios.dart';
import '../routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../widgets/estado_assincrono.dart';
import '../utils/formatters.dart';

/// TELA 09 — Histórico de avaliações (mais recente primeiro).
class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  Stream<List<Avaliacao>>? _avaliacoes;
  Stream<List<Crianca>>? _criancas;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_avaliacoes != null) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    final criancaId = arg is String
        ? arg
        : arg is Crianca
        ? arg.id
        : null;
    _avaliacoes = criancaId == null
        ? Repositorios.avaliacoes.observarTodas()
        : Repositorios.avaliacoes.observarDe(criancaId);
    _criancas = Repositorios.criancas.observarTodas();
  }

  Widget _moldura(Widget corpo) => Scaffold(
    appBar: const BackAppBar(title: 'Histórico'),
    body: corpo,
    bottomNavigationBar: const AppBottomNav(current: NavTab.historico),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Avaliacao>>(
      stream: _avaliacoes,
      builder: (context, snap) {
        if (snap.hasError) {
          return _moldura(
            const MensagemCentro(
              'Não foi possível carregar o histórico.',
              icone: Icons.error_outline,
            ),
          );
        }
        if (!snap.hasData) return _moldura(const CarregandoCentro());
        // Nomes das crianças ativas, atualizados ao vivo; crianças desativadas
        // (que mantêm histórico) são buscadas por id em cada item.
        return StreamBuilder<List<Crianca>>(
          stream: _criancas,
          builder: (context, snapC) {
            if (snapC.hasError) {
              return _moldura(
                const MensagemCentro(
                  'Não foi possível carregar o histórico.',
                  icone: Icons.error_outline,
                ),
              );
            }
            if (!snapC.hasData) return _moldura(const CarregandoCentro());
            final nomes = {for (final c in snapC.data!) c.id: c.nome};
            return _lista(context, snap.data!, nomes);
          },
        );
      },
    );
  }

  Widget _lista(
    BuildContext context,
    List<Avaliacao> itens,
    Map<String, String> nomes,
  ) {
    return _moldura(
      ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        children: [
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'Nenhuma avaliação registrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.cores.textoSecundario),
              ),
            ),
          for (final a in itens)
            Padding(
              key: ValueKey(a.id),
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.dadosCrianca,
                  arguments: a.criancaId,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NomeCrianca(
                            id: a.criancaId,
                            nome: nomes[a.criancaId],
                          ),
                          Text(
                            formatarData(a.data),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Peso: ${formatarNumero(a.pesoKg)} kg  |  Altura: ${formatarAltura(a.alturaCm)}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(a.situacao, dense: true),
                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Nome da criança no item do histórico. Se ela não está entre as ativas
/// (foi desativada), busca por id uma única vez.
class _NomeCrianca extends StatefulWidget {
  const _NomeCrianca({required this.id, this.nome});

  final String id;
  final String? nome;

  @override
  State<_NomeCrianca> createState() => _NomeCriancaState();
}

class _NomeCriancaState extends State<_NomeCrianca> {
  Future<Crianca?>? _porId;

  @override
  void initState() {
    super.initState();
    if (widget.nome == null) _porId = Repositorios.criancas.porId(widget.id);
  }

  @override
  void didUpdateWidget(_NomeCrianca old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _porId = widget.nome == null
          ? Repositorios.criancas.porId(widget.id)
          : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(fontWeight: FontWeight.w700, fontSize: 14);
    if (widget.nome != null) return Text(widget.nome!, style: estilo);
    _porId ??= Repositorios.criancas.porId(widget.id);
    return FutureBuilder<Crianca?>(
      future: _porId,
      builder: (context, snap) => Text(snap.data?.nome ?? '', style: estilo),
    );
  }
}
