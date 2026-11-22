import 'package:flutter/material.dart';

import '../data/models.dart';
import '../repositories/repositorios.dart';
import '../theme/app_palette.dart';
import 'common.dart';

/// Indicador de carregamento centralizado (telas que leem dos repositórios).
class CarregandoCentro extends StatelessWidget {
  const CarregandoCentro({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: 'Carregando',
      child: const CircularProgressIndicator(),
    ),
  );
}

/// Mensagem de erro/ausência centralizada, em português, sem estourar 360 dp.
class MensagemCentro extends StatelessWidget {
  const MensagemCentro(this.mensagem, {super.key, this.icone});

  final String mensagem;
  final IconData? icone;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 32, color: context.cores.textoSecundario),
            const SizedBox(height: 12),
          ],
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.cores.textoSecundario,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Acompanha ao vivo (`observarPorId`) a criança da rota e as avaliações dela nos repositórios.
///
/// [argumento] é o argumento de rota: `String` (id) ou [Crianca]. Sem
/// argumento usa [idPadrao] (a criança em destaque, `c0`). Para um [Crianca]
/// recebido, os dados atuais vêm do repositório; se ele não a tiver, vale o
/// próprio objeto. Id inexistente mostra "Criança não encontrada".
/// O Future e o Stream são criados uma vez (não a cada rebuild).
class CriancaComAvaliacoes extends StatefulWidget {
  const CriancaComAvaliacoes({
    super.key,
    required this.argumento,
    required this.titulo,
    required this.builder,
    this.idPadrao = 'c0',
  });

  final Object? argumento;
  final String titulo;
  final String idPadrao;

  /// [avaliacoes] vem da mais recente para a mais antiga.
  final Widget Function(
    BuildContext context,
    Crianca crianca,
    List<Avaliacao> avaliacoes,
  )
  builder;

  @override
  State<CriancaComAvaliacoes> createState() => _CriancaComAvaliacoesState();
}

class _CriancaComAvaliacoesState extends State<CriancaComAvaliacoes> {
  late final String _id;
  late final Stream<Crianca?> _crianca;
  late final Stream<List<Avaliacao>> _avaliacoes;

  @override
  void initState() {
    super.initState();
    final arg = widget.argumento;
    _id = arg is Crianca
        ? arg.id
        : arg is String
        ? arg
        : widget.idPadrao;
    _crianca = Repositorios.criancas.observarPorId(_id);
    _avaliacoes = Repositorios.avaliacoes.observarDe(_id);
  }

  Widget _moldura(Widget corpo) => Scaffold(
    appBar: BackAppBar(title: widget.titulo),
    body: corpo,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Crianca?>(
      stream: _crianca,
      builder: (context, snapC) {
        if (snapC.hasError) {
          return _moldura(
            const MensagemCentro(
              'Não foi possível carregar os dados da criança.',
              icone: Icons.error_outline,
            ),
          );
        }
        if (snapC.connectionState == ConnectionState.waiting) {
          return _moldura(const CarregandoCentro());
        }
        final arg = widget.argumento;
        final c = snapC.data ?? (arg is Crianca ? arg : null);
        if (c == null) {
          return _moldura(
            const MensagemCentro(
              'Criança não encontrada.',
              icone: Icons.search_off,
            ),
          );
        }
        return StreamBuilder<List<Avaliacao>>(
          stream: _avaliacoes,
          builder: (context, snapA) {
            if (snapA.hasError) {
              return _moldura(
                const MensagemCentro(
                  'Não foi possível carregar as avaliações.',
                  icone: Icons.error_outline,
                ),
              );
            }
            if (!snapA.hasData) return _moldura(const CarregandoCentro());
            return widget.builder(context, c, snapA.data!);
          },
        );
      },
    );
  }
}

/// Aviso de cadastro desativado (a criança continua visível, mas não aceita
/// edição nem novas avaliações).
class AvisoDesativado extends StatelessWidget {
  const AvisoDesativado({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cores.textoSecundario.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.block, size: 20, color: context.cores.textoSecundario),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Cadastro desativado',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}
