# Contexto para IAs — Projeto NutriMirim

Este arquivo guarda o histórico do que as IAs (Claude, ChatGPT, Gemini, Copilot etc.) já fizeram no projeto e o registro dos prompts usados pelos integrantes. Todas as LLMs que trabalharem no projeto devem ler este arquivo antes de começar e registrar aqui o que fizeram.

---

## 🤖 Instrução para a IA (leia antes de qualquer tarefa)

> **Se você é uma IA trabalhando neste repositório, siga estas regras:**
>
> 1. **Leia este arquivo inteiro antes de começar.** Ele resume o projeto, o que já foi feito e as decisões tomadas. Não refaça trabalho que já está registrado aqui e não contrarie decisões registradas sem avisar o integrante.
> 2. **Ao terminar a tarefa, registre o que fez.** Adicione uma linha no fim da tabela da seção "Registro de prompts", com: data, integrante, ferramenta/modelo, o prompt **exatamente como foi escrito** (sem corrigir) e um resumo curto do que foi feito e de quais arquivos mudaram.
> 3. **Se a tarefa mudou o projeto** (nova tela, nova regra, nova decisão), atualize também a seção "Decisões e cuidados" ou "Pendências conhecidas".
> 4. **Não apague nem reescreva registros antigos.** Só acrescente.
> 5. Responda em **português**, inclusive nas mensagens de commit (ver o padrão em "Decisões e cuidados").
> 6. **Nunca commite direto na `main` nem na `develop`.** Trabalhe numa branch da task e siga a seção "Como subir sua task (branches)".
> 7. Se você não puder editar arquivos (ex.: chat no navegador), entregue no fim da resposta a linha pronta para o integrante colar na tabela.

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

## Divisão de tarefas — front-end (a partir de 10/11/2026)

Cada integrante continua com as telas que prototipou na Atividade 04/05 e tem uma task fácil e uma difícil. Cada task deve sair com pelo menos um teste novo, e `flutter analyze` e `flutter test` precisam continuar passando.

**Ordem:** a task difícil do Davi (ids e datas nos modelos) vai primeiro, porque as tasks difíceis de Larissa, Talita e Lorena dependem dela. As tasks fáceis podem começar já.

| Integrante | Telas | 🟢 Task fácil | 🔴 Task difícil |
| --- | --- | --- | --- |
| Davi Santana Lóz | 01 Abertura, 02 Login, 03 Início (+ barra inferior) | Corrigir a barra inferior, que empilha uma segunda Home (`widgets/bottom_nav.dart`), e criar um teste de navegação. | Pôr `id` em `Crianca`, trocar as datas `String` por `DateTime` em `data/models.dart` e `mock_data.dart`, buscar avaliações por id em vez de nome e criar `utils/formatters.dart` para centralizar a formatação de número e de data. **Bloqueia os outros: fazer primeiro.** |
| Alexandre Afonso Silva Virgens | 02A–02C Recuperação de senha | Adicionar `flutter_localizations` com `pt_BR` no `main.dart` (calendário em português; ajustar o teste que procura `'OK'`) e escrever testes da recuperação de senha (e-mail inválido, senhas que não conferem). | Fazer o "Alto Contraste" funcionar de verdade: criar um `ThemeExtension` com as cores, usá-lo em `theme/` e `widgets/`, subir o contraste da borda dos campos para no mínimo 3:1 e as fontes para no mínimo 12 px. Depois disso, cada integrante troca `AppColors` pelo tema nas próprias telas, para evitar conflito no Git. |
| Larissa Barbosa dos Santos | 04 Nova avaliação, 05 Cadastro, 06 Registro de medidas | No cadastro: tirar a pré-seleção do sexo, adicionar `Semantics` (botão e selecionado) ao seletor e trocar o nascimento em texto livre por um DatePicker. | Fazer o cadastro salvar de verdade: controllers nos campos, máscara e dígito verificador do CPF e "Editar dados" abrindo o formulário preenchido com a criança escolhida. Escrever testes de validação. |
| Talita Santos das Virgens | 07 Resultado, 08 Curva, 09 Histórico | No Histórico: abrir a criança certa ao tocar no item, ordenar a lista da avaliação mais recente para a mais antiga e remover o filtro que só tem a opção "Todas". Escrever um teste do clique. | Na Curva: usar a criança selecionada em vez de dados fixos, alinhar o mock com a regra provisória (o caso dos 9,8 kg e a diferença 82/85 cm), melhorar o contraste dos rótulos e respeitar o `textScaler` no gráfico. Testar a variação "Desnutrição" do Resultado. |
| Lorena Reis Santos | 10 Dados da criança, 11 Perfil, 12 Lista de crianças | No Perfil: desabilitar o "Editar dados" ou mostrar "Em breve". Na Lista: fazer a busca ignorar acentos ("joao" encontra "João"). Escrever testes da busca. | Em Dados da criança: passar a criança para Registrar avaliação, Curva, Histórico e Editar dados, para que todo o fluxo mostre a mesma criança. Escrever testes de navegação. |

## Divisão de tarefas — back-end (a partir de 10/11/2026)

### Stack proposta (confirmar com o grupo)

