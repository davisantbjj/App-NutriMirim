# Justificativas

Este documento registra as principais decisões de interface e arquitetura do NutriMirim, aplicativo de monitoramento nutricional infantil usado por Agentes Comunitários de Saúde (ACS) e demais profissionais das Unidades Básicas de Saúde (UBS). As escolhas partem de quem usa o app e de onde ele é usado: um profissional em visita domiciliar ou em atendimento na UBS, muitas vezes com pouco tempo, conexão instável e a família da criança ao lado.

## Escolha das cores

A paleta combina azul e verde. O azul é a cor da marca e aparece nos botões principais (Entrar, Calcular, Salvar e Continuar), o que ajuda o profissional a identificar rapidamente a ação de cada tela. O verde remete a crescimento e saúde, reforça a identidade do logotipo (a criança com folhas brotando) e é usado em confirmações e resultados normais.

Na tela de Resultado, as cores seguem a lógica de semáforo, já conhecida por qualquer pessoa: verde para Normal, laranja para Atenção e vermelho para Desnutrição ou valores abaixo da faixa. Assim o profissional entende a situação da criança antes mesmo de ler os números.

No menu Início, cada cartão tem uma cor própria (azul-claro, azul, verde e laranja), o que facilita reconhecer a função pela posição e pela cor depois de algumas utilizações.

Quanto ao contraste, textos importantes ficam em azul-escuro sobre fundo branco ou muito claro, e os botões usam texto branco sobre azul forte. Os fundos dos cartões são tons suaves, para não competir com o conteúdo.

## Tipografia

Foi usada uma única família sem serifa em todo o aplicativo, porque ela tem boa leitura em telas pequenas e mantém a interface limpa. A hierarquia é feita por tamanho e peso: títulos das telas em negrito e tamanho maior, rótulos dos campos em peso médio e textos de apoio (orientações, descrições dos cartões) em tamanho menor e cor mais clara.

Os valores que o profissional precisa conferir, como peso, altura, Z-score e percentil, aparecem destacados e próximos do seu rótulo, para evitar erro de leitura durante o atendimento.

## Organização das informações

As telas seguem a mesma ordem do atendimento real: identificar a criança, registrar as medidas, ver o resultado e acompanhar a curva de crescimento. O profissional não precisa procurar a próxima etapa, porque cada tela termina com o botão que leva a ela.

O conteúdo é lido de cima para baixo, com o mais importante primeiro. Na tela de Resultado, o estado nutricional vem no topo, seguido dos indicadores (P/I, E/I e P/E), do detalhamento do cálculo, da explicação em linguagem simples e das orientações. Na tela Dados da criança, as informações ficam agrupadas em cartões (identificação, última avaliação e responsável), o que separa assuntos diferentes sem precisar de várias telas.

No Cadastro da Criança, os campos curtos ficam lado a lado (nascimento e sexo, bairro e UBS, CPF e contato do responsável), o que reduz a rolagem e deixa o formulário inteiro visível na maior parte dos celulares.

## Navegação

A barra de navegação inferior, com Início, Histórico, Avaliação e Perfil, fica fixa nas telas principais e pode ser alcançada com o polegar, o que facilita o uso com uma mão só. As telas internas têm seta de voltar no canto superior esquerdo, seguindo o padrão dos sistemas Android e iOS.

A Nova Avaliação começa com uma escolha simples: vincular uma criança já cadastrada ou cadastrar uma nova. Isso evita cadastros duplicados e encurta o caminho de quem já é acompanhado, que vai direto para o registro de medidas.

Para localizar uma criança, a lista tem busca por nome e filtro, e o Histórico mostra as avaliações da mais recente para a mais antiga, com um selo de situação que permite achar os casos que pedem atenção sem abrir cada registro.

A recuperação de senha foi dividida em três etapas curtas (informar o contato, confirmação de envio e nova senha) para que cada tela tenha uma única ação.

## Componentes

Os componentes foram mantidos poucos e repetidos em todo o app, para que o profissional aprenda uma vez e reconheça depois:

