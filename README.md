# 🔢 Numeric-Lock 🔒 

Desenvolvimento de uma simulação do funcionamento de um cofre eletrônico com senha de 6 dígitos no simulador EdSim51. A ideia geral do projeto consiste no aumento de tempo de espera para cada tentativa incorreta a partir de três erros. Serão utilizados os LEDs e o display LCD do simulador, como forma de indicação para o usuário.

## 🛠️ Utilização

Para utilização do programa, configure o simulador EdSim51 (Versão 2.1.38) da seguinte maneira.
- System Clock: 12.0 MHz
- Update Freq.: 10000 
- LEDs de 0 a 7, atribuídos ao pino P2
- LCD 16x2 atribuído ao P1, com Reg Select ligado em P1.3 e Enable ligado em P1.2
- Motor atribuído ao pino P3 - Motor Control Bit 0 e 1, são localizados em P3.0 e P3.1, respectivamente

## ➕ Funcionalidades
Atualmente foram atribuídos ao projeto essas funcionalidades:

- Gravação de nova senha na memória RAM enquanto estiver no estado aberto;
- Comparação com outra senha digitada pelo usuário;
- Feedback de estados do programa com os LEDs
- Feedback de estados do programa com o LCD 16x2
- Delay para nova tentativa com base no número de tentativas incorretas seguidas
- Utilização do motor como simulação da porta sendo aberta/fechada

## 🔨 Sub-rotinas do programa
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

## 💡 Indicações dos LEDs

Os leds atribuidos ao pino P2, informam os seguintes estados do programa:

- P2.0 - Fechado
- P2.1 - Aberto
- P2.6 - Digitar a nova senha
- P2.7 - Digitar a senha de abertura
- P2.2 - Senha incorreta

## 📺 Indicações do LCD

O LCD informa mensagens sobre o atual estado do programa, sendo:

- Digite uma nova senha
- Digite a senha do cofre
- Abrindo
- Fechando
- Senha incorreta

## 🔁 Fluxo de Funcionamento

``` mermaid
flowchart TD
    A[Setup: Inicialização] --> B[Abrir: Abertura do Cofre]
    B --> C[Main: Menu Principal]
    C --> D[Fechar: Fechamento do Cofre]
    D --> E[EntradaSenha: Validação]
    
    E -->|Senha Correta?| F{Compare}
    F -->|Sim| B
    F -->|Não| G[Incrementa pErros]
    G --> H[Mostra 'Senha Incorreta']
    H --> I[Espera tempo proporcional a pErros]
    I --> E
    
    %% Detalhamento das ações com quebras corretas
    A:::step -.-> A1[Inicia LCD<br>Configura portas<br>Zera pErros]
    B:::step -.-> B1[Mostra 'Abrindo'<br>Ativa motor P3.0/P3.1]
    C:::step -.-> C1[Mostra 'Digite nova senha'<br>Armazena em pSenha]
    D:::step -.-> D1[Mostra 'Fechando'<br>Ativa motor inverso]
    E:::step -.-> E1[Mostra 'Digite senha'<br>Armazena em pEntrada]
    
    classDef step fill:#3e0847,stroke:#0066cc,stroke-width:2px
    class A,B,C,D,E step
```
