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