- botão principal azul, largo e no rodapé ou logo após o conteúdo;
- botão secundário com contorno, para ações menos frequentes, como Gerar relatório;
- botão de saída em vermelho, usado apenas em Sair da conta;
- campos de texto com rótulo acima, exemplo de preenchimento e ícone indicando o tipo de dado (envelope, cadeado, balança, régua, calendário);
- botões de alternância para escolha do sexo, em vez de lista suspensa, porque exigem um toque só;
- cartões para agrupar informações e para as opções do menu;
- selos coloridos com texto (Normal, Atenção, Risco) para indicar a situação;
- chaves liga/desliga para as preferências do perfil;
- gráfico de curva de crescimento com abas para alternar entre Peso/Idade, Altura/Idade e Peso/Altura.

## Acessibilidade

A situação nutricional nunca é indicada só pela cor. Todo selo e indicador traz também o texto (Normal, Atenção, Abaixo da faixa) e, no cartão de resultado, um ícone de confirmação ou de alerta. Isso atende pessoas com daltonismo e segue a recomendação das diretrizes WCAG de não depender apenas da cor para transmitir informação.

O Perfil Profissional tem a opção de Alto Contraste, pensada tanto para usuários com baixa visão quanto para o uso ao ar livre, sob sol forte. Os botões principais ocupam quase toda a largura da tela e têm área de toque confortável. Os campos obrigatórios são marcados com asterisco e todos têm rótulo visível, o que também ajuda leitores de tela.

A tela de Resultado inclui a seção "O que isso significa?", com explicação em linguagem simples, porque nem todo profissional que usa o app tem formação em nutrição, e ele muitas vezes precisa explicar o resultado para a família.

Como ponto a melhorar, alguns textos de apoio e exemplos dentro dos campos usam cinza claro, que pode ficar abaixo do contraste mínimo recomendado. Esses tons serão revisados na implementação.

## Contexto de uso

O ACS trabalha principalmente em visitas domiciliares, em bairros onde a internet móvel pode ser fraca ou ausente. Por isso o app foi pensado para funcionar sem conexão e sincronizar depois, e o perfil mostra a data e a hora da última sincronização, com botão para sincronizar manualmente.

O atendimento costuma acontecer em pé, com a balança e a fita métrica em uso, e às vezes com a criança no colo do responsável. Isso justifica formulários curtos, campos numéricos com exemplo de preenchimento e botões grandes. O campo Altura/Comprimento é único porque atende tanto crianças medidas deitadas quanto em pé.

Como o app guarda dados de crianças e de seus responsáveis, a privacidade foi tratada desde a interface: o acesso exige login, o CPF do responsável aparece parcialmente oculto e o aviso "Seus dados são tratados com segurança e privacidade" fica visível na tela de entrada, em linha com a LGPD.

Cada profissional está vinculado a uma UBS, e as crianças também têm uma UBS de referência, o que reflete a organização da atenção primária no SUS.

## Arquitetura do sistema

O NutriMirim segue uma arquitetura cliente-servidor, com o aplicativo móvel de um lado e uma API central do outro.

- Aplicativo móvel: interface usada pelo profissional. Faz a coleta dos dados, o cálculo do estado nutricional e a exibição dos gráficos.
- Armazenamento local: guarda no próprio celular os cadastros e avaliações feitos sem internet, até a próxima sincronização.
- Módulo de sincronização: envia os registros locais para o servidor e baixa as atualizações da UBS quando há conexão.
- API (backend): recebe as requisições do app, aplica as regras de negócio e controla quem pode acessar cada dado.
- Autenticação: faz o login dos profissionais e a recuperação de senha por e-mail ou SMS.
- Banco de dados: armazena profissionais, UBS, crianças, responsáveis e o histórico de avaliações.
- Módulo de cálculo antropométrico: calcula idade, Z-score e percentil de P/I, E/I e P/E com base nas tabelas de referência da OMS, e classifica o resultado.
- Geração de relatórios: produz o relatório de acompanhamento da criança a partir da curva de crescimento.

Separar o cálculo em um módulo próprio permite atualizar as tabelas da OMS ou os critérios de classificação sem mexer nas telas. O armazenamento local com sincronização garante que o trabalho de campo não pare por falta de internet.
