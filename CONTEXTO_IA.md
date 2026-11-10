# Contexto para IAs — Projeto NutriMirim

Este arquivo guarda o histórico do que as IAs (Claude, ChatGPT, Gemini, Copilot etc.) já fizeram no projeto e o registro dos prompts usados pelos integrantes. Todas as LLMs que trabalharem no projeto devem ler este arquivo antes de começar e registrar aqui o que fizeram.

---

## 🤖 Instrução para a IA (leia antes de qualquer tarefa)

> **Se você é uma IA trabalhando neste repositório, siga estas regras:**
>
> 1. **Leia este arquivo inteiro antes de começar.** Ele resume o projeto, o que já foi feito e as decisões tomadas. Não refaça trabalho que já está registrado aqui e não contrarie decisões registradas sem avisar o integrante.
> 2. **Ao terminar a tarefa, registre o que fez.** Adicione uma linha no fim da tabela da seção "Registro de prompts", com: data, integrante, ferramenta/modelo, o prompt **exatamente como foi escrito** (sem corrigir) e um resumo curto do que foi feito e de quais arquivos mudaram.
> 3. **Se a tarefa mudou o projeto** (nova tela, nova regra, nova decisão), atualize também a seção "O que já foi feito" ou "Decisões e cuidados".
> 4. **Não apague nem reescreva registros antigos.** Só acrescente.
> 5. Responda em **português**, inclusive nas mensagens de commit (ver o padrão em "Decisões e cuidados").
> 6. Se você não puder editar arquivos (ex.: chat no navegador), entregue no fim da resposta a linha pronta para o integrante colar na tabela.

### Prompt para colar no início da conversa (ChatGPT, Gemini, Copilot, etc.)

Ferramentas que não leem o repositório sozinhas não veem este arquivo. Nesse caso, o integrante cola o prompt abaixo junto com o conteúdo deste arquivo:

```text
Estou trabalhando no projeto NutriMirim (app Flutter de vigilância nutricional infantil).
Abaixo está o arquivo CONTEXTO_IA.md com o contexto do projeto, o que as IAs já fizeram
e o registro de prompts. Leia tudo antes de responder, siga as regras da seção
"Instrução para a IA" e, no fim da sua resposta, me entregue a linha pronta para eu
adicionar na tabela "Registro de prompts" (data, meu nome, ferramenta/modelo, meu prompt
exatamente como escrevi e o resumo do que você fez).

Meu nome: <SEU NOME>
Minha tarefa: <SEU PEDIDO>

--- CONTEXTO_IA.md ---
<COLE AQUI O CONTEÚDO DESTE ARQUIVO>
```

---

## Sobre o projeto

- **O que é:** app de vigilância nutricional infantil para apoiar Agentes Comunitários de Saúde (ACS), pediatras e nutricionistas no combate à desnutrição e ao nanismo em comunidades carentes e UBS.
- **Turma:** Programação para Dispositivos Móveis — GP0015NOT07A.
- **Integrantes:** Alexandre Afonso Silva Virgens, Davi Santana Lóz, Larissa Barbosa dos Santos, Lorena Reis Santos, Talita Santos das Virgens.
- **Stack:** Flutter (Dart SDK ^3.9.2), sem pacotes externos além de `cupertino_icons`. Fontes Almarai e Bagel Fat One. Dados ainda são mock (sem back-end).
- **Branches:** `main` (principal) e `develop` (desenvolvimento).

### Estrutura

```text
README.md, CHANGELOG.md     → descrição, responsabilidades e histórico das atividades
CONTEXTO_IA.md              → este arquivo
docs/                       → estudo de caso, pesquisa, benchmark, personas, requisitos,
                              justificativa e PDFs dos protótipos/apresentações
appnutrimirim/              → app Flutter
  lib/main.dart             → entrada do app
  lib/routes.dart           → rotas das telas 01 a 12
  lib/app_state.dart        → estado global simples
  lib/theme/                → cores (contraste AA) e tema
  lib/widgets/              → componentes compartilhados e barra de navegação
  lib/data/                 → modelos e dados mock
  lib/screens/              → telas (auth/, avaliacao/, crianca/ e demais)
  test/                     → testes de widget
```

### Telas (rotas em `lib/routes.dart`)

| Nº | Tela | Rota |
| --- | --- | --- |
| 01 | Abertura (splash) | `/` |
| 02 | Login | `/login` |
| 02A–02C | Recuperação de senha (e-mail, enviado, nova senha) | `/recuperar`, `/recuperar/enviado`, `/recuperar/nova-senha` |
| 03 | Início | `/inicio` |
| 04 | Nova avaliação | `/avaliacao` |
| 05 | Cadastro da criança | `/avaliacao/cadastro` |
| 06 | Registro de medidas | `/avaliacao/medidas` |
| 07 | Resultado | `/avaliacao/resultado` |
| 08 | Curva de crescimento | `/crianca/curva` |
| 09 | Histórico | `/historico` |
| 10 | Dados da criança | `/crianca` |
| 11 | Perfil profissional | `/perfil` |
| 12 | Lista de crianças | `/criancas` |

