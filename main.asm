; --- Mapeamento de Hardware (8051) ---
RS      EQU     P1.3    ;Reg Select ligado em P1.3
EN      EQU     P1.2    ;Enable ligado em P1.2

           ORG 0000H
           LJMP Setup

pSenha   EQU 50h
pEntrada EQU 60h
pErros   EQU 70h

			ORG 0040H
StrNovaSenha1: 
		DB "Digite uma"
		DB 00h
StrNovaSenha2:
		DB "nova senha"
		DB 00h

StrSenha1:
		DB "Digite a Senha"
		DB 00h

StrSenha2:
		DB "do Cofre"
		DB 00h

StrAbrindo:
		DB "Abrindo"
		DB 00h

StrFechando:
		DB "Fechando"
		DB 00h
			
StrIncorreto:
		DB "Senha Incorreta"
		DB 00h

           ORG 0200H
; LEDs
; P2.0 - Fechado
; P2.1 - Aberto
; P2.6 - Digitar a nova senha
; P2.7 - Digitar a senha de abertura
; P2.2 - Senha incorreta

Setup:
				ACALL lcd_init
	
				MOV P2, #0FFh
				CLR P2.0
				MOV pErros, #0 ; contador de erros = 0
				LJMP Abrir
Main:
				ACALL MsgNovaSenha

				CLR P2.6
				MOV R6, #pSenha
				CALL Teclado
				SETB P2.6

				ACALL clearDisplay

				LJMP Fechar

EntradaSenha:
				CLR P2.7

				ACALL MsgSenha

				MOV R6, #pEntrada
				CALL Teclado
				SETB P2.6

				CALL clearDisplay

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

				ACALL MsgAbrindo

				; Ligando o motor para abrir a porta (girar em uma direção)
				SETB P3.0
				CLR P3.1
				
				ACALL DelayMotor

				; Parar o motor após delay
				CLR P3.0
				CLR P3.1

				ACALL clearDisplay

				JMP Main

SenhaErrada:
				MOV R0, pErros 
				INC R0 ; aumenta tentativas incorretas
				MOV pErros, R0
				MOV R0, #00h
				CLR P2.2

				ACALL MsgIncorreto

				MOV A, 00h
				CALL DelayVar

				ACALL clearDisplay

			Fechar:
				JNB P2.0, ErroSenha
				SETB P2.1
				SETB P2.6
				CLR P2.0

				ACALL MsgFechando

				; Ligando o motor para abrir a porta (girar em uma direção)
				SETB P3.1
				CLR P3.0
				
				
				; Delay opcional para deixar o motor ligado por um tempo
				ACALL DelayMotor

				; Parar o motor após delay
				CLR P3.0
				CLR P3.1

				ACALL clearDisplay

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
; -------- Delay do Motor ---------
DelayMotor:
				MOV R1, #03     ; tempo do motor ligado
MotorLoop1:
				MOV R2, #255
MotorLoop2:
				MOV R3, #255
MotorLoop3:
				DJNZ R3, MotorLoop3
				DJNZ R2, MotorLoop2
				DJNZ R1, MotorLoop1
				RET

; --------------- LCD ------------
; Escreva uma string no Display
; Entrada do endereço da String via DPTR
; Deve ser posicionado o cursor antes do envio da string
escreveStringROM:
  MOV R1, #00h
	; Inicia a escrita da String no Display LCD
loopLcd:
  MOV A, R1
	MOVC A,@A+DPTR 	 ;lê da memória de programa
	JZ finish		; if A is 0, then end of data has been reached - jump out of loop
	ACALL sendCharacter	; send data in A to LCD module
	INC R1			; point to next piece of data
   MOV A, R1
	JMP loopLcd		; repeat
finish:
	RET
	
	

; initialise the display
lcd_init:

	CLR RS		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delayLcd		; wait for BF to clear	
					; function set sent for first time - tells module to go into 4-bit mode
; Why is function set high nibble sent twice? See 4-bit operation on pages 39 and 42 of HD44780.pdf.

	SETB EN		; |
	CLR EN		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB EN		; |
	CLR EN		; | negative edge on E
				; function set low nibble sent
	CALL delayLcd		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delayLcd		; wait for BF to clear


; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delayLcd		; wait for BF to clear
	RET


sendCharacter:
	SETB RS  		; setb RS - indicates that data is being sent to module
	MOV C, ACC.7		; |
	MOV P1.7, C			; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delayLcd			; wait for BF to clear
	CALL delayLcd			; wait for BF to clear
	RET

;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereço da linha e coluna.
;|--------------------------------------------------------------------------------------|
;|linha 1 | 00 | 01 | 02 | 03 | 04 |05 | 06 | 07 | 08 | 09 |0A | 0B | 0C | 0D | 0E | 0F |
;|linha 2 | 40 | 41 | 42 | 43 | 44 |45 | 46 | 47 | 48 | 49 |4A | 4B | 4C | 4D | 4E | 4F |
;|--------------------------------------------------------------------------------------|
posicionaCursor:
	CLR RS	
	SETB P1.7		    ; |
	MOV C, ACC.6		; |
	MOV P1.6, C			; |
	MOV C, ACC.5		; |
	MOV P1.5, C			; |
	MOV C, ACC.4		; |
	MOV P1.4, C			; | high nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	MOV C, ACC.3		; |
	MOV P1.7, C			; |
	MOV C, ACC.2		; |
	MOV P1.6, C			; |
	MOV C, ACC.1		; |
	MOV P1.5, C			; |
	MOV C, ACC.0		; |
	MOV P1.4, C			; | low nibble set

	SETB EN			; |
	CLR EN			; | negative edge on E

	CALL delayLcd			; wait for BF to clear
	CALL delayLcd			; wait for BF to clear
	RET


;Retorna o cursor para primeira posição sem limpar o display
retornaCursor:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CALL delayLcd		; wait for BF to clear
	RET


;Limpa o display
clearDisplay:
	CLR RS	
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	SETB P1.4		; | low nibble set

	SETB EN		; |
	CLR EN		; | negative edge on E

	MOV R6, #40
	rotC:
	CALL delayLcd		; wait for BF to clear
	DJNZ R6, rotC
	RET


delayLcd:
	MOV R0, #50
	DJNZ R0, $
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

; Rotinas de escritas de string
MsgNovaSenha:
			ACALL clearDisplay
			MOV A, #03H
			ACALL posicionaCursor
			MOV DPTR, #StrNovaSenha1
			ACALL escreveStringROM
			
			CALL delayLcd			

			MOV A, #43H
			ACALL posicionaCursor
			MOV DPTR, #StrNovaSenha2
			JMP MsgReturn

MsgAbrindo:
			ACALL clearDisplay
			MOV A, #05H
			ACALL posicionaCursor
			MOV DPTR, #StrAbrindo
			JMP MsgReturn

MsgFechando:
			ACALL clearDisplay
			MOV A, #04H
			ACALL posicionaCursor
			MOV DPTR, #StrFechando
			JMP MsgReturn

MsgSenha:
			ACALL clearDisplay
			MOV A, #01H
			ACALL posicionaCursor
			MOV DPTR, #StrSenha1
			ACALL escreveStringROM
			
			CALL delayLcd			

			MOV A, #43H
			ACALL posicionaCursor
			MOV DPTR, #StrSenha2
			JMP MsgReturn

MsgIncorreto:
			ACALL clearDisplay
			MOV A, #00H
			ACALL posicionaCursor
			MOV DPTR, #StrIncorreto
			JMP MsgReturn

MsgReturn:
			ACALL escreveStringROM
			ACALL retornaCursor
			RET