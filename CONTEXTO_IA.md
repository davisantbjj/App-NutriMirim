# Contexto para IAs — Projeto NutriMirim

Este arquivo guarda o histórico do que as IAs (Claude, ChatGPT, Gemini, Copilot etc.) já fizeram no projeto e o registro dos prompts usados pelos integrantes. Todas as LLMs que trabalharem no projeto devem ler este arquivo antes de começar e registrar aqui o que fizeram.

---

## 🤖 Instrução para a IA (leia antes de qualquer tarefa)

> **Se você é uma IA trabalhando neste repositório, siga estas regras:**
>
> 1. **Leia este arquivo inteiro antes de começar.** Ele resume o projeto, o que já foi feito e as decisões tomadas. Não refaça trabalho que já está registrado aqui e não contrarie decisões registradas sem avisar o integrante.
> 2. **Ao terminar a tarefa, registre o que fez.** Adicione uma linha no fim da tabela da seção "Registro de prompts", com: data, integrante, ferramenta/modelo, o prompt **exatamente como foi escrito** (sem corrigir) e um resumo curto do que foi feito e de quais arquivos mudaram.
> 3. **Se a tarefa mudou o projeto** (nova tela, nova regra, nova decisão), atualize também a seção "Decisões e cuidados" ou "Pendências conhecidas". Se concluiu uma task da divisão, troque o status dela para ✅ (ou 🟡 se ficou parte por fazer).
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
- **Classificação nutricional (18/11/2026).** `lib/services/classificacao.dart` (Dart puro) segue as fontes oficiais, e não o mock. **Pontos de corte:** os do SISVAN para 0 a 5 anos (MS, "Orientações para a coleta e análise de dados antropométricos", 2011), sem faixas inventadas: -1,8 é adequado. **Cores** (convenção do app, porque o SISVAN não define cor): verde para a faixa adequada, amarelo para peso elevado para a idade, risco de sobrepeso e sobrepeso, e vermelho para z < -2 e obesidade; z < -3 é `grave`. **Alerta (RF12):** aparece em todo vermelho. É urgente (encaminhar no mesmo dia) só na magreza acentuada (P/E ou IMC/I < -3), que é a desnutrição aguda grave da OMS e do AIDPI; muito baixo peso e muito baixa estatura geram alerta prioritário. O z-score não detecta edema, por isso as condutas pedem para verificar inchaço nos dois pés. **Retorno (RF17):** 5 dias se grave (AIDPI, "peso muito baixo") e 30 dias para os outros vermelhos e amarelos (AIDPI, "peso baixo"). Na faixa adequada, o retorno é a próxima consulta do calendário mínimo do MS (1ª semana, 1, 2, 4, 6, 9, 12, 18 e 24 meses, depois uma por ano), e sem a data de nascimento a função devolve `null` para o profissional definir. Isso substitui o exemplo de 180 dias do RF17. **A conferir na versão oficial do AIDPI 2017:** o retorno de 30 dias para excesso de peso e o esquema completo do peso muito baixo (5 dias, depois 14 e 30). As chaves de `IndicadorAntropometrico` (`pi`, `ei`, `pe`, `imci`) são as do Firestore. Falta ligar `Gravidade` ao `Situacao` de `models.dart` na integração com o Resultado.
- **Curva de crescimento (18/11/2026).** A tela 08 recebe a criança pela rota: o `id` (recomendado) ou o objeto `Crianca`; sem argumento, mostra a criança em destaque. As curvas de referência (menina e menino) ficam em `lib/data/curvas_referencia.dart` e são **aproximadas**: o z-score OMS (task de back-end da Talita) deve substituí-las. Sem cálculo real, o card da última avaliação mostra "—" no Z-score e no percentil. O gráfico usa o `textScaler` e mede os rótulos para definir as margens.
- **Perfis de acesso (11/11/2026).** São 4 papéis: `master`, `acs`, `medico` e `nutricionista`. Os três últimos fazem tudo no app (crianças e avaliações) nas UBS da própria lista (`ubsIds`; o médico pode estar em mais de uma UBS). O `master` é o responsável pelo app: vê e grava os dados de todas as UBS, cadastra os usuários e as UBS. Ter poucos masters, porque ele acessa dados de crianças de todas as unidades (LGPD). Detalhes, campos e regras em [`docs/firestore.md`](docs/firestore.md).
- **Firestore.** Toda correção ou exclusão de avaliação (até 15 min, só o autor; o master a qualquer momento) e toda edição de criança exigem motivo e gravam o histórico em `alteracoes/{versao}` no mesmo lote; as regras recusam o que vier sem isso. Nada é apagado: criança e UBS são desativadas. Rodar os testes das regras: `cd firebase`, `npm install`, `npm test` (precisa de Node 24.12+ e Java).
- **Cores e alto contraste (18/11/2026).** Cores que mudam com o "Alto Contraste" (texto, texto secundário, bordas, ícones, fundo e superfície) vêm de `context.cores` (`lib/theme/app_palette.dart`, um `ThemeExtension`), e não de `AppColors`. Exemplo: `TextStyle(color: context.cores.textoSecundario)` no lugar de `AppColors.textMuted`. Cores de marca e de status continuam em `AppColors`. Quando a cor vier do `context`, tire o `const` do widget. Borda de campo e controle usa `cores.borda` (3:1); borda de cartão e divisória usa `cores.bordaSuave`. Fonte mínima de 12 px.
- **Firebase (18/11/2026).** Projeto `app-nutrimirim` (criado pelo Alexandre), com apps Android, iOS e Web registrados (pacote `br.com.nutrimirim.appnutrimirim`). O `lib/firebase_options.dart` e o `android/app/google-services.json` são versionados: as chaves do Firebase não são senhas, e a proteção dos dados são as regras do Firestore. O `main.dart` chama `Firebase.initializeApp` antes do `runApp`; os testes de widget montam o `NutriMirimApp` direto e não precisam do Firebase. Para rodar no Chrome, o `pubspec.yaml` precisa de `flutter_web_plugins` (SDK). Para adicionar outra plataforma, rode de novo `flutterfire configure --project=app-nutrimirim`. Quem precisar mexer no Console pede ao Alexandre para ser adicionado ao projeto.
- **Arquivos ignorados pelo Git:** `.claude/`, `CLAUDE.md` e `CLAUDE.local.md` são locais de cada integrante. O contexto compartilhado fica **neste arquivo**.
- **Referência do RF02 (17/11/2026):** Larissa determinou o uso da OMS. Pesquisa e parâmetros estão em [`docs/validacao-antropometrica-oms.md`](docs/validacao-antropometrica-oms.md). Os limites de plausibilidade em z-score foram identificados; a implementação deverá compartilhar os dados e o cálculo do RF03, preservar resultados indisponíveis e distinguir alerta de conferência de classificação nutricional. Isso ainda não altera o código do app.