Ainda não existe back-end, e o app usa `MockData`. A proposta é usar o **Firebase**:

- **Firebase Auth:** login, recuperação de senha e sessão.
- **Cloud Firestore:** banco com **cache offline nativo**. O app grava sem internet e sincroniza sozinho quando a rede volta, o que atende RF07 e RF08 sem precisar escrever um servidor próprio.
- **Camada de repositório:** as telas nunca falam com o Firebase direto. Elas usam interfaces (`CriancaRepository`, `AvaliacaoRepository`, `AuthService`), e cada interface tem uma implementação com Firestore e outra **em memória**, usada nos testes.
- **Regras de negócio** (z-score, classificação, validações) em `lib/services/`, como funções puras e testáveis, sem Flutter nem Firebase.

Fora do escopo das 3 semanas, por serem "Secundárias" na priorização: RF15 (leitura do Cartão SUS por câmera), RF19 (consolidado do turno) e a criptografia do banco local (RNF04, que fica registrada como pendência).

### Tasks

| Integrante | Área | 🟢 Task fácil | 🔴 Task difícil |
| --- | --- | --- | --- |
| Davi Santana Lóz | Dados e repositórios | Documentar as coleções do Firestore (`profissionais`, `criancas`, `avaliacoes`: campos e tipos) e escrever as **regras de segurança**, para que cada profissional só leia e grave os dados da própria UBS (LGPD). | Criar as interfaces `CriancaRepository` e `AvaliacaoRepository`, com uma implementação em memória e outra com Firestore, e trocar o `MockData` pelos repositórios nas telas. **Publicar as interfaces e a versão em memória primeiro, para os outros já trabalharem em cima delas.** |
| Alexandre Afonso Silva Virgens | Autenticação e sincronização | Configurar o Firebase no projeto (`firebase_core`, `flutterfire configure`) e criar o `AuthService`: login com e-mail e senha, recuperação de senha (`sendPasswordResetEmail`), logout e manter a sessão aberta. Ligar o serviço às telas 02 e 02A–02C. | Sincronização e status (RF08, RF16): detectar se há rede, mostrar no Histórico os registros pendentes de envio (`hasPendingWrites`) e testar o fluxo com o modo avião. |
| Larissa Barbosa dos Santos | Cadastro e medições | Criar `services/validadores.dart` com o dígito verificador do CPF e as faixas fisiológicas por idade (RF02), com testes. | Salvar a criança e a avaliação pelos repositórios (RF01, RF02) e permitir corrigir uma medição até 15 minutos depois do registro (RF14), com o registro de quem alterou e quando (RNF11). |
| Talita Santos das Virgens | Cálculo nutricional | Criar `services/classificacao.dart` com a classificação semafórica a partir do z-score (RF04), as micro-condutas por faixa (RF13), a sugestão da data de retorno (RF17) e o alerta de encaminhamento para z-score crítico (RF12), com testes. | Cálculo do z-score pela OMS (RF03): carregar as tabelas LMS da OMS (0 a 5 anos) como asset JSON, calcular peso-para-idade, altura-para-idade, peso-para-altura e IMC-para-idade com `z = ((X/M)^L − 1) / (L·S)` e fornecer os pontos da Curva (RF06). Testar contra valores das tabelas oficiais. **Substitui a regra provisória `peso < 10`.** |
| Lorena Reis Santos | Consultas e relatórios | Gerar o relatório resumido da avaliação em texto (RF10): dados da criança, z-score, classificação e data, com o botão de compartilhar. | Consultas: histórico longitudinal em ordem de data (RF05), busca por nome parcial ou CPF do responsável (RF11, guardando o nome normalizado sem acentos para a busca) e perfil do profissional com a UBS e a microárea (RF18). |

## Cronograma — 3 semanas, entregas às quartas

Toda entrega é um **merge na `develop`** feito até a quarta-feira, com `flutter analyze` e `flutter test` passando. Em cada quarta, o grupo confere junto o que entrou e ajusta a semana seguinte.

### Semana 1 — entrega qua 18/11/2026: base e tasks fáceis

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | 🟢 Barra inferior · 🔴 `id` e `DateTime` nos modelos + formatadores (**até sex 13/11**, porque bloqueia outros) | — |
| Alexandre | 🟢 `pt_BR` + testes da recuperação | 🟢 Firebase configurado + `AuthService` |
| Larissa | 🟢 Seletor de sexo, `Semantics` e DatePicker | 🟢 Validadores (CPF e faixas) |
| Talita | 🟢 Histórico abrindo a criança certa | 🟢 Classificação, condutas, retorno e alerta |
| Lorena | 🟢 Perfil + busca sem acentos | 🟢 Relatório resumido em texto |

### Semana 2 — entrega qua 25/11/2026: tasks difíceis do front-end e base de dados

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | — | 🟢 Coleções e regras do Firestore · 🔴 Repositórios (**interfaces e versão em memória até qui 19/11**) |
| Alexandre | 🔴 Alto contraste com `ThemeExtension` | — |
| Larissa | 🔴 Cadastro salvando e "Editar dados" preenchido | — |
| Talita | 🔴 Curva com a criança selecionada | 🔴 z-score OMS: tabelas carregadas e primeiro indicador funcionando |
| Lorena | 🔴 Criança passada pelo fluxo todo | — |

