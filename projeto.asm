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

TECLA_0				EQU 0		; tecla 0
TECLA_1				EQU 1		; tecla 1
TECLA_2				EQU 2		; tecla 2
TECLA_4				EQU 4		; tecla 4
TECLA_5				EQU 5		; tecla 5
TECLA_8				EQU 8		; tecla 8
TECLA_C				EQU 0CH		; tecla C
TECLA_D				EQU 0DH		; tecla D
MÁSCARA				EQU 0FH		; para isolar os 4 bits de menor peso

LINHA_4_TECLADO		EQU 1000b	; linha 4 do teclado (primeira a testar)
MAX_LINHA			EQU  31     ; número da linha mais abaixo que um objeto pode ocupar
MIN_COLUNA			EQU  0		; número da coluna mais à esquerda que um objeto pode ocupar
MAX_COLUNA			EQU  63     ; número da coluna mais à direita que um objeto pode ocupar
ATRASO				EQU	20H		; atraso para limitar a velocidade do movimento de um objeto

MOSTRA_ECRÃ					EQU 6006H   ; endereço do comando para mostrar o ecrã especificado
ESCONDE_ECRÃ				EQU 6008H   ; endereço do comando para esconder o ecrã especificado
APAGA_AVISO     			EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 				EQU 6000H   ; endereço do comando para apagar todos os pixels do ecrã especificado
APAGA_ECRÃS	 				EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
APAGA_CENARIO_FRONTAL		EQU 6044H   ; endereço do comando para apagar o cenário frontal
DEFINE_COLUNA   			EQU 600CH   ; endereço do comando para definir a coluna
DEFINE_LINHA    			EQU 600AH	; endereço do comando para definir a linha
DEFINE_PIXEL    			EQU 6012H   ; endereço do comando para escrever um pixel
SELECIONA_CENARIO_FUNDO		EQU 6042H   ; endereço do comando para selecionar um cenário de fundo
SELECIONA_CENARIO_FRONTAL 	EQU 6046H   ; endereço do comando para selecionar um cenário frontal
SELECIONA_ECRÃ		 		EQU 6004H   ; endereço do comando para selecionar um ecrã
TOCA_SOM					EQU 605AH   ; endereço do comando para reproduzir um som

LARGURA_ROVER	EQU	5 		; largura do rover
ALTURA_ROVER	EQU 4 		; altura do rover
COR_ROVER		EQU	0FFF0H	; cor do rover: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)
LINHA_ROVER     EQU 28      ; linha do rover (no fundo do ecrã)
COLUNA_ROVER	EQU 30      ; coluna inicial do rover (a meio do ecrã)

LARGURA_METEORO_1		EQU	1			;
ALTURA_METEORO_1		EQU 1			;
LARGURA_METEORO_2		EQU	2			;
ALTURA_METEORO_2		EQU 2			;
LARGURA_METEORO_3		EQU	3			;
ALTURA_METEORO_3		EQU 3			;
LARGURA_METEORO_4		EQU	4			;
ALTURA_METEORO_4		EQU 4			;
LARGURA_METEORO_5		EQU	5			;
ALTURA_METEORO_5		EQU 5			;
COR_METEORO_INDISTINTO 	EQU 08FFFH		;
COR_METEORO_BOM			EQU 0F0F0H		;
COR_METEORO_MAU			EQU 0FF00H		;
LINHA_METEORO   		EQU 0     		; linha inicial do meteoro (no topo do ecrã)

ENERGIA_INICIAL		EQU 100		; valor inicial da energia (em decimal)
ENERGIA_MÍNIMA  	EQU 0    	; valor mínimo de energia (em decimal)
ENERGIA_MÁXIMA_DEC	EQU 100 	; valor máximo de energia (em decimal)
ENERGIA_MÁXIMA_HEX	EQU 100H 	; valor máximo de energia (representação em hexadecimal do valor em decimal)


; ******************************************************************************
; * Dados 
; ******************************************************************************
	PLACE	1000H
