import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../repositories/repositorios.dart';
import '../../utils/formatters.dart';
import '../../routes.dart';
import '../../services/validadores.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_palette.dart';
import '../../utils/input_formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/estado_assincrono.dart';

/// TELA 05 — Cadastro da Criança (ficha de identificação).
class CadastroCriancaScreen extends StatefulWidget {
  const CadastroCriancaScreen({super.key, this.repositorio});
  final CriancaRepository? repositorio;

  @override
  State<CadastroCriancaScreen> createState() => _CadastroCriancaScreenState();
}

class _CadastroCriancaScreenState extends State<CadastroCriancaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpfCrianca = TextEditingController();
  final _nascimento = TextEditingController();
  final _bairro = TextEditingController();
  final _responsavel = TextEditingController();
  final _cpfResponsavel = TextEditingController();
  final _contato = TextEditingController();
  final _ubsTexto = TextEditingController();
  final _motivo = TextEditingController();
  final _nascimentoKey = GlobalKey<FormFieldState<String>>();
  final _sexoKey = GlobalKey<FormFieldState<Sexo>>();
  DateTime? _dataNascimento;
  bool _salvando = false;
  String? _erroSalvar;
  String? _novoId;
  String? _ubsId;
  Map<String, String> get _unidades {
    final s = Repositorios.sessao;
    if (s == null) return {};
    return {
      for (final id in s.master ? s.nomesUbs.keys : s.ubsIds)
        id: s.nomesUbs[id] ?? id,
    };
  }

  CriancaRepository get _repo => widget.repositorio ?? Repositorios.criancas;
  Crianca? _criancaInicial;
  bool _preenchido = false;
  bool _carregandoCrianca = false;
  String? _erroCrianca;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preenchido) return;
    _preenchido = true;
    final sessao = Repositorios.sessao;
    if (_unidades.containsKey(sessao?.ubsAtualId)) {
      _ubsId = sessao!.ubsAtualId;
    } else if (_unidades.length == 1) {
      _ubsId = _unidades.keys.single;
    }
    _ubsTexto.text = sessao == null
        ? ''
        : sessao.nomesUbs[sessao.ubsAtualId] ?? sessao.ubsAtualId;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    if (argumento is Crianca) {
      _preencher(argumento);
    } else if (argumento is String) {
      // Edicao por id: mostra "carregando" (sem formulario, para nao perder o
      // que o usuario digitar) ate o repositorio responder.
      _carregandoCrianca = true;
      _carregarCrianca(argumento);
    }
  }

  Future<void> _carregarCrianca(String id) async {
    String? erro;
    try {
      final c = await _repo.porId(id);
      if (!mounted) return;
      if (c == null) {
        erro = 'Criança não encontrada.';
      } else {
        _preencher(c);
      }
    } on RepositorioException catch (e) {
      erro = e.mensagem;
    } catch (_) {
      erro = 'Não foi possível carregar os dados da criança.';
    }
    if (!mounted) return;
    setState(() {
      _carregandoCrianca = false;
      _erroCrianca = erro;
    });
  }

  void _preencher(Crianca crianca) {
    _criancaInicial = crianca;
    _nome.text = crianca.nome;
    _cpfCrianca.text = const CpfInputFormatter()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: crianca.cpf),
        )
        .text;
    _dataNascimento = crianca.nascimento;
    _nascimento.text = crianca.nascimento == null
        ? ''
        : formatarData(crianca.nascimento!);
    _bairro.text = crianca.bairro;
    _ubsTexto.text = crianca.ubs;
    _responsavel.text = crianca.responsavel?.nome ?? '';
    _cpfResponsavel.text = crianca.responsavel?.cpf ?? '';
    _contato.text = crianca.responsavel?.telefone ?? '';
  }

  @override
  void dispose() {
    for (final controller in [
      _nome,
      _cpfCrianca,
      _nascimento,
      _bairro,
      _responsavel,
      _cpfResponsavel,
      _contato,
      _ubsTexto,
      _motivo,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherNascimento() async {
    final hoje = DateUtils.dateOnly(DateTime.now());
    final data = await showDatePicker(
      context: context,
      initialDate:
          _dataNascimento != null &&
              !_dataNascimento!.isAfter(hoje) &&
              _dataNascimento!.year >= 1900
          ? _dataNascimento!
          : hoje,
      firstDate: DateTime(1900),
      lastDate: hoje,
    );
    if (!mounted || data == null) return;
    _dataNascimento = data;
    _nascimento.text = formatarData(data);
    _nascimentoKey.currentState?.validate();
  }

  Future<void> _salvar() async {
    if (_salvando || !_formKey.currentState!.validate()) return;
    final inicial = _criancaInicial;
    final sessao = Repositorios.sessao;
    if (inicial != null && !inicial.ativa) return;
    if (inicial == null && (sessao == null || !_unidades.containsKey(_ubsId))) {
      setState(
        () => _erroSalvar =
            'Selecione uma UBS vinculada ao seu perfil antes de cadastrar.',
      );
      return;
    }
    final repo = _repo;
    final crianca = Crianca(
      id: inicial?.id ?? (_novoId ??= repo.novoId()),
      nome: _nome.text.trim(),
      cpf: _cpfCrianca.text,
      sexo: _sexoKey.currentState!.value!,
      bairro: _bairro.text.trim(),
      cadastradoEm: inicial?.cadastradoEm ?? DateTime.now(),
      nascimento: _dataNascimento,
      endereco: inicial?.endereco ?? '',
      ubs: inicial?.ubs ?? _unidades[_ubsId]!,
      microarea: inicial?.microarea,
      responsavel: Responsavel(
        nome: _responsavel.text.trim(),
        cpf: _cpfResponsavel.text,
        telefone: _contato.text.trim(),
        email: inicial?.responsavel?.email ?? '',
      ),
    );
    setState(() {
      _salvando = true;
      _erroSalvar = null;
    });
    var concluido = false;
    try {
      if (inicial == null) {
        await repo.cadastrar(crianca, ubsId: _ubsId);
      } else {
        await repo.editar(crianca, motivo: _motivo.text.trim());
      }
      concluido = true;
      if (!mounted) return;
      if (inicial == null) {
        Navigator.pushReplacementNamed(
          context,
          Routes.registroMedidas,
          arguments: crianca.id,
        );
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context, crianca.id);
      } else {
        Navigator.pushReplacementNamed(
          context,
          Routes.dadosCrianca,
          arguments: crianca.id,
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
    if (_carregandoCrianca || _erroCrianca != null) {
      return Scaffold(
        appBar: const BackAppBar(title: 'Cadastro da Criança'),
        body: _erroCrianca != null
            ? MensagemCentro(_erroCrianca!, icone: Icons.error_outline)
            : const CarregandoCentro(),
      );
    }
    const gap = SizedBox(height: 16);
    return Scaffold(
      appBar: const BackAppBar(title: 'Cadastro da Criança'),
      body: AbsorbPointer(
        absorbing: _salvando || _criancaInicial?.ativa == false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              if (_criancaInicial?.ativa == false) const AvisoDesativado(),
              const Text(
                'Dados de Identificação',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              gap,
              LabeledField(
                controller: _nome,
                label: 'Nome completo',
                required: true,
                hint: 'Digite o nome da criança',
              ),
              gap,
              LabeledField(
                controller: _cpfCrianca,
                label: 'CPF da criança',
                hint: '000.000.000-00',
                icon: Icons.child_care_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [CpfInputFormatter()],
                validator: (v) => validarCpf(v, obrigatorio: false),
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      controller: _nascimento,
                      fieldKey: _nascimentoKey,
                      label: 'Nascimento',
                      required: true,
                      hint: 'DD/MM/AAAA',
                      icon: Icons.cake_outlined,
                      readOnly: true,
                      onTap: _escolherNascimento,
                      validator: (_) => _dataNascimento == null
                          ? 'Escolha a data de nascimento'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _sexoToggle()),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      controller: _bairro,
                      label: 'Bairro',
                      required: true,
                      hint: 'Ex.: Centro',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _criancaInicial == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FieldLabel(
                                'UBS de Referência',
                                required: true,
                              ),
                              DropdownButtonFormField<String>(
                                initialValue: _ubsId,
                                isExpanded: true,
                                hint: const Text('Selecione a UBS'),
                                items: [
                                  for (final u in _unidades.entries)
                                    DropdownMenuItem(
                                      value: u.key,
                                      child: Text(
                                        u.value,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                                onChanged: (v) => setState(() => _ubsId = v),
                                validator: (v) =>
                                    v == null ? 'Selecione uma UBS' : null,
                              ),
                            ],
                          )
                        : LabeledField(
                            label: 'UBS de Referência',
                            controller: _ubsTexto,
                            readOnly: true,
                            hint: 'Selecione a UBS no perfil',
                          ),
                  ),
                ],
              ),
              gap,
              LabeledField(
                controller: _responsavel,
                label: 'Responsável legal',
                required: true,
                hint: 'Nome do pai, mãe ou tutor',
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      controller: _cpfResponsavel,
                      label: 'CPF Responsável',
                      required: true,
                      hint: '000.000.000-00',
                      keyboardType: TextInputType.number,
                      inputFormatters: [CpfInputFormatter()],
                      validator: (v) =>
                          v == _criancaInicial?.responsavel?.cpf &&
                              (v?.contains('*') ?? false)
                          ? null
                          : validarCpf(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LabeledField(
                      controller: _contato,
                      label: 'Contato',
                      required: true,
                      hint: '(00) 00000-0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: const [TelefoneInputFormatter()],
                    ),
                  ),
                ],
              ),
              if (_criancaInicial != null) ...[
                gap,
                LabeledField(
                  label: 'Motivo da alteração',
                  controller: _motivo,
                  required: true,
                  validator: (v) =>
                      (v ?? '').trim().length < 3 ||
                          (v ?? '').trim().length > 200
                      ? 'Informe de 3 a 200 caracteres'
                      : null,
                ),
              ],
              if (_erroSalvar != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _erroSalvar!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_salvando)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Aguardando confirmação do salvamento. Sem conexão, o envio aguarda a rede.',
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvando || _criancaInicial?.ativa == false
                    ? null
                    : _salvar,
                child: Text(
                  _salvando
                      ? 'Salvando...'
                      : _criancaInicial == null
                      ? 'Salvar e Continuar'
                      : 'Salvar alterações',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sexoToggle() {
    return FormField<Sexo>(
      key: _sexoKey,
      initialValue: _criancaInicial?.sexo,
      validator: (sexo) => sexo == null ? 'Selecione o sexo' : null,
      builder: (field) {
        Widget option(Sexo s, String label) {
          final selected = field.value == s;
          void selecionar() {
            field.didChange(s);
            field.validate();
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: s == Sexo.feminino ? 4 : 0),
              child: Semantics(
                label: label,
                button: true,
                selected: selected,
                inMutuallyExclusiveGroup: true,
                onTap: selecionar,
                excludeSemantics: true,
                child: Material(
                  color: selected
                      ? AppColors.primary
                      : context.cores.superficie,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: BorderSide(
                      color: selected ? AppColors.primary : context.cores.borda,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: selecionar,
                    child: SizedBox(
                      height: 48,
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: selected
                                ? Colors.white
                                : context.cores.textoSecundario,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Sexo', required: true),
            Row(
              children: [
                option(Sexo.masculino, 'Masculino'),
                option(Sexo.feminino, 'Feminino'),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
