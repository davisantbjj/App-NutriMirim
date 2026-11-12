# Cloud Firestore: coleções e regras de segurança

Este documento descreve o modelo de dados do NutriMirim no Cloud Firestore e as regras de segurança (`firestore.rules`). Cada profissional lê e grava **somente os dados das UBS da sua lista** (LGPD); o `master` (responsável pelo app) acessa todas.

Arquivos relacionados (raiz do repositório):

- `firestore.rules`: regras de segurança.
- `firestore.indexes.json`: índices compostos.
- `firebase.json`: aponta para as regras, os índices e o emulador.
- `firebase/`: testes das regras (emulador, 63 testes).

## Papéis e permissões

| Papel | Alcance | O que pode fazer |
| --- | --- | --- |
| `acs`, `medico`, `nutricionista` | UBS da própria lista (`ubsIds`) | Todos iguais, sem restrição por papel: ler e cadastrar crianças, editar/desativar criança (com motivo e log), registrar avaliações, corrigir ou excluir a **própria** avaliação em até 15 min (com motivo e log). Ler o próprio perfil e as UBS da lista. Alterar só a própria `microarea`. |
| `master` | Todas as UBS | Tudo acima, sem limite de UBS e sem a janela de 15 min nas avaliações; ler crianças, avaliações e logs de qualquer UBS (inclusive `collectionGroup('alteracoes')`); cadastrar, editar, ativar e desativar profissionais (nome, papel, `ubsIds`); cadastrar e editar UBS. **Não pode se desativar nem tirar o próprio papel `master`.** |
| Logado sem perfil, ou perfil `ativo: false` | nenhum | Nada (exceto ler o próprio perfil). |
| Não logado | nenhum | Nada. |

Ninguém apaga nada pelo app: sem `delete` em nenhuma coleção. Desativa-se com `ativa`/`ativo: false` ou `excluida: true`.

**Aviso de LGPD sobre o master:** o `master` acessa dados de crianças e responsáveis de **todas** as UBS e cadastra contas. Mantenha **poucos masters** (idealmente 1 ou 2), use e-mails institucionais, ative verificação em duas etapas nessas contas e revise a lista periodicamente.

## Visão geral

| Coleção | Id do documento | Quem cria | Quem lê |
| --- | --- | --- | --- |
| `ubs` | id curto (ex.: `ubs-jardim-das-flores`) | master | master; demais só as UBS da própria lista |
| `profissionais` | `uid` do Firebase Auth | master (ou console/admin) | o próprio profissional e o master |
| `criancas` | gerado no cliente (`collection.doc().id`) | profissional ativo da UBS, ou master | profissionais ativos da UBS e master |
| `avaliacoes` | gerado no cliente | idem | idem |
| `criancas/{id}/alteracoes/{versao}` | `string(versao)` | quem edita a criança, no mesmo lote | idem |
| `avaliacoes/{id}/alteracoes/{versao}` | `string(versao)` | quem corrige a avaliação, no mesmo lote | idem |

`criancas` e `avaliacoes` são coleções **raiz** e cada documento tem **um único** `ubsId`, que precisa estar em `perfil.ubsIds` (ou o usuário ser master).

Convenções:

- **Datas sem hora** (`nascimento`, `cadastradoEm`, `retornoSugerido`): texto `aaaa-mm-dd`, ano 2000 a 2099, mês 01-12, dia 01-31. `nascimento` e `cadastradoEm` não podem estar no futuro (comparado com a data UTC do servidor).
- **Instantes** (`data` da medição, `criadoEm`, `atualizadoEm`, `alteradoEm`): `timestamp`. `criadoEm`, `atualizadoEm` e `alteradoEm` são gravados com `FieldValue.serverTimestamp()`; as regras exigem que sejam iguais a `request.time`.
- Enums gravados com o `.name` do enum Dart: `sexo` = `masculino` | `feminino`; `situacao` = `normal` | `atencao` | `risco` | `abaixo`; `papel` = `master` | `acs` | `medico` | `nutricionista`.
- Campos opcionais podem estar ausentes ou ser `null`.

