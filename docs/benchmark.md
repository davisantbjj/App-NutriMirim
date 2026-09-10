# Benchmark

## 1. WHO Anthro - Organização Mundial da Saúde

É uma ferramenta de software desenvolvida pela Organização Mundial da Saúde para avaliar e analisar o crescimento e o estado nutricional de crianças, utilizando medidas antropométricas padronizadas.

### Principais funcionalidades
- Cálculo automatizado de z-score e percentis baseados nos padrões de crescimento infantil da OMS (de 0 a 5 anos).
- Indicadores como peso para a idade, altura para a idade, peso para a altura e IMC para a idade.
- Geração de curvas e tabelas de referência globais.

### Pontos positivos
- Fonte oficial e universalmente aceita das tabelas de crescimento.
- Precisão matemática e validação científica internacional.

### Pontos negativos
- Interfaces desktop legadas.
- Fluxo de trabalho burocrático e pouco ágil.
- Pouca adequação para uso em dispositivos móveis e atendimento em campo.

### Aspectos de interface e experiência
- Visual utilitário e ultrapassado.
- Exigência de muitos cliques e navegação por menus densos.
- Baixa atenção à usabilidade mobile.

### O que aproveitar ou melhorar no projeto
- Aproveitar a exatidão das fórmulas e tabelas oficiais da OMS.
- Melhorar a experiência com um design mais fluido.
- Simplificar a entrada de dados e reduzir telas complexas.

---

## 2. SISVAN (Sistema de Vigilância Alimentar e Nutricional) - Ministério da Saúde do Brasil

É o Sistema de Vigilância Alimentar e Nutricional do SUS, responsável por monitorar continuamente o estado nutricional e o consumo alimentar da população brasileira, especialmente na Atenção Primária à Saúde.

### Principais funcionalidades
- Coleta e registro de dados antropométricos no âmbito do SUS.
- Cálculo automático dos índices nutricionais.
- Emissão de relatórios epidemiológicos.
- Integração com o prontuário eletrônico (e-SUS APS).

### Pontos positivos
- Alinhamento com as diretrizes de saúde pública do Brasil.
- Acompanhamento longitudinal do paciente na rede pública.
- Mapeamento de vulnerabilidades nutricionais para gestores.

### Pontos negativos
- Sistema web frequentemente instável.
- Dependência de conexão constante com a internet.
- Telas densas, lentas e com excesso de campos burocráticos.

### Aspectos de interface e experiência
- Interface institucional pesada.
- Formulários extensos e fragmentados.
- Treinamento complexo para operadores.
- Atrito na rotina de agentes de saúde.

### O que aproveitar ou melhorar no projeto
- Aproveitar a lógica de classificação nutricional adotada pelo Ministério da Saúde.
- Incorporar pontos de corte para desnutrição e obesidade.
- Criar um modo offline-first para salvar dados localmente e sincronizar depois.
- Priorizar uma interface limpa e ágil para aumentar a velocidade de digitação.

---

## 3. PediTools - Calculadora Pediátrica Web

É uma ferramenta de cálculo clínico rápido focada no ponto de atendimento, permitindo o cálculo instantâneo de z-scores da OMS e CDC a partir da idade gestacional, cronológica, peso, estatura e perímetro cefálico.

### Principais funcionalidades
- Cálculo rápido de z-scores em contexto clínico.
- Suporte a idade gestacional e cronológica.
- Uso de peso, estatura e perímetro cefálico como variáveis de entrada.

### Pontos positivos
- Extremamente rápida.
- Sem barreiras complexas de entrada para consultas rápidas.
- Foco absoluto na utilidade clínica imediata.

### Pontos negativos
- Voltada apenas para cálculo pontual.
- Não atende vigilância nutricional populacional.
- Não mantém histórico longitudinal nem curvas de evolução estruturadas.

### Aspectos de interface e experiência
- Minimalista e funcional.
- Fórmulas curtas e resultados imediatos na mesma tela.
- Sem recarregamentos desnecessários.

### O que aproveitar ou melhorar no projeto
- Aproveitar a agilidade e a disposição visual dos campos de entrada.
- Automatizar o cálculo da idade exata a partir da data de nascimento e da medição.
- Adicionar persistência de dados e gráficos de acompanhamento histórico.

---

## O que nosso aplicativo poderá fazer de diferente ou melhor?

### Funcionamento Offline-First nativo
Diferente do SISVAN ou de ferramentas web que travam sem internet, o app poderá salvar todos os cadastros e cálculos localmente no dispositivo (smartphone ou tablet). Os dados são sincronizados automaticamente em segundo plano assim que houver conexão, sendo essencial para áreas remotas ou unidades básicas com Wi-Fi instável.

### Cálculo instantâneo com geração gráfica imediata
Ao inserir data de nascimento, data da medição, peso e altura, o app calcula os z-scores (Peso/Idade, Altura/Idade e Peso/Altura) em frações de segundo e plota automaticamente o ponto na curva de crescimento da OMS na tela, substituindo o trabalho manual de traçar linhas em gráficos de papel.

### Alertas de risco nutricional em tempo real
Em vez de apenas exibir o número do z-score, o aplicativo pode categorizar o resultado visualmente com cores intuitivas, como verde para eutrofia, amarelo para risco e vermelho para desnutrição aguda ou obesidade grave, além de exibir recomendações rápidas de conduta baseadas nos protocolos do Ministério da Saúde.

### Histórico longitudinal acessível e limpo
Ao contrário das calculadoras pontuais como o PediTools, o app manterá o prontuário da criança na palma da mão, permitindo visualizar a evolução das curvas de crescimento ao longo dos meses em um histórico unificado, facilitando a identificação precoce de desvios como stunting e ganho excessivo de peso.

### Interface moderna e fluxo de trabalho ultrarrápido (Mobile-First)
Telas limpas, botões grandes para digitação ágil em ambientes clínicos movimentados e campos inteligentes que calculam a idade exata da criança em dias/meses automaticamente, evitando erros de cálculo humano comuns no dia a dia.

---

## Fontes

- BRASIL. Ministério da Saúde. Secretaria de Atenção à Saúde. Departamento de Atenção Básica. Marco de referência da vigilância alimentar e nutricional na atenção básica. Brasília, DF: Ministério da Saúde, 2015. Disponível em: https://bvsms.saude.gov.br/bvs/publicacoes/marco_referencia_vigilancia_alimentar.pdf. Acesso em: 9 set. 2026.
- CHOU, J. H. et al. PediTools electronic growth chart calculators: application development and validation. Journal of Medical Internet Research, v. 22, n. 1, e16204, 2020. Disponível em: https://www.jmir.org/2020/1/e16204/. Acesso em: 9 set. 2026.
- SALA SITUAÇÃO DE SAÚDE. O que é o Sistema de Vigilância Alimentar e Nutricional (SISVAN)? Disponível em: https://salasituacao.saude.gov.br/o-que-e-o-sistema-de-vigilancia-alimentar-e-nutricional-sisvan/. Acesso em: 9 set. 2026. (Nota: substituir pelo link exato da página, caso necessário).
- WORLD HEALTH ORGANIZATION (WHO). WHO Anthro Survey Analyser and other tools. Genebra: World Health Organization. Disponível em: https://www.who.int/tools/child-growth-standards/software. Acesso em: 9 set. 2026.

## Conclusão

As ferramentas analisadas reforçam a importância de combinar rigor científico com uma experiência de uso eficiente. O projeto pode se diferenciar ao unir confiabilidade nutricional com uma interface simples, rápida e adaptada ao contexto clínico e comunitário.