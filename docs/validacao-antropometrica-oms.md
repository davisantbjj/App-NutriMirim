# Referência OMS para a validação antropométrica — RF02

Pesquisa realizada em 17/11/2026 para Larissa Barbosa dos Santos.

**Situação atualizada em 17/11/2026:** cálculo dos quatro indicadores e validação de plausibilidade implementados localmente, conforme a seção 6. As seções 1–5 preservam o levantamento e a proposta anteriores. Persistência, classificação nutricional, condutas e integração com a curva continuam pendentes.

## 1. Relação com os requisitos e o código atual

`docs/pesquisa.md` já prevê os padrões OMS de 2006, parâmetros LMS e os indicadores P/I, E/I, P/E e IMC/I. `docs/requisitos.md` atribui a validação ao RF02 e o cálculo ao RF03. Conforme `CONTEXTO_IA.md`, Larissa desenvolve o RF02 e Talita desenvolve as tabelas e o cálculo do RF03.

A tela `registro_medidas_screen.dart` atualmente aceita peso de 0,5 a 60 kg e altura de 40 a 130 cm, sem consultar idade ou sexo. A escolha de resultado por `peso < 10` é provisória. Esses limites não implementam os critérios OMS encontrados nesta pesquisa. Manter o aviso de resultado ilustrativo até a integração e validação do cálculo real.

## 2. Parâmetros de plausibilidade

A OMS utiliza os seguintes limites para sinalizar z-scores extremos ou potencialmente incorretos. São critérios de qualidade dos dados, não faixas de eutrofia:

| Indicador | Sigla | Sinalizar quando |
| --- | --- | --- |
| Peso para idade | WAZ / P/I | z < −6 ou z > +5 |
| Comprimento/altura para idade | HAZ / E/I | z < −6 ou z > +6 |
| Peso para comprimento/altura | WHZ / P/E | z < −5 ou z > +5 |
| IMC para idade | BAZ / IMC/I | z < −5 ou z > +5 |