## `ubs/{id}`

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `nome` | string (2 a 120) | sim | Nome da UBS. |
| `endereco` | string (até 200) | não | Endereço. |
| `municipio` | string (2 a 80) | sim | Município. |
| `ativa` | bool | sim | `false` impede novos cadastros e avaliações nessa UBS (os dados continuam legíveis). |
| `criadoEm` | timestamp | sim | Servidor; imutável. |
| `atualizadoEm` | timestamp | sim | Servidor; muda a cada edição. |

Só o master cria e edita. Sem exclusão (desative com `ativa: false`).

## `profissionais/{uid}`

O id é o `uid` do Firebase Auth. Criado pelo master (ou pelo console/admin) ao cadastrar o profissional.

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `nome` | string (2 a 120) | sim | Nome. Só o master altera (evita alguém se passar por colega). |
| `email` | string | sim | E-mail de login. |
| `papel` | string | sim | `master`, `acs`, `medico` ou `nutricionista`. |
| `ubsIds` | list de string (1 a 20; pode ser vazia só para master) | sim | Ids das UBS onde atua (ex.: o médico em várias). |
| `microarea` | string (1 a 30) | não | Microárea/campanha do ACS (RF18). O próprio profissional pode alterar. |
| `ativo` | bool | sim | `false` bloqueia todo acesso. |

```json
{
  "nome": "Ana Souza",
  "email": "ana@ubs.exemplo",
  "papel": "acs",
  "ubsIds": ["ubs-jardim-das-flores"],
  "microarea": "03",
  "ativo": true
}
```

As regras não conferem se cada id de `ubsIds` existe em `ubs` (limite de leituras por requisição); o app do master deve escolher a partir da lista de UBS.

## `criancas/{id}`

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `ubsId` | string | sim | UBS dona do cadastro (em `perfil.ubsIds`); a UBS deve estar ativa; nunca muda. |
| `nome` | string (2 a 120) | sim | Nome da criança. |
| `nomeBusca` | string (2 a 120) | sim | `nome` em minúsculas e sem acentos (RF11). **O app deve regravar a partir de `nome` a cada edição**; as regras só garantem que está em minúsculas. |
| `sexo` | string | sim | `masculino` ou `feminino`. |
| `bairro` | string (até 80) | não | Bairro. |
| `endereco` | string (até 200) | não | Endereço. |
| `nascimento` | string `aaaa-mm-dd` ou null | não | Nulo = "Não informado". |
| `cadastradoEm` | string `aaaa-mm-dd` | sim | Data do cadastro; imutável. |
| `responsavel` | map ou null | não | Responsável legal (abaixo). |
| `ativa` | bool | sim | `false` = cadastro desativado (exclusão lógica). |
| `ultimaSituacao` | string (enum) | não | Situação da última avaliação (resumo para listas). |
| `ultimaAvaliacaoEm` | timestamp | não | Data da última avaliação (resumo). |
| `versao` | int | sim | Contador de edições: 0 na criação, +1 a cada edição de dados. |
| `criadoPor` | string | sim | `uid` de quem cadastrou; imutável. |
| `criadoEm` | timestamp | sim | Servidor; imutável. |
| `atualizadoEm` | timestamp | sim | Servidor. |
| `alteradoPor` | string | só após edição | `uid` de quem editou por último (RNF11). |
| `alteradoEm` | timestamp | só após edição | Quando (RNF11). |
| `motivoAlteracao` | string (3 a 200) | só após edição | Motivo da última edição (RNF11). |

Mapa `responsavel` (só estes campos, sem aninhar mais nada):

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `nome` | string (2 a 120) | sim | Nome do responsável legal. |
| `cpf` | string, 11 dígitos | não | CPF só com números. |
| `telefone` | string, 10 ou 11 dígitos | não | Telefone só com números (DDD + número). |
| `email` | string | não | E-mail (regex simples). Peça só se houver uso real (LGPD). |

