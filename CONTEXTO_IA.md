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
- **Modelos e ids (11/11/2026).** `Crianca` tem `id` (`c0` a `c10` no mock) e `Avaliacao` guarda `criancaId`. Busque sempre por id: `MockData.criancaPorId(id)`, `MockData.avaliacoesDe(criancaId)` (da mais recente para a mais antiga) e `MockData.ultimaAvaliacaoDe(criancaId)`. Nunca busque por nome. As listas do mock são imutáveis; quando for preciso salvar, use os repositórios (back-end), não `MockData.criancas.add`.
- **Datas.** `cadastradoEm`, `nascimento` (pode ser nulo: "Não informado") e `Avaliacao.data` são `DateTime` local. Datas sem hora (nascimento, cadastro) devem ser gravadas no Firestore como texto `aaaa-mm-dd` ou ao meio-dia, nunca à meia-noite UTC, para não aparecer o dia anterior no fuso de Brasília.
- **Formatação.** Use só `lib/utils/formatters.dart`: `formatarData`, `formatarDataHora`, `formatarDecimal`, `formatarNumero`, `formatarPeso`, `formatarAltura`, `idadeEmMeses` e `formatarIdade`. Abaixo de 24 meses a idade fica só em meses ("18 meses"), como na caderneta e nas curvas da OMS.
- **Navegação entre telas.** Para a task da Lorena e os repositórios, a recomendação é passar o `id` da criança como argumento da rota, e não o objeto `Crianca` inteiro.
- **Arquivos ignorados pelo Git:** `.claude/`, `CLAUDE.md` e `CLAUDE.local.md` são locais de cada integrante. O contexto compartilhado fica **neste arquivo**.

## Pendências conhecidas

Encontradas na revisão de 10/11/2026 e ainda não corrigidas. Ao corrigir uma, marque `[x]` e registre o prompt.

- [x] Tocar em "Início" na barra inferior empilha uma segunda Home (`lib/widgets/bottom_nav.dart:56-60`). Corrigido em 11/11/2026.
- [x] Tocar num item do Histórico sempre abre a mesma criança, porque nenhum argumento é passado (`lib/screens/historico_screen.dart:39`).
- [ ] As telas de dados, registro, curva e histórico não passam a criança adiante, e "Editar dados" abre o cadastro vazio (`dados_crianca_screen.dart`).
- [ ] O mock contradiz a regra provisória `peso < 10 → desnutrição`: a criança de 9,8 kg aparece como "Normal". A curva mostra 82 cm e o mock tem 85 cm, e os dados da curva estão fixos.
- [ ] "Editar dados" do Perfil tem `onPressed: () {}`, então o botão parece ativo e não faz nada.
- [x] No cadastro, o nascimento usa DatePicker, o sexo inicia sem seleção e os CPFs têm máscara e validação dos dígitos verificadores.
- [x] Os modelos não têm `id`, as datas são `String` e a busca de avaliações é feita por nome. Corrigido em 11/11/2026.
- [ ] O "Alto Contraste" quase não muda nada, porque as telas usam `AppColors` e cores fixas direto, sem passar pelo `Theme`.
- [x] Localização `pt_BR` configurada; o DatePicker aparece em Português do Brasil.
- [ ] A borda dos campos tem contraste de 1,35:1 e o WCAG pede 3:1. Há fontes de 9 a 11 px.
- [x] A formatação de número e de data está duplicada em várias telas. Corrigido em 11/11/2026 (`lib/utils/formatters.dart`).
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

### Entrega 1 — qua 11/11/2026 (amanhã): tasks fáceis do front-end

Só há um dia de prazo, então esta entrega reúne apenas as tasks pequenas, que mexem em poucos arquivos.

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | 🟢 Barra inferior sem a Home duplicada | — |
| Alexandre | 🟢 `pt_BR` + testes da recuperação | — |
| Larissa | 🟢 Seletor de sexo, `Semantics` e DatePicker | — |
| Talita | 🟢 Histórico abrindo a criança certa | — |
| Lorena | 🟢 Perfil + busca sem acentos | — |

