# Requisitos e Funcionalidades do NutriMirim

## 1. Visão geral

O NutriMirim é um aplicativo mobile pensado para apoiar a avaliação nutricional infantil em contextos reais de Atenção Primária à Saúde, especialmente em campanhas comunitárias e atendimentos em Unidades Básicas de Saúde (UBS). A proposta principal é reduzir a dependência de cálculos manuais, automatizar a classificação nutricional e oferecer uma resposta rápida e confiável para profissionais como Agentes Comunitários de Saúde (ACS), nutricionistas e médicos.

Com base na análise do estudo de caso, pesquisa, benchmark e personas, o app irá priorizar:

- rapidez no uso;
- baixo consumo de recursos;
- operação offline;
- classificação visual clara;
- apoio à decisão sem substituir o julgamento clínico;
- proteção de dados de crianças e de menores.

---

## 2. Funcionalidades do aplicativo

### 2.1. Cadastro da criança

- Nome: Cadastro da criança
- Descrição: Permitir registrar os dados básicos da criança, como nome, data de nascimento, sexo, responsável legal e outras informações essenciais para o acompanhamento.
- Necessidade do usuário que atende: O ACS necessita registrar rapidamente a criança em campanhas e atendimentos, sem criar muitas etapas ou campos complexos.
- Justificativa: A identificação e a organização do histórico são essenciais para que o app consiga calcular a idade correta, comparar medidas no tempo e manter o acompanhamento longitudinal.

### 2.2. Registro de medidas antropométricas

- Nome: Registro de peso, altura e data da medição
- Descrição: Incluir campos para informar peso, estatura/altura e data da avaliação, com validação de valores e entradas em formato simples e objetivo.
- Necessidade do usuário que atende: Usuários precisam inserir dados de forma ágil, sem muita burocracia e com baixa chance de erro.
- Justificativa: Essas variáveis são as bases do cálculo de z-score e da classificação nutricional segundo as referências da OMS e do SISVAN.

### 2.3. Cálculo automático de z-score

- Nome: Cálculo automático de indicadores antropométricos
- Descrição: O sistema deve calcular automaticamente indicadores como peso para idade, altura para idade, peso para altura e IMC para idade, com base nos padrões da OMS.
- Necessidade do usuário que atende: ACS e profissionais de saúde precisam obter um resultado confiável sem realizar cálculos manuais ou consultar tabelas complexas.
- Justificativa: Essa funcionalidade é o núcleo do projeto, pois elimina o erro humano e reduz o tempo de triagem e acompanhamento.

### 2.4. Classificação visual do estado nutricional

- Nome: Indicador semafórico de risco nutricional
- Descrição: Exibir o resultado em cores e mensagens simples, como verde (saudável), amarelo (risco) e vermelho (desnutrição ou obesidade grave), associando a classificação ao escore z ou percentual correspondente.
- Necessidade do usuário que atende: O agente comunitário precisa saber rapidamente se a criança está em situação de risco ou fora do padrão, sem ter que interpretar gráficos complexos.
- Justificativa: A identificação visual rápida aumenta a eficiência do atendimento em campo, reduz o tempo de análise e melhora a tomada de decisão.

### 2.5. Histórico de acompanhamento da criança

- Nome: Histórico longitudinal do crescimento
- Descrição: Armazenar as avaliações anteriores da criança para permitir comparar medidas ao longo do tempo e visualizar evolução em meses ou anos.
- Necessidade do usuário que atende: Nutricionistas e profissionais de saúde precisam acompanhar a trajetória da criança e identificar desvios precocemente.
- Justificativa: O acompanhamento contínuo é essencial para detectar desnutrição, nanismo, ganho excessivo de peso ou outros problemas de crescimento.

### 2.6. Gráfico de curva de crescimento da OMS

- Nome: Visualização de curva de crescimento
- Descrição: Plotar os pontos da criança em uma curva de referência da OMS e permitir a visualização de evolução ao longo das medições.
- Necessidade do usuário que atende: Médicos e nutricionistas exigem uma visão técnica do resultado, com o escore z e a posição da criança em relação à curva padrão.
- Justificativa: Essa função atua como suporte à análise clínica, permitindo entender melhor o estado nutricional e a tendência de crescimento.

### 2.7. Modo offline-first

- Nome: Funcionamento offline
- Descrição: O aplicativo deve funcionar sem depender de internet para realizar os cálculos e salvar registros locais, sincronizando dados quando houver conexão.
- Necessidade do usuário que atende: Em campanhas em áreas carentes e em locais com pouca conectividade, o app precisa continuar funcionando normalmente.
- Justificativa: O uso real em campo exige confiabilidade mesmo sem sinal de celular ou Wi‑Fi, especialmente em comunidades vulneráveis.