### Edição, desativação e resumo

- **Edição de dados e desativação (`ativa: false`)**: `versao` sobe +1, exige `motivoAlteracao`, `alteradoPor` (= quem está logado), `alteradoEm` (= servidor) e a criação, **no mesmo lote**, do log `criancas/{id}/alteracoes/{versao}` (ver "Logs de auditoria"). `ubsId`, `criadoPor`, `criadoEm` e `cadastradoEm` não mudam.
- **Resumo da última avaliação**: o repositório atualiza `ultimaSituacao` e `ultimaAvaliacaoEm` no **mesmo lote** que grava a avaliação. Essa atualização só pode mudar esses 2 campos mais `atualizadoEm`, e **não** exige motivo, versão nem log. Só vale para criança ativa. As regras não conferem se o resumo bate com a avaliação (quem altera o resumo é qualquer profissional da UBS).

## `avaliacoes/{id}`

| Campo | Tipo | Obrigatório | Descrição |
| --- | --- | --- | --- |
| `ubsId` | string | sim | UBS da avaliação; igual à da criança, ativa e em `perfil.ubsIds`. Imutável. |
| `criancaId` | string | sim | Id em `criancas` (deve existir, da mesma UBS e **ativa**). Imutável. |
| `profissionalId` | string | sim | `uid` do autor (quem está logado). Imutável. |
| `profissionalNome` | string | sim | Cópia do `nome` do perfil (as regras conferem), para exibir no histórico. Imutável. |
| `microarea` | string | não | Microárea do profissional no momento (RF18). Na criação deve ser ausente/nula ou igual à `microarea` do perfil (o master pode informar qualquer uma). Imutável. |
| `data` | timestamp | sim | Data/hora da medição (de 2000-01-01 até 1 dia à frente). |
| `pesoKg` | number | sim | De 0,5 a 60 kg. |
| `alturaCm` | number | sim | De 40 a 130 cm. |
| `tipoMedida` | string | não | `deitado` ou `em_pe`. |
| `situacao` | string (enum) | sim | Situação geral. |
| `indicadores` | map | sim | Chaves fixas `pi`, `ei`, `pe`, `imci` (peso/idade, estatura/idade, peso/estatura, IMC/idade); pelo menos uma presente. Cada uma é `{ zScore: number (-10 a 10), situacao: enum }`. |
| `desnutricao` | bool | sim | Resultado de desnutrição (tela de Resultado). |
| `versaoTabelaOms` | string (1 a 40) | sim | Versão das tabelas OMS usadas no cálculo (ex.: `oms-2006`). |
| `retornoSugerido` | string `aaaa-mm-dd` | não | Data de retorno sugerida (RF17). |
| `excluida` | bool | sim | `true` = excluída logicamente (RF14). |
| `motivoExclusao` | string (3 a 200) | só se `excluida` | Motivo da exclusão. Proibido quando `excluida` é `false`. |
| `versao` | int | sim | 0 na criação, +1 a cada correção/exclusão. |
| `criadoEm` | timestamp | sim | Servidor; imutável. Base da janela de 15 min. |
| `atualizadoEm` | timestamp | sim | Servidor. |
| `alteradoPor` | string | só após correção | `uid` de quem corrigiu/excluiu (RNF11). |
| `alteradoEm` | timestamp | só após correção | Quando. |
| `motivoAlteracao` | string (3 a 200) | só após correção | Motivo (RNF11). |

