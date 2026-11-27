# Cadastro de profissionais e UBS (pelo Console do Firebase)

Passo a passo para criar as contas de **agente de saúde (ACS), médico, nutricionista e administrador (master)** no projeto `app-nutrimirim`. Até a entrega de 01/12/2026 o app não tem tela de cadastro de usuários (ver "Depois de 01/12" no fim), então o cadastro é feito no [Console do Firebase](https://console.firebase.google.com/project/app-nutrimirim).

Quem não tiver acesso ao Console pede ao Alexandre para ser adicionado ao projeto.

> **Use só dados fictícios** nas contas de teste e da apresentação (LGPD). Contas de pessoas reais só com autorização delas.

## Como funciona

Cada pessoa tem **duas partes**, ligadas pelo **UID**:

1. **Conta de login** no Firebase Authentication: só e-mail e senha. Não sabe qual é o papel.
2. **Perfil** no Firestore, em `profissionais/{uid}`: papel, UBS, microárea e se está ativo. As regras (`firestore.rules`) e o app leem o papel daqui.

Sem o perfil, a pessoa até entra no app, mas as regras negam qualquer leitura e gravação de dados. Com `ativo: false`, o acesso também é negado.

## Passo 0 — criar a UBS (uma vez por UBS)

Os profissionais só acessam as UBS listadas no perfil, então a UBS precisa existir antes.

1. Console → **Firestore Database** → coleção **`ubs`** (crie a coleção se não existir) → **Add document**.
2. **Document ID:** um id legível, sem espaços nem acentos. Exemplo: `ubs-centro`. Esse id é o que vai em `ubsIds` dos profissionais.
3. Campos:

| Campo | Tipo no Console | Exemplo |
| --- | --- | --- |
| `nome` | string | `UBS Centro` |
| `municipio` | string | `Aracaju` |
| `endereco` | string (opcional) | `Rua Exemplo, 100` |
| `ativa` | boolean | `true` |
| `criadoEm` | timestamp | data e hora de agora |
| `atualizadoEm` | timestamp | data e hora de agora |

Não crie outros campos: as regras recusam documentos de UBS com campos a mais quando o master editar pelo app.

## Passo 1 — criar a conta de login

1. Console → **Authentication** → **Users** → **Add user**.
2. Informe o **e-mail** da pessoa e uma **senha provisória** (mínimo de 6 caracteres).
3. Na lista, copie o **User UID** da conta criada (ex.: `Xy12AbC...`).

## Passo 2 — criar o perfil com o papel

1. Console → **Firestore Database** → coleção **`profissionais`** → **Add document**.
2. **Document ID:** cole o **User UID** do passo 1 (não use o "Auto-ID").
3. Campos comuns a todos:

| Campo | Tipo no Console | Valor |
| --- | --- | --- |
| `nome` | string | Nome completo (2 a 120 caracteres) |
| `email` | string | O mesmo e-mail da conta |
| `papel` | string | Ver a tabela abaixo |
| `ubsIds` | **array** de strings | Ids das UBS (passo 0) |
| `ativo` | boolean | `true` |

4. Campos por papel:

| Papel | `papel` | `ubsIds` | `microarea` (string) |
| --- | --- | --- | --- |
| Agente de saúde | `acs` | uma UBS: `["ubs-centro"]` | **sim**, a microárea dele (ex.: `03`) |
| Médico | `medico` | uma ou várias: `["ubs-centro", "ubs-norte"]` | não criar o campo |
| Nutricionista | `nutricionista` | uma ou várias: `["ubs-centro"]` | não criar o campo |
| Administrador | `master` | pode ser vazio: `[]` | não criar o campo |

Exemplo de ACS:

```json
{
  "nome": "Ana Souza",
  "email": "ana@ubs.exemplo",
  "papel": "acs",
  "ubsIds": ["ubs-centro"],
  "microarea": "03",
  "ativo": true
}
```

Campos aceitos: só `nome`, `email`, `papel`, `ubsIds`, `microarea` e `ativo` (modelo completo em [`firestore.md`](firestore.md#profissionaisuid)).

## Passo 3 — a pessoa cria a própria senha

Envie à pessoa o e-mail cadastrado (nunca a senha provisória por mensagem). Ela abre o app, toca em **"Esqueci minha senha"**, informa o e-mail e cria a senha pelo link que chega. A senha provisória deixa de valer.

## Conferência (o Console não passa pelas regras)

O Console grava como administrador e **não confere os campos**. Um erro de digitação faz o app negar o acesso da pessoa. Antes de terminar, confira:

- [ ] O Document ID do perfil é exatamente o **User UID** da conta.
- [ ] `papel` está em minúsculas e é um de `master`, `acs`, `medico`, `nutricionista` (sem acento: `medico`).
- [ ] `ubsIds` é do tipo **array** (não string) e cada id existe em `ubs`.
- [ ] `ubsIds` tem **no máximo 20** UBS. O Console não passa pelas regras, que recusam mais de 20; com mais de 30, as consultas do app (`whereIn`) falham e o profissional não vê nenhuma criança.
- [ ] `ativo` é **boolean** `true` (não a string `"true"`).
- [ ] Não há campos a mais nem com nome diferente (ex.: `ubsId`, `microArea`).
- [ ] A pessoa consegue entrar e ver as crianças da UBS dela.

## Manutenção

- **Mudar papel, UBS ou nome:** edite o documento em `profissionais/{uid}`. O próprio profissional só pode mudar a `microarea` pelo app.
- **Desligar alguém:** mude `ativo` para `false` e, se quiser, desative a conta em Authentication (**Disable account**). **Não apague** o perfil nem a conta: o histórico de avaliações guarda quem fez cada uma.
- **Trocar e-mail:** altere em Authentication e no campo `email` do perfil.
- **Poucos masters:** o master vê os dados de crianças de todas as UBS. Dê o papel só a quem é responsável pelo app (LGPD).

## Contas para a apresentação

Crie **uma conta fictícia de cada papel** na mesma UBS de teste (e o médico em duas UBS), para mostrar as diferenças entre os perfis:

| Conta | Papel | UBS | Microárea |
| --- | --- | --- | --- |
| acs.teste@... | `acs` | `ubs-centro` | `03` |
| medico.teste@... | `medico` | `ubs-centro`, `ubs-norte` | — |
| nutri.teste@... | `nutricionista` | `ubs-centro` | — |
| master.teste@... | `master` | — | — |

Criadas em 25/11/2026 com os e-mails `davisant28+master`, `+acs`, `+medico` e `+nutri` (`@gmail.com`) e as UBS `ubs-centro` e `ubs-norte`. Detalhes em `CONTEXTO_IA.md` ("Contas de teste").

## Depois de 01/12 (opcional)

- **Script com o Admin SDK** em `firebase/` que cria conta e perfil a partir de um JSON. Exige uma chave de conta de serviço, que **nunca** vai para o Git.
- **Tela "Cadastrar profissional" para o master** no app, chamando uma Cloud Function (criar a conta pelo app com `createUserWithEmailAndPassword` desconectaria o master). As regras já permitem que só o master crie e edite perfis.