; Reserva do espaço para as pilhas dos processos
	STACK 100H			; espaço reservado para a pilha do programa principal
SP_inicial:				; este é o endereço com que o SP deve ser inicializado
	STACK 100H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:		; este é o endereço com que o SP deste processo deve ser inicializado
	STACK 100H			; espaço reservado para a pilha do processo "energia"
SP_inicial_energia:		; este é o endereço com que o SP deste processo deve ser inicializado
	STACK 100H			; espaço reservado para a pilha do processo "rover"
SP_inicial_rover:		; este é o endereço com que o SP deste processo deve ser inicializado
	STACK 100H			; espaço reservado para a pilha do processo "meteoro"
SP_inicial_meteoro:		; este é o endereço com que o SP deste processo deve ser inicializado
	STACK 100H			; espaço reservado para a pilha do processo "controlo"
SP_inicial_controlo:	; este é o endereço com que o SP deste processo deve ser inicializado


; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0		; rotina de atendimento da interrupção 0
	WORD 0				; rotina de atendimento da interrupção 1
	WORD rot_int_2		; rotina de atendimento da interrupção 2
	WORD 0				; rotina de atendimento da interrupção 3


estado:
	WORD 2 				; 0 (ativo), 1 (pausa), 2 (parado)
contador_atraso:
	WORD ATRASO			; contador usado para gerar o atraso

evento_ativo:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo boneco que a interrupção ocorreu
evento_int_0:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo boneco que a interrupção ocorreu
evento_int_2:
	LOCK 0				; LOCK para a rotina de interrupção comunicar ao processo boneco que a interrupção ocorreu

tecla_premida:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; uma vez por cada tecla carregada
nenhuma_tecla_premida:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; uma vez por cada tecla carregada


DEF_ROVER:		; tabela que define o rover (cor, largura, altura, pixels)
	WORD	LARGURA_ROVER, ALTURA_ROVER
	WORD	0, 0, COR_ROVER, 0, 0
	WORD	COR_ROVER, 0, COR_ROVER, 0, COR_ROVER
	WORD	COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER
	WORD	0, COR_ROVER, 0, COR_ROVER, 0

DEF_METEORO_BOM:
	WORD	1
	WORD	DEF_METEORO_1
	WORD	DEF_METEORO_2
	WORD	DEF_METEORO_BOM_3
	WORD	DEF_METEORO_BOM_4
	WORD	DEF_METEORO_BOM_5

DEF_METEORO_MAU:
	WORD	1
	WORD	DEF_METEORO_1
	WORD	DEF_METEORO_2
	WORD	DEF_METEORO_MAU_3
	WORD	DEF_METEORO_MAU_4
	WORD	DEF_METEORO_MAU_5

DEF_METEORO_1:
	WORD	LARGURA_METEORO_1, ALTURA_METEORO_1
	WORD	COR_METEORO_INDISTINTO

DEF_METEORO_2:
	WORD	LARGURA_METEORO_2, ALTURA_METEORO_2
	WORD	COR_METEORO_INDISTINTO, COR_METEORO_INDISTINTO
	WORD	COR_METEORO_INDISTINTO, COR_METEORO_INDISTINTO

DEF_METEORO_BOM_3:
	WORD	LARGURA_METEORO_3, ALTURA_METEORO_3
	WORD	0, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, 0

DEF_METEORO_BOM_4:
	WORD	LARGURA_METEORO_4, ALTURA_METEORO_4
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, 0

DEF_METEORO_BOM_5:
	WORD	LARGURA_METEORO_5, ALTURA_METEORO_5
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, 0

DEF_METEORO_MAU_3:
	WORD	LARGURA_METEORO_3, ALTURA_METEORO_3
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU
	WORD	0, COR_METEORO_MAU, 0
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU

DEF_METEORO_MAU_4:
	WORD	LARGURA_METEORO_4, ALTURA_METEORO_4
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU
	WORD	0, COR_METEORO_MAU, COR_METEORO_MAU, 0
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU

DEF_METEORO_MAU_5:
	WORD	LARGURA_METEORO_5, ALTURA_METEORO_5
	WORD	COR_METEORO_MAU, 0, 0, 0, COR_METEORO_MAU
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU, 0, COR_METEORO_MAU
	WORD	0, COR_METEORO_MAU, COR_METEORO_MAU, COR_METEORO_MAU, 0
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU, 0, COR_METEORO_MAU
	WORD	COR_METEORO_MAU, 0, 0, 0, COR_METEORO_MAU


; ******************************************************************************
; * Programa principal
; ******************************************************************************
	PLACE   0000H						; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial					; inicializa SP para a palavra a seguir à última da pilha
	MOV  BTE, tab						; inicializa BTE (registo de Base da Tabela de Exceções)
	MOV  [APAGA_ECRÃS], R1				; apaga todos os pixels já desenhados
	MOV	 R1, 0							; cenário de fundo número 0
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo

	CALL controlo
	CALL teclado
	CALL energia
	CALL rover
	CALL meteoro
	EI0					; permite interrupções 0
	EI2					; permite interrupções 2
	EI					; permite interrupções (geral)

programa_principal:
	YIELD
	JMP programa_principal


; ******************************************************************************
; TECLADO - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
PROCESS SP_inicial_teclado		; indicação de que a rotina que se segue é um processo, com indicação do valor para inicializar o SP
teclado:
	MOV  R2, TEC_LIN   			; endereço do periférico das linhas
	MOV  R3, TEC_COL   			; endereço do periférico das colunas
	MOV  R4, 4					; para calcular o valor da tecla
	MOV  R5, MÁSCARA			; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

inicializa_teclado:
	MOV  R8, 0					; para processar a coluna
	MOV  R7, 3					; primeira linha a testar (de 0 a 3)
	MOV  R6, LINHA_4_TECLADO	; primeira linha a testar (identificação em binário)

ciclo_teclado:
	YIELD
	MOVB [R2], R6						; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      					; ler do periférico de entrada (colunas)
	AND  R0, R5							; elimina bits para além dos bits 0-3
	JNZ  processa_coluna				; se for detetada uma tecla, processa-a
	SUB  R7, 1							; linha acima da atual (de 0 a 3)
	SHR  R6, 1							; linha acima da atual (identificação em binário)
	JNZ  ciclo_teclado					; se houver linha acima, testa-a
	MOV	 [nenhuma_tecla_premida], R0	; informa quem estiver bloqueado neste LOCK que nenhuma tecla está a ser premida	
	JMP  inicializa_teclado 			; se não houver linha acima

processa_coluna:
	SHR  R0, 1				; o valor da coluna, de 0 a 3, é o número de shifts para
							; a direita que se fazem até este valor ser 0
	JZ   processa_tecla
	ADD  R8, 1				; contador (será o valor da coluna, de 0 a 3)
	JMP  processa_coluna

processa_tecla:	; o valor da tecla é igual a 4 * linha + coluna (linha e coluna entre 0 e 3)
	MOV  R0, R7
	MUL  R0, R4
	ADD  R0, R8	 				; valor da tecla premida
	MOV	 [tecla_premida], R0	; informa quem estiver bloqueado neste LOCK que uma tecla foi premida (e o seu valor)
	JMP  inicializa_teclado


; ******************************************************************************
; ENERGIA - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
PROCESS SP_inicial_energia		; indicação de que a rotina que se segue é um processo, com indicação do valor para inicializar o SP
energia:
	MOV  R2, [evento_ativo]

inicializa_energia:
	MOV  R0, ENERGIA_MÍNIMA
	MOV  R1, ENERGIA_MÁXIMA_DEC
	MOV  R11, ENERGIA_INICIAL 	; valor inicial da energia (em decimal)
	CALL mostra_energia			; mostra a energia do rover nos displays
	JMP  ciclo_energia

retorna_ativo_energia:
	MOV  R2, [evento_ativo]

