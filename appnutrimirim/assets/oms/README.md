# Dados de referência OMS

Origem: World Health Organization, pacote `anthro`, revisão
`b776d8a12b1c97369c748b561159fd2ec4f4db58`.

https://github.com/WorldHealthOrganization/anthro/tree/b776d8a12b1c97369c748b561159fd2ec4f4db58/data-raw/growthstandards

As cinco tabelas TXT foram preservadas sem alteração. Contêm dados de referência,
não dados de pacientes. `origem.json` registra URLs e SHA-256. A licença do
repositório de origem está em `LICENSE-anthro.md` (GPL-3.0).

| Arquivo | Uso | Linhas de dados |
| --- | --- | --- |
| weianthro.txt | Peso por idade | 3654 |
| lenanthro.txt | Comprimento/altura por idade | 3654 |
| bmianthro.txt | IMC por idade | 3654 |
| wflanthro.txt | Peso por comprimento | 1302 |
| wfhanthro.txt | Peso por altura | 1102 |

Idade nas tabelas: dias 0–1826, para cada sexo. Códigos: 1 masculino,
2 feminino. As medidas de comprimento/altura estão em centímetros e os pesos
em quilogramas. L, M e S são preservados na precisão original.

Para reproduzir a importação, execute `tool/importar_oms.ps1` dentro de
`appnutrimirim/`. A importação usa uma revisão fixa; atualizar a referência exige
revisar os testes de paridade e a documentação. O aplicativo usa os assets locais
e não faz consultas de rede ao validar uma criança.

Convenções e limitações da integração: `../../../docs/validacao-antropometrica-oms.md`.
