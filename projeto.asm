; ******************************************************************************
; Projeto - Versão Intermédia - 03/06/2022
;
; Grupo 25:
;	Afonso da Conceição Ribeiro, 102763
;	Nuno Miguel Rodrigues Gonçalves, 103392
;
; Unidade Curricular de Introdução à Arquitetura de Computadores, 1.º Ano
; Licenciatura em Engenharia Informática e de Computadores - Alameda
; Instituto Superior Técnico - Universidade de Lisboa
; Ano Letivo 2021/2022, Semestre 2, Período 4
; ******************************************************************************

; ******************************************************************************
; Atribuição de teclas a comandos:
; Tecla 0 - Move o rover para a esquerda
; Tecla 1 - Move o rover para a direita
; Tecla 4 - Decrementa o valor da energia nos displays
; Tecla 5 - Incrementa o valor da energia nos displays
; Tecla 8 - Move o meteoro para baixo
; ******************************************************************************

; ******************************************************************************
; * Constantes
; ******************************************************************************
DISPLAYS   			EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)

LINHA_4_TECLADO		EQU 1000b	; linha 4 do teclado (primeira a testar)
NENHUMA_TECLA		EQU	-1		; nenhuma tecla detetada
TECLA_0				EQU 0		; tecla 0
TECLA_1				EQU 1		; tecla 1
TECLA_4				EQU 4		; tecla 4
TECLA_5				EQU 5		; tecla 5
TECLA_8				EQU 8		; tecla 8
MÁSCARA				EQU 0FH		; para isolar os 4 bits de menor peso

MAX_LINHA	EQU  31     ; número da linha mais abaixo que um objeto pode ocupar
MIN_COLUNA	EQU  0		; número da coluna mais à esquerda que um objeto pode ocupar
MAX_COLUNA	EQU  63     ; número da coluna mais à direita que um objeto pode ocupar
ATRASO		EQU	1500H	; atraso para limitar a velocidade do movimento de um objeto

APAGA_AVISO     		EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6000H   ; endereço do comando para apagar todos os pixels do ecrã especificado
APAGA_ECRÃS	 			EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
DEFINE_COLUNA   		EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_LINHA    		EQU 600AH	; endereço do comando para definir a linha
DEFINE_PIXEL    		EQU 6012H   ; endereço do comando para escrever um pixel
SELECIONA_CENARIO_FUNDO	EQU 6042H   ; endereço do comando para selecionar um cenário de fundo
SELECIONA_ECRÃ		 	EQU 6004H   ; endereço do comando para selecionar um ecrã
TOCA_SOM				EQU 605AH   ; endereço do comando para reproduzir um som

LARGURA_ROVER	EQU	5 		; largura do rover
ALTURA_ROVER	EQU 4 		; altura do rover
COR_ROVER		EQU	0FFF0H	; cor do rover: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)
LINHA_ROVER     EQU  28     ; linha do rover (no fundo do ecrã)
COLUNA_ROVER	EQU  30     ; coluna inicial do rover (a meio do ecrã)

LARGURA_METEORO	EQU	5 		; largura do meteoro
ALTURA_METEORO	EQU 5 		; altura do meteoro
COR_METEORO 	EQU 0FF00H  ; cor do meteoro: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
LINHA_METEORO   EQU 0       ; linha inicial do meteoro (no topo do ecrã)
COLUNA_METEORO	EQU 30      ; coluna do meteoro (a meio do ecrã)

ENERGIA_INICIAL		EQU 50 		; valor inicial da energia (em decimal)
ENERGIA_MÍNIMA  	EQU 0    	; valor mínimo de energia (em decimal)
ENERGIA_MÁXIMA_DEC	EQU 100 	; valor máximo de energia (em decimal)
ENERGIA_MÁXIMA_HEX	EQU 100H 	; valor máximo de energia (representação em hexadecimal do valor em decimal)


; ******************************************************************************
; * Dados 
; ******************************************************************************
	PLACE       1000H
pilha:
	STACK 100H			; espaço reservado para a pilha
SP_inicial:				; este é o endereço com que o SP deve ser inicializado

