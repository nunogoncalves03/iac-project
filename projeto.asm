; ******************************************************************************
; * IST-UL
; * Modulo:    xxx.asm
; * Descrição: xxx
; ******************************************************************************

; ******************************************************************************
; * Constantes
; ******************************************************************************
DISPLAYS   			EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_1_TECLADO		EQU 0001b	; linha 1 do teclado
LINHA_2_TECLADO		EQU 0010b	; linha 2 do teclado
LINHA_3_TECLADO		EQU 0100b	; linha 3 do teclado
LINHA_4_TECLADO		EQU 1000b	; linha 4 do teclado
COLUNA_1_TECLADO	EQU 0001b	; coluna 1 do teclado
COLUNA_2_TECLADO	EQU 0010b	; coluna 2 do teclado
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

DEFINE_LINHA    		EQU 600AH	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H   ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6000H   ; endereço do comando para apagar todos os pixels ecrã especificado
APAGA_ECRÃS	 			EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo
SELECIONA_ECRÃ		 	EQU 6004H   ; endereço do comando para selecionar o ecrã
TOCA_SOM				EQU 605AH   ; endereço do comando para tocar um som

MAX_LINHA		EQU  31     ; número da linha mais abaixo que o objeto pode ocupar
MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63     ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	1800H	; atraso para limitar a velocidade de movimento do boneco

LARGURA_ROVER	EQU	5 		; largura do boneco
ALTURA_ROVER	EQU 4 		; altura do boneco
COR_ROVER		EQU	0FFF0H	; cor do rover: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)
LINHA_ROVER     EQU  28     ; linha do rover (a meio do ecrã)
COLUNA_ROVER	EQU  30     ; coluna do rover (a meio do ecrã)

LARGURA_METEORO	EQU	5 		; largura do meteoro
ALTURA_METEORO	EQU 5 		; altura do meteoro
COR_METEORO 	EQU 0FF00H  ; cor do meteoro: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
LINHA_METEORO   EQU 0       ; linha do meteoro (a meio do ecrã)
COLUNA_METEORO	EQU 30      ; coluna do meteoro (a meio do ecrã)

ENERGIA_INICIAL	EQU 50 			; valor inicial da energia (em decimal)
ENERGIA_MÍNIMA  EQU 0    		; valor mínimo de energia (em decimal)
ENERGIA_MÁXIMA  EQU 100    		; valor máximo de energia (em decimal)

; ******************************************************************************
; * Dados 
; ******************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
DEF_ROVER:					; tabela que define o rover (cor, largura, altura, pixels)
	WORD	LARGURA_ROVER, ALTURA_ROVER
	WORD	0, 0, COR_ROVER, 0, 0
	WORD	COR_ROVER, 0, COR_ROVER, 0, COR_ROVER
	WORD	COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER
	WORD	0, COR_ROVER, 0, COR_ROVER, 0

DEF_METEORO:
	WORD	LARGURA_METEORO, ALTURA_METEORO
	WORD	COR_METEORO, 0, 0, 0, COR_METEORO
	WORD	COR_METEORO, 0, COR_METEORO, 0, COR_METEORO
	WORD	0, COR_METEORO, COR_METEORO, COR_METEORO, 0
	WORD	COR_METEORO, 0, COR_METEORO, 0, COR_METEORO
	WORD	COR_METEORO, 0, 0, 0, COR_METEORO


; ******************************************************************************
; * Código
; ******************************************************************************
	PLACE   0000H			; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir à última da pilha
	MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃS], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0				; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV  R6, LINHA_4_TECLADO  	; primeira linha a testar (4ª linha)
inicializa_meteoro:
	MOV  R1, 1
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 1
	MOV  R1, LINHA_METEORO		; linha do meteoro
	MOV  R2, COLUNA_METEORO		; coluna do meteoro
	MOV	 R4, DEF_METEORO		; endereço da tabela que define o meteoro
	CALL	desenha_boneco		; desenha o meteoro a partir da tabela
	MOV  R8, R1					; cópia da linha do meteoro
	MOV  R9, R2					; cópia da coluna do meteoro
	MOV  R10, R4				; cópia da endereço da tabela que define o meteoro
inicializa_rover:
	MOV  R1, 0
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 0
    MOV  R1, LINHA_ROVER	  	; linha do rover
	MOV  R2, COLUNA_ROVER	  	; coluna do rover
	MOV	 R4, DEF_ROVER		  	; endereço da tabela que define o rover
	CALL	desenha_boneco		; desenha o rover a partir da tabela