### 2.8. Interface simples e rápida para uso em campo

- Nome: Fluxo de avaliação simples
- Descrição: Estruturar a navegação com poucos passos, campos reduzidos e ações diretas para completar a avaliação em poucos toques.
- Necessidade do usuário que atende: ACS e profissionais em UBSs frequentemente lidam com alto volume de atendimentos e pouco tempo disponível.
- Justificativa: A simplicidade da interface melhora a usabilidade, reduz erros e torna o uso possível em smartphones básicos.

### 2.9. Alta legibilidade em ambientes externos

- Nome: Visualização adaptada ao contexto de uso
- Descrição: Ajustar contraste, fontes, botões e cores para leitura clara em ambientes iluminados, em campo ou em áreas externas.
- Necessidade do usuário que atende: A coleta pode acontecer ao ar livre, em luz forte, e o usuário precisa enxergar facilmente os dados e as respostas.
- Justificativa: A boa legibilidade é essencial para manter a agilidade e a precisão durante campanhas e visitas domiciliares.

### 2.10. Proteção de dados e privacidade

- Nome: Segurança e anonimização de dados
- Descrição: Recolher apenas o necessário, permitir o registro do responsável legal e oferecer mecanismos de anonimização ou controle de visibilidade dos dados quando necessário.
- Necessidade do usuário que atende: O app lida com dados sensíveis de menores, então é indispensável cuidar da privacidade e da conformidade com a LGPD.
- Justificativa: O projeto atua com população infantil em situação de vulnerabilidade, exigindo responsabilidade ética e jurídica no tratamento dos dados.

### 2.11. Exportação de relatório resumido

- Nome: Relatório de avaliação
- Descrição: Gerar um resumo com dados da criança, classificação nutricional, escore z e data da medição para uso em acompanhamento ou consulta.
- Necessidade do usuário que atende: Profissionais da saúde precisam registrar e compartilhar facilmente a situação da criança com o responsável ou com a equipe.
- Justificativa: Essa funcionalidade facilita a documentação do atendimento e apoia a continuidade do cuidado.

---

# Requisitos Funcionais

## RF01 a RF19

1. **RF01 - Cadastro de Criança:** O sistema deve permitir o registro e persistência de dados cadastrais (nome, data de nascimento, sexo e responsável legal).
2. **RF02 - Validação e Registro Antropométrico:** O sistema deve validar (faixas fisiológicas compatíveis com idade/peso) e salvar peso (kg), estatura/altura (cm) e data da medição.
3. **RF03 - Cálculo Automático de z-score:** O sistema deve calcular automaticamente o z-score para os indicadores peso-para-idade, altura-para-idade, peso-para-altura e IMC-para-idade via tabelas OMS.
4. **RF04 - Classificação Semafórica:** O sistema deve mapear o z-score calculado para faixas de risco e exibir o indicador visual correspondente (verde, amarelo, vermelho) com legenda descritiva.
5. **RF05 - Consulta de Histórico Longitudinal:** O sistema deve recuperar e exibir a listagem cronológica de todas as avaliações antropométricas prévias de uma criança cadastrada.
6. **RF06 - Plotagem em Curva OMS:** O sistema deve renderizar o gráfico de referência da OMS plotando os pontos históricos e o ponto atual da criança para o indicador selecionado.
7. **RF07 - Persistência Local (Offline-First):** O sistema deve gravar e ler cadastros e avaliações diretamente no banco de dados local do dispositivo móvel sem exigir conexão ativa.
8. **RF08 - Sincronização de Dados:** O sistema deve identificar o retorno da conectividade de rede e enviar os registros locais pendentes para o servidor central (quando aplicável).
9. **RF09 - Fluxo de Atendimento em Campo (Wizard):** O sistema deve disponibilizar um fluxo sequencial otimizado (máximo de 3 etapas: seleção/cadastro > medição > resultado) para agilizar o atendimento.
10. **RF10 - Exportação de Relatório Resumido:** O sistema deve gerar um resumo textual/visual simplificado da avaliação (com dados da criança, z-score e classificação) para compartilhamento ou leitura rápida do responsável.
11. **RF11 - Busca de Cadastros:** O sistema deve permitir a busca rápida de crianças cadastradas por nome parcial ou CPF/identificador do responsável em base local.
12. **RF12 - Alerta de Encaminhamento Clínico:** O sistema deve exibir modal de alerta prioritário com diretriz de encaminhamento médico imediato ao detectar z-scores críticos (vermelho severo).
13. **RF13 - Micro-condutas por Faixa de Risco:** O sistema deve apresentar orientações práticas padronizadas (ex: reforço de aleitamento materno, marcos alimentares) vinculadas à cor do semafórico.
14. **RF14 - Revisão/Exclusão de Medição Recente:** O sistema deve permitir a correção ou exclusão de um lançamento antropométrico incorreto em até 15 minutos após o registro em campo.
15. **RF15 - Leitura de CNS (Cartão SUS) via Câmera:** O sistema deve capturar o número do Cartão Nacional de Saúde por OCR/QR Code para preenchimento ágil do identificador do usuário.
16. **RF16 - Indicador de Status de Sincronização:** O sistema deve sinalizar visualmente no histórico quais registros locais estão pendentes de envio ao servidor central.
17. **RF17 - Sugestão de Retorno por Risco:** O sistema deve calcular e sugerir a data ideal de reavaliação com base na gravidade (ex: 30 dias para alto risco, 180 dias para escore normal).
18. **RF18 - Vinculação de Unidade/Campanha:** O sistema deve permitir associar o lote de atendimentos a uma UBS específica ou código de microárea/campanha do ACS.
19. **RF19 - Consolidado de Atendimento do Turno:** O sistema deve gerar um relatório resumido agregando quantitativos de triagem do dia (total avaliado, distribuído por cores do semafórico) para o ACS.


