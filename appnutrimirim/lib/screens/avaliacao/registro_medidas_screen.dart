import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models.dart';
import '../../repositories/repositorios.dart';
import '../../repositories/validacao.dart';
import '../../utils/formatters.dart';
import '../../data/oms_assets.dart';
import '../../routes.dart';
import '../../services/antropometria_oms.dart';
import '../../services/relatorio_avaliacao.dart';
import '../../services/resultado_nutricional.dart';
import '../../services/validadores.dart';
import '../../widgets/common.dart';
import '../../widgets/estado_assincrono.dart';

/// TELA 06 — Registro e conferência das medidas, sem diagnóstico fictício.
class RegistroMedidasScreen extends StatefulWidget {
  const RegistroMedidasScreen({
    super.key,
    this.crianca,
    this.carregarTabelas,
    this.compartilharTexto,
    this.avaliacao,
    this.repositorio,
  });
  final Crianca? crianca;
  final Future<TabelasOms> Function()? carregarTabelas;
  final Future<void> Function(String texto)? compartilharTexto;
  final Avaliacao? avaliacao;
  final AvaliacaoRepository? repositorio;

  @override
  State<RegistroMedidasScreen> createState() => _RegistroMedidasScreenState();
}

class _RegistroMedidasScreenState extends State<RegistroMedidasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peso = TextEditingController();
  final _altura = TextEditingController();
  final _data = TextEditingController();
  final _nascimentoTexto = TextEditingController();
  final _motivo = TextEditingController();
  final _resultadoKey = GlobalKey();
  Crianca? _crianca;
  bool _carregandoCrianca = false;
  String? _erroCrianca;
  DateTime? _nascimento, _dataEscolhida;
  PosicaoMedicao? _posicao;
  bool? _edema;
  bool _inicializado = false, _carregando = false;
  String? _erroCarregamento;
  ValidacaoAntropometrica? _resultado;
  Avaliacao? _avaliacaoInicial;
  bool _salvando = false;
  String? _erroSalvar;
  String? _novoId;

  @override
  void initState() {
    super.initState();
    _peso.addListener(_invalidar);
    _altura.addListener(_invalidar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    _avaliacaoInicial =
        widget.avaliacao ?? (argumento is Avaliacao ? argumento : null);
    final a = _avaliacaoInicial;
    if (a != null) {
      _peso.text = formatarMedidaParaEdicao(a.pesoKg);
      _altura.text = formatarMedidaParaEdicao(a.alturaCm);
      _dataEscolhida = a.data;
      _data.text = formatarData(a.data);
      _posicao = a.tipoMedida == 'deitado'
          ? PosicaoMedicao.deitado
          : a.tipoMedida == 'em_pe'
          ? PosicaoMedicao.emPe
          : null;
      _edema = a.edema;
    }
    _crianca = widget.crianca ?? (argumento is Crianca ? argumento : null);
    _aplicarNascimento();
    final id = a?.criancaId ?? (argumento is String ? argumento : null);
    if (_crianca == null && id != null) {
      _carregandoCrianca = true;
      _carregarCrianca(id);
    }
  }

  Future<void> _carregarCrianca(String id) async {
    Crianca? c;
    String? erro;
    try {
      c = await Repositorios.criancas.porId(id);
      if (c == null) erro = 'Criança não encontrada.';
    } on RepositorioException catch (e) {
      erro = e.mensagem;
    } catch (_) {
      erro = 'Não foi possível carregar os dados da criança.';
    }
    if (!mounted) return;
    setState(() {
      _carregandoCrianca = false;
      _erroCrianca = erro;
      if (c != null) {
        _crianca = c;
        _aplicarNascimento();
      }
    });
  }

  void _aplicarNascimento() {
    _nascimento = _crianca?.nascimento;
    _nascimentoTexto.text = _nascimento == null
        ? ''
        : formatarData(_nascimento!);
  }

  @override
  void dispose() {
    for (final c in [_peso, _altura, _data, _nascimentoTexto, _motivo]) {
      c.dispose();
    }
    super.dispose();
  }

  void _invalidar() {
    if (_resultado != null || _erroCarregamento != null) {
      setState(() {
        _resultado = null;
        _erroCarregamento = null;
        _erroSalvar = null;
      });
    }
  }

  Future<void> _escolherData() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final atual = _dataEscolhida;
    final data = await showDatePicker(
      context: context,
      initialDate: atual != null && !atual.isAfter(hoje) && atual.year >= 1900
          ? atual
          : hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (!mounted || data == null) return;
    setState(() {
      _resultado = null;
      _dataEscolhida = data;
      _data.text = formatarData(data);
    });
  }

  String? _validarData(String? _) {
    if (_dataEscolhida == null) return 'Escolha a data da medição';
    if (_nascimento != null && idadeEmDias(_nascimento!, _dataEscolhida!) < 0) {
      return 'Data anterior ao nascimento';
    }
    return null;
  }

  Future<void> _validar() async {
    if (_crianca != null && !_crianca!.ativa) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro desativado: não é possível registrar avaliação.',
          ),
        ),
      );
      return;
    }
    if (_carregando || _crianca == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _carregando = true;
      _resultado = null;
      _erroCarregamento = null;
    });
    try {
      final tabelas = await (widget.carregarTabelas ?? carregarTabelasOms)();
      if (!mounted) return;
      // Revalida após o carregamento: o usuário pode ter editado os campos.
      if (!_formKey.currentState!.validate()) return;
      final resultado = tabelas.validar(
        sexo: _crianca!.sexo == Sexo.masculino
            ? SexoOms.masculino
            : SexoOms.feminino,
        nascimento: _nascimento,
        medicao: _dataEscolhida,
        hoje: DateTime.now(),
        pesoKg: interpretarMedida(_peso.text),
        alturaCm: interpretarMedida(_altura.text),
        posicao: _posicao,
        edema: _edema,
      );
      setState(() => _resultado = resultado);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _resultadoKey.currentContext;
        if (mounted && ctx != null) Scrollable.ensureVisible(ctx);
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _erroCarregamento =
              'Não foi possível carregar as referências OMS. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _salvar(ResultadoNutricional resultado) async {
    if (_salvando || _resultado == null || !_formKey.currentState!.validate()) {
      return;
    }
    final repo = widget.repositorio ?? Repositorios.avaliacoes;
    final inicial = _avaliacaoInicial;
    final classificacao = resultado.classificacao;
    final indicadores = {
      for (final i in classificacao.indicadores)
        i.indicador.chave: Indicador(
          i.indicador.nome,
          i.zScore,
          situacaoDe(i.gravidade, i.desvio),
        ),
    };
    final avaliacao = Avaliacao(
      id: inicial?.id ?? (_novoId ??= repo.novoId()),
      criancaId: _crianca!.id,
      data: _dataEscolhida!,
      pesoKg: interpretarMedida(_peso.text)!,
      alturaCm: interpretarMedida(_altura.text)!,
      tipoMedida: _posicao == PosicaoMedicao.deitado ? 'deitado' : 'em_pe',
      edema: _edema,
      situacao: classificacao.edema
          ? Situacao.abaixo
          : situacaoDe(classificacao.gravidade, classificacao.pior.desvio),
      indicadores: indicadores,
      desnutricao: classificacao.desnutricao,
      retornoSugerido: resultado.retorno,
      criadoEm: inicial?.criadoEm,
      profissionalId: inicial?.profissionalId,
      profissionalNome: inicial?.profissionalNome,
      profissionalPapel: inicial?.profissionalPapel,
    );
    setState(() {
      _salvando = true;
      _erroSalvar = null;
    });
    var concluido = false;
    try {
      validarAvaliacao(avaliacao, DateTime.now());
      if (inicial == null) {
        await repo.registrar(avaliacao);
      } else {
        await repo.corrigir(avaliacao, motivo: _motivo.text.trim());
      }
      concluido = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            inicial == null
                ? 'Avaliação salva.'
                : 'Correção salva com histórico da alteração.',
          ),
        ),
      );
      if (inicial != null && Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(
          context,
          Routes.resultado,
          arguments: resultado,
        );
      }
    } on RepositorioException catch (e) {
      if (mounted) setState(() => _erroSalvar = e.mensagem);
    } catch (_) {
      if (mounted) {
        setState(
          () => _erroSalvar =
              'Não foi possível salvar. Confira a conexão e tente novamente.',
        );
      }
    } finally {
      if (mounted && !concluido) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final crianca = _crianca;
    if (_carregandoCrianca || _erroCrianca != null) {
      return Scaffold(
        appBar: const BackAppBar(title: 'Registro de Medidas'),
        body: _erroCrianca != null
            ? MensagemCentro(_erroCrianca!, icone: Icons.error_outline)
            : const CarregandoCentro(),
      );
    }
    return Scaffold(
      appBar: BackAppBar(
        title: _avaliacaoInicial == null
            ? 'Registro de Medidas'
            : 'Corrigir avaliação',
      ),
      body: crianca == null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Selecione uma criança para validar as medidas por idade e sexo.',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.listaCriancas),
                    child: const Text('Selecionar criança'),
                  ),
                ],
              ),
            )
          : AbsorbPointer(
              absorbing: _salvando,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (!crianca.ativa) ...[
                      const AvisoDesativado(),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      crianca.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Conferência das medidas pela referência OMS. Informe os dados observados nesta avaliação.',
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Nascimento',
                      controller: _nascimentoTexto,
                      required: true,
                      readOnly: true,
                      hint: 'DD/MM/AAAA',
                      icon: Icons.cake_outlined,
                      validator: (_) => _nascimento == null
                          ? 'Informe o nascimento no cadastro da criança'
                          : null,
                    ),
                    TextButton(
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          Routes.cadastroCrianca,
                          arguments: crianca.id,
                        );
                        if (mounted) {
                          _invalidar();
                          await _carregarCrianca(crianca.id);
                        }
                      },
                      child: const Text('Editar cadastro da criança'),
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      controller: _peso,
                      label: 'Peso (kg)',
                      required: true,
                      hint: 'Ex.: 12,5',
                      icon: Icons.scale_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: validarMedida,
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      controller: _altura,
                      label: 'Altura/Comprimento (cm)',
                      required: true,
                      hint: 'Ex.: 85,0',
                      icon: Icons.straighten,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: validarMedida,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Posição da medição', required: true),
                    DropdownButtonFormField<PosicaoMedicao>(
                      initialValue: _posicao,
                      isExpanded: true,
                      hint: const Text('Selecione'),
                      items: const [
                        DropdownMenuItem(
                          value: PosicaoMedicao.deitado,
                          child: Text('Deitado (comprimento)'),
                        ),
                        DropdownMenuItem(
                          value: PosicaoMedicao.emPe,
                          child: Text('Em pé (altura)'),
                        ),
                      ],
                      onChanged: (v) {
                        _invalidar();
                        setState(() => _posicao = v);
                      },
                      validator: (v) => v == null ? 'Informe a posição' : null,
                    ),
                    const SizedBox(height: 16),
                    const FieldLabel('Edema bilateral nos pés', required: true),
                    DropdownButtonFormField<bool>(
                      initialValue: _edema,
                      isExpanded: true,
                      hint: const Text('Selecione'),
                      items: const [
                        DropdownMenuItem(value: false, child: Text('Ausente')),
                        DropdownMenuItem(value: true, child: Text('Presente')),
                      ],
                      onChanged: (v) {
                        _invalidar();
                        setState(() => _edema = v);
                      },
                      validator: (v) =>
                          v == null ? 'Informe se há edema' : null,
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      controller: _data,
                      label: 'Data da medição',
                      required: true,
                      validator: _validarData,
                      hint: 'DD/MM/AAAA',
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      onTap: _escolherData,
                    ),
                    const SizedBox(height: 24),
                    if (_avaliacaoInicial != null) ...[
                      const Text(
                        'A correção exige motivo. O autor pode corrigir antes de completar 15 minutos do registro; o administrador pode corrigir depois desse prazo.',
                      ),
                      const SizedBox(height: 12),
                      LabeledField(
                        label: 'Motivo da correção',
                        controller: _motivo,
                        required: true,
                        validator: (v) =>
                            (v ?? '').trim().length < 3 ||
                                (v ?? '').trim().length > 200
                            ? 'Informe de 3 a 200 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: _carregando ? null : _validar,
                      child: Text(
                        _carregando ? 'Validando...' : 'Validar medidas',
                      ),
                    ),
                    if (_erroCarregamento != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(_erroCarregamento!),
                      ),
                    if (_resultado != null) _resumo(_resultado!),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _resumo(ValidacaoAntropometrica resultado) {
    final crianca = _crianca;
    final dataAvaliacao = _dataEscolhida;
    final nutricional = crianca == null || dataAvaliacao == null
        ? null
        : montarResultadoNutricional(
            criancaId: crianca.id,
            validacao: resultado,
            dataAvaliacao: dataAvaliacao,
            nascimento: _nascimento,
            edema: _edema ?? false,
          );
    return Padding(
      key: _resultadoKey,
      padding: const EdgeInsets.only(top: 24),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Validação OMS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final erro in resultado.erros) Text(erro),
            if (resultado.precisaConferencia)
              const Text(
                'Confira peso, altura, nascimento e data da medição. Há valores fora dos limites de plausibilidade.',
              ),
            if (resultado.erros.isEmpty &&
                !resultado.precisaConferencia &&
                !resultado.temIndisponiveis)
              const Text(
                'Sem alertas de plausibilidade. Isso não significa estado nutricional normal.',
              ),
            if (resultado.medidaAjustadaCm != null &&
                (resultado.medidaAjustadaCm! - interpretarMedida(_altura.text)!)
                        .abs() >
                    0.001)
              Text(
                'Medida usada no cálculo: ${formatarDecimal(resultado.medidaAjustadaCm!)} cm. A medida original foi mantida.',
              ),
            for (final indicador in resultado.indicadores)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${indicador.indicador.rotulo}: '
                  '${indicador.zScore == null ? 'indisponível' : 'z = ${formatarDecimal(indicador.zScore!, casas: 2)}'}'
                  '${indicador.estado == EstadoPlausibilidade.conferir ? ' — conferir medida' : ''}'
                  '${indicador.motivo == null ? '' : '\n${indicador.motivo}'}',
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Prévia: as medidas só serão gravadas ao salvar a avaliação.',
            ),
            const SizedBox(height: 16),
            if (nutricional != null) ...[
              if (_erroSalvar != null)
                Text(
                  _erroSalvar!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (_salvando)
                const Text(
                  'Aguardando confirmação do salvamento. Sem conexão, o envio aguarda a rede.',
                ),
              ElevatedButton.icon(
                onPressed: _salvando ? null : () => _salvar(nutricional),
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  _salvando
                      ? 'Salvando...'
                      : _avaliacaoInicial == null
                      ? 'Salvar avaliação'
                      : 'Salvar correção',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.resultado,
                  arguments: nutricional,
                ),
                icon: const Icon(Icons.assessment_outlined),
                label: const Text('Ver resultado'),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: () => _compartilharRelatorio(resultado),
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartilhar relatório'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _compartilharRelatorio(ValidacaoAntropometrica resultado) async {
    final crianca = _crianca;
    final nascimento = _nascimento;
    final dataAvaliacao = _dataEscolhida;
    if (crianca == null || nascimento == null || dataAvaliacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe os dados da criança e da avaliação.'),
        ),
      );
      return;
    }

    final texto = gerarRelatorioAvaliacao(
      crianca: crianca,
      nascimento: nascimento,
      dataAvaliacao: dataAvaliacao,
      validacao: resultado,
    );

    try {
      final compartilhar = widget.compartilharTexto;
      if (compartilhar != null) {
        await compartilhar(texto);
        return;
      }

      final resultadoCompartilhamento = await SharePlus.instance.share(
        ShareParams(
          text: texto,
          subject: 'Relatório NutriMirim - ${crianca.nome}',
        ),
      );
      if (resultadoCompartilhamento.status == ShareResultStatus.unavailable &&
          mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O compartilhamento não está disponível.'),
          ),
        );
      }
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível compartilhar o relatório.'),
        ),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O compartilhamento não está disponível.'),
        ),
      );
    }
  }
}
