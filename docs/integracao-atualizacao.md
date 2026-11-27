# Integração para revisão — atualizacao

Branch criada a partir de `origin/develop` em `cddf60c`, em 18/11/2026. Reúne os seis PRs abertos para revisão conjunta antes de qualquer integração à `develop`.

| PR | Branch | Commit de origem |
| --- | --- | --- |
| #15 | `feat/alto-contraste` | `3824dc8` |
| #16 | `feat/curva-crianca-selecionada` | `994bfd2` |
| #17 | `feat/firebase-config` | `b2fc306` |
| #18 | `feat/classificacao-nutricional` | `9cdd298` |
| #19 | `fix/navegacao-dados-crianca` | `7a7633f` |
| #20 | `feat/larissa-cadastro-cpf-oms-2026-11-17` | `3c07cd4` |

## Resoluções da integração

- Cadastro e medidas usam os modelos atuais: ID da criança e datas em `DateTime`. As telas aceitam IDs de crianças do mock e objetos recebidos pela rota. O cadastro preserva ID, data de cadastro, endereço e e-mail na passagem para medidas.
- Novos cadastros recebem um ID temporário com prefixo `rascunho-`, apenas para o fluxo em memória. O repositório deverá atribuir o ID definitivo quando a persistência for implementada.
- A curva mantém os dados da criança selecionada e a adaptação à escala de texto. A barra inferior combina o layout responsivo com a paleta de alto contraste.
- A máscara de CPF tem implementação única, com preservação do cursor e rejeição de entradas acima de 11 dígitos. A máscara de telefone e o calendário em português foram preservados.
- Os testes anteriores de cadastro foram mantidos também em `cadastro_localizacao_mascaras_test.dart`. Os testes de medidas foram adaptados ao fluxo OMS, substituindo a regra provisória de peso fixo.
- Dois testes em `integracao_cadastro_oms_test.dart` verificam o fluxo real do cadastro até medidas por ID e por objeto, com preservação dos dados.
- Os registros históricos das branches foram mantidos em `CONTEXTO_IA.md`. _(26/11/2026: as verificações e listas de tarefas antigas foram trocadas pela lista única de "Pendências"; o histórico de cada pedido continua no "Registro de prompts".)_

## Validação

- `dart analyze`: sem problemas.
- `flutter test --no-pub`: 188 testes passando.
- `flutter build web --no-pub`: build concluído em `build/web`.
- As dependências foram resolvidas por `flutter pub get`. A preparação dos plugins desktop encontrou a exigência de suporte a links simbólicos do Windows; os testes e o build web foram executados com as dependências já resolvidas. Não houve alteração de configuração do Windows.
- Não foram executados builds Android/iOS nem testes de acesso ao serviço Firebase em execução. As regras Firestore não foram alteradas por esta integração.

## O que revisar antes do merge na develop

1. Abrir uma criança na lista e conferir Dados, Histórico, Curva, Editar dados e Registrar Avaliação.
2. Conferir máscaras, calendário em português, campos obrigatórios e carregamento das tabelas OMS.
3. Alternar alto contraste e conferir as telas nos tamanhos de fonte usados pelo projeto.
4. Conferir a inicialização Firebase no ambiente de execução escolhido.

As limitações das entregas continuam explícitas: cadastro e medidas ainda não persistem; o serviço de classificação ainda precisa ser conectado ao Resultado; as curvas desenhadas usam referências aproximadas, enquanto a validação de medidas usa os assets OMS. Não há nova implementação dessas tarefas nesta integração.

As alterações não commitadas da pasta de trabalho original não fazem parte desta branch. A integração foi feita em worktree separada, sem novo merge em `develop` ou `main` e sem mudar a base ou encerrar os PRs originais.