- **Branch de revisão atualizacao (18/11/2026):** reúne os PRs #15 a #20 sobre origin/develop em cddf60c. Cadastro/OMS adaptados a IDs e DateTime; navegação, curva, tema e máscaras conciliados. Os registros antigos abaixo são históricos. O serviço de classificação ainda não está ligado ao Resultado e a curva ainda usa referências aproximadas. Validação: dart analyze sem problemas, 188 testes e build web concluídos. Revisão antes de integrar à develop: [docs/integracao-atualizacao.md](docs/integracao-atualizacao.md).

## Pendências conhecidas

Encontradas na revisão de 10/11/2026 e ainda não corrigidas. Ao corrigir uma, marque `[x]` e registre o prompt.

- [x] Tocar em "Início" na barra inferior empilha uma segunda Home (`lib/widgets/bottom_nav.dart:56-60`). Corrigido em 11/11/2026.
- [x] Tocar num item do Histórico sempre abre a mesma criança, porque nenhum argumento é passado (`lib/screens/historico_screen.dart:39`).
- [x] As telas de dados, registro, curva e histórico não passam a criança adiante, e "Editar dados" abre o cadastro vazio (`dados_crianca_screen.dart`). Corrigido em 18/11/2026.
- [x] O mock contradiz a regra provisória `peso < 10 → desnutrição`: a criança de 9,8 kg aparece como "Normal". A curva mostra 82 cm e o mock tem 85 cm, e os dados da curva estão fixos. Corrigido em 18/11/2026 (a criança em destaque passou a 10,2 kg e a Curva lê as avaliações do mock).
- [x] "Editar dados" do Perfil foi desabilitado e sinalizado como "em breve".
- [x] No cadastro, o nascimento usa DatePicker, o sexo inicia sem seleção e os CPFs têm máscara e validação dos dígitos verificadores.
- [x] Os modelos não têm `id`, as datas são `String` e a busca de avaliações é feita por nome. Corrigido em 11/11/2026.
- [ ] O "Alto Contraste" quase não muda nada, porque as telas usam `AppColors` e cores fixas direto, sem passar pelo `Theme`. _(18/11/2026: tema, `widgets/` e telas 02A–02C já usam `context.cores`. Falta cada integrante trocar `AppColors` nas próprias telas.)_
- [x] Localização `pt_BR` configurada; o DatePicker aparece em Português do Brasil.
- [x] A borda dos campos tem contraste de 1,35:1 e o WCAG pede 3:1. Corrigido em 18/11/2026 (`AppColors.borderStrong`, 3,46:1).
- [ ] Há fontes de 9 a 11 px. _(18/11/2026: corrigidas em `widgets/`. Faltam `login_screen.dart:139` e `home_screen.dart:116` (Davi), `curva_crescimento_screen.dart:235` e `:362` e `historico_screen.dart:58` (Talita), `lista_criancas_screen.dart:194` e `perfil_screen.dart:95` (Lorena).)_
- [x] A formatação de número e de data está duplicada em várias telas. Corrigido em 11/11/2026 (`lib/utils/formatters.dart`).
- [ ] Com a fonte em 2x, a barra inferior estoura 30 px na horizontal (`lib/widgets/bottom_nav.dart:46`). Encontrado em 18/11/2026; os testes de tela pequena só vão até 1,3x/1,5x.
- [ ] Faltam testes de login, recuperação de senha, cadastro, lista, barra inferior e histórico.

