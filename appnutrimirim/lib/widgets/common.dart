import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';

/// Logotipo do NutriMirim (criança com folhas).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 110,
    this.withName = false,
    this.login = false,
  });

  final double size;
  final bool withName;

  /// Versão completa e sem corte usada no Login e na Recuperação de senha.
  final bool login;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      login
          ? 'assets/images/logo_login.png'
          : withName
          ? 'assets/images/logo_completo.png'
          : 'assets/images/logo.png',
      width: size,
      semanticLabel: 'Logotipo NutriMirim',
    );
  }
}

/// Wordmark "NutriMirim" (Nutri azul + Mirim verde) usado no Início.
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 24});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontFamily: 'BagelFatOne', fontSize: fontSize);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Nutri',
            style: style.copyWith(color: AppColors.wordmarkBlue),
          ),
          TextSpan(
            text: 'Mirim',
            style: style.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

/// AppBar com seta de voltar e título em negrito, como nas telas internas.
class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({super.key, required this.title, this.centerTitle = false});

  final String title;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      centerTitle: centerTitle,
      leading: IconButton(
        tooltip: 'Voltar',
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(title),
    );
  }
}

/// Botão "‹ Voltar" em texto usado no fluxo de recuperação de senha.
class TextBackButton extends StatelessWidget {
  const TextBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.maybePop(context),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textDark,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.chevron_left, size: 22),
      label: const Text('Voltar'),
    );
  }
}

/// Rótulo de campo com asterisco para obrigatórios.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [if (required) const TextSpan(text: ' *')],
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

/// Campo de texto com rótulo acima, exemplo e ícone opcional.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    this.label,
    this.required = false,
    this.hint,
    this.icon,
    this.suffix,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.fieldKey,
  });

  final GlobalKey<FormFieldState<String>>? fieldKey;
  final String? label;
  final bool required;
  final String? hint;
  final IconData? icon;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) FieldLabel(label!, required: required),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          validator:
              validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty)
                        ? 'Campo obrigatório'
                        : null
                  : null),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, size: 22),
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Cartão branco com borda suave, base de vários blocos do protótipo.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.onTap,
    this.radius = 12,
  });

  final double radius;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Selo colorido com texto (Normal, Atenção, Risco).
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.situacao, {
    super.key,
    this.withDot = false,
    this.dense = false,
  });

  final Situacao situacao;
  final bool withDot;

  /// Versão menor, para caber em tabelas estreitas.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 14,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: situacao.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withDot) ...[
            Icon(Icons.circle, size: 10, color: situacao.color),
            const SizedBox(width: 6),
          ],
          Text(
            situacao.label,
            style: TextStyle(
              color: situacao.textColor,
              fontWeight: FontWeight.w700,
              fontSize: dense ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Linha "rótulo ........ valor" usada nos cartões de dados.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão "Última avaliação" com idade, peso, Z-score, percentil e selo.
class LastEvaluationCard extends StatelessWidget {
  const LastEvaluationCard({
    super.key,
    required this.data,
    required this.peso,
    required this.situacao,
    this.idade = '—',
    this.idadeSub,
    this.zScore = '—',
    this.percentil = '—',
    this.footer,
  });

  final String data;
  final String peso;
  final Situacao situacao;
  final String idade;
  final String? idadeSub;
  final String zScore;
  final String percentil;
  final Widget? footer;

  static const _cinzaTitulo = Color(0xFF1D2939);
  static const _cinzaRotulo = Color(0xFF667085);
  static const _cinzaValor = Color(0xFF344054);
  static const _divisoria = Color(0xFFEAECF0);

  @override
  Widget build(BuildContext context) {
    Widget cell(String title, String value, {String? sub, int flex = 2}) =>
        Expanded(
          flex: flex,
          child: Column(
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _cinzaRotulo, fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _cinzaValor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  style: const TextStyle(color: _cinzaRotulo, fontSize: 10),
                ),
            ],
          ),
        );

    const divider = VerticalDivider(width: 1, thickness: 1, color: _divisoria);

    return AppCard(
      padding: EdgeInsets.zero,
      color: const Color(0xFFFDFDFD),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Última avaliação',
                    style: TextStyle(
                      color: _cinzaTitulo,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: _cinzaRotulo,
                ),
                const SizedBox(width: 6),
                Text(
                  data,
                  style: const TextStyle(color: _cinzaRotulo, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  cell('Idade', idade, sub: idadeSub, flex: 3),
                  divider,
                  cell('Peso', peso),
                  divider,
                  cell('Z-Score', zScore),
                  divider,
                  cell('Percentil', percentil),
                  divider,
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        const Text(
                          'Classificação',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _cinzaRotulo, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: StatusBadge(
                            situacao,
                            withDot: true,
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(padding: const EdgeInsets.only(bottom: 6), child: footer),
        ],
      ),
    );
  }
}