DEF_ROVER:		; tabela que define o rover (cor, largura, altura, pixels)
	WORD	LARGURA_ROVER, ALTURA_ROVER
	WORD	0, 0, COR_ROVER, 0, 0
	WORD	COR_ROVER, 0, COR_ROVER, 0, COR_ROVER
	WORD	COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER
	WORD	0, COR_ROVER, 0, COR_ROVER, 0

DEF_METEORO:	; tabela que define o meteoro (cor, largura, altura, pixels)
	WORD	LARGURA_METEORO, ALTURA_METEORO
	WORD	COR_METEORO, 0, 0, 0, COR_METEORO
	WORD	COR_METEORO, 0, COR_METEORO, 0, COR_METEORO
	WORD	0, COR_METEORO, COR_METEORO, COR_METEORO, 0
	WORD	COR_METEORO, 0, COR_METEORO, 0, COR_METEORO
	WORD	COR_METEORO, 0, 0, 0, COR_METEORO


; ******************************************************************************
; * Código
; ******************************************************************************
	PLACE   0000H						; o código tem de começar em 0000H
início:
	MOV  SP, SP_inicial					; inicializa SP para a palavra a seguir à última da pilha
	MOV  [APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado
	MOV  [APAGA_ECRÃS], R1				; apaga todos os pixels já desenhados
	MOV	 R1, 0							; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

inicializa_meteoro:
	MOV  R1, 1
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 1
	MOV  R1, LINHA_METEORO		; linha do meteoro
	MOV  R2, COLUNA_METEORO		; coluna do meteoro
	MOV	 R4, DEF_METEORO		; endereço da tabela que define o meteoro
	CALL desenha_boneco			; desenha o meteoro a partir da tabela
	MOV  R8, R1					; cópia da linha do meteoro
	MOV  R9, R2					; cópia da coluna do meteoro
	MOV  R10, R4				; cópia do endereço da tabela que define o meteoro

inicializa_rover:
	MOV  R1, 0
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 0
    MOV  R1, LINHA_ROVER	  	; linha do rover
	MOV  R2, COLUNA_ROVER	  	; coluna do rover
	MOV	 R4, DEF_ROVER		  	; endereço da tabela que define o rover
	CALL desenha_boneco			; desenha o rover a partir da tabela

inicializa_displays:
	MOV  R11, ENERGIA_INICIAL 	; valor inicial da energia (em decimal)
	CALL mostra_energia			; mostra a energia do rover nos displays


espera_tecla:					; neste ciclo espera-se até uma tecla ser premida
	CALL teclado				; leitura às teclas

	CMP  R0, NENHUMA_TECLA		; se nenhuma tecla for premida, repete o ciclo
	JZ   espera_tecla
	CMP	 R0, TECLA_0			; se a tecla 0 for premida, move o rover para a esquerda
	JZ	 move_rover_esquerda
	CMP	 R0, TECLA_1			; se a tecla 1 for premida, move o rover para a direita
	JZ	 move_rover_direita
	CMP	 R0, TECLA_4			; se a tecla 4 for premida, decrementa o valor da energia
	JZ	 decrementa_energia
	CMP	 R0, TECLA_5			; se a tecla 5 for premida, incrementa o valor da energia
	JZ	 incrementa_energia
	MOV  R5, TECLA_8
	CMP	 R0, R5					; se a tecla 8 for premida, move o meteoro para baixo
	JZ	 move_meteoro_baixo

ha_tecla:             			; neste ciclo espera-se até nenhuma tecla estar premida
    CALL teclado 				; leitura às teclas
    CMP  R0, NENHUMA_TECLA		; há tecla premida?
    JNZ  ha_tecla      			; se ainda houver uma tecla premida, espera até não haver
    JMP  espera_tecla			; se já não houver uma tecla premida, espera até haver


move_rover_esquerda:
	MOV	 R7, -1					; o rover vai-se deslocar para a esquerda (coluna anterior)
	JMP	 ve_limites_horizontal

move_rover_direita:
	MOV	 R7, +1					; o rover vai-se deslocar para a direita (coluna seguinte)

ve_limites_horizontal:
	CALL testa_limites_horizontal	; vê se chegou aos limites do ecrã e, se sim, força R7 a 0
	CMP	 R7, 0						; se R7 estiver a 0, não é para mover o rover
	JZ	 espera_tecla				; se não é para mover o rover, espera pela próxima tecla
	CALL move_rover
	JMP  espera_tecla


incrementa_energia:
	PUSH R0
	MOV  R0, ENERGIA_MÁXIMA_DEC	; valor máximo de energia	
	CMP  R11, R0
	JZ   sai_incremento			; se a energia máxima foi atingida, não incrementa mais
    ADD  R11, 1					; incrementa o valor da energia
    CALL mostra_energia			; mostra energia do rover nos displays
sai_incremento:
	POP  R0
    JMP  ha_tecla 				; espera até a tecla deixar de ser premida

decrementa_energia:
	CMP  R11, ENERGIA_MÍNIMA    ; valor mínimo de energia
	JZ   ha_tecla 				; se a energia mínima foi atingida, não decrementa mais
    SUB  R11, 1					; decrementa o valor da energia
    CALL mostra_energia 		; mostra energia do rover nos displays
    JMP  ha_tecla 				; espera até a tecla deixar de ser premida


move_meteoro_baixo:
	CALL testa_limites_vertical ; vê se chegou aos limites do ecrã e, se sim, força R3 a 0
	CMP  R3, 0 					; se R3 estiver a 0, não é para mover o meteoro
	JZ   ha_tecla				; se não é para mover o meteoro, espera pela próxima tecla
	ADD  R8, R3					; se é para mover o meteoro, incrementa a sua linha
	CALL move_meteoro
	JMP  ha_tecla 				; espera até a tecla deixar de ser premida


; ******************************************************************************
; * Rotinas
; ******************************************************************************

; ******************************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
;
; Argumentos:	R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
; ******************************************************************************
escreve_pixel:
	MOV  [DEFINE_LINHA], R1		; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3		; altera a cor do pixel na linha e coluna selecionadas
	RET


; ******************************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas, com a forma e
;				   cor definidas na respetiva tabela.
;
; Argumentos:	R1 - linha
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
	ADD	 R4, 2				; endereço da altura do boneco (2 porque a largura é uma word)
	MOV  R6, [R4]			; obtém a altura do boneco
	ADD	 R4, 2				; endereço da cor do 1.º pixel (2 porque a largura é uma word)
desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel		; escreve o pixel na linha e coluna definidas
	ADD	 R4, 2				; endereço da cor do próximo pixel (2 porque a cor do pixel é uma word)
    ADD  R2, 1              ; próxima coluna
    SUB  R5, 1				; menos uma coluna para tratar
    JNZ  desenha_pixels     ; repete até percorrer toda a largura (colunas) do objeto
db_proxima_linha:
	SUB  R6, 1 				; linhas por desenhar
	JZ   sai_desenha_boneco ; todas as linhas já desenhadas?
	ADD  R1, 1 		   	    ; próxima linha
	MOV  R5, R7			    ; obtém a largura do boneco
	SUB  R2, R5		 	    ; primeira coluna
	JMP  desenha_pixels
sai_desenha_boneco:
	POP  R7
	POP  R6
	POP	 R5
	POP	 R4
	POP	 R3
	POP	 R2
	POP  R1
	RET


; ******************************************************************************
; ATRASO - Executa um ciclo que implementa um atraso, para limitar a velocidade
;		   de movimento de um boneco.
;
; ******************************************************************************
atraso:
	PUSH R11
	MOV  R11, ATRASO
ciclo_atraso:			; executa o ciclo R11 vezes
	SUB	 R11, 1	
	JNZ	 ciclo_atraso
	POP	 R11
	RET


; ******************************************************************************
; TECLADO - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
teclado:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R7
	PUSH R8

	MOV  R2, TEC_LIN   			; endereço do periférico das linhas
	MOV  R3, TEC_COL   			; endereço do periférico das colunas
	MOV  R4, 4					; para calcular o valor da tecla
	MOV  R5, MÁSCARA			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R8, 0					; para processar a coluna
	MOV  R7, 3					; primeira linha a testar (de 0 a 3)
	MOV  R6, LINHA_4_TECLADO	; primeira linha a testar (identificação em binário)

ciclo_teclado:
	MOVB [R2], R6			; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      		; ler do periférico de entrada (colunas)
	AND  R0, R5				; elimina bits para além dos bits 0-3
	JNZ  processa_coluna	; se for detetada uma tecla, processa-a
	SUB  R7, 1				; linha acima da atual (de 0 a 3)
	SHR  R6, 1				; linha acima da atual (identificação em binário)
	JNZ  ciclo_teclado		; se houver linha acima, testa-a
	MOV  R0, NENHUMA_TECLA	; se não houver linha acima, devolve o valor de nenhuma tecla lida
	JMP  sai_teclado

processa_coluna:
	SHR  R0, 1				; o valor da coluna, de 0 a 3, é o número de shifts para
							; a direita que se fazem até este valor ser 0
	JZ   processa_tecla
	ADD  R8, 1				; contador (será o valor da coluna, de 0 a 3)
	JMP  processa_coluna

processa_tecla:	; o valor da tecla é igual a 4 * linha + coluna (linha e coluna entre 0 e 3)
	MOV  R0, R7
	MUL  R0, R4
	ADD  R0, R8	; valor da tecla premida

sai_teclado:
	POP  R8
	POP  R7
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET


; ******************************************************************************
; TESTA_LIMITES_HORIZONTAL - Testa se o boneco chegou aos limites na horizontal
;							 do ecrã e, se sim, força R7 a 0.
;
; Argumentos:	R2 - coluna em que o boneco está
;				R4 - endereço da largura do boneco
;			 	R7 - sentido de movimento do boneco (valor a somar à coluna
;					 em cada movimento: +1 para a direita, -1 para a esquerda)
;
; Retorna: 		R7 - o mesmo, caso o boneco não tenha chegado aos limites do
;					 ecrã; 0, caso contrário
;
; ******************************************************************************
testa_limites_horizontal:
	PUSH R5
	PUSH R6

	MOV	 R6, [R4]				; obtém a largura do boneco
testa_limite_esquerdo:			; vê se o boneco chegou ao limite esquerdo
	MOV	 R5, MIN_COLUNA
	CMP  R2, R5					; compara a coluna atual com a coluna mais à esquerda
	JGT	 testa_limite_direito	; se o boneco não estiver no limite esquerdo, testa o limite direito
	CMP	 R7, 0
	JGE	 sai_testa_limites 		; se R7 for positivo, o boneco pode ser movido
								; (pois é para a direita)
	JMP	 impede_movimento		; se R7 for negativo, impede-se o movimento do boneco
								; (pois seria para a esquerda)
testa_limite_direito:			; vê se o boneco chegou ao limite direito
	ADD	 R6, R2					; posição a seguir ao extremo direito do boneco
	MOV	 R5, MAX_COLUNA
	CMP	 R6, R5					; compara a coluna seguinte ao boneco com a coluna mais à direita
	JLE	 sai_testa_limites		; se o boneco não estiver no limite direito, pode ser movido
	CMP	 R7, 0
	JLE	 sai_testa_limites 		; se R7 for negativo, o boneco pode ser movido
								; (pois é para a esquerda)
	JMP	 impede_movimento		; se R7 for positivo, impede-se o movimento do boneco
								; (pois seria para a direita)
impede_movimento:
	MOV	 R7, 0					; impede o movimento, forçando R7 a 0
sai_testa_limites:	
	POP	 R6
	POP	 R5
	RET


; ******************************************************************************
; TESTA_LIMITES_VERTICAL - Testa se o boneco chegou aos limites na vertical
;						   do ecrã.
;
; Argumentos:	R8 - linha em que o boneco está
;
; Retorna: 		R3 - 1, caso o boneco não tenha chegado aos limites do ecrã;
;					 0, caso contrário
;
; ******************************************************************************
testa_limites_vertical:
	PUSH R9
	PUSH R10
	PUSH R11

	MOV  R3, 0 						; impede o movimento, forçando R3 a 0
	MOV  R9, MAX_LINHA
	MOV  R11, R8					; copia a linha em que o boneco está
	ADD  R10, 2 					; obtém o endereço da altura do boneco
	MOV  R10, [R10]					; copia a altura do boneco
	ADD  R11, R10					; posição a seguir ao extremo inferior do boneco
	CMP  R11, R9					; compara a linha seguinte ao boneco com a linha mais abaixo
	JGT  sai_testa_limites_vertical	; se o boneco estiver no limite inferior, não pode ser movido
	MOV  R3, 1 						; permite o movimento, forçando R3 a 1
sai_testa_limites_vertical:
	POP  R11
	POP  R10
	POP  R9
	RET


; ******************************************************************************
; MOVE_ROVER - Apaga o rover da posição atual e desenha-o na nova posição
;
; Argumentos:	R7 - variação do valor da coluna do rover (-1 caso mova para a
;					 esquerda, 1 caso mova para a direita)
;
; ******************************************************************************
move_rover:
	PUSH R10
	CALL atraso 			; ciclo para implementar um atraso
	MOV  R10, 0 			; ecrã do rover
	MOV  [APAGA_ECRÃ], R10  ; apaga o rover
	ADD	 R2, R7				; para desenhar o rover na coluna pretendida (à esquerda ou à direita)
	CALL desenha_boneco 	; desenha o rover a partir da tabela
	POP  R10
	RET


; ******************************************************************************
; MOVE_METEORO - Apaga o meteoro da posição atual e desenha-o na nova posição
;
; Argumentos:   R8 - linha do meteoro
;               R9 - coluna do meteoro
;               R10 - tabela que define o meteoro
;
; ******************************************************************************
move_meteoro:
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R11

	CALL atraso 			 	; ciclo para implementar um atraso
	MOV  R11, 1 				; ecrã do meteoro
	MOV  [APAGA_ECRÃ], R11 		; apaga o meteoro
	MOV  [SELECIONA_ECRÃ], R11  ; seleciona o ecrã do meteoro

	MOV  R11, 0
	MOV  R1, R8					; cópia da linha do meteoro
	MOV  R2, R9					; cópia da coluna do meteoro
	MOV  R4, R10				; cópia do endereço da tabela que define o meteoro
	CALL desenha_boneco			; desenha o meteoro a partir da tabela
	MOV  [TOCA_SOM], R11		; comando para tocar o som do meteoro
	MOV  [SELECIONA_ECRÃ], R11  ; seleciona o ecrã do rover

	POP  R11
	POP  R4
	POP  R2
	POP  R1
	RET


; ******************************************************************************
; MOSTRA_ENERGIA - Mostra a energia do rover nos displays, em percentagem do
;				   valor inicial (em decimal)
;
; Argumentos:	R11 - percentagem do valor inicial da energia (em decimal)
;
; ******************************************************************************
mostra_energia:
	PUSH R11
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R2, ENERGIA_MÁXIMA_DEC	; valor máximo de energia (em decimal)
	MOV  R3, ENERGIA_MÁXIMA_HEX ; valor máximo de energia
								; (representação em hexadecimal do valor em decimal)
	CMP  R11, R2				; se o valor da energia for máximo, mostra-se, nos
								; displays, a sua representação em hexadecimal
	JZ   display
	
	MOV  R2, 10 	; para proceder a operações de divisão inteira e resto de divisão por 10
	MOV  R3, 0H 	; valor a ser mostrado nos displays
	MOV  R1, R11	; cópia do valor da energia
	MOD  R1, R2 	; dígito das unidades, em decimal, do valor da energia
	DIV  R11, R2	; dígito das dezenas, em decimal, do valor da energia
	SHL  R11, 4 	; representação, em hexadecimal, das dezenas do valor da energia, em decimal
	ADD  R3, R1 	; representação, em hexadecimal, das unidades do valor da energia, em decimal
	ADD  R3, R11 	; representação, em hexadecimal, do valor da energia, em decimal
					; (caso este tenha apenas dois dígitos, sendo o dígito das centenas 0)
display:
	MOV  [DISPLAYS], R3	; mostrar, nos displays, o valor da energia, apresentado em decimal

	POP  R3
	POP  R2
	POP  R1
	POP  R11
	RET