### Situação das tasks de Larissa — verificação local em 17/11/2026

Esta verificação considera os arquivos desta cópia do projeto; não confirma entregas de outros integrantes. Larissa autorizou expressamente criar, commitar e enviar uma branch separada em 17/11/2026, substituindo, para esta entrega, a orientação anterior de manter tudo apenas na working tree. Branch desta entrega: `feat/larissa-cadastro-cpf-oms-2026-11-17`, criada a partir da `develop`. Alterações locais anteriores a este trabalho ficam fora do commit.

- [x] Task fácil de front-end (11/11): sexo sem pré-seleção, Semantics e calendário, com testes.
- [x] Task fácil de back-end (18/11): validadores de CPF e plausibilidade das medidas conforme a OMS, com testes. Conclui a validação do RF02; o salvamento permanece pendente.
- [ ] Task difícil de front-end (25/11): cadastro salvando e edição preenchida. Controllers, máscara e validação já adiantados.
- [ ] Task difícil de back-end (01/12): persistência de criança/avaliação, correção em até 15 minutos e auditoria.

| Entrega | Task | Situação e dependências |
| --- | --- | --- |
| 11/11 | Sexo sem pré-seleção, Semantics e calendário | **Concluída em 17/11.** Implementados com testes em `cadastro_crianca_test.dart`. Sexo e nascimento obrigatórios; calendário impede datas futuras. A localização `pt_BR` continua na task de Alexandre. |
| 18/11 | `services/validadores.dart`: CPF e faixas por idade | **Concluída em 17/11 (validação).** CPF com ambos os verificadores e rejeição de repetições; parâmetros OMS por sexo/idade, quatro indicadores, alertas de plausibilidade e motivos de indisponibilidade implementados em conjunto com `services/antropometria_oms.dart`, com tabelas oficiais offline e testes. Persistência do RF02 ainda pendente. |
| 25/11 | Cadastro salvando e edição preenchida | Adiantados controllers, máscara e validação de CPF no formulário. A persistência e edição permanecem pendentes: modelos com `id`/`DateTime` e repositórios do Davi ainda ausentes nesta cópia; Lorena deve encaminhar a criança na ação "Editar dados". O botão ainda apenas navega após validar. |
| 01/12 | Salvar criança/avaliação e corrigir medição em até 15 minutos, com auditoria | Pendente dos repositórios do Davi, identificação do profissional pelo serviço de autenticação do Alexandre e contrato de auditoria (usuário, data e motivo, conforme RNF11). |

**RF02 e Talita — situação atual:** a validação de medidas é responsabilidade de Larissa; tabelas LMS e cálculo de z-score (RF03) foram atribuídos a Talita. Após a definição da OMS por Larissa e seu pedido de implementação, esta entrega adiantou a base numérica compartilhável e concluiu a validação, sem depender de nova implementação de Talita para esse fluxo. Talita ainda precisa integrar classificação, condutas, Resultado e Curva conforme suas tasks; elas não são marcadas como concluídas aqui. Alertas de plausibilidade não equivalem a diagnóstico nutricional. A pesquisa e a implementação abaixo registram a evolução dessa decisão.

**Cuidados do cadastro:** CPF da criança permanece opcional; o do responsável é obrigatório. A checagem é matemática e não comprova existência ou titularidade na Receita. Nenhuma faixa clínica nova foi inventada. A seleção de nascimento não introduz limite clínico de idade; apenas impede data futura (o calendário inicia em 1900). `LabeledField` ganhou suporte opcional a `inputFormatters` para aplicar a máscara nos dois campos de CPF.

**Validação local:** `dart analyze` sem problemas e `flutter test` com 72 testes passando, incluindo 35 novos casos de CPF, máscara e cadastro, além dos testes existentes de layout em 360 dp. Os testes de cadastro foram adicionados; os testes das demais telas listadas nas pendências continuam fora desta task.

**Atualização posterior em 17/11/2026 — pesquisa OMS:** a referência e os limites de plausibilidade foram encontrados e documentados em `docs/validacao-antropometrica-oms.md`. A pendência anterior de descobrir a referência está resolvida. Permanecem a implementação do RF02 e a integração com os parâmetros/cálculo do RF03 da Talita, além da definição conjunta da versão e da fronteira etária. Larissa pode desenvolver desde já a checagem de entradas e a sinalização de z-scores. Não foram modificados arquivos Dart nesta pesquisa; os testes acima pertencem à implementação anterior.