Fonte dos limites: [WHO Anthro 3.2.2, seção 3.4.2](https://www.who.int/docs/default-source/child-growth/child-growth-standards/software/anthro-pc-manual-v322.pdf#page=23). As comparações são estritas: um valor exatamente no limite não recebe esse alerta. Cada indicador tem sua própria sinalização; ausência de resultado não equivale a resultado válido. Convenções confirmadas na [função oficial de sinalização](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score-helper.R).

O manual orienta conferir a digitação e, quando possível, repetir a medição ao encontrar valores sinalizados. Também distingue esses limites de resultados nutricionais extremos que ainda são plausíveis. A exclusão usada em análises de inquéritos não deve ser confundida com apagar o registro individual de atendimento. Fonte: [WHO Anthro 3.2.2, seção 3.4.2, página impressa 14 / página 23 do PDF](https://www.who.int/docs/default-source/child-growth/child-growth-standards/software/anthro-pc-manual-v322.pdf#page=23).

**Proposta para o NutriMirim:** mostrar “Confira peso, altura, nascimento e data da medição” quando houver alerta; preservar os valores originais e registrar a conferência/correção. Não bloquear uma criança apenas porque seu indicador nutricional saiu da faixa esperada. Por exemplo, WAZ = −4 não aciona o limite de plausibilidade de −6, embora deva seguir para avaliação nutricional. Ausência de alerta também não comprova que a medida está correta.

## 3. Entradas necessárias

O cálculo deve receber sexo, idade exata na data da medição, peso em kg, comprimento/altura em cm e posição em que a medida foi obtida. A idade deve vir da diferença entre nascimento e medição, não da idade atual. O pacote oficial aceita idade em dias; a falta de idade ou sexo limita os indicadores disponíveis. Fonte: [API oficial `anthro_zscores`](https://worldhealthorganization.github.io/anthro/reference/anthro_zscores.html).

Para o formulário, propõe-se rejeitar números não finitos, valores menores ou iguais a zero, datas futuras e medição anterior ao nascimento. Essas verificações de entrada podem ser feitas por Larissa antes de integrar o RF03. Uma avaliação fora da cobertura de uma tabela deve retornar “indicador indisponível”, sem extrapolar silenciosamente a referência.

### Posição da medida e cobertura das tabelas

Na implementação oficial consultada, a transição comprimento/altura usa 731 dias: abaixo disso, altura medida em pé recebe +0,7 cm; a partir disso, comprimento deitado recebe −0,7 cm. O código também sinaliza medida em pé em menores de 9 meses. A integração precisa conservar a posição real e a medida original para evitar dupla conversão. Fontes: [rotina principal](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score.R) e [rotina de ajuste](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score-helper.R).

O indicador peso/comprimento cobre 45–110 cm; peso/altura cobre 65–120 cm, incluindo os extremos. São domínios dessas tabelas específicas, não limites gerais para aceitar uma medida ou calcular altura/idade. Fora do domínio, P/E fica indisponível; os demais indicadores devem ser avaliados separadamente. Fonte: [implementação oficial de peso por comprimento/altura](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score-weight-for-lenhei.R).

Edema exige tratamento específico: o pacote oficial não calcula os indicadores individuais relacionados ao peso nessa situação. A conversão usada para estimar prevalência em inquéritos não deve ser aplicada como um z-score individual inventado. Fonte: [documentação de `oedema` no código oficial](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score.R).

### Limite etário: definir antes de integrar

Os gráficos OMS são apresentados como nascimento a cinco anos, enquanto o pacote R `anthro` consultado calcula z-scores para idade em meses < 60. O manual antigo do aplicativo de computador descreve cobertura até 60 meses completos. Portanto, “0 a 5 anos” no contexto não define sozinho qual regra computacional será usada na fronteira. Fontes: [padrões OMS](https://www.who.int/tools/child-growth-standards), [documentação do pacote](https://worldhealthorganization.github.io/anthro/reference/anthro_zscores.html) e [manual, seção 3.3.2](https://www.who.int/docs/default-source/child-growth/child-growth-standards/software/anthro-pc-manual-v322.pdf#page=19).

**Proposta para Larissa e Talita:** usar a mesma versão de referência e a mesma regra etária em validação, cálculo e testes. Se a escolha for o pacote `anthro`, reproduzir seu recorte < 60 meses e sua conversão de idade. Para ampliar a cobertura, definir explicitamente a transição para outra referência; não extrapolar a última linha da tabela. Essa decisão ainda não foi aplicada ao app.

## 4. Onde obter os parâmetros

As páginas oficiais disponibilizam gráficos e tabelas por sexo:

| Uso | Fonte |
| --- | --- |
| Peso para idade | [OMS — Weight-for-age](https://www.who.int/toolkits/child-growth-standards/standards/weight-for-age) |
| Comprimento/altura para idade | [OMS — Length/height-for-age](https://www.who.int/tools/child-growth-standards/standards/length-height-for-age) |
| Peso para comprimento/altura | [OMS — Weight-for-length/height](https://www.who.int/tools/child-growth-standards/standards/weight-for-length-height) |
| Dados usados pelo pacote oficial | [WorldHealthOrganization/anthro — growthstandards](https://github.com/WorldHealthOrganization/anthro/tree/master/data-raw/growthstandards) |

O diretório de dados contém `weianthro.txt`, `lenanthro.txt`, `wflanthro.txt`, `wfhanthro.txt` e `bmianthro.txt`, correspondentes aos indicadores necessários. Na importação futura, registrar versão, URL de origem, integridade do arquivo, unidades e condições de uso; guardar uma única cópia de referência para RF02 e RF03. Nesta pesquisa foram identificados os arquivos, mas eles não foram importados como assets.

**Cuidados com o cálculo:** o resumo LMS em `CONTEXTO_IA.md` não é a implementação completa. O código oficial usa ajuste dos escores extremos além de ±3 para os indicadores pertinentes e arredondamento antes da sinalização. Talita deverá reproduzir e testar essas convenções; aplicar a fórmula LMS básica indiscriminadamente nos extremos pode alterar os alertas. Fonte: [funções oficiais de cálculo e sinalização](https://github.com/WorldHealthOrganization/anthro/blob/b776d8a12b1c97369c748b561159fd2ec4f4db58/R/z-score-helper.R).

## 5. Divisão prática e testes

Este é o contrato de integração proposto, não uma API já existente:

1. **Larissa:** conferir entradas e datas; aplicar os limites de plausibilidade aos z-scores retornados; apresentar alertas e estados indisponíveis.
2. **Talita:** importar os parâmetros oficiais e calcular os indicadores, com posição de medição, domínio das tabelas, idade e convenções numéricas documentados.
3. **Integração:** a tela recebe a criança correta, envia suas medidas ao serviço comum e preserva os motivos de indisponibilidade. O salvamento permanece nos repositórios.

Larissa pode escrever e testar a função que recebe z-scores sem esperar todo o RF03. Para validar peso/altura reais por idade, porém, será necessário integrar o cálculo oficial ou limites equivalentes derivados e verificados a partir dele. Não criar uma segunda tabela manual de limites por faixas largas de idade.

Casos mínimos de teste propostos:

- Exatamente nos quatro limites, 0,01 abaixo/acima e resultados no interior dos intervalos.
- WAZ = −4 continua no fluxo de classificação nutricional; WAZ = −6,01 exige conferência.
- Um indicador sinalizado não invalida automaticamente todos os outros.
- Resultado ausente, NaN ou infinito nunca vira “sem alerta”.
- Nascimento, medição anterior ao nascimento, data futura e diferença de datas atravessando ano bissexto.
- Transição de 730 para 731 dias; posição de medição; preservação do valor original.
- P/E nos extremos 45/110 e 65/120 cm e imediatamente fora deles.
- Fronteira etária da implementação escolhida, edema e dados obrigatórios ausentes.
- Paridade com resultados do software/pacote OMS para exemplos de ambos os sexos, incluindo extremos e arredondamento.

**Conclusão operacional:** os critérios de plausibilidade foram encontrados. A tarefa RF02 continua parcialmente pendente porque faltam implementação, dados compartilhados com RF03 e integração com o fluxo da criança; não falta mais identificar a fonte dos limites de z-score.

## 6. Implementação local — 17/11/2026

Após a pesquisa, Larissa solicitou: “Implemente os parametros para o código, conforme a OMS, e a necessidade do nosso aplicativo”.

- `lib/services/antropometria_oms.dart`: cálculo em Dart puro dos quatro indicadores, ajuste de extremos, interpolação de P/E, arredondamento a duas casas com empate para o par, limites de plausibilidade e motivos de indisponibilidade. A função não determina diagnóstico nem estado nutricional.
- `lib/services/validadores.dart`: leitura de medidas positivas com vírgula ou ponto decimal; rejeição de formatos inválidos, expoentes e números não finitos.
- `assets/oms/`: cinco arquivos TXT originais da revisão `b776d8a12b1c97369c748b561159fd2ec4f4db58`, licença de origem e manifesto SHA-256. Foram mantidos em TXT, em vez de converter para JSON, para preservar integralmente os parâmetros publicados. `tool/importar_oms.ps1` reproduz a importação.
- `lib/data/oms_assets.dart`: carrega e mantém as referências em memória, com nova tentativa em caso de falha. O app funciona offline e não envia medidas a nenhum serviço externo.
- Cadastro e ficha da criança passam a criança selecionada ao registro de medidas. O modelo existente foi preservado; a data textual é convertida com validação estrita. Se o nascimento estiver ausente, o profissional pode informá-lo na avaliação, sem persistência automática.
- A tela 06 exige posição observada, presença/ausência de edema e data da medição. “Validar medidas” apresenta os escores e os alertas, conserva os campos originais e invalida o resultado ao editar uma entrada. Foi retirada dessa tela a navegação baseada em `peso < 10` para resultados mock. A tela 07 e sua classificação ilustrativa continuam separadas, aguardando integração clínica.

### Decisões adotadas nesta implementação

1. Cobertura do pacote consultado: `idadeEmDias / 30.4375 < 60`; os arquivos importados contêm dias 0–1826. Dias posteriores retornam indicadores indisponíveis. Não se aplica “até cinco anos e onze meses”.
2. Idade calculada por datas civis na data da medição, sem efeito de horas ou horário de verão. Medição futura ou anterior ao nascimento é erro de entrada.
3. Posição não é inferida. Ajuste de +0,7/−0,7 cm na transição de 731 dias; medida original permanece no campo. Em pé antes de 9 meses exige nova medida e deixa os indicadores dependentes de altura indisponíveis. **Essa indisponibilidade é uma decisão conservadora do app:** o pacote oficial sinaliza a posição inadequada, mas ainda retorna alguns escores; o app não os apresenta até a conferência.
4. Edema não é presumido ausente. Quando presente, P/I, P/E e IMC/I ficam indisponíveis; E/I permanece calculável.
5. Não há bloqueio por limites globais de kg/cm sem idade. Um indicador extremo pede conferência; domínio ausente ou cálculo não finito nunca vira “sem alerta”.
6. Esta entrega implementa a parte de validação do RF02 e adianta a base numérica compartilhada com RF03. Talita poderá reutilizá-la para classificação/curva, evitando outra cópia de tabelas. O salvamento e a auditoria permanecem nas tarefas de integração.

### Evidências de teste

`test/antropometria_oms_test.dart` compara P/I = 0,24 para menina de 1522 dias e 17 kg, E/I = −6,09 para menino de 987 dias medido deitado com 72,86 cm e E/I = −2,55 para menina de 731 dias com 77,5 cm em pé. Esses resultados são publicados nos [testes de peso/idade](https://github.com/WorldHealthOrganization/anthro/blob/master/tests/testthat/test-zscore-weight-for-age.R) e [testes gerais do pacote OMS](https://github.com/WorldHealthOrganization/anthro/blob/master/tests/testthat/test-zscores.R).

Os demais testes verificam medianas das tabelas, interpolação, fronteiras de idade e P/E, edema, posição, datas, formato numérico, resultados ausentes e assets incompletos. `test/registro_medidas_test.dart` cobre assets reais, erros e nova tentativa, preservação de valores, limpeza de resultados ao editar, navegação e layout em 360 dp com fonte ampliada. Os testes antigos de limites fixos e resultado mock foram substituídos porque esse comportamento deixou de existir na tela 06.

Execução final: `dart analyze` sem problemas, `flutter test` com 73 testes passando e SHA-256 das cinco tabelas conferidos. Esses testes verificam a implementação e os exemplos descritos, sem substituir a avaliação clínica do produto.