### Comandos

Rodar dentro de `appnutrimirim/`:

```bash
flutter pub get     # instalar dependências
flutter run         # rodar o app
flutter analyze     # análise estática
flutter test        # testes
```

---

## O que já foi feito

| Data | O quê | Feito com IA? |
| --- | --- | --- |
| 02/09 a 29/09/2026 | Atividades 01 a 05: estudo de caso, pesquisa, benchmark, personas, requisitos, protótipos e apresentações (ver `README.md` e `CHANGELOG.md`) | Não registrado |
| 04/11/2026 | Criação do projeto Flutter, fontes e logos do protótipo | Não registrado |
| 04/11/2026 | Tema com cores em contraste AA e componentes compartilhados | Não registrado |
| 04/11/2026 | Modelos e dados mock fictícios | Não registrado |
| 04/11/2026 | Telas 01 a 12 fiéis ao protótipo do Figma, com validação no registro de medidas (faixas, vírgula decimal, data obrigatória) e aviso de resultado ilustrativo | Não registrado |
| 04/11/2026 | Testes: validações, contraste AA, conteúdo e overflow das telas em 360 dp | Não registrado |
| 10/11/2026 | Revisão geral do código pelo agente revisor do Claude Code | Sim — Claude Code |
| 10/11/2026 | Criação deste arquivo `CONTEXTO_IA.md` | Sim — Claude Code |

> Quem fez alguma das etapas "Não registrado" com ajuda de IA pode corrigir a coluna e adicionar o prompt no registro abaixo.

## Decisões e cuidados

- **Dados mock são fictícios.** Nomes, endereço e CPF em `lib/data/mock_data.dart` são inventados. Nunca usar dados reais de crianças ou responsáveis (LGPD).
- **O resultado nutricional é ilustrativo.** O cálculo de z-score ainda não segue as tabelas oficiais da OMS; a tela mostra um aviso disso. Não remover o aviso enquanto o cálculo não for real.
- **Fidelidade ao protótipo.** As telas seguem o protótipo de alta fidelidade (`docs/prototipoAltaFidelidade.pdf`). Mudanças visuais devem ser combinadas com o grupo.
- **Acessibilidade.** As cores foram escolhidas para contraste AA, e os testes verificam isso. Manter os testes passando ao mudar cores.
- **Tela pequena.** Os testes checam overflow em 360 dp de largura.
- **Commits em português.** Toda mensagem de commit é escrita em português, no formato `tipo: descrição curta`, com o verbo no presente. Tipos usados: `feat` (funcionalidade/tela), `fix` (correção), `test` (testes), `docs` (documentação), `chore` (configuração e arquivos de apoio) e `refactor` (reorganização sem mudar o comportamento). Exemplos: `feat: telas 01-12 fiéis ao protótipo do Figma` e `fix: barra inferior não duplica a Home`.
- **Arquivos ignorados pelo Git:** `.claude/`, `CLAUDE.md` e `CLAUDE.local.md` são locais de cada integrante. O contexto compartilhado fica **neste arquivo**.

## Pendências conhecidas

Encontradas na revisão de 10/11/2026 e ainda não corrigidas. Ao corrigir uma, marque `[x]` e registre o prompt.

- [ ] Tocar em "Início" na barra inferior empilha uma segunda Home (`lib/widgets/bottom_nav.dart:56-60`).
- [ ] Tocar num item do Histórico sempre abre a mesma criança, porque nenhum argumento é passado (`lib/screens/historico_screen.dart:39`).
- [ ] As telas de dados, registro, curva e histórico não passam a criança adiante, e "Editar dados" abre o cadastro vazio (`dados_crianca_screen.dart`).
- [ ] O mock contradiz a regra provisória `peso < 10 → desnutrição`: a criança de 9,8 kg aparece como "Normal". A curva mostra 82 cm e o mock tem 85 cm, e os dados da curva estão fixos.
- [ ] "Editar dados" do Perfil tem `onPressed: () {}`, então o botão parece ativo e não faz nada.
- [ ] No cadastro, o nascimento é texto livre, o CPF não tem máscara nem validação e o sexo já vem marcado.
- [ ] Os modelos não têm `id`, as datas são `String` e a busca de avaliações é feita por nome.
- [ ] O "Alto Contraste" quase não muda nada, porque as telas usam `AppColors` e cores fixas direto, sem passar pelo `Theme`.
- [ ] Não há localização `pt_BR`: o DatePicker aparece em inglês.
- [ ] A borda dos campos tem contraste de 1,35:1 e o WCAG pede 3:1. Há fontes de 9 a 11 px.
- [ ] A formatação de número e de data está duplicada em várias telas.
- [ ] Faltam testes de login, recuperação de senha, cadastro, lista, barra inferior e histórico.

## Divisão de tarefas (a partir de 10/11/2026)