**Atualização posterior em 17/11/2026 — implementação OMS:** por solicitação expressa de Larissa, a validação agora usa os cinco arquivos oficiais offline, com origem/licença/SHA-256, e um serviço Dart puro para os quatro indicadores. A tela 06 recebe a criança do cadastro/ficha, calcula idade na medição, exige posição e informação de edema e mostra alertas de plausibilidade ou motivos de indisponibilidade. A cobertura adotada é `idadeEmDias / 30.4375 < 60`, com dados de 0–1826 dias. A regra provisória `peso < 10` foi retirada desse fluxo; o botão agora é “Validar medidas”. Isso adianta a base numérica reutilizável por Talita no RF03; não implementa classificação, condutas, curva, salvamento ou auditoria. Os detalhes e a política para posição inadequada em menores de 9 meses estão na seção 6 de `docs/validacao-antropometrica-oms.md`. O aviso ilustrativo da tela 07 permanece.

**Verificação da implementação OMS:** `dart analyze` sem problemas; `flutter test` com 73 testes passando. Conferidos os SHA-256 dos cinco arquivos de referência e a ausência de erros em `git diff --check`. Os testes de limites fixos/mocks da tela 06 foram substituídos por testes do novo comportamento.

## Divisão de tarefas — front-end (a partir de 10/11/2026)

Cada integrante continua com as telas que prototipou na Atividade 04/05 e tem uma task fácil e uma difícil. Cada task deve sair com pelo menos um teste novo, e `flutter analyze` e `flutter test` precisam continuar passando.

**Ordem:** a task difícil do Davi (ids e datas nos modelos) vai primeiro, porque as tasks difíceis de Larissa, Talita e Lorena dependem dela. As tasks fáceis podem começar já.

**Status das tasks:** ✅ concluída (já na `develop`) · 🟡 em andamento · ⬜ a fazer. Ao terminar uma task e fazer o merge na `develop`, troque o símbolo dela para ✅ e, se for o caso, escreva o que ficou faltando. Este é o único lugar com o status das tasks; o cronograma abaixo mostra só as datas.