### Semana 1 — entrega qua 18/11/2026: base de dados e tasks fáceis do back-end

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | 🔴 `id` e `DateTime` nos modelos + formatadores (**até sex 13/11**, porque bloqueia outros) | 🟢 Coleções e regras do Firestore |
| Alexandre | — | 🟢 Firebase configurado + `AuthService` |
| Larissa | — | 🟢 Validadores (CPF e faixas) |
| Talita | — | 🟢 Classificação, condutas, retorno e alerta |
| Lorena | — | 🟢 Relatório resumido em texto |

### Semana 2 — entrega qua 25/11/2026: tasks difíceis do front-end e repositórios

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | — | 🔴 Repositórios (**interfaces e versão em memória até qui 19/11**) |
| Alexandre | 🔴 Alto contraste com `ThemeExtension` | — |
| Larissa | 🔴 Cadastro salvando e "Editar dados" preenchido | — |
| Talita | 🔴 Curva com a criança selecionada | 🔴 z-score OMS: tabelas carregadas e primeiro indicador funcionando |
| Lorena | 🔴 Criança passada pelo fluxo todo | — |

### Semana 3 — entrega final ter 01/12/2026: tasks difíceis do back-end e integração

A entrega final é na **terça-feira**, um dia antes do ritmo das quartas.

| Integrante | Front-end | Back-end |
| --- | --- | --- |
| Davi | Integração final, `develop` → `main`, `README.md` e `CHANGELOG.md` | Revisar os PRs dos repositórios e das regras |
| Alexandre | Cada um troca `AppColors` pelo tema nas próprias telas | 🔴 Sincronização e status pendente |
| Larissa | (idem) | 🔴 Salvar avaliação + correção em 15 min |
| Talita | (idem) | 🔴 z-score: os 4 indicadores integrados ao Resultado e à Curva |
| Lorena | (idem) | 🔴 Histórico, busca e perfil no Firestore |

