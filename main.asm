           ORG 0000H
           LJMP Main

pSenha EQU 50h
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
				
				

				JMP $				

Compare:
		; R7 ponteiro de inicio do array correto
		; R6 ponteiro de inicio do array p/ comparar
		; R2 contador do indice
		; R3 resposta (#01h incorreto/#00h correto)
		; R1 e R0, usados p/ endereçamento
		; R4 tamanho do array que quer comparar
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
				

Teclado:
				MOV A, #0H
				MOV R5, #0H
		Loop:
				CALL Linha
				CJNE R5, #06h, Loop
				RET

		Linha:
				MOV R0, #01 ; clear R0 - the first key is key1

				; scan row0
				SETB P0.0 ; set row3
				CLR P0.3 ; clear row0
				CALL colScan ; call column-scan subroutine

          		; scan row1
				SETB P0.3 ; set row0
				CLR P0.2 ; clear row1
				CALL colScan ; call column-scan subroutine

				; scan row2
				SETB P0.2; set row1
				CLR P0.1 ; clear row2
				CALL colScan ; call column-scan subroutine

				; scan row3
				SETB P0.1 ; set row2
				CLR P0.0 ; clear row3
				CALL colScan ; call column-scan subroutine

				RET				

		colScan:
				JNB P0.6, gotKey ; if col0 is cleared - key found
				INC R0 ; otherwise move to next key
				JNB P0.5, gotKey ; if col1 is cleared - key found
				INC R0 ; otherwise move to next key
				JNB P0.4, gotKey ; if col2 is cleared - key found
				INC R0 ; otherwise move to next key
				RET ; return from subroutine - key not found
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
;Espera a tecla ser desprecionada para contar outra
				JNB P0.6, espera
				JNB P0.5, espera
				JNB P0.4, espera
				
				RET
