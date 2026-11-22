# Projeto NutriMirim

## Integrantes

- Alexandre Afonso Silva Virgens
- Davi Santana Lóz
- Larissa Barbosa dos Santos
- Lorena Reis Santos
- Talita Santos das Virgens

## Turma

**Programação para Dispositivos Móveis - GP0015NOT07A**

## Breve descrição do projeto

O NutriMirim é um projeto voltado para a vigilância nutricional infantil, desenvolvido para apoiar Agentes Comunitários de Saúde (ACS), pediatras, médicos especialistas e nutricionistas no combate à desnutrição e ao nanismo em comunidades carentes e Unidades Básicas de Saúde (UBS).

## ATIVIDADE 01 — ANÁLISE DO ESTUDO DE CASO 02/02/2026

| Integrante | Responsabilidade |
| --- | --- |
| Davi Santana Lóz | Problema; públicos e usuários |
| Larissa Barbosa dos Santos | Personalidade, identidade e experiência; funcionalidades e características já definidas |
| Lorena Reis Santos | Contexto de uso; objetivo e proposta de valor |
| Talita Santos das Virgens | Restrições e condições; pontos de atenção |

## ATIVIDADE 02 — PESQUISA, BENCHMARK E PERSONAS - 09/09/2026

| Integrante | Responsabilidade |
| --- | --- |
| Alexandre Afonso Silva Virgens | Pesquisa |
| Davi Santana Lóz | Pesquisa e atualizar o CHANGELOG.md |
| Larissa Barbosa dos Santos | Benchmark e Apresentação |
| Lorena Reis Santos | Benchmark |
| Talita Santos das Virgens | Personas e atualizar o README.md |

## ATIVIDADE 03 — FUNCIONALIDADES E REQUISITOS - 16/09/2026 

| Integrante | Responsabilidade | 
| --- | --- | 
| Alexandre Afonso Silva Virgens | Requisitos não funcionais | 
| Davi Santana Lóz | CRUD e atualizar o CHANGELOG.md | 
| Larissa Barbosa dos Santos | Funcionalidades | 
| Lorena Reis Santos | Requisitos funcionais e apresentação | 
| Talita Santos das Virgens | Priorização e atualizar o README.md | 

## ATIVIDADE 04 e 05 — PROTOTIPAÇÃO, APRESENTAÇÃO E ENTREGA FINAL - 29/09/2026 

| Integrante | Responsabilidade | 
| --- | --- | 
| Alexandre Afonso Silva Virgens | Telas: Recuperação de senha 02A-02C | 
| Davi Santana Lóz | Telas: Abertura 01 - Login 02 - inicio 03 | 
| Larissa Barbosa dos Santos | Telas: Nova avaliação 04 - Cadastro da criança 05 - Registro de Medidas 06; Baixa fidelidade e justificativas.md | 
| Lorena Reis Santos | Telas: Dados da criança 10 - Perfil Profissional 11 - Cadastro de Crianças 12; Apresentação | 
| Talita Santos das Virgens |Telas: Resultado 07 - Curva de Crescimento 08 - Histórico 09; Atualizar o README.md e o CHANGELOG.md| 

## DESENVOLVIMENTO DO APLICATIVO EM FLUTTER - 04/11/2026

| Integrante | Responsabilidade |
| --- | --- |
| Davi Santana Lóz | Criação do projeto Flutter (`appnutrimirim/`) e importação do protótipo do Figma para o código |

## PLANEJAMENTO DO DESENVOLVIMENTO - 11/11/2026

| Integrante | Responsabilidade |
| --- | --- |
| Alexandre Afonso Silva Virgens |Desenvolvimento das telas de recuperação de senha, configuração da localização em português e implementação de testes de validação. | 
| Davi Santana Lóz | Revisão geral do código; criação do `CONTEXTO_IA.md` (contexto compartilhado para IAs, registro de prompts, padrão de commits e fluxo de branches); divisão das tasks de front-end e back-end; cronograma de entregas; Desenvolvimento das telas de Abertura, Login e Início. Correção da navegação, refatoração dos modelos de dados, padronização de datas e implementação de testes. | 
| Larissa Barbosa dos Santos | Desenvolvimento das telas de Nova Avaliação, Cadastro e Registro de Medidas. Melhorias de acessibilidade, seleção de datas e validação de CPF. | 
| Lorena Reis Santos | Desenvolvimento das telas de Dados da Criança, Perfil e Lista de Crianças. Melhorias na busca, ajustes de interface e implementação de testes. | 
| Talita Santos das Virgens | Desenvolvimento das telas de Resultado, Curva de Crescimento e Histórico. Correção da navegação, ordenação das avaliações e implementação de testes; Atualizar o README.md e o CHANGELOG.md|

## SEMANA 1 — BASE DE DADOS E TASKS FÁCEIS DO BACK-END - 18/11/2026

| Integrante | Responsabilidade |
| --- | --- |
| Alexandre Afonso Silva Virgens | Configuração do Firebase no projeto `app-nutrimirim` (Android, iOS e Web). Alto contraste com `ThemeExtension` (`lib/theme/app_palette.dart`), borda dos campos com contraste 3:1 e fontes de no mínimo 12 px nos componentes compartilhados. |
| Davi Santana Lóz | Coleções e regras de segurança do Firestore por UBS e por perfil de acesso (`docs/firestore.md`, `firestore.rules` e 63 testes no emulador). Integração dos PRs da semana na `develop` e ajuste do `firebase_core` para o Flutter 3.35.3. |
| Larissa Barbosa dos Santos | Validação das medidas pela OMS, com as tabelas oficiais offline (`lib/services/antropometria_oms.dart` e `docs/validacao-antropometrica-oms.md`), validadores de CPF e cadastro com sexo obrigatório, `Semantics` e calendário. |
| Lorena Reis Santos | Criança passada por todo o fluxo a partir de Dados da criança (registro, curva, histórico e edição preenchida). Relatório resumido da avaliação em texto, com botão de compartilhar (RF10). |
| Talita Santos das Virgens | Classificação nutricional pelos pontos de corte do SISVAN, com condutas, data de retorno e alerta de encaminhamento (`lib/services/classificacao.dart`). Curva de crescimento com a criança selecionada, contraste AA nos rótulos e respeito ao tamanho da fonte. |

## SEMANA 2 — TASKS DIFÍCEIS DO FRONT-END E REPOSITÓRIOS - 25/11/2026 (em andamento)

| Integrante | Responsabilidade |
| --- | --- |
| Davi Santana Lóz | Repositórios de crianças e avaliações (`lib/repositories/`), com uma versão em memória e outra com Firestore, e as telas lendo os dados pelos repositórios em vez do mock. Concluída em 22/11 (PR #26). |

As tasks de cada integrante, o cronograma e o fluxo de branches estão detalhados no [`CONTEXTO_IA.md`](CONTEXTO_IA.md).

### Cronograma de entregas (às quartas-feiras; a final é na terça)

| Entrega | Data | Conteúdo |
| --- | --- | --- |
| 1 | 11/11/2026 | Tasks fáceis do front-end |
| 2 | 18/11/2026 | Modelos de dados e tasks fáceis do back-end |
| 3 | 25/11/2026 | Tasks difíceis do front-end e repositórios |
| 4 | 01/12/2026 | Tasks difíceis do back-end, integração e entrega final do app |

## Como rodar o aplicativo

Dentro da pasta `appnutrimirim/`:

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```

Testes das regras do Firestore (precisam de Node 24.12+ e Java 21), dentro da pasta `firebase/`:

```bash
npm install
npm test
```