```json
{
  "ubsId": "ubs-jardim-das-flores",
  "criancaId": "AbC123",
  "profissionalId": "uidDaAna",
  "profissionalNome": "Ana Souza",
  "microarea": "03",
  "data": "<timestamp 2026-11-11 09:30>",
  "pesoKg": 12.5,
  "alturaCm": 90,
  "tipoMedida": "em_pe",
  "situacao": "normal",
  "indicadores": {
    "pi": { "zScore": -0.5, "situacao": "normal" },
    "ei": { "zScore": 0.2, "situacao": "normal" },
    "pe": { "zScore": -0.1, "situacao": "normal" },
    "imci": { "zScore": 0.0, "situacao": "normal" }
  },
  "desnutricao": false,
  "versaoTabelaOms": "oms-2006",
  "retornoSugerido": "2026-12-11",
  "excluida": false,
  "versao": 0,
  "criadoEm": "<serverTimestamp>",
  "atualizadoEm": "<serverTimestamp>"
}
```

**Resultado calculado no cliente:** `situacao`, `indicadores` e `desnutricao` são gravados pelo app e as regras só validam tipos e faixas, não o cálculo. As telas devem **recalcular a partir de `pesoKg`, `alturaCm`, `data` e do nascimento** (RF12), e não confiar cegamente nesses campos. O campo `versaoTabelaOms` permite saber com qual tabela foi calculado.

### Correção e exclusão (RF14)

- Só o **autor** corrige ou exclui, e só enquanto `request.time < criadoEm + 15 min`. O **master** pode sempre.
- Podem mudar: `data`, `pesoKg`, `alturaCm`, `tipoMedida`, `situacao`, `indicadores`, `desnutricao`, `versaoTabelaOms`, `retornoSugerido`, `excluida`, `motivoExclusao` e os campos de auditoria. Todo o resto é imutável.
- Toda correção sobe `versao` em 1 e grava `atualizadoEm`, `alteradoPor`, `alteradoEm`, `motivoAlteracao`, junto com o log (mesmo lote).
- Avaliação já excluída não pode mais ser editada. As consultas devem filtrar `excluida == false`.
- Se a correção mudar a situação, o repositório deve atualizar também `ultimaSituacao`/`ultimaAvaliacaoEm` da criança (em lote separado ou no mesmo, ver o limite de acessos abaixo).

## Logs de auditoria (RNF11)

`criancas/{id}/alteracoes/{versao}` e `avaliacoes/{id}/alteracoes/{versao}`. O id do documento é `string(versao)` (o mesmo `versao` novo do documento principal).

Como funciona: a regra de `update` do documento principal exige `!exists(.../alteracoes/{versao})` (o log não pode existir antes do lote, o que bloqueia log antigo ou importado) e `existsAfter(.../alteracoes/{versao})`, e a regra de `create` do log compara o documento **antes** (`get`) e **depois** (`getAfter`) do lote. Resultado: não existe correção sem log, nem log sem correção, nem log falso. Os logs são imutáveis (sem update nem delete).

Conferências do log: UBS do usuário; `versao` = antes + 1 e igual ao id; autor do log = `request.auth.uid` = `alteradoPor`; `alteradoEm` = servidor; `motivo` = `motivoAlteracao` (3 a 200); valores anteriores iguais aos do documento real. Na avaliação, o autor deve ser o `profissionalId` dentro dos 15 min (ou o master).

Log da **criança**: `alteradoPor`, `alteradoEm`, `motivo`, `versao`, `nomeAnterior` (string), `responsavelAnterior` (map ou `null`), `ativaAnterior` (bool), `nascimentoAnterior`, `bairroAnterior`, `enderecoAnterior` (valor anterior ou `null` se não existia) e `sexoAnterior`. Todos são conferidos com o documento real (`antes.get(campo, null)`).

Log da **avaliação**: `alteradoPor`, `alteradoEm`, `motivo`, `versao`, `acao` (`correcao` ou `exclusao`), `pesoKgAnterior`, `alturaCmAnterior`, `dataAnterior`, `situacaoAnterior`, `indicadoresAnterior`, `desnutricaoAnterior`.

Quem lê: profissionais da UBS do documento principal e o master. `collectionGroup('alteracoes')` só para o master.

