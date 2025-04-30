           ORG 0000H
           LJMP Setup

pSenha   EQU 50h
pEntrada EQU 60h
pErros   EQU 70h

           ORG 0100H
; LEDs
; P2.0 - Fechado
; P2.1 - Aberto
; P2.6 - Digitar a nova senha
; P2.7 - Digitar a senha de abertura
; P2.2 - Senha incorreta

Setup:
				MOV P2, #0FFh
				CLR P2.0
				MOV pErros, #0 ; contador de erros = 0
				LJMP Abrir
Main:
				CLR P2.6
				MOV R6, #pSenha
				CALL Teclado
				SETB P2.6

				LJMP Fechar

EntradaSenha:
				CLR P2.7
				MOV R6, #pEntrada
				CALL Teclado
				SETB P2.6

				MOV R7, #pSenha
				MOV R6, #pEntrada
				MOV R4, #06h
				CALL Compare

				CJNE R3, #00h, SenhaErrada
		Abrir:
				; senha correta
				MOV pErros, #0 ; zera contador de erros
				SETB P2.7
				SETB P2.0
				CLR P2.1

				; Ligando o motor para abrir a porta (girar em uma direção)
				SETB P3.0
				CLR P3.1
				
				
				; Delay opcional para deixar o motor ligado por um tempo
				ACALL DelayMotor

				; Parar o motor após delay
				CLR P3.0
				CLR P3.1

				JMP Main

SenhaErrada:
				MOV R0, pErros 
				INC R0 ; aumenta tentativas incorretas
				MOV pErros, R0
				MOV R0, #00h
				CLR P2.2
			Fechar:
				JNB P2.0, ErroSenha
				SETB P2.1
				SETB P2.6
				CLR P2.0

				; Ligando o motor para abrir a porta (girar em uma direção)
				SETB P3.1
				CLR P3.0
				
				
				; Delay opcional para deixar o motor ligado por um tempo
				ACALL DelayMotor

				; Parar o motor após delay
				CLR P3.0
				CLR P3.1
			ErroSenha:
				MOV A, pErros
				CALL DelayVar ; delay proporcional ao erro
				SETB P2.2
				JMP EntradaSenha

Compare:
				; R7 ponteiro senha correta
				; R6 ponteiro senha digitada
				; R4 tamanho da senha
				; R3 retorna #01 para incorreto
				MOV R2, #0H
				MOV R3, #0H
		CompLoop:
				MOV A, R7
				ADD A, R2
				MOV R1, A

				MOV A, R6
				ADD A, R2
				MOV R0, A

				MOV A, @R1
				MOV B, @R0

				CJNE A, B, Incorreto
				JMP Correto
		Incorreto:
				MOV R3, #01H
				JMP compReturn
		Correto:
				DEC R4
				MOV A, R4
				INC R2
				JNZ CompLoop
		compReturn:
				RET

; ---------------- ENTRADA VIA TECLADO ----------------
Teclado:
		; Entrada R6 do inicio do ponteiro
		; da memoria RAM para armazenar os 6
		; valores
				MOV A, #0H
				MOV R5, #0H
		Loop:
				CALL Linha
		Sair:
				CJNE R5, #06h, Loop
				RET

Linha:
				MOV R0, #01 ; valor da tecla

				; Linha 0
				SETB P0.0
				CLR P0.3
				CALL colScan

				; Linha 1
				SETB P0.3
				CLR P0.2
				CALL colScan

				; Linha 2
				SETB P0.2
				CLR P0.1
				CALL colScan

				; Linha 3
				SETB P0.1
				CLR P0.0
				CALL colScan

				RET

colScan:
				JNB P0.6, gotKey
				INC R0
				JNB P0.5, gotKey
				INC R0
				JNB P0.4, gotKey
				INC R0
				RET

gotKey:
				MOV A, R0
				MOV R2, A
				CJNE R2, #0Ch, guardar
				CJNE R6, #pSenha, guardar
				LJMP Fechar
guardar:
				MOV A, R6
				ADD A, R5
				MOV R1, A
				MOV A, R2
				MOV @R1, A
				INC R5

espera:
				JNB P0.6, espera
				JNB P0.5, espera
				JNB P0.4, espera
				RET

DelayMotor:
				MOV R1, #10     ; tempo do motor ligado
MotorLoop1:
				MOV R2, #255
MotorLoop2:
				MOV R3, #255
MotorLoop3:
				DJNZ R3, MotorLoop3
				DJNZ R2, MotorLoop2
				DJNZ R1, MotorLoop1
				RET

; ---------------- DELAY VARIÁVEL ----------------
DelayVar:
				; A contém o multiplicador do tempo
				MOV R1, A
				CJNE R1, #00h, DelayLoop
				RET
DelayLoop:
				MOV R2, #250
Loop1:
				MOV R3, #255
Loop2:
				DJNZ R3, Loop2
				DJNZ R2, Loop1
				DJNZ R1, DelayLoop
				RET
