; *********************************************************************************
; * IST-UL
; * Modulo:    xxx.asm
; * Descrição: xxx
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DISPLAYS   			EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO		EQU 8		; linha a testar (4ª linha, 1000b)
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA		EQU 1		; tecla na primeira coluna do teclado (tecla 0)
TECLA_DIREITA		EQU 2		; tecla na segunda coluna do teclado (tecla 1)

DEFINE_LINHA    		EQU 600AH	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H   ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo

LINHA        	EQU  28        ; linha do boneco (a meio do ecrã))
COLUNA			EQU  30        ; coluna do boneco (a meio do ecrã)

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63     ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	1600H	; atraso para limitar a velocidade de movimento do boneco

LARGURA		EQU	5 		; largura do boneco
ALTURA		EQU 4 		; altura do boneco
COR_PIXEL	EQU	0FFF0H	; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)

ENERGIA		EQU 0 		; energia

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
DEF_BONECO:					; tabela que define o boneco (cor, largura, altura, pixels)
	WORD		LARGURA, ALTURA
	WORD		0, 0, COR_PIXEL, 0, 0
	WORD		COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL
	WORD		COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
	WORD		0, COR_PIXEL, 0, COR_PIXEL, 0
     

; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0				; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
							; à última da pilha
                            
	MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 0				; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

    MOV  R1, LINHA				; linha do boneco
	MOV  R2, COLUNA				; coluna do boneco
	MOV	 R4, DEF_BONECO			; endereço da tabela que define o boneco
	MOV  R6, LINHA_TECLADO  	; linha a testar (4ª linha, 1000b)
	MOV	 R7, 1					; valor a somar à coluna do boneco, para o movimentar
	MOV  R10, ENERGIA 			;
	MOV  [DISPLAYS], R10

mostra_boneco:
	CALL	desenha_boneco		; desenha o boneco a partir da tabela

tecla_premida:               ; verificar se uma tecla de movimento ainda está a ser premida
    CALL teclado
    CMP  R0, 0         		 ; há tecla premida?
    JNZ  testa_esquerda      ; se ainda houver uma tecla premida, move o rover
    JMP  espera_tecla

espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
	CALL	teclado			; leitura às teclas
	CMP	 R0, 0
	JZ	 tec_proxima_linha	; nenhuma tecla detectada, proxima linha
	JMP  processamento_linha

tec_proxima_linha:
    SHR  R6, 1       		; preparar próxima linha
    JNZ  espera_tecla  		;
    MOV  R6, LINHA_TECLADO ;
    JMP  espera_tecla  		;

ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    CALL	teclado
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  espera_tecla

processamento_linha:
	CMP  R6, 1 		; linha 1
	JZ   testa_esquerda
	CMP  R6, 2 		; linha 2
	JZ   testa_linha_2
	CMP  R6, 4 		; linha 3
	JZ   testa_linha_3
	JMP  espera_tecla

testa_esquerda:
	CMP	R0, TECLA_ESQUERDA 	; tecla 0
	JNZ	testa_direita
	MOV	R7, -1			; vai deslocar para a esquerda
	JMP	ve_limites
testa_direita:
	CMP	R0, TECLA_DIREITA 	; tecla 1
	JNZ	espera_tecla		; tecla que não interessa
	MOV	R7, +1			; vai deslocar para a direita
ve_limites:
	MOV	R6, [R4]			; obtém a largura do boneco
	CALL	testa_limites		; vê se chegou aos limites do ecrã e se sim força R7 a 0
	CMP	R7, 0
	JZ	espera_tecla		; se não é para movimentar o objeto, vai ler o teclado de novo
move_boneco:
	MOV	R11, ATRASO		; atraso para limitar a velocidade de movimento do boneco		
	CALL	atraso

	;CALL	apaga_boneco		; apaga o boneco na sua posição corrente
	MOV  [APAGA_ECRÃ], R1
coluna_seguinte:
	ADD	R2, R7			; para desenhar objeto na coluna seguinte (direita ou esquerda)

	JMP	mostra_boneco		; vai desenhar o boneco de novo

testa_linha_2:
    CMP  R0, 1H         ; tecla 4
    JZ   decremento
    CMP  R0, 2H 		; tecla 5
    JZ   incremento
    JMP  espera_tecla
incremento:
    ADD  R10, 1
    MOV  [DISPLAYS], R10
    JMP  ha_tecla
decremento:
    SUB  R10, 1
    MOV  [DISPLAYS], R10
    JMP  ha_tecla

testa_linha_3:
	JMP espera_tecla


; **********************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
desenha_boneco:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH    R6
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2				; endereço da altura (2 porque a largura é uma word)
	MOV R6, [R4]			; obtém a altura do boneco
	ADD	R4, 2				; endereço da cor do 1º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
	ADD	R4, 2				; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1              ; próxima coluna
    SUB  R5, 1				; menos uma coluna para tratar
    JNZ  desenha_pixels     ;  continua até percorrer toda a largura do objeto
db_proxima_linha:
	SUB  R6, 1 		   	   ; ultima linha?
	JZ   sai_desenha_boneco;
	ADD  R1, 1 		   	   ; proxima linha
	MOV  R5, [DEF_BONECO]  ; obtém a largura do boneco
	SUB  R2, R5		 	   ; proxima coluna
	JMP  desenha_pixels
sai_desenha_boneco:
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET


; **********************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R4 - tabela que define o boneco
;
; **********************************************************************
apaga_boneco:
	PUSH	R1
	PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
	PUSH	R6
	MOV	R5, [R4]			; obtém a largura do boneco
	ADD	R4, 2				; endereço da da altura (2 porque a largura é uma word)
	MOV R6, [R4]			; obtém a altura do boneco
apaga_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	R3, 0				; cor para apagar o próximo pixel do boneco
	CALL	escreve_pixel	; escreve cada pixel do boneco
    ADD  R2, 1              ; próxima coluna
    SUB  R5, 1				; menos uma coluna para tratar
    JNZ  apaga_pixels      	; continua até percorrer toda a largura do objeto
ab_proxima_linha:
	MOV  R5, [DEF_BONECO]  ; obtém a largura do boneco
	SUB  R2, R5		 	   ; proxima coluna
	SUB  R6, 1 		   	   ; ultima linha?
	JZ   sai_apaga_boneco  ;
	ADD  R1, 1 		   	   ; proxima linha
	JMP  apaga_pixels
sai_apaga_boneco:
	POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
	POP R1
	RET


; **********************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; **********************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2		; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna já selecionadas
	RET


; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET


; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   inverte o sentido de movimento
; Argumentos:	R2 - coluna em que o objeto está
;			R6 - largura do boneco
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 	R7 - novo sentido de movimento (pode ser o mesmo)	
; **********************************************************************
testa_limites:
	PUSH	R5
	PUSH	R6
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


; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
; Argumentos:	R6 - linha a testar (em formato 1, 2, 4 ou 8)
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)	
; **********************************************************************
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