### Semana 3 — entrega final qua 02/12/2026: tasks difíceis do back-end e integração

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | Integração final, `develop` → `main`, `README.md` e `CHANGELOG.md` | Revisar os PRs dos repositórios e das regras |
| Alexandre | Cada um troca `AppColors` pelo tema nas próprias telas | 🔴 Sincronização e status pendente |
| Larissa | (idem) | 🔴 Salvar avaliação + correção em 15 min |
| Talita | (idem) | 🔴 z-score: os 4 indicadores integrados ao Resultado e à Curva |
| Lorena | (idem) | 🔴 Histórico, busca e perfil no Firestore |

**Até ter 02/12:** todos os PRs na `develop`. **Na quarta 02/12:** merge da `develop` na `main` e entrega.

## Como subir sua task (branches)

**Ninguém commita direto na `main` nem na `develop`.** Cada task é feita numa branch própria, criada a partir da `develop`, e só entra na `develop` por Pull Request (PR).

- `main`: versão entregue. Só recebe a `develop` nas entregas.
- `develop`: versão em desenvolvimento, sempre funcionando.
- `tipo/descricao-curta`: uma branch por task. O tipo é o mesmo dos commits (`feat`, `fix`, `test`, `docs`, `refactor`). Exemplos: `fix/barra-inferior-home`, `feat/cadastro-salvar`, `fix/historico-crianca`.

### Passo a passo

```bash
# 1. Atualizar a develop e criar a branch da task
git checkout develop
git pull
git checkout -b fix/barra-inferior-home

# 2. Trabalhar e commitar (mensagens em português)
git add <arquivos>
git commit -m "fix: barra inferior não duplica a Home"

# 3. Antes de subir, conferir se está tudo passando (dentro de appnutrimirim/)
flutter analyze
flutter test

# 4. Subir a branch
git push -u origin fix/barra-inferior-home
```

5. No GitHub, abra um **Pull Request da sua branch para a `develop`**, não para a `main`. No título, use o mesmo padrão dos commits. Na descrição, conte o que mudou e como testar.
6. Peça para **outro integrante revisar**. Depois da aprovação, faça o merge e apague a branch.

### Quando a `develop` mudou enquanto você trabalhava

Se alguém fez merge antes de você (por exemplo, a task de modelos do Davi), traga as mudanças para a sua branch antes de abrir o PR:

```bash
git checkout develop
git pull
git checkout <sua-branch>
git merge develop
# se der conflito: resolva os arquivos, depois "git add" e "git commit"
```

### Cuidados

- Uma branch por task. A task fácil e a difícil ficam em branches separadas.
- Antes de começar, faça commit ou guarde o que estiver pendente. Evite deixar `git stash` esquecido: um stash antigo causou um conflito no `docs/requisitos.md` em 10/11/2026.
- Não suba arquivos gerados (`build/`, `.dart_tool/`), que o `.gitignore` já ignora.

---

## Registro de prompts

Regras: uma linha por pedido, a mais recente no fim. Copie o prompt **exatamente como foi escrito**. Se o prompt for longo, resuma na coluna e cole o texto completo em "Prompts longos", logo abaixo.

| Data | Integrante | Ferramenta / modelo | Prompt | O que a IA fez (arquivos) |
| --- | --- | --- | --- | --- |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "claude chame o analisador para ver como esrtar o codigo" | Chamou o agente revisor. Resultado: `flutter analyze` sem problemas e 37 testes passando. Veredito: aprovado com ressalvas (ver "Pendências conhecidas"). Nenhum arquivo alterado. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "crie um arquivo de contexto para detalhar o que as ias ja fizerem e esse mesmo arquivo tem que ter um registro de prompts que estao sendo usados. importante esse aruivo se md e que tenha o promp para que todas as llm que os integrantes usarem saibam que tem o contexto e tem que registrar os prompts" | Criou `CONTEXTO_IA.md` (este arquivo). |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "divida as telas para 5 pessoas fazendo com que cada pessoa tenha uma task mais facil e outra mais dificil." | Dividiu as pendências da revisão entre os 5 integrantes (uma task fácil e uma difícil para cada) e adicionou a seção "Divisão de tarefas" em `CONTEXTO_IA.md`. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "colo que no contexto que os commit sao em portugues para padronizar" | Adicionou o padrão de commits em português nas seções "Decisões e cuidados" e "Instrução para a IA" do `CONTEXTO_IA.md`. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "faça a divisao do backend da mesma forma que voce fez o front. cria as entregas semnas para todo o projeto em 3 semanas. entregando toda quarta feira." | Propôs o back-end com Firebase e repositórios, dividiu uma task fácil e uma difícil de back-end para cada integrante e montou o cronograma de 3 semanas (entregas em 18/11, 25/11 e 02/12) em `CONTEXTO_IA.md`. |

### Prompts longos

<!-- Formato:
#### AAAA-MM-DD — Integrante — Ferramenta
```text
prompt completo
```
-->
