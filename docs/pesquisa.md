# Pesquisa de Mercado e Usuário

## 1. Informações Relevantes sobre o Problema

A desnutrição infantil e outros desvios do crescimento comprometem de forma severa o desenvolvimento físico e neurológico das crianças, sobretudo nos primeiros anos de vida. Por essa razão, o acompanhamento periódico do crescimento por meio de medidas antropométricas (peso, comprimento/estatura e IMC) constitui uma ação prioritária e ininterrupta nos serviços de Atenção Primária à Saúde.

A Organização Mundial da Saúde (OMS) estabeleceu os Padrões de Crescimento Infantil (crianças de 0 a 5 anos), definindo indicadores antropométricos essenciais: peso-para-idade (P/I), comprimento/estatura-para-idade (E/I), peso-para-comprimento/estatura (P/E) e IMC-para-idade (IMC/I). Esses padrões fornecem a base biométrica internacional para identificar distúrbios pondero-estaturais precocemente.

No contexto do SUS, o Ministério da Saúde padroniza a coleta e a análise de dados por meio da Norma Técnica do Sistema de Vigilância Alimentar e Nutricional (SISVAN). Todavia, na ponta do serviço, a operacionalização ainda depende maciçamente do preenchimento físico da **Caderneta da Criança**. Embora o documento seja um instrumento completo, pesquisas de saúde pública apontam dificuldades crônicas na adesão ao preenchimento de suas curvas milimetradas.

Um estudo transversal publicado em 2024 na revista *Epidemiologia e Serviços de Saúde*, conduzido com 411 mães em unidades básicas de saúde de Salvador-BA, revelou que, dentre as 282 cadernetas disponíveis para inspeção, **apenas 32,9% apresentavam as curvas de crescimento completamente preenchidas**. A pesquisa identificou barreiras operacionais severas, incluindo alta demanda, escassez de tempo, falta de capacitação periódica e ausência de instrumentos ágeis de registro. 

Esses dados comprovam a oportunidade e a urgência do desenvolvimento de ferramentas digitais leves que automatizem cálculos, reduzam o tempo de triagem e auxiliem os profissionais na tomada de conduta sem substituir o julgamento clínico.

---

## 2. Necessidades e Dificuldades dos Usuários

### 2.1. Agentes Comunitários de Saúde (ACS)
Os Agentes Comunitários de Saúde atuam na linha de frente territorial, realizando pesagens em campo, mutirões comunitários e visitas domiciliares.

* **Dificuldades Identificadas:**
  * Necessidade de registrar e classificar medições sob intensa pressão de tempo e filas.
  * Dependência do porte e do estado físico da Caderneta da Criança pela família.
  * Dificuldade visual em cruzar medidas em grades milimétricas impressas sob luz natural em ambientes externos.
  * Aparelhos celulares institucionais ou pessoais de entrada (baixo processamento e memória restrita).
* **Necessidades para o Aplicativo:**
  * Interface direta e de alto contraste, otimizada para poucos campos de preenchimento.
  * Teclado numérico amplo para entrada rápida de medidas (peso, estatura e data de nascimento).
  * Feedback imediato por código semafórico (Verde, Amarelo, Vermelho), indicando necessidade de alerta ou encaminhamento.
  * Operação determinística e offline, eliminando a dependência de sinal de internet em campo.

### 2.2. Pediatras, Nutricionistas e Médicos de UBS
Profissionais responsáveis pela conduta terapêutica, prescrição de suplementação alimentar e acompanhamento clínico contínuo.

* **Dificuldades Identificadas:**
  * Histórico longitudinal fragmentado decorrente do extravio ou não preenchimento da caderneta de papel.
  * Divergência metodológica entre anotações visuais aproximadas realizadas por diferentes profissionais.
  * Tempo de consulta exíguo para cálculo manual de desvios padrão em tabelas complexas.
* **Necessidades para o Aplicativo:**
  * Apresentação precisa do escore Z numérico com precisão decimal.
  * Visualização integrada das curvas de crescimento padronizadas da OMS (-3 a +3 DP) para análise de tendência.
  * Histórico estruturado de pesagens anteriores para acompanhamento evolutivo do ganho pondero-estatural.
  * Notificação clara de que a ferramenta atua como suporte à decisão clínica e triagem, cabendo ao profissional o diagnóstico final.

---

## 3

---

## 4. Fontes Utilizadas

1. **PALOMBO, C. N. T. et al.**  
   *Uso e preenchimento da caderneta da criança entre beneficiários do Programa Bolsa Família em Salvador-Bahia, Brasil: estudo transversal, 2023.* Epidemiologia e Serviços de Saúde, v. 33, 2024.  
   * **Relevância:** Aponta que apenas 32,9% das cadernetas possuem as curvas preenchidas, comprovando o gargalo operacional na atenção básica.  
   * **Link:** [https://www.scielo.br/j/ress/a/G4Jh75jJzhQGFxJ8Xw93bNF/](https://www.scielo.br/j/ress/a/G4Jh75jJzhQGFxJ8Xw93bNF/)

2. **WORLD HEALTH ORGANIZATION (WHO).**  
   *WHO Child Growth Standards: Length/height-for-age, weight-for-age, weight-for-length, weight-for-height and body mass index-for-age: Methods and development.* Genebra: WHO, 2006.  
   * **Relevância:** Referência internacional primordial que fornece a metodologia e os valores de calibração para o algoritmo de cálculo antropométrico.  
   * **Link:** [https://www.who.int/tools/child-growth-standards/standards](https://www.who.int/tools/child-growth-standards/standards)

3. **BRASIL. MINISTÉRIO DA SAÚDE.**  
   *Orientações para a coleta e análise de dados antropométricos em serviços de saúde: Norma Técnica do Sistema de Vigilância Alimentar e Nutricional — SISVAN.* Brasília: Ministério da Saúde, 2011.  
   * **Relevância:** Padroniza as faixas de corte de escore Z e estabelece as regras de classificação nutricional adotadas na rede SUS.  
   * **Link:** [https://bvsms.saude.gov.br/bvs/publicacoes/orientacoes_coleta_analise_dados_antropometricos.pdf](https://bvsms.saude.gov.br/bvs/publicacoes/orientacoes_coleta_analise_dados_antropometricos.pdf)

4. **BRASIL. MINISTÉRIO DA SAÚDE.**  
   *Caderneta da Criança: Passaporte da Cidadania — 7ª edição.* Brasília: Ministério da Saúde, 2024.  
   * **Relevância:** Gabarito oficial de acompanhamento infantil, servindo de base visual para a organização dos dados e gráficos do app.  
   * **Link:** [https://bvsms.saude.gov.br/bvs/publicacoes/caderneta_crianca_menino_passaporte_cidadania_7ed.pdf](https://bvsms.saude.gov.br/bvs/publicacoes/caderneta_crianca_menino_passaporte_cidadania_7ed.pdf)

5. **BRASIL. PRESIDÊNCIA DA REPÚBLICA.**  
   *Lei nº 13.709, de 14 de agosto de 2018 — Lei Geral de Proteção de Dados Pessoais (LGPD).*  
   * **Relevância:** Fundamenta os requisitos de privacidade, controle de acesso e minimização de dados sensíveis de menores de idade.  
   * **Link:** [http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm](http://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)

---

## 5