**Limite de acessos:** cada requisição em lote pode fazer até 20 leituras de documentos nas regras (`get`/`exists`/`getAfter`). Cada gravação com log gasta alguns acessos (perfil, UBS, criança, log). Por isso, **não junte muitas crianças/avaliações num mesmo lote** (um lote com mais de ~19 acessos é recusado). A fila offline do Firestore envia um lote por vez, então grave uma alteração por lote.

## Pendências conhecidas das regras (para a task dos repositórios)

- **Resumo da criança forjável:** `ultimaSituacao`/`ultimaAvaliacaoEm` podem ser alterados sem log por qualquer profissional da UBS. Correção futura: gravar também `ultimaAvaliacaoId` na criança e conferir, com `getAfter` da avaliação no mesmo lote, que o resumo bate com ela; ou calcular o resumo numa Cloud Function. Até lá, as telas devem tratar o resumo como dica e não como fonte de verdade (a verdade são as avaliações).

## Exclusão

O app **não apaga** nada (`allow delete: if false`). "Excluir" criança é `ativa: false` (com motivo e log); "excluir" avaliação é `excluida: true` (com motivo e log, em até 15 min). Remoções definitivas (por exemplo, pedido do titular na LGPD) são feitas pelo console/admin, por quem tem permissão no projeto.

## Índices compostos (`firestore.indexes.json`)

| Coleção | Campos | Uso |
| --- | --- | --- |
| `avaliacoes` | `ubsId` ↑, `criancaId` ↑, `excluida` ↑, `data` ↓ | Histórico da criança para o profissional (RF05): `where ubsId == X`, `criancaId == Y`, `excluida == false`, `orderBy data desc`. |
| `avaliacoes` | `criancaId` ↑, `excluida` ↑, `data` ↓ | Mesmo histórico, para o master (sem filtro de UBS). |
| `criancas` | `ubsId` ↑, `ativa` ↑, `nomeBusca` ↑ | Lista de cadastros ativos ordenada por nome. |
| `criancas` | `ubsId` ↑, `nomeBusca` ↑ | Lista ordenada por nome, com ou sem inativos. |

Consultas de profissional **precisam** incluir `ubsId` com `==` ou `in` usando só UBS da própria lista (o `in` aceita até 30 valores; testado com 2 UBS). Consulta sem `ubsId`, com `!=`, só por `criancaId` ou só por CPF é negada. Para vários `ubsIds`, use `where('ubsId', 'in', ubsIds)`. O master pode consultar sem filtro.

### Busca (RF11)

A busca por nome parcial é feita **no app**: consulte as crianças da(s) UBS (`ubsId in ubsIds` + `ativa == true`; com o cache offline são leituras locais) e filtre com `contains` sobre `nomeBusca`, sem acento. Isso evita a limitação do Firestore a busca por prefixo. Se um dia usar prefixo no servidor, o padrão é `where('nomeBusca', '>=', termo)` e `where('nomeBusca', '<=', termo + '')`, e o `''` (string vazia) deve ser escrito explicitamente quando o termo estiver vazio. A busca por CPF é uma igualdade: `where('ubsId', 'in', ubsIds)` e `where('responsavel.cpf', '==', cpf)`.

## Mapeamento `models.dart` ↔ Firestore