Cada integrante continua com as telas que prototipou na Atividade 04/05 e tem uma task fácil e uma difícil. Cada task deve sair com pelo menos um teste novo, e `flutter analyze` e `flutter test` precisam continuar passando.

**Ordem:** a task difícil do Davi (ids e datas nos modelos) vai primeiro, porque as tasks difíceis de Larissa, Talita e Lorena dependem dela. As tasks fáceis podem começar já.

| Integrante | Telas | 🟢 Task fácil | 🔴 Task difícil |
| --- | --- | --- | --- |
| Davi Santana Lóz | 01 Abertura, 02 Login, 03 Início (+ barra inferior) | Corrigir a barra inferior, que empilha uma segunda Home (`widgets/bottom_nav.dart`), e criar um teste de navegação. | Pôr `id` em `Crianca`, trocar as datas `String` por `DateTime` em `data/models.dart` e `mock_data.dart`, buscar avaliações por id em vez de nome e criar `utils/formatters.dart` para centralizar a formatação de número e de data. **Bloqueia os outros: fazer primeiro.** |
| Alexandre Afonso Silva Virgens | 02A–02C Recuperação de senha | Adicionar `flutter_localizations` com `pt_BR` no `main.dart` (calendário em português; ajustar o teste que procura `'OK'`) e escrever testes da recuperação de senha (e-mail inválido, senhas que não conferem). | Fazer o "Alto Contraste" funcionar de verdade: criar um `ThemeExtension` com as cores, usá-lo em `theme/` e `widgets/`, subir o contraste da borda dos campos para no mínimo 3:1 e as fontes para no mínimo 12 px. Depois disso, cada integrante troca `AppColors` pelo tema nas próprias telas, para evitar conflito no Git. |
| Larissa Barbosa dos Santos | 04 Nova avaliação, 05 Cadastro, 06 Registro de medidas | No cadastro: tirar a pré-seleção do sexo, adicionar `Semantics` (botão e selecionado) ao seletor e trocar o nascimento em texto livre por um DatePicker. | Fazer o cadastro salvar de verdade: controllers nos campos, máscara e dígito verificador do CPF e "Editar dados" abrindo o formulário preenchido com a criança escolhida. Escrever testes de validação. |
| Talita Santos das Virgens | 07 Resultado, 08 Curva, 09 Histórico | No Histórico: abrir a criança certa ao tocar no item, ordenar a lista da avaliação mais recente para a mais antiga e remover o filtro que só tem a opção "Todas". Escrever um teste do clique. | Na Curva: usar a criança selecionada em vez de dados fixos, alinhar o mock com a regra provisória (o caso dos 9,8 kg e a diferença 82/85 cm), melhorar o contraste dos rótulos e respeitar o `textScaler` no gráfico. Testar a variação "Desnutrição" do Resultado. |
| Lorena Reis Santos | 10 Dados da criança, 11 Perfil, 12 Lista de crianças | No Perfil: desabilitar o "Editar dados" ou mostrar "Em breve". Na Lista: fazer a busca ignorar acentos ("joao" encontra "João"). Escrever testes da busca. | Em Dados da criança: passar a criança para Registrar avaliação, Curva, Histórico e Editar dados, para que todo o fluxo mostre a mesma criança. Escrever testes de navegação. |

---

## Registro de prompts

Regras: uma linha por pedido, a mais recente no fim. Copie o prompt **exatamente como foi escrito**. Se o prompt for longo, resuma na coluna e cole o texto completo em "Prompts longos", logo abaixo.

| Data | Integrante | Ferramenta / modelo | Prompt | O que a IA fez (arquivos) |
| --- | --- | --- | --- | --- |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "claude chame o analisador para ver como esrtar o codigo" | Chamou o agente revisor. Resultado: `flutter analyze` sem problemas e 37 testes passando. Veredito: aprovado com ressalvas (ver "Pendências conhecidas"). Nenhum arquivo alterado. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "crie um arquivo de contexto para detalhar o que as ias ja fizerem e esse mesmo arquivo tem que ter um registro de prompts que estao sendo usados. importante esse aruivo se md e que tenha o promp para que todas as llm que os integrantes usarem saibam que tem o contexto e tem que registrar os prompts" | Criou `CONTEXTO_IA.md` (este arquivo). |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "divida as telas para 5 pessoas fazendo com que cada pessoa tenha uma task mais facil e outra mais dificil." | Dividiu as pendências da revisão entre os 5 integrantes (uma task fácil e uma difícil para cada) e adicionou a seção "Divisão de tarefas" em `CONTEXTO_IA.md`. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "colo que no contexto que os commit sao em portugues para padronizar" | Adicionou o padrão de commits em português nas seções "Decisões e cuidados" e "Instrução para a IA" do `CONTEXTO_IA.md`. |

### Prompts longos

<!-- Formato:
#### AAAA-MM-DD — Integrante — Ferramenta
```text
prompt completo
```
-->
