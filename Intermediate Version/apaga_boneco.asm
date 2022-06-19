; ******************************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; ******************************************************************************
apaga_boneco:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	PUSH 	R7
	MOV	R5, [R4]			; obtém a largura do boneco
	MOV R7, R5				; cópia da largura do boneco
	ADD	R4, 2				; endereço da da altura (2 porque a largura é uma word)
	MOV R6, [R4]			; obtém a altura do boneco
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0				; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
    ADD  R2, 1              ; próxima coluna
    SUB  R5, 1				; menos uma coluna para tratar
    JNZ  apaga_pixels      	; continua até percorrer toda a largura do objeto
ab_proxima_linha:
	MOV  R5, R7  ; obtém a largura do boneco
	SUB  R2, R5		 	   ; proxima coluna
	SUB  R6, 1 		   	   ; ultima linha?
	JZ   sai_apaga_boneco  ;
	ADD  R1, 1 		   	   ; proxima linha
	JMP  apaga_pixels
sai_apaga_boneco:
	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET
