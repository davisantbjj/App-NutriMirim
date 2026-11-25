# Diagrama de Classes (Modelos de Domínio)

Classes de `lib/data/models.dart` e `lib/repositories/`, como estão no código em 23/11/2026.

## Modelos de domínio

```mermaid
classDiagram
    direction LR

    class Sexo {
        <<enumeration>>
        masculino
        feminino
    }

    class Situacao {
        <<enumeration>>
        normal
        atencao
        risco
        abaixo
        +String label
        +Color color
        +Color textColor
        +Color background
    }

    class Responsavel {
        +String nome
        +String cpfMascarado
        +String telefone
        +String email
    }

    class Crianca {
        +String id
        +String nome
        +Sexo sexo
        +String bairro
        +DateTime cadastradoEm
        +String endereco
        +String ubs
        +DateTime? nascimento
        +Responsavel? responsavel
        +bool ativa
        +copyWith(...) Crianca
    }

    class Avaliacao {
        +String id
        +String criancaId
        +DateTime data
        +double pesoKg
        +double alturaCm
        +Situacao situacao
        +DateTime? criadoEm
        +String? profissionalId
        +String? profissionalNome
        +String? tipoMedida
        +Map~String, Indicador~ indicadores
        +bool desnutricao
        +String versaoTabelaOms
        +DateTime? retornoSugerido
        +bool excluida
        +copyWith(...) Avaliacao
    }

    class Indicador {
        +String nome
        +double zScore
        +Situacao situacao
    }

    class ResultadoAvaliacao {
        +bool desnutricao
        +List~Indicador~ indicadores
    }

    class PapelProfissional {
        <<enumeration>>
        master
        acs
        medico
        nutricionista
    }

    class SessaoProfissional {
        +String uid
        +String nome
        +PapelProfissional papel
        +List~String~ ubsIds
        +String ubsAtualId
        +String? microarea
        +Map~String, String~ nomesUbs
        +bool master
    }

    Crianca "1" o-- "0..1" Responsavel : responsável legal
    Crianca --> Sexo
    Crianca "1" <-- "0..*" Avaliacao : criancaId
    Avaliacao "1" *-- "1..4" Indicador : pi, ei, pe, imci
    Avaliacao --> Situacao
    Indicador --> Situacao
    ResultadoAvaliacao "1" *-- "1..*" Indicador
    SessaoProfissional --> PapelProfissional
    SessaoProfissional "1" ..> "0..*" Avaliacao : registra como autor
```

## Repositórios

As telas só acessam os dados por `Repositorios.criancas` e `Repositorios.avaliacoes`. Cada interface tem duas implementações: a de memória é a padrão do app e dos testes, e a do Firestore é ativada depois do login.

```mermaid
classDiagram
    direction TB

    class CriancaRepository {
        <<interface>>
        +novoId() String
        +observarTodas() Stream~List~Crianca~~
        +porId(String id) Future~Crianca?~
        +observarPorId(String id) Stream~Crianca?~
        +buscar(String termo) Future~List~Crianca~~
        +cadastrar(Crianca crianca) Future~void~
        +editar(Crianca crianca, String motivo) Future~void~
        +desativar(String id, String motivo) Future~void~
    }

    class AvaliacaoRepository {
        <<interface>>
        +novoId() String
        +observarTodas() Stream~List~Avaliacao~~
        +observarDe(String criancaId) Stream~List~Avaliacao~~
        +ultimaDe(String criancaId) Future~Avaliacao?~
        +registrar(Avaliacao avaliacao) Future~Avaliacao~
        +corrigir(Avaliacao avaliacao, String motivo) Future~void~
        +excluir(String id, String motivo) Future~void~
    }

    class Repositorios {
        <<static>>
        +CriancaRepository criancas
        +AvaliacaoRepository avaliacoes
        +usarMemoria() BancoMemoria
        +usarFirestore(SessaoProfissional sessao) void
        +reiniciar() void
    }

    class CriancaRepositoryMemoria
    class AvaliacaoRepositoryMemoria
    class CriancaRepositoryFirestore {
        -SessaoProfissional sessao
        -FirebaseFirestore firestore
    }
    class AvaliacaoRepositoryFirestore {
        -SessaoProfissional sessao
        -FirebaseFirestore firestore
    }
    class BancoMemoria

    class RepositorioException {
        +String mensagem
    }
    class MotivoObrigatorio
    class NaoEncontrado
    class PrazoCorrecaoExpirado
    class PermissaoNegada
    class DadosInvalidos
    class EstadoInvalido

    CriancaRepository <|.. CriancaRepositoryMemoria
    CriancaRepository <|.. CriancaRepositoryFirestore
    AvaliacaoRepository <|.. AvaliacaoRepositoryMemoria
    AvaliacaoRepository <|.. AvaliacaoRepositoryFirestore

    Repositorios --> CriancaRepository
    Repositorios --> AvaliacaoRepository
    CriancaRepositoryMemoria --> BancoMemoria
    AvaliacaoRepositoryMemoria --> BancoMemoria

    RepositorioException <|-- MotivoObrigatorio
    RepositorioException <|-- NaoEncontrado
    RepositorioException <|-- PrazoCorrecaoExpirado
    RepositorioException <|-- PermissaoNegada
    RepositorioException <|-- DadosInvalidos
    RepositorioException <|-- EstadoInvalido

    CriancaRepository ..> RepositorioException : lança
    AvaliacaoRepository ..> RepositorioException : lança
```

## Observações

- `Crianca.ubs` guarda o nome da UBS para exibir na tela. No Firestore é gravado o id (`ubsId`), que vem da sessão (`SessaoProfissional.ubsAtualId`).
- `Avaliacao.criancaId` é a associação com `Crianca`: uma criança tem zero ou mais avaliações, e cada avaliação pertence a uma única criança.
- `Avaliacao.indicadores` usa as chaves fixas `pi` (peso/idade), `ei` (estatura/idade), `pe` (peso/estatura) e `imci` (IMC/idade). O repositório exige pelo menos uma delas.
- `profissionalId`, `profissionalNome` e `criadoEm` são preenchidos pelo repositório a partir da sessão, e não pela tela.
- Não existe uma classe `Ubs` nem uma classe `Profissional` no Dart. Esses dados ficam no Firestore e chegam ao app pela `SessaoProfissional`.