ciclo_energia:
	MOV  R2, [evento_int_2] 	; lock

	MOV  R9, [estado]
	CMP  R9, 1
	JZ   retorna_ativo_energia  ; pausa
	CMP  R9, 2
	JZ   energia 				; parado

	MOV  R10, 0 				; variavel auxiliar
	ADD  R10, R11 				; variavel auxiliar
	ADD  R10, R2 				; variavel auxiliar

	CMP  R10, R1 				; energia máxima
	JGE  ciclo_energia
	CMP  R10, R0 				; energia mínima
	JLE  ciclo_energia

	MOV  R11, R10
	CALL mostra_energia
	JMP  ciclo_energia


; ******************************************************************************
; ROVER - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
PROCESS SP_inicial_rover		; indicação de que a rotina que se segue é um processo, com indicação do valor para inicializar o SP
rover:
	MOV  R1, [evento_ativo]

inicializa_rover:
	MOV  R1, 0
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 0
    MOV  R1, LINHA_ROVER	  	; linha do rover
	MOV  R2, COLUNA_ROVER	  	; coluna do rover
	MOV	 R4, DEF_ROVER		  	; endereço da tabela que define o rover
	CALL desenha_boneco			; desenha o rover a partir da tabela
	JMP  espera_tecla_movimentação

retorna_ativo_rover:
	MOV  R3, [evento_ativo]

espera_tecla_movimentação:
	MOV  R0, [tecla_premida]

	MOV  R3, [estado]
	CMP  R3, 1 					; pausa
	JZ   retorna_ativo_rover
	CMP  R3, 2 					; parado
	JZ   rover

	CMP	 R0, TECLA_0			; se a tecla 0 for premida, move o rover para a esquerda
	JZ	 move_rover_esquerda
	CMP	 R0, TECLA_2			; se a tecla 2 for premida, move o rover para a direita
	JZ   move_rover_direita
	JMP  espera_tecla_movimentação

move_rover_esquerda:
	MOV	 R7, -1					; o rover vai-se deslocar para a esquerda (coluna anterior)
	JMP	 ve_limites_horizontal

move_rover_direita:
	MOV	 R7, +1					; o rover vai-se deslocar para a direita (coluna seguinte)

ve_limites_horizontal:
	CALL testa_limites_horizontal	; vê se chegou aos limites do ecrã e, se sim, força R7 a 0
	CMP	 R7, 0						; se R7 estiver a 0, não é para mover o rover
	JZ	 espera_tecla_movimentação  ; se não é para mover o rover, espera pela próxima tecla
	CALL move_rover
	JMP  espera_tecla_movimentação


; ******************************************************************************
; METEORO - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
PROCESS SP_inicial_meteoro		; indicação de que a rotina que se segue é um processo, com indicação do valor para inicializar o SP
meteoro:
	MOV  R1, [evento_ativo]
	MOV  R9, 8

inicializa_meteoro:
	MOV  R1, 1
	MOV  [SELECIONA_ECRÃ], R1   ; seleciona ecrã 1
	CALL meteoro_aleatório 		; R3
	MOV  [R3], R1
	MOV  R1, LINHA_METEORO		; linha do meteoro
	CALL coluna_aleatória 		; R2
	MOV	 R4, [R3+2]				; endereço da tabela que define o meteoro
	CALL desenha_boneco			; desenha o meteoro a partir da tabela
	MOV  R10, 2
	JMP  espera_evento

retorna_ativo_meteoro:
	MOV  R0, [evento_ativo]

espera_evento:
	MOV  R0, [evento_int_0]

	MOV  R0, [estado]
	CMP  R0, 1 					; pausa
	JZ   retorna_ativo_meteoro
	CMP  R0, 2 					; parado
	JZ   meteoro

move_meteoro_baixo:
	ADD  R1, 1					; se é para mover o meteoro, incrementa a sua linha
	MOV  R11, 32
	MOD  R1, R11
	JZ   espera_meteoro

	MOV  R0, R3
	MOV  R5, [R0]
	MOV  R6, 5
	CMP  R5, R6
	JZ   chama_move_meteoro
	ADD  R5, 1
	MOV  [R0], R5