## 4. CRUD
O CRUD do NutriMirim foca no gerenciamento dos dados cadastrais das crianças, do responsável legal e dos registros das avaliações antropométricas.

### 4.1. Cadastro da Criança
* **C (Criar):** Permitir o cadastro de uma criança com nome, data de nascimento, sexo, responsável legal e demais dados necessários.
* **R (Consultar):** Permitir consultar os dados cadastrais da criança e seu histórico de avaliações.
* **U (Atualizar):** Permitir corrigir ou atualizar os dados cadastrais da criança.
* **D (Excluir):** Permitir a exclusão do cadastro de forma controlada, respeitando as normas de proteção de dados.

### 4.2. Avaliação Antropométrica
* **C (Criar):** Registrar uma nova avaliação com peso, estatura/comprimento e data da medição.
* **R (Consultar):** Consultar avaliações anteriores, indicadores, escore-Z, classificação e evolução da criança.
* **U (Atualizar):** Permitir a correção de medidas apenas por um curto período logo após o registro, caso haja erro de digitação.
* **D (Excluir):** **NÃO APLICÁVEL.**

**Justificativa (Ausência da operação "D" na Avaliação):**
A operação de exclusão (D) não se aplica às Avaliações Antropométricas, pois esses registros são utilizados para acompanhar longitudinalmente o crescimento da criança. A exclusão definitiva de uma avaliação poderia comprometer o histórico e a análise da evolução antropométrica. Em caso de erro, a correção deve ocorrer de forma controlada, preservando a integridade e a rastreabilidade dos dados.

### 4.3. Responsável Legal
* **C (Criar):** Cadastrar o responsável legal e vinculá-lo à criança.
* **R (Consultar):** Consultar os dados do responsável autorizado.
* **U (Atualizar):** Permitir a atualização dos dados de contato e identificação do responsável.
* **D (Excluir):** Permitir a remoção do vínculo ou exclusão dos dados de forma controlada, quando aplicável.

## 2.5. Priorização

A classificação das funcionalidades do NutriMirim foi definida a partir da análise da persona prioritária (Ana Paula, Agente Comunitária de Saúde), das condições de infraestrutura levantadas na pesquisa (comunidades carentes, dispositivos de baixo custo e ausência frequente de sinal de internet) e das necessidades clínicas da persona secundária (Mariana Costa, Nutricionista).

---

### Essenciais
*Indispensáveis para a proposta central do projeto: viabilizar a triagem antropométrica rápida, precisa, sem o uso de papel e com funcionamento offline em áreas vulneráveis.*

* **Cadastro Básico da Criança (Funcionalidade 2.1 / RF01):**
  * *Justificativa:* Coletar dados cadastrais mínimos (nome, sexo, data de nascimento e responsável legal) é a base de entrada necessária para calcular a idade exata e alimentar o algoritmo biométrico, além de assegurar o cumprimento legal da LGPD para menores de idade.
* **Registro de Medidas Antropométricas (Funcionalidade 2.2 / RF02):**
  * *Justificativa:* Permite a inserção com validação de consistência dos dados de peso (kg), estatura/comprimento (cm) e data da avaliação, fornecendo as variáveis indispensáveis para a análise do crescimento.
* **Cálculo Automático de Z-Score (Funcionalidade 2.3 / RF03):**
  * *Justificativa:* Constitui o núcleo algorítmico da aplicação. Automatiza o cálculo dos indicadores antropométricos (P/I, E/I, P/E e IMC/I) conforme os padrões oficiais da OMS, eliminando o erro humano decorrente de tabelas manuais.
* **Classificação Visual Semafórica (Funcionalidade 2.4 / RF04):**
  * *Justificativa:* Atende diretamente à dor mais urgente do ACS em campo, traduzindo valores matemáticos complexos em um diagnóstico visual intuitivo (verde para eutrofia, amarelo para risco e vermelho para desnutrição/obesidade grave).
* **Operação Offline-First Local (Funcionalidade 2.7 / RF07):**
  * *Justificativa:* É a principal restrição técnica do projeto. Como mutirões e campanhas frequentemente ocorrem em locais sem sinal de operadora móvel ou Wi-Fi, o armazenamento e os cálculos matemáticos devem operar 100% de forma local.
* **Fluxo de Atendimento em Campo Simplificado (Funcionalidade 2.8 / RF09):**
  * *Justificativa:* Estrutura uma navegação em formato assistido (wizard) de no máximo 3 etapas, viabilizando triagens rápidas sob filas intensas e alta demanda de atendimento.

---

### Importantes
*Agregam valor significativo ao acompanhamento longitudinal e ao suporte clínico especializado, mas não inviabilizam a realização da triagem imediata inicial.*

* **Histórico Longitudinal de Acompanhamento (Funcionalidade 2.5 / RF05):**
  * *Justificativa:* Permite monitorar a evolução pondero-estatural da criança ao longo das visitas, mitigando os problemas de subnotificação e perda física da Caderneta de Saúde em papel.
* **Plotagem em Curva de Crescimento da OMS (Funcionalidade 2.6 / RF06):**
  * *Justificativa:* Atende às necessidades técnicas dos nutricionistas e pediatras para análise visual de tendências clínicas, utilizando renderização vetorial leve para evitar travamentos em celulares com 2GB de RAM.
* **Exportação de Relatório Resumido (Funcionalidade 2.11 / RF10):**
  * *Justificativa:* Gera comprovantes e relatórios em PDF/texto para compartilhamento com os responsáveis ou equipe multidisciplinar, servindo como apoio documental e não operacional.
* **Alerta de Encaminhamento Clínico e Micro-condutas (RF12 / RF13):**
  * *Justificativa:* Fornece orientações padronizadas pelo Ministério da Saúde e alertas de suporte à decisão clínica imediata quando detectadas situações de desnutrição aguda ou escore-Z crítico (< -2 DP).
* **Busca Local de Cadastros (RF11):**
  * *Justificativa:* Facilita o resgate rápido de fichas de crianças previamente cadastradas durante retornos e mutirões sucessivos, evitando duplicidade de dados no banco local.
* **Sincronização em Segundo Plano e Status de Envio (Funcionalidade 2.7 / RF08 / RF16):**
  * *Justificativa:* Garante o envio seguro dos dados acumulados em campo para os sistemas centrais assim que houver rede disponível, indicando visualmente ao usuário a situação de cada registro.

---

### Secundárias
*Funcionalidades complementares de automação avançada ou conveniência administrativa que podem ser implementadas em versões futuras sem comprometer o fluxo operacional.*

* **Leitura de Cartão SUS via Câmera/OCR (RF15):**
  * *Justificativa:* Recurso de conveniência para preenchimento ágil do número do CNS, mas que exige processamento óptico adicional e depende da qualidade de câmeras de smartphones básicos.
* **Consolidado de Atendimentos do Turno (RF19) e Vinculação de Unidade/Campanha (RF18):**
  * *Justificativa:* Ferramentas administrativas voltadas ao fechamento de metas e relatórios diários de produtividade do ACS no território.
* **Sugestão Automática de Retorno por Risco (RF17):**
  * *Justificativa:* Auxílio de agendamento que calcula o intervalo recomendado para a próxima pesagem, tarefa que pode ser definida de forma direta pelo próprio profissional de saúde.
* **Revisão/Exclusão de Medição em até 15 Minutos (RF14):**
  * *Justificativa:* Mecanismo de tolerância a erros pontuais de digitação recente que pode ser contornado pela validação rigorosa dos limites antes da confirmação do salvamento.