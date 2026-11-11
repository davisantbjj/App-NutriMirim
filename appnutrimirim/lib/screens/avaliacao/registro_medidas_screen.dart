import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../routes.dart';
import '../../widgets/common.dart';
import '../../utils/formatters.dart';

/// TELA 06 — Registro de Medidas antropométricas.
class RegistroMedidasScreen extends StatefulWidget {
  const RegistroMedidasScreen({super.key});

  @override
  State<RegistroMedidasScreen> createState() => _RegistroMedidasScreenState();
}

class _RegistroMedidasScreenState extends State<RegistroMedidasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _peso = TextEditingController();
  final _altura = TextEditingController();
  final _data = TextEditingController();
  final _dataKey = GlobalKey<FormFieldState<String>>();
  DateTime? _dataEscolhida;

  @override
  void dispose() {
    _peso.dispose();
    _altura.dispose();
    _data.dispose();
    super.dispose();
  }

  /// Converte o texto (aceita vírgula). Rejeita "NaN"/"Infinity".
  double? _parse(String? v) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    return (n != null && n.isFinite) ? n : null;
  }

  String? _numero(
    String? v, {
    required double min,
    required double max,
    required String unidade,
  }) {
    final n = _parse(v);
    if (n == null) return 'Informe um valor válido';
    if (n < min || n > max) {
      return 'Informe entre ${formatarNumero(min)} e ${formatarNumero(max)} $unidade';
    }
    return null;
  }

  String? _validarPeso(String? v) =>
      _numero(v, min: 0.5, max: 60, unidade: 'kg');

  String? _validarAltura(String? v) =>
      _numero(v, min: 40, max: 130, unidade: 'cm');

  String? _validarData(String? v) {
    final d = _dataEscolhida;
    if (d == null) return 'Escolha a data da medição';
    final hoje = DateTime.now();
    if (d.isAfter(DateTime(hoje.year, hoje.month, hoje.day))) {
      return 'A data não pode ser futura';
    }
    return null;
  }

  Future<void> _escolherData() async {
    final hoje = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _dataEscolhida ?? hoje,
      firstDate: DateTime(hoje.year - 6),
      lastDate: hoje,
    );
    if (!mounted) return;
    if (d != null) {
      _dataEscolhida = d;
      _data.text = formatarData(d);
      // Revalida só este campo para limpar o erro anterior.
      _dataKey.currentState?.validate();
    }
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    // Regra provisória até o cálculo de Z-score (OMS) ser implementado:
    // peso abaixo de 10 kg mostra a variação "Desnutrição" da tela 07.
    final peso = _parse(_peso.text)!;
    Navigator.pushNamed(
      context,
      Routes.resultado,
      arguments: peso < 10
          ? MockData.resultadoDesnutricao
          : MockData.resultadoNormal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BackAppBar(title: 'Registro de Medidas'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const Text(
              'Medidas antropométricas',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
              validator: _validarPeso,
            ),
            const SizedBox(height: 24),
            LabeledField(
              controller: _altura,
              label: 'Altura/Comprimento (cm)',
              required: true,
              hint: 'Ex.: 85,0',
              icon: Icons.straighten,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validarAltura,
            ),
            const SizedBox(height: 24),
            LabeledField(
              controller: _data,
              fieldKey: _dataKey,
              label: 'Data da medição',
              required: true,
              validator: _validarData,
              hint: 'DD/MM/AAAA',
              icon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _escolherData,
            ),
            const SizedBox(height: 60),
            ElevatedButton(onPressed: _calcular, child: const Text('Calcular')),
          ],
        ),
      ),
    );
  }
}