| Integrante | Telas | 🟢 Task fácil | 🔴 Task difícil |
| --- | --- | --- | --- |
| Davi Santana Lóz | 01 Abertura, 02 Login, 03 Início (+ barra inferior) | ✅ Corrigir a barra inferior, que empilha uma segunda Home (`widgets/bottom_nav.dart`), e criar um teste de navegação. | ✅ Pôr `id` em `Crianca`, trocar as datas `String` por `DateTime` em `data/models.dart` e `mock_data.dart`, buscar avaliações por id em vez de nome e criar `utils/formatters.dart` para centralizar a formatação de número e de data. **Bloqueia os outros: fazer primeiro.** _(Concluída em 11/11, PR #8.)_ |
| Alexandre Afonso Silva Virgens | 02A–02C Recuperação de senha | ✅ Adicionar `flutter_localizations` com `pt_BR` no `main.dart` (calendário em português; ajustar o teste que procura `'OK'`) e escrever testes da recuperação de senha (e-mail inválido, senhas que não conferem). | 🟡 Fazer o "Alto Contraste" funcionar de verdade: criar um `ThemeExtension` com as cores, usá-lo em `theme/` e `widgets/`, subir o contraste da borda dos campos para no mínimo 3:1 e as fontes para no mínimo 12 px. Depois disso, cada integrante troca `AppColors` pelo tema nas próprias telas, para evitar conflito no Git. _(Tema e widgets prontos em 18/11: `lib/theme/app_palette.dart`, borda dos campos em 3:1 e fontes de 12 px nos widgets. Falta cada um trocar `AppColors` e as fontes pequenas nas próprias telas.)_ |
| Larissa Barbosa dos Santos | 04 Nova avaliação, 05 Cadastro, 06 Registro de medidas | ✅ No cadastro: tirar a pré-seleção do sexo, adicionar `Semantics` (botão e selecionado) ao seletor e trocar o nascimento em texto livre por um DatePicker. | 🟡 Fazer o cadastro salvar de verdade: controllers nos campos, máscara e dígito verificador do CPF e "Editar dados" abrindo o formulário preenchido com a criança escolhida. Escrever testes de validação. _(Máscara e dígito verificador do CPF prontos em 11/11, PR #2. Falta salvar e o "Editar dados".)_ |
| Talita Santos das Virgens | 07 Resultado, 08 Curva, 09 Histórico | ✅ No Histórico: abrir a criança certa ao tocar no item, ordenar a lista da avaliação mais recente para a mais antiga e remover o filtro que só tem a opção "Todas". Escrever um teste do clique. _(Concluída em 11/11, PR #10.)_ | ✅ Na Curva: usar a criança selecionada em vez de dados fixos, alinhar o mock com a regra provisória (o caso dos 9,8 kg e a diferença 82/85 cm), melhorar o contraste dos rótulos e respeitar o `textScaler` no gráfico. Testar a variação "Desnutrição" do Resultado. _(Concluída em 18/11; entrou na `develop` pelo PR #21, junto com a navegação da Lorena.)_ |
| Lorena Reis Santos | 10 Dados da criança, 11 Perfil, 12 Lista de crianças | ✅ No Perfil: desabilitar o "Editar dados" ou mostrar "Em breve". Na Lista: fazer a busca ignorar acentos ("joao" encontra "João"). Escrever testes da busca. _(Concluída em 11/11, PR #11.)_ | ✅ Em Dados da criança: passar a criança para Registrar avaliação, Curva, Histórico e Editar dados, para que todo o fluxo mostre a mesma criança. Escrever testes de navegação. _(Concluída em 18/11/2026.)_ |

## Divisão de tarefas — back-end (a partir de 10/11/2026)

### Stack proposta (confirmar com o grupo)

Ainda não existe back-end, e o app usa `MockData`. A proposta é usar o **Firebase**:

- **Firebase Auth:** login, recuperação de senha e sessão.
- **Cloud Firestore:** banco com **cache offline nativo**. O app grava sem internet e sincroniza sozinho quando a rede volta, o que atende RF07 e RF08 sem precisar escrever um servidor próprio.
- **Camada de repositório:** as telas nunca falam com o Firebase direto. Elas usam interfaces (`CriancaRepository`, `AvaliacaoRepository`, `AuthService`), e cada interface tem uma implementação com Firestore e outra **em memória**, usada nos testes.
- **Regras de negócio** (z-score, classificação, validações) em `lib/services/`, como funções puras e testáveis, sem Flutter nem Firebase.

**Status:** mesma legenda da divisão do front-end (✅ concluída · 🟡 em andamento · ⬜ a fazer).

Fora do escopo das 3 semanas, por serem "Secundárias" na priorização: RF15 (leitura do Cartão SUS por câmera), RF19 (consolidado do turno) e a criptografia do banco local (RNF04, que fica registrada como pendência).

### Tasks

| Integrante | Área | 🟢 Task fácil | 🔴 Task difícil |
| --- | --- | --- | --- |
| Davi Santana Lóz | Dados e repositórios | ✅ Documentar as coleções do Firestore (`profissionais`, `criancas`, `avaliacoes`: campos e tipos) e escrever as **regras de segurança**, para que cada profissional só leia e grave os dados da própria UBS (LGPD). _(Concluída em 11/11: `docs/firestore.md`, `firestore.rules` e 63 testes em `firebase/`.)_ | ⬜ Criar as interfaces `CriancaRepository` e `AvaliacaoRepository`, com uma implementação em memória e outra com Firestore, e trocar o `MockData` pelos repositórios nas telas. **Publicar as interfaces e a versão em memória primeiro, para os outros já trabalharem em cima delas.** |
| Alexandre Afonso Silva Virgens | Autenticação e sincronização | 🟡 Configurar o Firebase no projeto (`firebase_core`, `flutterfire configure`) e criar o `AuthService`: login com e-mail e senha, recuperação de senha (`sendPasswordResetEmail`), logout e manter a sessão aberta. Ligar o serviço às telas 02 e 02A–02C. _(Firebase configurado em 18/11: projeto `app-nutrimirim`, apps Android, iOS e Web. Falta o `AuthService` e ligar às telas.)_ | ⬜ Sincronização e status (RF08, RF16): detectar se há rede, mostrar no Histórico os registros pendentes de envio (`hasPendingWrites`) e testar o fluxo com o modo avião. |
| Larissa Barbosa dos Santos | Cadastro e medições | ✅ Criar `services/validadores.dart` com o dígito verificador do CPF e as faixas fisiológicas por idade (RF02), com testes. _(CPF em 11/11, PR #2. Faixas pela OMS em 17/11, `services/antropometria_oms.dart`; entrou na `develop` pelo PR #21.)_ | ⬜ Salvar a criança e a avaliação pelos repositórios (RF01, RF02) e permitir corrigir uma medição até 15 minutos depois do registro (RF14), com o registro de quem alterou e quando (RNF11). |
| Talita Santos das Virgens | Cálculo nutricional | ✅ Criar `services/classificacao.dart` com a classificação semafórica a partir do z-score (RF04), as micro-condutas por faixa (RF13), a sugestão da data de retorno (RF17) e o alerta de encaminhamento para z-score crítico (RF12), com testes. _(Concluída em 18/11; entrou na `develop` pelo PR #21. As telas ainda não usam o serviço: isso fica para a task difícil.)_ | ⬜ Cálculo do z-score pela OMS (RF03): carregar as tabelas LMS da OMS (0 a 5 anos) como asset JSON, calcular peso-para-idade, altura-para-idade, peso-para-altura e IMC-para-idade com `z = ((X/M)^L − 1) / (L·S)` e fornecer os pontos da Curva (RF06). Testar contra valores das tabelas oficiais. **Substitui a regra provisória `peso < 10`.** |
| Lorena Reis Santos | Consultas e relatórios | ✅ Gerar o relatório resumido da avaliação em texto (RF10): dados da criança, z-score, classificação e data, com o botão de compartilhar. _(Concluída em 18/11: `services/relatorio_avaliacao.dart` e botão na tela 06; entrou na `develop` pelo PR #24.)_ | ⬜ Consultas: histórico longitudinal em ordem de data (RF05), busca por nome parcial ou CPF do responsável (RF11, guardando o nome normalizado sem acentos para a busca) e perfil do profissional com a UBS e a microárea (RF18). |

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
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "no contexto_ia era bom ter dalgum espaco nas task para marcar como concluida" | Branch `docs/status-das-tasks`. Pôs um status (✅ concluída, 🟡 em andamento, ⬜ a fazer) em cada task das tabelas de divisão do front-end e do back-end, com a legenda, e marcou o que já entrou na `develop` (PRs #1/#6, #2, #4 e #8). Acrescentou na "Instrução para a IA" que a IA deve atualizar o status. Só `CONTEXTO_IA.md`. |
| 11/11/2026 | Davi Santana Lóz | Claude Code (Claude Opus 5.5) | "Vamos fazer as minhas tasks de back-end." Ao longo da conversa: "Serão 4 perfis de acesso: master, ACS, médico e nutricionista. Todos têm acesso a tudo, e o master tem uma opção a mais: cadastrar os usuários." · "O master é o responsável pelo app, então ele também cadastra as UBS." · "O médico pode estar em mais de uma UBS." | Criou a branch `feat/firestore-colecoes-regras` com os agentes backend, seguranca e revisor. Documentou as coleções `ubs`, `profissionais`, `criancas` e `avaliacoes` em `docs/firestore.md`. Escreveu as regras em `firestore.rules`: 4 perfis (master, acs, medico e nutricionista), o master com acesso total e cadastro de usuários e UBS, o profissional em várias UBS e histórico obrigatório em toda correção. 63 testes no emulador (`firebase/`). |
| 11/11/2026 | Não informado | Copilot SDK in VS Code | "leia o contexto_IA.md" | Leu o contexto do projeto; registrou este pedido em `CONTEXTO_IA.md`. |
| 11/11/2026 | Lorena Reis Santos | Copilot SDK in VS Code | "Identificação! Meu nome é Lorena Reis Santos e minha tarefa é criar as telas de Dados da criança, perfil do profissional e lista de crianças." | Registrou a identificação da integrante e sua área de atuação neste histórico. |
| 11/11/2026 | Lorena Reis Santos | Copilot SDK in VS Code | "No Perfil: desabilitar o \"Editar dados\" ou mostrar \"Em breve\". Na Lista: fazer a busca ignorar acentos (\"joao\" encontra \"João\"). Escrever testes da busca." | Desabilitou e sinalizou o botão de edição do Perfil; fez a busca da Lista ignorar acentos e caixa e adicionou testes para ambos em `perfil_screen.dart`, `lista_criancas_screen.dart` e `telas_test.dart`. |
| 11/11/2026 | Lorena Reis Santos | Copilot SDK in VS Code | "Na Lista: fazer a busca ignorar acentos (\"joao\" encontra \"João\")." | Confirmou que a busca sem acentos já está implementada e coberta por teste em `lista_criancas_screen.dart` e `telas_test.dart`; nenhuma alteração adicional de código foi necessária. |
| 18/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Opus 5.5) | "rode o projeto" · "reinicie" · "retome" | Rodou `flutter run -d chrome` (o Windows desktop não compila sem o Visual Studio). Nenhum arquivo alterado. |
| 18/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Opus 5.5) | "Essa task da esquerda ja foi feita?" · "Essa task da direita foi feita?" · "Como essa task pode ser feita? me mande os passos a passos e eu crio uma branch nova e etc... não quero que tenha coautoria la no git" · "O que você consegue fazer aqui sem publicar nada?  e o que fica faltando pra eu ter que fazer?" | Conferiu que a task fácil (pt_BR e testes da recuperação) estava concluída e que a do Alto Contraste não tinha sido feita. Explicou o passo a passo da task difícil. Nenhum arquivo alterado. |
| 18/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Opus 5.5) | "faça o que vc consegue e depois deixe os passos para eu fazer o restante" | Branch `feat/alto-contraste`, sem commit nem push (o integrante commita, sem coautoria). Criou `lib/theme/app_palette.dart` (`ThemeExtension` com paleta normal e de alto contraste e o atalho `context.cores`). `app_theme.dart` passou a usar a paleta; borda dos campos e trilho do switch em `AppColors.borderStrong` (`#6F8BA6`, 3,46:1). Em `widgets/common.dart` e `widgets/bottom_nav.dart`, as cores neutras vêm da paleta e as fontes de 10 e 11 px passaram a 12. Telas 02A e 02B usam `context.cores`. Criou `test/alto_contraste_test.dart` (7 testes). `flutter analyze` sem problemas e 102 testes passando. Atualizou status da task, pendências e "Decisões e cuidados". |
| 18/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Opus 5.5) | "Tudo certo com essas duas tasks?" · "Essas duas tasks são as próximas - verifique e não publique nada antes de me avisar" · "Qual é a entrega que temos pra hoje?" · "Quero fazer outra task relacionada ao firebase" (escolheu "Só configurar o Firebase") | Conferiu o PR #15 (base `develop`, sem conflitos, sem revisor) e que as tasks de back-end do Alexandre não tinham sido começadas. Nenhum arquivo alterado. |
| 18/11/2026 | Alexandre Afonso Silva Virgens | Claude Code (Claude Opus 5.5) | "Se está perguntando sobre nome de projeto eu criei o projeto no firebase então quando mexer pode fvincular ao meu projeto criado lá , não entendi sobre as plataformas que ficaram de fora, explique ´rpmtp sigo com a sua recomendação (Minha recomendação é commitar, para o app compilar para todo o grupo.) - faça [...] Posso rodar o flutterfire configure com essas opções?- não vai ser feito nada no github não é? eu não quero coautoria - quero eu mesmo criando e enviando commits pra la" | Branch `feat/firebase-config`, sem commit nem push. Adicionou `firebase_core` e `flutter_web_plugins` (`pubspec.yaml`, `pubspec.lock`). Rodou `flutterfire configure` no projeto `app-nutrimirim` (apps Android, iOS e Web): gerou `lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json` e o plugin `google-services` no Gradle. `main.dart` chama `Firebase.initializeApp`. Criou `test/firebase_options_test.dart` (2 testes). App abre no Chrome sem erro, `flutter analyze` sem problemas e 96 testes passando. |
| 18/11/2026 | Talita Santos das Virgens | Claude Code (Claude Opus 5.5) | "vou iniciar a task facil do backend Cálculo nutricional \|Criar `services/classificacao.dart` com a classificação semafórica a partir do z-score (RF04), as micro-condutas por faixa (RF13), a sugestão da data de retorno (RF17) e o alerta de encaminhamento para z-score crítico (RF12), com testes." · "nunca faça o commit, quem faz sou eu manualmente" · "não vá pelos dados do mock e sim o certo, o que é de fato valido" | Branch `feat/classificacao-nutricional` (sem commit, que a integrante faz). Criou `lib/services/classificacao.dart`: classificação por indicador e por avaliação com os pontos de corte oficiais do SISVAN (a faixa de atenção tirada do mock foi removida), micro-condutas por gravidade, desvio e idade, retorno pelo AIDPI e pelo calendário mínimo de consultas do MS e alerta urgente só na magreza acentuada. Criou `test/classificacao_test.dart` com 32 testes. `flutter analyze` sem problemas e 126 testes passando. Registrou as fontes em "Decisões e cuidados". |
| 18/11/2026 | Talita Santos das Virgens | Claude Code (Claude Opus 5.5) | "finalizar a task dificil do front" ·| Branch `feat/curva-crianca-selecionada`. A Curva (tela 08) usa a criança da rota (`id` ou `Crianca`) e as avaliações dela, com curvas de menina e menino (`lib/data/curvas_referencia.dart`) e avisos quando não há avaliação ou data de nascimento. A criança em destaque passou de 9,8 para 10,2 kg (`lib/data/mock_data.dart`). Os rótulos do gráfico passaram a ter contraste AA, e o gráfico respeita o `textScaler` (margens, balão e altura acompanham a fonte; rótulos que se sobrepõem são pulados). Criou `test/curva_crescimento_test.dart` (Curva, coerência do mock e variação Desnutrição do Resultado). `flutter analyze` sem problemas e 104 testes passando. |
| 18/11/2026 | Lorena Reis Santos | Copilot SDK in VS Code | "meu nome é Lorena. a minha task difícil é a seguinte: Em Dados da criança: passar a criança para Registrar avaliação, Curva, Histórico e Editar dados, para que todo o fluxo mostre a mesma criança. Escrever testes de navegação." | Passou o `id` da criança pelas telas 05, 06, 08 e 09 a partir da tela 10; o cadastro de edição passou a ser preenchido com os dados da criança; o Histórico passou a aceitar a criança selecionada; a barra inferior ganhou layout responsivo na largura pequena. Adicionou `test/navegacao_crianca_test.dart` com testes de navegação. `flutter analyze` limpo e 98 testes passando. Arquivos: `lib/screens/crianca/dados_crianca_screen.dart`, `lib/screens/crianca/lista_criancas_screen.dart`, `lib/screens/avaliacao/registro_medidas_screen.dart`, `lib/screens/avaliacao/cadastro_crianca_screen.dart`, `lib/screens/crianca/curva_crescimento_screen.dart`, `lib/screens/historico_screen.dart`, `lib/widgets/bottom_nav.dart`, `test/navegacao_crianca_test.dart` e `CONTEXTO_IA.md`. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "Chat, sou Larissa, vamos verificar quais são minhas tasks, as que eu preciso e posso fazer sem precisar dos outros, e adiantar as minhas tasks (Leia o arquivo contexto.ia)" | Leu o contexto e os requisitos, conferiu dependências locais e implementou sexo obrigatório com Semantics, DatePicker, controllers e CPF com máscara/validação. Criou `lib/services/validadores.dart`, `lib/utils/cpf_input_formatter.dart` e três arquivos de testes; alterou `cadastro_crianca_screen.dart`, `widgets/common.dart` e este contexto. Persistência e faixas por idade continuam pendentes. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "Ainda não, se não me engano essa task era de Talita. Procure e analise se o que preciso fazer, depende dela." | Confirmou a divisão RF02 (Larissa) e RF03/tabelas OMS (Talita), a ausência de limites por idade e a necessidade de alinhar a referência com Talita/grupo; registrou as dependências sem alterar cálculos clínicos. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "O que falta fazer?" | Explicou as pendências de RF02, persistência, edição, auditoria e tema, distinguindo as partes prontas e as dependências dos demais integrantes. Registro acrescentado junto à pesquisa seguinte. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "No caso essa validação de peso e altura por idade, dever seguir os da OMS (organizaçao mundial da saude), leia o contextos dos arquivos e vasculhe a internet, para podermos utilzar para os parametros" | Releu contexto, pesquisa, estudo de caso, requisitos e código; consultou páginas, manual e implementação oficiais da OMS. Criou `docs/validacao-antropometrica-oms.md` com limites de plausibilidade, fontes dos dados, regras de medição, proposta de integração RF02/RF03 e casos de teste. Atualizou este contexto, sem alterar Dart ou executar comandos de escrita no Git. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "Implemente os parametros para o código, conforme a OMS, e a necessidade do nosso aplicativo" | Importou tabelas oficiais com procedência e licença em `assets/oms/`, criou importador, `services/antropometria_oms.dart` e `data/oms_assets.dart`, ampliou `validadores.dart`, conectou cadastro/ficha à validação na tela 06 e substituiu a regra de resultado mock por alertas OMS. Atualizou `pubspec.yaml`, testes e documentação. Persistência e classificação clínica permanecem pendentes; nenhuma escrita no Git. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "O que falta fazermos agora?" | Detalhou as pendências de persistência, edição, auditoria e integração, distinguindo as validações concluídas das dependências dos demais integrantes. |
| 17/11/2026 | Larissa Barbosa dos Santos | ChatGPT / Codex | "Quero que vocë suba essas alterações em uma nova branch, para que possamos comparar com a outra futuramente. Então, deve ser subida em uma branch separada. Se atente a marcar as minhas tasks que foram concluidas no arquivo contexto_ia, por favor! Suba a branch a identificando as tasks feitas hoje" | Atualizou o checklist e a situação das tasks de Larissa neste contexto; organizou cadastro acessível, validadores de CPF/OMS, tabelas oficiais, documentação e testes para a branch `feat/larissa-cadastro-cpf-oms-2026-11-17`, a partir da `develop`, conforme autorização expressa para commit e envio. Alterações locais preexistentes excluídas desta entrega. |

| 18/11/2026 | Não informado | ChatGPT / Codex | "preciso juntas todas em uma nova brach atualizacao e juntas todas a brachs abertar para pr la depois irei analisar e juntar com a develop por ultimo" | Criou atualizacao a partir de origin/develop e reuniu os PRs #15 a #20 em worktree separada. Resolveu conflitos preservando IDs/DateTime, navegação, curva, alto contraste, Firebase, CPF/OMS e registros históricos; preservou os testes das branches e acrescentou dois testes de integração. dart analyze sem problemas, 188 testes passando e build web concluído. Documentou revisão em docs/integracao-atualizacao.md; alterações locais preexistentes preservadas. |

### Prompts longos

<!-- Formato:
#### AAAA-MM-DD — Integrante — Ferramenta
```text
prompt completo
```
-->
