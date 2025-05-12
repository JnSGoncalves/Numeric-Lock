# Numeric-Lock

Desenvolvimento de uma simulação do funcionamento de um cofre eletrônico com senha de 6 dígitos no simulador EdSim51. A ideia geral do projeto consiste no aumento de tempo de espera para cada tentativa incorreta a partir de três erros. Serão utilizados os LEDs e o display LCD do simulador, como forma de indicação para o usuário.

## Utilização

Para utilização do programa, configure o simulador EdSim51 (Versão 2.1.38) da seguinte maneira.
- System Clock: 12.0 MHz
- Update Freq.: 10000 
- LEDs de 0 a 7, atribuídos ao pino P2
- LCD 16x2 atribuído ao P1, com Reg Select ligado em P1.3 e Enable ligado em P1.2
- Motor atribuído ao pino P3 - Motor Control Bit 0 e 1, são localizados em P3.0 e P3.1, respectivamente

## Funcionalidades
Atualmente foram atribuídos ao projeto essas funcionalidades:

- Gravação de nova senha na memória RAM enquanto estiver no estado aberto;
- Comparação com outra senha digitada pelo usuário;
- Feedback de estados do programa com os LEDs
- Feedback de estados do programa com o LCD 16x2
- Delay para nova tentativa com base no número de tentativas incorretas seguidas
- Utilização do motor como simulação da porta sendo aberta/fechada

## Sub-rotinas do programa
Suas funcionalidades estão distribuídas nas seguintes sub-rotinas:

- **Teclado** – Guarda 6 dígitos digitados pelo usuário em um vetor iniciado no endereçado dado pelo registrador R6
- **Compare** – Compara dois vetores indicados pelos registradores R7 e R6 com tamanho indicados pelo registrador R4. A resposta da comparação é fornecida no registrador R3 (Valor 00h – Vetores de valores iguais / Valor 01h – Vetores de valores diferentes)
- **DelayVar –** Sub-rotina de delay do programa (variável ao número atribuído no Acumulador)
- **DelayMotor –** Sub-rotina responsável pelo controle do tempo em que o motor fica ligado ao realizar a abertura ou fechamento.
- **Lcd_init** – Inicializa o LCD 16x2.
- **PosicionaCursor –** Posiciona o cursor na linha e coluna do LCD desejada.
- **ClearDisplay** – Limpa o display LCD
- **EscreveStringROM** – Sub-rotina que faz a escrita das strings, armazenadas na ROM do programa, no LCD 16x2.
- **Abrir –** Parte do código destinada a fazer a transição do estado fechado para aberto.
- **Fechar –** Parte do código destinada a fazer a transição do estado aberto para fechado.
- **Setup –** Configuração inicial do programa
- **Main –** Loop principal do programa

## Indicações dos LEDs

Os leds atribuidos ao pino P2, informam os seguintes estados do programa:

- P2.0 - Fechado
- P2.1 - Aberto
- P2.6 - Digitar a nova senha
- P2.7 - Digitar a senha de abertura
- P2.2 - Senha incorreta

## Indicações do LCD

O LCD informa mensagens sobre o atual estado do programa, sendo:

- Digite uma nova senha
- Digite a senha do cofre
- Abrindo
- Fechando
- Senha incorreta

## Fluxo de Funcionamento

**1. Inicialização (Setup)**

- Inicia o LCD e configura as portas.
- Zera o contador de erros


**2. Abertura do Cofre (Abrir)**

- Mostra mensagem "Abrindo".
- Liga, por um breve período, o motor (P3.0/P3.1) para abrir o cofre.


**3. Menu Principal (Main)**

- Mostra a mensagem para digitar nova senha.
- Usuário digita uma nova senha (armazenada em pSenha).


**4. Fechamento do Cofre (Fechar)**

- Mostra "Fechando".
- Liga o motor na direção inversa para fechar.


**5. Entrada de Senha (EntradaSenha)**

- Mostra mensagem para digitar a senha do cofre.
- Armazena senha digitada em pEntrada.
- Compara com a senha correta (Compare):
- Se correta: volta ao Abrir.
- Se incorreta: incrementa contador de erros (pErros), mostra "Senha Incorreta" e espera um tempo proporcional ao número de erros, depois volta para EntradaSenha.