**Até seg 30/11:** todos os PRs na `develop`. **Na terça 01/12:** merge da `develop` na `main` e entrega final do app.

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
- **Confira o `base` do PR antes de criar.** Ele tem que ser `develop`. Em 11/11/2026 um PR foi mergeado na `main` por engano.
- **Nunca use o botão "Revert" do GitHub num merge.** Em 11/11/2026, reverter um merge na `main` apagou o app inteiro, e isso entrou na `develop`. Se algo entrou errado, peça ajuda antes.
- Se o `flutter pub get` mudar o `pubspec.lock` ou os arquivos `generated_plugin...` sem você ter mexido em dependências, não commite: é diferença de versão do Flutter. Desfaça com `git restore`.

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
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "a primeira entrega tem que ser amanha" | Adicionou a Entrega 1 em 11/11 com as tasks fáceis do front-end e moveu a task fácil de back-end do Davi para a semana de 18/11. |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "atualize o readme e changelog do que foi feito na semana passda e hoje" | Atualizou `README.md` (desenvolvimento de 04/11, planejamento de 10/11, cronograma e como rodar) e `CHANGELOG.md` (registros de 04/11 e 10/11). |
| 10/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "entrefa final do app é dia 1" | Mudou a entrega final de qua 02/12 para ter 01/12 no cronograma do `CONTEXTO_IA.md`, no `README.md` e no `CHANGELOG.md`. |
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "ola, leia o contexto e veja qual é minha taks para entrega de hoje" | Leu o `CONTEXTO_IA.md` e informou a task da Entrega 1 (barra inferior sem a Home duplicada). Nenhum arquivo alterado. |
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "sim, pode fazer chame o time" | Criou a branch `fix/barra-inferior-home` e chamou os agentes frontend, testes e revisor. Início agora volta à Home que já está na pilha (`popUntil`) e recria a Home se ela não estiver lá (`lib/widgets/bottom_nav.dart`). Criou `test/bottom_nav_test.dart` com 6 testes de navegação. `flutter analyze` sem problemas e 43 testes passando. Marcou a pendência como corrigida. |
| 11/11/2026 | Larissa Barbosa dos Santos | Codex (GPT-5.6) | "No campo do CPF, deixar a máscara funcionando, para que ao digitar o número, eles fiquem no formato de CPF. Confirme se máscara e dígito verificador do CPF está funcionando. O calendário está em inglês, deixar em Português Brasileiro. E se atentar a máscara do número telefônico também, para que ele não adicione número a mais, pra seguir conforme a formatação." | Implementou máscaras de CPF e telefone com limite de 11 dígitos, validação dos dígitos verificadores do CPF e localização `pt_BR`; adicionou testes de máscara, limites, CPF válido/inválido e locale do calendário. `dart analyze` sem problemas e 43 testes passando (`pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, `lib/widgets/common.dart`, `lib/utils/input_formatters.dart`, `lib/services/validadores.dart`, `lib/screens/avaliacao/cadastro_crianca_screen.dart`, `test/cadastro_crianca_test.dart`). |
| 11/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Sonnet 5.5) | "Leia o CONTEXTO_IA.md na raiz do projeto antes de começar e siga as regras dele. Sou o Alexandre Afonso Silva Virgens e minha task fácil de hoje (11/11) é: adicionar flutter_localizations com pt_BR no main.dart para o DatePicker aparecer em português, ajustar o teste que procura 'OK' (test/registro_medidas_test.dart) e escrever testes da recuperação de senha (e-mail inválido e senhas que não conferem). Trabalhe só no projeto local, numa branch nova a partir da develop, sem fazer push. Rode flutter analyze e flutter test, faça o commit em português no padrão tipo: descrição e registre meu prompt na tabela do CONTEXTO_IA.md. Não versione CLAUDE.md nem variáveis de ambiente." | Branch `feat/localizacao-pt-br`. Adicionou `flutter_localizations` com `pt_BR` em `pubspec.yaml`, `pubspec.lock` e `lib/main.dart` (locale, delegates e supportedLocales). Em `test/registro_medidas_test.dart`, o MaterialApp passou a usar `pt_BR` (o botão do DatePicker continua `'OK'` em português). Criou `test/recuperacao_senha_test.dart` com testes da 02A (campo vazio bloqueia, e-mail válido avança) e da 02C (senhas que não conferem, senha curta, senhas iguais). `flutter analyze` sem problemas e 43 testes passando. A 02A só valida "campo obrigatório" (não checa o formato do e-mail). |
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "ja fiz o merge na devolop. vamos fazer o pr da brach cadastro crianca vakudacoes" | Descobriu que a `develop` tinha perdido o app (o PR #1 foi mergeado na `main` e revertido pelo GitHub, e o revert entrou na `develop` pelo PR #3). Guiou a restauração (`fix/restaura-develop` e PR #6), resolveu os conflitos do `CONTEXTO_IA.md` nos PRs #2 (cadastro) e #4 (localização) e tirou a configuração `pt_BR` duplicada do `lib/main.dart` no #4. Todos os commits foram feitos pelo integrante. |
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "chame o time e pode começar" | Branch `feat/modelos-id-datetime`, com os agentes frontend, testes e revisor. `id` em `Crianca`, `criancaId` em `Avaliacao`, datas em `DateTime`, busca por id e listas imutáveis no mock (`lib/data/models.dart`, `lib/data/mock_data.dart`). Criou `lib/utils/formatters.dart` e trocou a formatação duplicada em 7 telas. Testes novos: `test/formatters_test.dart` e `test/mock_data_test.dart`. `flutter analyze` sem problemas e 89 testes passando. Atualizou "Decisões e cuidados" e as pendências. |
| 11/11/2026 | Talita Santos das Virgens | Claude Code (Claude Sonnet 5.5) | "Escrever um teste do clique." (pedido de testes) | Histórico passa a abrir a criança do item (`MockData.criancaPorId`), ordena por data decrescente e perde o filtro "Todas" (agora `StatelessWidget`). Arquivos: `lib/screens/historico_screen.dart`, `test/historico_test.dart` (3 testes). `flutter analyze` limpo e 40 testes passando. |

### Prompts longos

<!-- Formato:
#### AAAA-MM-DD — Integrante — Ferramenta
```text
prompt completo
```
-->
