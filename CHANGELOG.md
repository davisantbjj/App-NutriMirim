## [25/11/2026]

### Adicionado
- `AuthService` com login por e-mail e senha, recuperação de senha, logout e sessão mantida, ligado às telas de Abertura, Login, Recuperação de senha e Perfil (`firebase_auth`).
- Sessão do profissional: depois do login, o app lê o perfil em `profissionais/{uid}` (papel, UBS e microárea) e passa a usar o Firestore. Perfil ausente ou inativo volta ao login.
- Z-score pela OMS (tabelas LMS 2006) nos quatro indicadores, integrado ao Resultado e à Curva de crescimento.
- Perfil por papel: nome, papel, UBS e microárea reais e seletor de UBS para o médico.
- Lista de crianças e Início filtrados pela microárea do ACS, com a opção de ver toda a UBS.
- Banco Firestore criado no projeto (São Paulo), com as regras e os índices publicados e contas de teste de cada papel.
- Cadastro e avaliações salvos pelos repositórios: cadastro e edição com motivo obrigatório, escolha da UBS de Referência entre as UBS da sessão e bloqueio de envio duplicado. A avaliação grava as medidas, a posição, o edema, os indicadores, a classificação e o retorno. Pelo Histórico, a avaliação pode ser corrigida em até 15 minutos, com recálculo e auditoria (branch `feat/larissa-cadastro-avaliacoes`, aguardando o PR).
- Campos novos no Firestore: `criancas.cpf` (opcional) e `avaliacoes.edema`, com `cpfAnterior` e `edemaAnterior` nos logs. As regras foram atualizadas e publicadas (67 testes no emulador).
- Passo a passo do cadastro de profissionais (`docs/cadastro-de-profissionais.md`), diagrama de classes (`docs/diagrama-de-classes.md`) e diagrama de casos de uso (`docs/casos-de-uso.md`).
- Testes do login, dos erros de autenticação, da sessão do profissional e do Histórico (463 testes na `develop`; 481 com a branch da Larissa).

### Modificado
- Registro de medidas abre o Resultado com a classificação calculada, e o Resultado abre a Curva da mesma criança. O Resultado não usa mais o mock.
- Curva de crescimento com as linhas da OMS no lugar das curvas aproximadas, e o card da última avaliação mostra o z-score e o percentil.
- Cores neutras trocadas pelo tema (`context.cores`) e fontes de no mínimo 12 px nas telas de Resultado, Curva, Histórico, Lista, Perfil, Dados da criança, Cadastro e Nova avaliação.
- `Responsavel.cpf` passa a ser o nome do CPF completo do responsável (`cpfMascarado` fica como nome antigo, por compatibilidade).
- Percentil e medidas formatados pelo `formatarDecimal`.
- `README.md` e `CHANGELOG.md` atualizados com a semana de 25/11.

### Corrigido
- Erros fora do Firebase Auth deixavam o app parado na Abertura. Agora ele volta ao Login, e um erro ao sair mostra a mensagem no Perfil.
- A recuperação de senha não informa mais se um e-mail tem conta.
- O cache offline do Firestore (com dados das crianças) ficava no aparelho depois de sair e podia ser visto pela próxima conta. Agora é apagado ao sair, e o app não deixa sair enquanto houver gravações ainda não enviadas.
- Troca de UBS no Firestore.

## [22/11/2026]

### Adicionado
- Repositórios de crianças e avaliações (`CriancaRepository` e `AvaliacaoRepository`), com uma versão em memória (padrão do app e dos testes) e outra com Cloud Firestore (`cloud_firestore`).
- Edição, desativação, correção e exclusão com motivo obrigatório e registro de auditoria; correção de avaliação em até 15 minutos pelo autor (o master pode sempre).
- Busca de crianças por nome sem acento ou pelo CPF do responsável.
- Dois índices novos do Firestore para o histórico geral de avaliações.
- Testes dos repositórios, das conversões para o Firestore e dos estados de carregamento e erro das telas (379 testes no total).

### Modificado
- Lista de crianças, Histórico, Dados da criança, Curva, Cadastro e Registro de medidas passaram a ler os dados pelos repositórios, e não mais direto do mock.
- Dados da criança e Curva atualizam sozinhos após uma edição e mostram "Criança não encontrada." para um id inexistente.
- Criança desativada mostra "Cadastro desativado" e não pode ser editada nem receber avaliação.
- `README.md` e `CHANGELOG.md` atualizados com a semana de 18/11.

## [18/11/2026]

### Adicionado
- Configuração do Firebase no projeto `app-nutrimirim` (Android, iOS e Web).
- Coleções e regras de segurança do Firestore por UBS e por perfil de acesso (master, ACS, médico e nutricionista), com 63 testes no emulador.
- Validação antropométrica pela OMS, com as tabelas oficiais offline e alertas de plausibilidade das medidas.
- Classificação nutricional pelos pontos de corte do SISVAN, com condutas, sugestão de retorno e alerta de encaminhamento.
- Relatório resumido da avaliação em texto, com botão de compartilhar.
- Alto contraste com `ThemeExtension` (`context.cores`).