inicializa_displays:
	MOV  R11, ENERGIA_INICIAL 	; valor inicial da energia (em decimal)
	CALL mostra_energia			; mostra a energia do rover nos displays


espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	CALL	teclado			; leitura às teclas
	CMP	 R0, 0
	JZ	 proxima_linha 		; nenhuma tecla detectada, proxima linha
	JMP  processa_linha
proxima_linha:
    SHR  R6, 1       			; preparar próxima linha
    JNZ  espera_tecla  			;
    MOV  R6, LINHA_4_TECLADO	;
    JMP  espera_tecla  			;
processa_linha:
	CMP  R6, LINHA_1_TECLADO	; linha 1
	JZ   testa_linha_1			; há tecla premida na linha 1?
	CMP  R6, LINHA_2_TECLADO	; linha 2
	JZ   testa_linha_2
	CMP  R6, LINHA_3_TECLADO	; linha 3
	JZ   testa_linha_3
	JMP  espera_tecla			; linha 4
ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    CALL	teclado
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  espera_tecla


testa_linha_1:
testa_tecla_esquerda: 		; testa a tecla que move o rover para a esquerda (tecla 0)
	CMP	R0, COLUNA_1_TECLADO; tecla 0
	JNZ	testa_tecla_direita ; tecla esquerda não premida? 
	MOV	R7, -1				; vai deslocar para a esquerda
	JMP	ve_limites_horizontal
testa_tecla_direita: 		; testa a tecla que move o rover para a direita (tecla 1)
	CMP	R0, COLUNA_2_TECLADO; tecla 1
	JNZ	espera_tecla		; nenhuma tecla de movimento premida?
	MOV	R7, +1				; vai deslocar para a direita
ve_limites_horizontal:
	CALL	testa_limites_horizontal	; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla		; se não é para movimentar o objeto, vai ler o teclado de novo
	CALL move_rover
tecla_premida:               ; verifica se uma tecla de movimento ainda está a ser premida
    CALL teclado 			 ; lê as teclas da linha (armazenada em R6)
    CMP  R0, 0         		 ; há tecla premida?
    JNZ  testa_linha_1		 ; se ainda houver uma tecla premida, move o rover
    JMP  espera_tecla		 ; caso contrário, espera-se até uma tecla ser premida


testa_linha_2:
    CMP  R0, COLUNA_1_TECLADO   ; tecla que decrementa a energia do rover (tecla 4)
    JZ   decrementa_energia
    CMP  R0, COLUNA_2_TECLADO 	; tecla que incrementa a energia do rover (tecla 5)
    JZ   incrementa_energia
    JMP  espera_tecla 			; nenhuma tecla de incremento/decremento de energia premida?
incrementa_energia:
	PUSH R0
	MOV  R0, ENERGIA_MÁXIMA		; valor máximo de energia	
	CMP  R11, R0				;
	JGE  sai_incremento			; energia máxima atingida?
    ADD  R11, 1					; incrementa o valor da energia
    CALL mostra_energia			; mostra energia do rover nos displays
sai_incremento:
	POP  R0		
    JMP  ha_tecla		
decrementa_energia:
	CMP  R11, ENERGIA_MÍNIMA    ; valor mínimo de energia
	JLE  ha_tecla 				; energia mínima atingida?
    SUB  R11, 1					; decrementa o valor da energia
    CALL mostra_energia 		; mostra energia do rover nos displays
    JMP  ha_tecla 				;


testa_linha_3:
	CMP	R0, COLUNA_1_TECLADO 	; tecla 8
	JNZ	espera_tecla
	CALL testa_limites_vertical
	CMP R3, 0
	JZ  espera_tecla
	ADD R8, R3
	CALL move_meteoro
	JMP ha_tecla


; ******************************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; ******************************************************************************
desenha_boneco:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	MOV	 R5, [R4]			; obtém a largura do boneco
	MOV  R7, R5				; cópia da largura do boneco
	ADD	 R4, 2				; endereço da altura (2 porque a largura é uma word)
	MOV  R6, [R4]			; obtém a altura do boneco
	ADD	 R4, 2				; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
	ADD	 R4, 2				; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1              ; próxima coluna
    SUB  R5, 1				; menos uma coluna para tratar
    JNZ  desenha_pixels     ;  continua até percorrer toda a largura do objeto
db_proxima_linha:
	SUB  R6, 1 		   	   ; ultima linha?
	JZ   sai_desenha_boneco;
	ADD  R1, 1 		   	   ; proxima linha
	MOV  R5, R7			   ; obtém a largura do boneco
	SUB  R2, R5		 	   ; proxima coluna
	JMP  desenha_pixels