| Modelo Dart | Firestore | Observação |
| --- | --- | --- |
| `Crianca.id` | id do documento em `criancas` | Gerado no cliente com `collection.doc().id` (funciona offline). |
| `Crianca.nome` | `nome` | O repositório também grava `nomeBusca`. |
| `Crianca.sexo` (`Sexo`) | `sexo` | `.name`: `masculino`/`feminino`. |
| `Crianca.bairro`, `endereco` | `bairro`, `endereco` | Texto. |
| `Crianca.ubs` (nome) | `ubsId` | O modelo guarda o **nome** da UBS; no Firestore vai o **id** da UBS. O nome vem de `ubs/{id}.nome`. |
| `Crianca.cadastradoEm` (`DateTime`) | `cadastradoEm` (`aaaa-mm-dd`) | Formatar a data **local**; ao ler, montar `DateTime` local (sem converter fuso). |
| `Crianca.nascimento` (`DateTime?`) | `nascimento` (`aaaa-mm-dd` ou `null`) | Idem. |
| `Responsavel.nome` | `responsavel.nome` | |
| `Responsavel.cpfMascarado` | `responsavel.cpf` | Gravar **11 dígitos**; a máscara é montada na tela. |
| `Responsavel.telefone` | `responsavel.telefone` | Gravar só dígitos (10 ou 11). |
| `Responsavel.email` | `responsavel.email` | Opcional. |
| `Avaliacao.criancaId` | `criancaId` | |
| `Avaliacao.data` (`DateTime`) | `data` (`Timestamp`) | |
| `Avaliacao.pesoKg`, `alturaCm` | `pesoKg`, `alturaCm` | `double`. |
| `Avaliacao.situacao` (`Situacao`) | `situacao` | `.name`: `normal`/`atencao`/`risco`/`abaixo`. |

Campos que o modelo **ainda não tem** e o repositório precisa adicionar:

- `Crianca`: `nomeBusca`, `ativa`, `versao`, `criadoPor`, `criadoEm`, `atualizadoEm`, `alteradoPor`, `alteradoEm`, `motivoAlteracao`, `ultimaSituacao`, `ultimaAvaliacaoEm`.
- `Avaliacao`: `id`, `ubsId`, `profissionalId`, `profissionalNome`, `microarea`, `tipoMedida`, `indicadores`, `desnutricao`, `versaoTabelaOms`, `retornoSugerido`, `excluida`, `motivoExclusao`, `versao`, `criadoEm`, `atualizadoEm`, `alteradoPor`, `alteradoEm`, `motivoAlteracao`. (`Indicador.nome` do modelo vira a chave `pi`/`ei`/`pe`/`imci`; `Indicador.zScore`/`situacao` vão em `{zScore, situacao}`.)

## Comportamento offline

O Firestore grava no cache local e envia depois (RF07, RF08). As regras rodam **no servidor, quando a gravação chega**, e `serverTimestamp()` vira o horário da sincronização. Consequências:

- `criadoEm` de uma avaliação criada offline é a **hora da sincronização**, não a da medição (a hora da medição fica em `data`). A janela de 15 min conta a partir daí.
- Uma correção feita offline e sincronizada depois de `criadoEm + 15 min` é **recusada** (`permission-denied`). Mostre ao usuário que a correção não foi aceita e descarte/refaça a alteração local.
- Uma correção offline logo após uma criação offline funciona se as duas chegarem ao servidor em sequência na janela.
- O lote da correção é atômico: se a regra recusar, nada é gravado (nem o log).

## Decisões de LGPD

- **Isolamento por UBS:** nenhuma leitura ou escrita sai das UBS da lista do profissional. Quem não está logado, não tem perfil ou está inativo não acessa nada.
- **Perfil e UBS controlados pelo master:** o profissional não troca a própria UBS, papel, nome nem e-mail; só a `microarea`.
- **Minimização:** do responsável guardamos nome, CPF, telefone e e-mail (só o nome é obrigatório). Não guardamos RG, Cartão SUS nem foto. O e-mail do responsável é opcional e só deve ser pedido se houver uso. O CPF fica com **11 dígitos** porque precisamos buscar e exibir (RF11).
- **Hash de CPF não resolve:** um hash simples (SHA-256) de CPF é quebrável por força bruta (só ~10^9 combinações). Se o grupo quiser esconder o CPF, a opção futura é um **HMAC com chave secreta** calculado numa Cloud Function (a busca vira igualdade sobre o HMAC e o CPF deixa de ser exibido). Não implementado agora. Também não criamos subdocumento privado para o CPF nesta fase.
- **Sem exclusão física pelo app** e com trilha de auditoria imutável (quem, quando, motivo e valores anteriores).
- **Cache offline não criptografado:** o cache do Firestore no aparelho não é criptografado (RNF04 segue como pendência). Mitigação recomendada: no logout, chamar `FirebaseFirestore.instance.terminate()` e depois `clearPersistence()`, para não deixar dados de crianças no aparelho.
- **Criptografia no servidor:** o Firestore criptografa em trânsito e em repouso.
- **Dados de teste:** sempre fictícios.

## Criação de contas (para o Alexandre)

1. No Firebase Auth, **desative o cadastro público**: o app não deve ter tela de "criar conta"; e, no console, remova provedores desnecessários. As regras já impedem quem não tem `profissionais/{uid}` de acessar dados, mas desativar o cadastro reduz abuso.
2. **Sem plano Blaze (opção simples):** o master cria a conta pelo app usando uma **segunda instância do `FirebaseApp`** (`Firebase.initializeApp(name: 'secundario', options: ...)`) e `FirebaseAuth.instanceFor(app: segundo).createUserWithEmailAndPassword(...)`. Assim a sessão do master na instância principal **não é trocada**. Em seguida grava `profissionais/{uid}` (com o `uid` retornado) na instância principal e dá `signOut()` na secundária. A senha inicial deve ser temporária, com envio de `sendPasswordResetEmail`.
3. **Com plano Blaze:** uma Cloud Function chamável (Admin SDK, verificando `papel == 'master'` no perfil do chamador) cria o usuário e o perfil. É mais seguro (a senha não passa pelo app do master).
4. O primeiro `master` é criado pelo console do Firebase (Auth + documento `profissionais/{uid}` com `papel: 'master'`), porque as regras só deixam um master criar perfis.

## Outras recomendações

- **App Check:** ative o Firebase App Check (Play Integrity no Android) para reduzir uso do projeto por apps falsos.
- **Alerta de orçamento:** configure um alerta de orçamento no Google Cloud/Firebase para detectar uso inesperado.
- **Arquivos de configuração do Firebase:** `google-services.json` e `lib/firebase_options.dart` contêm identificadores do projeto, **não segredos** (o acesso é protegido pelas regras e pelo App Check). Decidam em grupo se serão versionados; se o repositório é público, avalie restringir a chave de API no console. Não versionar contas de serviço (`*-adminsdk-*.json`).
- **`.firebaserc`:** ainda não existe. Será criado por `firebase use --add` (guarda só o id do projeto). Recomendo **versionar** para todos publicarem no mesmo projeto.
- **`npm audit`:** só apresenta alertas em dependências do `firebase-tools` (ferramenta de desenvolvimento, não vai no app).

## Como rodar os testes das regras

Requisitos: **Node 24.12 ou superior** (`engines` em `firebase/package.json`) e Java 21 (o emulador do Firestore usa Java). Não é preciso conta nem projeto Firebase: o teste usa o projeto de demonstração `demo-nutrimirim`.

```bash
cd firebase
npm install
npm test
```

`npm test` sobe o emulador do Firestore (porta 8080) com `firebase emulators:exec` e roda `node --test` sobre `firebase/test/regras.test.mjs`; o host do emulador vem da variável `FIRESTORE_EMULATOR_HOST`. Na primeira execução o emulador é baixado. As mensagens `PERMISSION_DENIED` no meio da saída são esperadas (testes de negação).

## Como publicar as regras depois

Só depois de o projeto Firebase estar configurado (task do Alexandre), os testes passarem e existir pelo menos um `master` (ver acima). Rode **da raiz do repositório** (onde está o `firebase.json`), usando o `firebase-tools` instalado em `firebase/`:

```bash
npx --prefix firebase firebase login
npx --prefix firebase firebase deploy --only firestore:rules,firestore:indexes --project <id-do-projeto>
```

Para publicar só as regras: `--only firestore:rules`. Nada foi publicado até agora.