chama_move_meteoro:
	MOV  R6, 2
	MUL  R5, R6
	MOV  R4, [R0+R5]
	CALL move_meteoro
	JMP  espera_evento			; espera até a tecla deixar de ser premida

espera_meteoro:
	MOV  R11, 1 				; ecrã do meteoro
	MOV  [APAGA_ECRÃ], R11 		; apaga o meteoro
	MOV  R0, [evento_int_0]
	SUB  R10, 1
	JNZ  espera_meteoro
	MOV  R10, 2
	CALL coluna_aleatória
	CALL meteoro_aleatório 		; R3
	MOV  [R3], R11
	MOV	 R4, [R3+2]				; endereço da tabela que define o meteoro
	CALL move_meteoro
	JMP  espera_evento			; espera até a tecla deixar de ser premida


; ******************************************************************************
; CONTROLO - Lê as teclas do teclado e retorna o valor da tecla premida.
;
; Retorna: 		R0 - valor da tecla premida;
;					 se não for premida nenhuma tecla, o valor é forçado a -1
;
; ******************************************************************************
PROCESS SP_inicial_controlo		; indicação de que a rotina que se segue é um processo, com indicação do valor para inicializar o SP
controlo:
inicializa_controlo:
	MOV	 R0, 1								; cenário número 0
	MOV  [SELECIONA_CENARIO_FRONTAL], R0	; seleciona o cenário frontal

ciclo_inicio:
	MOV  R1, [tecla_premida]
	MOV  R2, TECLA_C
	CMP  R1, R2
	JNZ  ciclo_inicio
	MOV  R0, 0
	MOV  [estado], R0
	MOV  [evento_ativo], R1
	MOV  [APAGA_CENARIO_FRONTAL], R1

espera_pausa:
	MOV  R1, [tecla_premida]
	MOV  R2, TECLA_D
	CMP  R1, R2
	JNZ  espera_pausa
	MOV  R0, 1
	MOV  [estado], R0

	;MOV	 R0, 0								; cenário número 0
	;MOV  [ESCONDE_ECRÃ], R0
	;MOV	 R0, 1								; cenário número 0
	;MOV  [ESCONDE_ECRÃ], R0
	;MOV	 R0, 1								; cenário número 0
	;MOV  [SELECIONA_CENARIO_FRONTAL], R0		; seleciona o cenário frontal

	MOV  R1, [nenhuma_tecla_premida]

ciclo_pausa:
	MOV  R1, [tecla_premida]
	MOV  R2, TECLA_D
	CMP  R1, R2
	JNZ  ciclo_pausa
	MOV  R0, 0
	MOV  [estado], R0
	MOV  [evento_ativo], R1

	;MOV  [APAGA_CENARIO_FRONTAL], R1
	;MOV	 R0, 0								; cenário número 0
	;MOV  [MOSTRA_ECRÃ], R0
	;MOV	 R0, 1								; cenário número 0
	;MOV  [MOSTRA_ECRÃ], R0

	MOV  R1, [nenhuma_tecla_premida]
	JMP  espera_pausa





















; **********************************************************************
; ROT_INT_0 -	Rotina de atendimento da interrupção 0
;			Faz a barra descer uma linha. A animação da barra é causada pela
;			invocação periódica desta rotina
; **********************************************************************
rot_int_0:
	MOV [evento_int_0], R0 	; R0 irrelevante
	RFE						; Return From Exception (diferente do RET)


; **********************************************************************
; ROT_INT_2 -	Rotina de atendimento da interrupção 2
;			Faz a barra descer uma linha. A animação da barra é causada pela
;			invocação periódica desta rotina
; **********************************************************************
rot_int_2:
	PUSH R0
	MOV R0, -5
	MOV [evento_int_2], R0
	POP R0
	RFE						; Return From Exception (diferente do RET)


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

	CALL testa_limites_vertical
	SUB  R6, R3

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