sai_desenha_boneco:
	POP R7
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET


; ******************************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; ******************************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; ******************************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; ******************************************************************************
atraso:
	PUSH R11
	MOV  R11, ATRASO 	; atraso para limitar a velocidade de movimento do boneco
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET


; ******************************************************************************
; TESTA_LIMITES_HORIZONTAL - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   inverte o sentido de movimento
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - novo sentido de movimento (pode ser o mesmo)
;
; ******************************************************************************
testa_limites_horizontal:
	PUSH	R5
	PUSH	R6
	MOV	R6, [R4]			; obtém a largura do boneco
testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JGT	testa_limite_direito
	CMP	R7, 0				; passa a deslocar-se para a direita
	JGE	sai_testa_limites
	JMP	impede_movimento	; entre limites. Mantém o valor do R7
testa_limite_direito:		; vê se o boneco chegou ao limite direito
	ADD	R6, R2			; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JLE	sai_testa_limites	; entre limites. Mantém o valor do R7
	CMP	R7, 0			; passa a deslocar-se para a direita
	JGT	impede_movimento
	JMP	sai_testa_limites
impede_movimento:
	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	R6
	POP	R5
	RET


; ******************************************************************************
; MUDAR - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; ******************************************************************************
testa_limites_vertical:
	PUSH R9 
	PUSH R10 				; 
	PUSH R11 				;

	MOV R3, 0
	MOV R9, MAX_LINHA
	MOV R11, R8
	ADD R10, 2
	MOV R10, [R10]
	ADD R11, R10
	CMP R11, R9
	JGT sai_testa_limites_vertical		; vê se chegou ao limite inferior do ecrã
	MOV R3, 1 				; proxima linha
sai_testa_limites_vertical:
	POP R11
	POP R10
	POP R9
	RET


; ******************************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
;
; ******************************************************************************
teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5

	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
	MOV  R3, TEC_COL   ; endereço do periférico das colunas
	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R2], R6      ; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
	AND  R0, R5        ; elimina bits para além dos bits 0-3

	POP	R5
	POP	R3
	POP	R2
	RET


; ******************************************************************************
; MOSTRA_ENERGIA - Mostra a energia do rover em percentagem do valor inicial nos displays
; Argumentos:	R11 - percentagem do valor inicial da energia (em decimal)
;
; ******************************************************************************
mostra_energia:
	PUSH R11
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R2, 10
	MOV  R3, 0H
	MOV  R1, R11
	MOD  R1, R2
	ADD  R3, R1
	SUB  R11, R1
	DIV  R11, R2
	SHL  R11, 4
	ADD  R3, R11
	MOV  R2, 0A0H
	CMP  R11, R2
	JNZ  display
	MOV  R3, 100H
display:
	MOV  [DISPLAYS], R3

	POP R3
	POP R2
	POP R1
	POP R11
	RET


; ******************************************************************************
; MUDAR - Mostra a energia do rover em percentagem do valor inicial nos displays
; Argumentos:	R11 - percentagem do valor inicial da energia (em decimal)
;
; ******************************************************************************
move_rover:
	PUSH R10
	CALL	atraso 			; ciclo para implementar um atraso
	MOV  R10, 0
	MOV  [APAGA_ECRÃ], R10  ; apaga o rover
	ADD	R2, R7				; para desenhar objeto na coluna seguinte (direita ou esquerda)
	CALL	desenha_boneco	 ; desenha o rover a partir da tabela
	POP  R10
	RET


; ******************************************************************************
; MUDAR - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; ******************************************************************************
move_meteoro:
	PUSH  R1
	PUSH  R2
	PUSH  R3
	PUSH  R4
	PUSH R10

	CALL atraso 			 ; ciclo para implementar um atraso
	MOV  R10, 1
	MOV  [APAGA_ECRÃ], R10 		; apaga ecrã 1
	MOV  [SELECIONA_ECRÃ], R10  ; seleciona ecrã 1
	POP  R10

	MOV   R3, 0
	MOV   R1, R8					; cópia linha
	MOV   R2, R9					; cópia coluna
	MOV   R4, R10					; cópia DEF_METEORO
	CALL  desenha_boneco			; desenha o meteoro a partir da tabela
	MOV   [TOCA_SOM], R3			; comando para tocar o som
	MOV   [SELECIONA_ECRÃ], R3   	; seleciona ecrã 0

	POP R4
	POP R3
	POP R2
	POP R1
	RET
