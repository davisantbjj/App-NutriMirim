import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/mock_data.dart';
import '../../utils/formatters.dart';
import '../../data/oms_assets.dart';
import '../../routes.dart';
import '../../services/antropometria_oms.dart';
import '../../services/validadores.dart';
import '../../widgets/common.dart';

/// TELA 06 — Registro e conferência das medidas, sem diagnóstico fictício.
class RegistroMedidasScreen extends StatefulWidget {
  const RegistroMedidasScreen({super.key, this.crianca, this.carregarTabelas});
  final Crianca? crianca;
  final Future<TabelasOms> Function()? carregarTabelas;

  @override
  State<RegistroMedidasScreen> createState() => _RegistroMedidasScreenState();
}

class _RegistroMedidasScreenState extends State<RegistroMedidasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peso = TextEditingController();
  final _altura = TextEditingController();
  final _data = TextEditingController();
  final _nascimentoTexto = TextEditingController();
  final _resultadoKey = GlobalKey();
  Crianca? _crianca;
  DateTime? _nascimento, _dataEscolhida;
  PosicaoMedicao? _posicao;
  bool? _edema;
  bool _inicializado = false, _carregando = false;
  String? _erroCarregamento;
  ValidacaoAntropometrica? _resultado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    _inicializado = true;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    _crianca =
        widget.crianca ??
        (argumento is Crianca
            ? argumento
            : argumento is String
            ? MockData.criancaPorId(argumento)
            : null);
    _nascimento = _crianca?.nascimento;
    _nascimentoTexto.text = _nascimento == null
        ? ''
        : formatarData(_nascimento!);
  }

  @override
  void dispose() {
    for (final c in [_peso, _altura, _data, _nascimentoTexto]) {
      c.dispose();
    }
    super.dispose();
  }

  void _invalidar() {
    if (_resultado != null || _erroCarregamento != null) {
      setState(() {
        _resultado = null;
        _erroCarregamento = null;
      });
    }
  }

  Future<void> _escolherData({bool nascimento = false}) async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final atual = nascimento ? _nascimento : _dataEscolhida;
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
      if (nascimento) {
        _nascimento = data;
        _nascimentoTexto.text = formatarData(data);
      } else {
        _dataEscolhida = data;
        _data.text = formatarData(data);
      }
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

  @override
  Widget build(BuildContext context) {
    final crianca = _crianca;
    return Scaffold(
      appBar: const BackAppBar(title: 'Registro de Medidas'),
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
          : Form(
              key: _formKey,
              onChanged: _invalidar,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
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
                    onTap: () => _escolherData(nascimento: true),
                    validator: (_) => _nascimento == null
                        ? 'Escolha a data de nascimento'
                        : null,
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
                    validator: (v) => v == null ? 'Informe se há edema' : null,
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
    );
  }

  Widget _resumo(ValidacaoAntropometrica resultado) {
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
                'Medida usada no cálculo: ${resultado.medidaAjustadaCm!.toStringAsFixed(1).replaceAll('.', ',')} cm. A medida original foi mantida.',
              ),
            for (final indicador in resultado.indicadores)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${indicador.indicador.rotulo}: '
                  '${indicador.zScore == null ? 'indisponível' : 'z = ${indicador.zScore!.toStringAsFixed(2).replaceAll('.', ',')}'}'
                  '${indicador.estado == EstadoPlausibilidade.conferir ? ' — conferir medida' : ''}'
                  '${indicador.motivo == null ? '' : '\n${indicador.motivo}'}',
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Esta conferência não substitui a avaliação nutricional. Os dados desta tela ainda não são salvos.',
            ),
          ],
        ),
      ),
    );
  }
}