### Modificado
- Curva de crescimento passou a usar a criança selecionada e as avaliações dela, com curvas de menina e menino.
- Dados da criança passam a mesma criança para Registro de medidas, Curva, Histórico e Editar dados, que abre o formulário preenchido.
- Registro de medidas passou a validar as medidas pela OMS, em vez da regra provisória `peso < 10`.
- Borda dos campos com contraste de 3:1 e fontes de no mínimo 12 px nos componentes compartilhados.

### Corrigido
- Mock da criança em destaque coerente com a situação "Normal" (10,2 kg).
- Contraste dos rótulos do gráfico da curva e respeito ao tamanho da fonte do sistema.
- `firebase_core` ajustado para a versão compatível com o Flutter 3.35.3.

## [11/11/2026]

### Adicionado
- Testes automatizados de navegação, recuperação de senha e busca de crianças.
- Suporte à localização `pt_BR` no aplicativo.
- Identificador único (`id`) no modelo de crianças.
- Utilitários para formatação de datas e números.
- Máscara e validação de CPF.
- Seleção de data de nascimento por calendário (`DatePicker`).
- Recursos de acessibilidade no formulário de cadastro.

### Modificado
- Modelos de dados atualizados para utilizar `DateTime` e relacionar avaliações pelo ID da criança.
- Histórico de avaliações ordenado da mais recente para a mais antiga.
- Busca de crianças aprimorada para ignorar acentos.
- Interface do Perfil ajustada para indicar funcionalidades indisponíveis.
- Cadastro atualizado para remover a pré-seleção do sexo.

### Corrigido
- Duplicação da tela inicial na barra de navegação inferior.
- Navegação do Histórico para abrir a criança correspondente.
- Remoção do filtro sem funcionalidade da tela de Histórico.

## [10/11/2026]

### Adicionado
- `CONTEXTO_IA.md`: contexto compartilhado para as IAs usadas pelo grupo, com instruções para qualquer LLM, prompt pronto para ferramentas externas e registro dos prompts usados.
- Padrão de commits em português (`tipo: descrição`) e fluxo de trabalho com uma branch por task e Pull Request para a `develop`.
- Divisão das tasks de front-end e back-end entre os 5 integrantes, com uma task fácil e uma difícil para cada um.
- Proposta de back-end com Firebase (Auth e Firestore com funcionamento offline) e camada de repositórios.
- Cronograma de 3 semanas com entregas às quartas-feiras (11/11, 18/11 e 25/11) e entrega final do app na terça-feira, 01/12.
- Lista de pendências encontradas na revisão geral do código.

### Modificado
- `README.md` atualizado com o desenvolvimento do aplicativo, o planejamento, o cronograma e como rodar o app.
- `CHANGELOG.md` atualizado com os registros de 04/11 e 10/11.

## [04/11/2026]

### Adicionado
- Projeto Flutter do aplicativo NutriMirim (`appnutrimirim/`).
- Importação do protótipo do Figma para o código.

### Modificado
- `.gitignore` atualizado para ignorar os arquivos locais do Claude Code.

## [29/09/2026]

### Adicionado
- Atividades 04 e 05: Desenvolvida a prototipação das telas do aplicativo NutriMirim.
- Criadas as telas de abertura, login, recuperação de senha, início, nova avaliação, cadastro da criança, registro de medidas, resultado, curva de crescimento, histórico, dados da criança, perfil profissional e cadastro de crianças.
- Elaborado o protótipo de baixa fidelidade.
- Elaborado o protótipo final para apresentação e entrega.
- Elaborado o justificativas.md

### Modificado
- `README.md` atualizado com as responsabilidades dos integrantes nas Atividades 04 e 05.
- `CHANGELOG.md` atualizado com o registro das atividades de prototipação, apresentação e entrega final.

## [16/09/2026]

### Adicionado

* Elaborados os requisitos e funcionalidades do NutriMirim.
* Definidos os requisitos funcionais (RF01 a RF19) do aplicativo.
* Documentadas as funcionalidades relacionadas ao cadastro da criança, registro de medidas antropométricas, cálculo de z-score, classificação nutricional, histórico de acompanhamento, curvas de crescimento, funcionamento offline, relatórios e proteção de dados.
* Estruturado o CRUD para o gerenciamento dos dados da criança, responsável legal e avaliações antropométricas.
* Definida a priorização das funcionalidades em **Essenciais, Importantes e Secundárias**, considerando as necessidades dos usuários e o contexto de uso em campo.

## [09/09/2026]

### Adicionado
- Atividade 02: Adicionados documentos de pesquisa (`docs/pesquisa.md`), benchmark (`docs/benchmark.md`), personas (`docs/personas.md`) e apresentação (`docs/apresentacao.pdf`).

### Modificado
- `README.md` atualizado com as responsabilidades de cada integrante.

## [02/09/2026]

### Adicionado
- Análise inicial do estudo de caso.
