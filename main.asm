           ORG 0000H
           LJMP Main

pSenha   EQU 50h
pEntrada EQU 60h

           ORG 0100H
Main:
				MOV R6, #pSenha
				CALL Teclado

				MOV R6, #pEntrada
				CALL Teclado

				MOV R7, #pSenha
				MOV R6, #pEntrada
				MOV R4, #06h
				CALL Compare

				CJNE R3, #00h, SenhaErrada

				; Senha correta - colocar aqui a lógica que quiser (ex: abrir menu, acender LED, etc.)
				JMP $

SenhaErrada:
				CALL Delay5s
				JMP Main

; ---------------- COMPARAÇÃO DE SENHAS ----------------
Compare:
				; R7 ponteiro senha correta
				; R6 ponteiro senha digitada
				; R4 tamanho da senha
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
				MOV A, #0H
				MOV R5, #0H
		Loop:
				CALL Linha
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

; ---------------- DELAY DE 5 SEGUNDOS ----------------
Delay5s:
				MOV R1, #5 ; repete 5 vezes delay de ~1s

DelayLoop1s:
				MOV R2, #250
Loop1:
				MOV R3, #255
Loop2:
				MOV R4, #255
Loop3:
				DJNZ R4, Loop3
				DJNZ R3, Loop2
				DJNZ R2, Loop1
				DJNZ R1, DelayLoop1s
				RET