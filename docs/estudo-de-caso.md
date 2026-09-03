## 1.1. Problema
**Problema:** O aplicativo visa apoiar o combate à desnutrição infantil em comunidades carentes.
**Relevância:** Substitui os defasados cadernos de curvas de crescimento em papel pela automatização do cálculo antropométrico.
**Necessidade:** Os profissionais de saúde necessitam de uma ferramenta rápida e precisa para calcular o Z-Score (Peso/Idade, Altura/Idade e Peso/Altura) utilizando as tabelas oficiais da OMS.

## 1.2. Público e usuários
**Agentes Comunitários de Saúde (ACS):**
- **Relação/Situação:** Utilizam o app esporadicamente durante campanhas de pesagem em campo.
- **Necessidades:** Precisam de respostas claras e imediatas sobre o estado nutricional da criança (ex: "Está desnutrida ou não?") sem análises complexas.

**Pediatras, Nutricionistas e Médicos:**
- **Relação/Situação:** Uso técnico e contínuo diário dentro de UBSs e consultórios.
- **Necessidades:** Exigem acesso aos micro-dados (Z-Score exato) e visualização do gráfico de crescimento plotado para acompanhamento clínico.

## 1.3. Contexto de uso
**Ambientes e Iluminação:** Será usado tanto em ambientes internos (UBSs) quanto externos (campanhas ao ar livre), exigindo ativação automática de alto contraste em locais muito claros.  
**Dispositivos e Conectividade:** O uso ocorrerá em smartphones básicos (com até 2GB de RAM e GPU fraca), exigindo processamento 100% offline.  
**Condições do Usuário:** Em UBSs lotadas, o usuário tem pouco tempo e alto nível de demanda, exigindo uma interface focada em poucos campos e alto desempenho.

## 1.4. Objetivo e proposta de valor 
O NutriMirim automatiza a avaliação nutricional infantil transformando o dispositivo móvel em uma "trena digital". O maior benefício é eliminar o erro humano no cálculo de tabelas da OMS, entregando um diagnóstico visual rápido (verde, amarelo, vermelho) que acelera a tomada de decisão para suplementação. 

## 1.5. Personalidade, identidade e experiência 

- **Palavras conceituais: Desnutrição, Z-Score, Curvas de Crescimento, Percentil, Antropometria.**  

- **Personalidade e Tom:** Técnica, exata e robusta. A interface não deve ter "rodeios", precisa ser direta, prático e transmitir a confiabilidade de um instrumento de medição calibrado e sem erros.  

- **Cores e Memória:** O visual utilizará cores âmbar (nutrição) sem infantilizar o produto. Deseja ser lembrado como "A trena digital que mede o futuro das crianças brasileiras".  

## 1.6. Funcionalidades e características já definidas 

- **Formulário de dados antropométricos:** Atende à necessidade de coletar Peso, Altura, Data de Nascimento e Sexo para alimentar o algoritmo da OMS.  

- **Cálculo offline no código Dart:** Garante que o aplicativo funcione em áreas rurais ou sem internet, dispensando consultas ao Firebase.  

- **Alerta automático de classificação:** Atende à necessidade do ACS de saber instantaneamente o que fazer (ex: "Abaixo do Z-Score -2, verificar suplementação") usando um sistema de cores.  

- **Rasterização simples de gráficos:** Atende à necessidade de rodar sem travamentos em celulares com GPUs fracas.

## 1.7. Restrições e condições 

- **Interações:** A funcionalidade principal de avaliação deve ser concluída em, no máximo, 3 toques.  

- **Telas:** O protótipo é restrito a um máximo de 4 telas principais.  

- **Hardware:** O sistema deve performar bem em aparelhos com apenas 2GB de RAM.  

- **Armazenamento e Rede:** As tabelas da OMS devem ficar armazenadas localmente em assets (offline), proibindo o uso de banco de dados em nuvem para o cálculo.  

- **Privacidade:** Por lidar com menores de idade hiper vulneráveis, é obrigatória a inclusão do campo "Responsável Legal" e o sistema deve permitir a anonimização total dos dados para fins estatísticos públicos.  

## 1.8. Pontos de atenção 

- **Funcionamento 100% Offline e Leveza:** É o fator técnico mais crítico, pois campanhas em comunidades carentes frequentemente não possuem rede móvel, e os aparelhos dos agentes públicos costumam ser de entrada.  

- **Duplicidade de Experiência (ACS x Médicos):** O sucesso do app depende de equilibrar uma interface extremamente simples e colorida para os agentes em campo, mantendo a profundidade dos gráficos técnicos exigidos pelos pediatras.  

- **Privacidade e Anonimização:** Como o aplicativo coleta dados de saúde de crianças em situação de vulnerabilidade, qualquer falha no isolamento público do nome do paciente pode gerar graves problemas legais e éticos. 