; **********************************************************************
; ATRASO - Faz ATRASO iterações, para implementar um atraso no tempo,
;		 de forma não bloqueante.
; Argumentos: Nenhum
; Saidas:		R10 - Se 0, o atraso chegou ao fim
; **********************************************************************
atraso:
	PUSH R0
	MOV  R10, [contador_atraso]	; obtém valor do contador do atraso
	SUB  R10, 1
	MOV  [contador_atraso], R10	; atualiza valor do contador do atraso
	JNZ  sai
	MOV  R0, ATRASO
	MOV  [contador_atraso], R0	; volta a colocar o valor inicial no contador do atraso
sai:
	POP  R0
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
; Argumentos:	R1 - linha em que o boneco está
; 				R6 - 
;
; Retorna: 		R3 - 1, caso o boneco não tenha chegado aos limites do ecrã;
;					 0, caso contrário
;
; ******************************************************************************
testa_limites_vertical:
	PUSH R0

	MOV  R3, R6						; impede o movimento, forçando R3 a 0
	MOV  R0, MAX_LINHA
	ADD  R0, 1
	SUB  R0, R1
	SUB  R3, R0
	CMP  R3, 0
	JGT  sai_testa_limites_vertical
	MOV  R3, 0

sai_testa_limites_vertical:
	POP  R0
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
	PUSH R11
	CALL atraso 			; ciclo para implementar um atraso
	CMP  R10, 0             ; tempo de espera chegou ao fim?
	JNZ  sai_move_rover
	MOV  R10, 0 			; ecrã do rover
	MOV  [APAGA_ECRÃ], R10  ; apaga o rover
	ADD	 R2, R7				; para desenhar o rover na coluna pretendida (à esquerda ou à direita)
	CALL desenha_boneco 	; desenha o rover a partir da tabela
sai_move_rover:
	POP  R11
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
	PUSH R11

	MOV  R11, 1 				; ecrã do meteoro
	MOV  [APAGA_ECRÃ], R11 		; apaga o meteoro
	MOV  [SELECIONA_ECRÃ], R11  ; seleciona o ecrã do meteoro

	CALL desenha_boneco			; desenha o meteoro a partir da tabela
	;MOV  [TOCA_SOM], R11		; comando para tocar o som do meteoro
	MOV  R11, 0
	MOV  [SELECIONA_ECRÃ], R11  ; seleciona o ecrã do rover

	POP  R11
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


; ******************************************************************************
; VALOR_ALEATÓRIO - Escreve um pixel na linha e coluna indicadas.
;
; Argumentos:	R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
;				R2
; ******************************************************************************
valor_aleatório:
	PUSH R0
    MOV  R0, TEC_COL   ; endereço do periférico das colunas
    MOVB R2, [R0]      ; ler do periférico de entrada (colunas)
    SHR  R2, 5
    POP  R0
    RET


; ******************************************************************************
; VALOR_ALEATÓRIO - Escreve um pixel na linha e coluna indicadas.
;
; Argumentos:	R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
;				R2
; ******************************************************************************
coluna_aleatória:
	PUSH R0
	PUSH R1

	MOV  R0, 8
	CALL valor_aleatório
	MUL  R2, R0
	MOV  R1, R2 	
	CALL valor_aleatório
	MOV  R0, 4
	MOD  R2, R0
	ADD  R2, R1		

    POP  R1
    POP  R0
    RET


; ******************************************************************************
; VALOR_ALEATÓRIO - Escreve um pixel na linha e coluna indicadas.
;
; Argumentos:	R1 - linha
;               R2 - coluna
;               R3 - cor do pixel (em formato ARGB de 16 bits)
;
;				R3
; ******************************************************************************
meteoro_aleatório:
	PUSH R2
	CALL valor_aleatório
	CMP  R2, 1
	JGT  meteoro_mau 

meteoro_bom:
	MOV  R3, DEF_METEORO_BOM
	JMP  sai_meteoro_aleatório

meteoro_mau:
	MOV  R3, DEF_METEORO_MAU

sai_meteoro_aleatório:
    POP  R2
    RET
