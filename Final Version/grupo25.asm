; ******************************************************************************
; Projeto - Versão Final - 18/06/2022
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
; Tecla 0 - Movimenta o rover para a esquerda
; Tecla 1 - Dispara o míssil
; Tecla 2 - Movimenta o rover para a direita
; Tecla C - Começa o jogo
; Tecla D - Suspende/continua o jogo
; Tecla E - Termina o jogo
; ******************************************************************************


; ******************************************************************************
; * Constantes
; ******************************************************************************
DISPLAYS   			EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)

TECLA_0				EQU 0H		; tecla 0
TECLA_1				EQU 1H		; tecla 1
TECLA_2				EQU 2H		; tecla 2
TECLA_C				EQU 0CH		; tecla C
TECLA_D				EQU 0DH		; tecla D
TECLA_E				EQU 0EH		; tecla E
MÁSCARA				EQU 0FH		; para isolar os 4 bits de menor peso

LINHA_4_TECLADO_DEC	EQU 3 		; linha 4 do teclado de 0 a 3 (primeira a testar)
LINHA_4_TECLADO_BIN	EQU 1000b	; linha 4 do teclado em binário (primeira a testar)
MIN_LINHA			EQU 0 		; número da linha mais acima que um objeto pode ocupar
LINHAS 				EQU 32 		; número total de linhas no ecrã
MIN_COLUNA			EQU 0		; número da coluna mais à esquerda que um objeto pode ocupar
MAX_COLUNA			EQU 63     	; número da coluna mais à direita que um objeto pode ocupar
ATRASO				EQU	10H		; atraso para limitar a velocidade do movimento de um objeto
ATRASO_METEOROS 	EQU 6H 		; atraso para sequenciar a aparição dos meteoros

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

LARGURA_METEORO_1		EQU	1		; largura dos meteoros do primeiro tamanho
ALTURA_METEORO_1		EQU 1		; altura dos meteoros do primeiro tamanho
LARGURA_METEORO_2		EQU	2		; largura dos meteoros do segundo tamanho
ALTURA_METEORO_2		EQU 2		; altura dos meteoros do segundo tamanho
LARGURA_METEORO_3		EQU	3		; largura dos meteoros do terceiro tamanho
ALTURA_METEORO_3		EQU 3		; altura dos meteoros do terceiro tamanho
LARGURA_METEORO_4		EQU	4		; largura dos meteoros do quarto tamanho
ALTURA_METEORO_4		EQU 4		; altura dos meteoros do quarto tamanho
LARGURA_METEORO_5		EQU	5		; largura dos meteoros do quinto tamanho
ALTURA_METEORO_5		EQU 5		; altura dos meteoros do quinto tamanho
COR_METEORO_INDISTINTO 	EQU 08FFFH	; cor dos meteoros dos dois tamanhos iniciais: cinzento transparente em ARGB
COR_METEORO_BOM			EQU 0F0F0H	; cor dos meteoros bons: verde em ARGB
COR_METEORO_MAU			EQU 0FF00H	; cor dos meteoros maus: vermelho em ARGB
METEOROS 				EQU 4 		; número de meteoros a utilizar no jogo
AUMENTOS 				EQU 4 		; número de vezes que os meteoros aumentam de tamanho
AUM_TAMANHO 			EQU 3 		; número de movimentos do meteoro até aumentar de tamanho

HÁ_COLISÃO 				EQU 1 		; indica que ocorreu uma colisão
SEM_COLISÃO 			EQU 0 		; indica que não ocorreu colisão

LARGURA_EXPLOSÃO	EQU	5			; largura do efeito de explosão
ALTURA_EXPLOSÃO		EQU 5			; altura do efeito de explosão
COR_EXPLOSÃO		EQU 0F0FFH		; cor dos efeitos de explosão: azul claro em ARGB
ATRASO_EXPLOSÃO		EQU 7 			; atraso para apagar a explosão

COR_MÍSSIL			EQU 0FC0CH		; cor dos mísseis: roxo em ARGB
LINHA_MÍSSIL 		EQU 27 			; linha inicial do míssil
SEM_MISSIL 			EQU -1 			; indica que não existe míssil
DISTÂNCIA_MÍSSIL	EQU 12 			; distância que o míssil navega

ENERGIA_INICIAL		EQU 100		; valor inicial da energia (em decimal)
ENERGIA_MÍNIMA  	EQU 0    	; valor mínimo de energia (em decimal)
ENERGIA_MÁXIMA_DEC	EQU 100 	; valor máximo de energia (em decimal)
ENERGIA_MÁXIMA_HEX	EQU 100H 	; valor máximo de energia (representação em hexadecimal do valor em decimal)

; variações da energia
DIM_ENERGIA_TEMPO 	EQU -5 		; diminuição periódica de energia do rover
DIM_ENERGIA_MÍSSIL	EQU -5 		; diminuição da energia no disparo de um míssil
AUM_ENERGIA_MÍSSIL	EQU 5 		; aumento da energia na colisão do míssil com um meteoro mau
AUM_ENERGIA_METEORO	EQU 10 		; aumento da energia na colisão do rover com um meteoro bom

; cenários
CEN_ESPAÇO 		EQU 0 ; cenário de fundo
CEN_INÍCIO 		EQU 1 ; início
CEN_PAUSA 		EQU 2 ; pausa
CEN_TERMINADO	EQU 3 ; jogo terminado pelo utilizador (game over)
CEN_COLISÃO 	EQU 4 ; rover colidiu (game over)
CEN_ENERGIA 	EQU 5 ; rover ficou sem energia (game over)

; sons
SOM_DISPARO 	EQU 0 ; som de disparo do míssil
SOM_EXPLOSÃO 	EQU 1 ; som de explosão e de game over, quando o rover colide com um meteoro mau
SOM_ENERGIA		EQU 2 ; som do aumento de energia proveniente da colisão do rover com um meteoro bom
SOM_SEM_ENERGIA	EQU 3 ; som de game over, quando o rover fica sem energia

; valores que podem ser tomados pela variável "estado"
ESTADO_ATIVO 	EQU 0
ESTADO_PAUSA	EQU 1
ESTADO_PARADO	EQU 2

; ecrãs (os ecrãs de cada meteoro estão no registo R11 do respetivo processo)
ECRÃ_ROVER 		EQU 4
ECRÃ_MÍSSIL 	EQU 5


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

	STACK 100H			; espaço reservado para a pilha da primeira instância do processo "meteoro"
SP_inicial_meteoro_0:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha da segunda instância do processo "meteoro"
SP_inicial_meteoro_1:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha da terceira instância do processo "meteoro"
SP_inicial_meteoro_2:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha da quarta instância do processo "meteoro"
SP_inicial_meteoro_3:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "controlo"
SP_inicial_controlo:	; este é o endereço com que o SP deste processo deve ser inicializado

	STACK 100H			; espaço reservado para a pilha do processo "míssil"
SP_inicial_míssil:		; este é o endereço com que o SP deste processo deve ser inicializado


; tabela com os SP iniciais das instâncias do processo "meteoro"
meteoro_SP_tab:
	WORD	SP_inicial_meteoro_0
	WORD	SP_inicial_meteoro_1
	WORD	SP_inicial_meteoro_2
	WORD	SP_inicial_meteoro_3


; Tabela das rotinas de interrupção
tab_rotinas_interrupção:
	WORD rot_int_0		; rotina de atendimento da interrupção 0
	WORD rot_int_1		; rotina de atendimento da interrupção 1
	WORD rot_int_2		; rotina de atendimento da interrupção 2
	WORD 0

estado:
	WORD ESTADO_PARADO

contador_atraso:
	WORD ATRASO				; contador usado para gerar o atraso

colisão_míssil:
	WORD SEM_COLISÃO		; inicialmente, não há colisão

cenario_jogo: 				; toma valores de cenários do jogo
	WORD 0


evento_ativo:
	LOCK 0 					; LOCK para os processos voltarem ao ativo

evento_int_0: 				; 0 (mover o rover e testar colisões); 1 (apenas testar colisões)
	LOCK 0					; LOCK para a rotina de interrupção comunicar ao processo "meteoro" que a
							; interrupção ocorreu

evento_int_1: 			
	LOCK 0					; LOCK para a rotina de interrupção comunicar ao processo "míssil" que a
							; interrupção ocorreu

evento_int_2: 				; tem o valor da variação da energia
	LOCK 0					; LOCK para a rotina de interrupção comunicar ao processo "energia" que a
							; interrupção ocorreu


tecla_premida:
	LOCK 0					; LOCK para o teclado comunicar aos restantes processos que tecla 
							; detetou, uma vez por cada tecla carregada
tecla_continuo:
	LOCK 0					; LOCK para o teclado comunicar aos restantes processos que tecla
							; detetou, continuamente

coluna_rover:				; coluna do rover (apenas a coluna é relevante, pois a linha é constante)
	WORD	COLUNA_ROVER	; coluna inicial

posição_míssil:				; inicalmente, não há nenhum míssil
	WORD	SEM_MISSIL		; linha inicial do míssil
	WORD	SEM_MISSIL		; coluna inicial do míssil


DEF_ROVER:			; tabela que define o rover (cor, largura, altura, pixels)
	WORD	LARGURA_ROVER, ALTURA_ROVER
	WORD	0, 0, COR_ROVER, 0, 0
	WORD	COR_ROVER, 0, COR_ROVER, 0, COR_ROVER
	WORD	COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER, COR_ROVER
	WORD	0, COR_ROVER, 0, COR_ROVER, 0

DEF_EXPLOSÃO:		; tabela que define o rover (cor, largura, altura, pixels)
	WORD	LARGURA_EXPLOSÃO, ALTURA_EXPLOSÃO
	WORD	0, COR_EXPLOSÃO, 0, COR_EXPLOSÃO, 0
	WORD	COR_EXPLOSÃO, 0, COR_EXPLOSÃO, 0, COR_EXPLOSÃO
	WORD	0, COR_EXPLOSÃO, 0, COR_EXPLOSÃO, 0
	WORD	COR_EXPLOSÃO, 0, COR_EXPLOSÃO, 0, COR_EXPLOSÃO
	WORD	0, COR_EXPLOSÃO, 0, COR_EXPLOSÃO, 0

DEF_METEORO_BOM:	; tabela das tabelas que definem os meteoros bons
	WORD	DEF_METEORO_1
	WORD	DEF_METEORO_2
	WORD	DEF_METEORO_BOM_3
	WORD	DEF_METEORO_BOM_4
	WORD	DEF_METEORO_BOM_5

DEF_METEORO_MAU:	; tabela das tabelas que definem os meteoros maus
	WORD	DEF_METEORO_1
	WORD	DEF_METEORO_2
	WORD	DEF_METEORO_MAU_3
	WORD	DEF_METEORO_MAU_4
	WORD	DEF_METEORO_MAU_5

DEF_METEORO_1:		; tabela que define os meteoros do primeiro tamanho
	WORD	LARGURA_METEORO_1, ALTURA_METEORO_1
	WORD	COR_METEORO_INDISTINTO

DEF_METEORO_2:		; tabela que define os meteoros do segundo tamanho
	WORD	LARGURA_METEORO_2, ALTURA_METEORO_2
	WORD	COR_METEORO_INDISTINTO, COR_METEORO_INDISTINTO
	WORD	COR_METEORO_INDISTINTO, COR_METEORO_INDISTINTO

DEF_METEORO_BOM_3:	; tabela que define os meteoros bons do terceiro tamanho
	WORD	LARGURA_METEORO_3, ALTURA_METEORO_3
	WORD	0, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, 0

DEF_METEORO_BOM_4:	; tabela que define os meteoros bons do quarto tamanho
	WORD	LARGURA_METEORO_4, ALTURA_METEORO_4
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, 0

DEF_METEORO_BOM_5:	; tabela que define os meteoros bons do quinto tamanho
	WORD	LARGURA_METEORO_5, ALTURA_METEORO_5
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, 0
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM
	WORD	0, COR_METEORO_BOM, COR_METEORO_BOM, COR_METEORO_BOM, 0

DEF_METEORO_MAU_3:	; tabela que define os meteoros maus do terceiro tamanho
	WORD	LARGURA_METEORO_3, ALTURA_METEORO_3
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU
	WORD	0, COR_METEORO_MAU, 0
	WORD	COR_METEORO_MAU, 0, COR_METEORO_MAU

DEF_METEORO_MAU_4:	; tabela que define os meteoros maus do quarto tamanho
	WORD	LARGURA_METEORO_4, ALTURA_METEORO_4
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU
	WORD	0, COR_METEORO_MAU, COR_METEORO_MAU, 0
	WORD	COR_METEORO_MAU, 0, 0, COR_METEORO_MAU

DEF_METEORO_MAU_5:	; tabela que define os meteoros maus do quinto tamanho
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
	MOV  BTE, tab_rotinas_interrupção	; inicializa BTE (registo de Base da Tabela de Exceções)
	MOV  [APAGA_ECRÃS], R1				; apaga todos os pixels já desenhados
	MOV  R1, CEN_ESPAÇO
	MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
	MOV  R1, CEN_INÍCIO
	MOV  [cenario_jogo], R1 			; cenário inicial

	MOV  R11, ENERGIA_MÁXIMA_DEC
	CALL mostra_energia 				; mostra a energia máxima nos displays

	CALL teclado 						; inicializa o processo "teclado"
	CALL controlo 						; inicializa o processo "controlo"
	CALL rover 							; inicializa o processo "rover"
	CALL míssil 						; inicializa o processo "míssil"

	MOV  R11, METEOROS
loop_meteoros:							; ciclo para inicializar todas as instâncias do processo "meteoro"
	DEC  R11
	CALL meteoro
	CMP  R11, 0
	JNZ  loop_meteoros

	CALL energia 						; inicializa o processo "energia"

	EI0 								; permite interrupções 0
	EI1									; permite interrupções 1
	EI2									; permite interrupções 2
	EI									; permite interrupções (geral)

programa_principal:
	YIELD
	JMP  programa_principal


; ******************************************************************************
; PROCESSO CONTROLO - Trata das teclas de começar, suspender/continuar e
; 					  terminar o jogo.
;
; ******************************************************************************
PROCESS SP_inicial_controlo		; indicação de que a rotina que se segue é um processo,
								; com indicação do valor para inicializar o SP
controlo:
	MOV  R0, [cenario_jogo]
	CMP  R0, CEN_TERMINADO 					; se o valor da variável cenario_jogo for igual ou
											; superior a CEN_TERMINADO, o jogo acabou
	JGE  game_over
	MOV  [SELECIONA_CENARIO_FRONTAL], R0	; caso contrário, é o início do jogo,
											; e a variável tem o valor 1
	JMP  ciclo_inicio

game_over:
	MOV  R0, [cenario_jogo]
	MOV  [SELECIONA_CENARIO_FRONTAL], R0	; seleciona o respetivo cenário frontal de "game over"

ciclo_inicio:
	MOV  R1, [tecla_premida]				; espera que seja detetada uma tecla
	MOV  R2, TECLA_C 						; tecla C
	CMP  R1, R2 							; verifica se foi detetada a tecla C
	JNE  ciclo_inicio						; o jogo só começa quando for detetada a tecla C
	MOV  R0, CEN_TERMINADO					; a menos que o rover exploda ou fique sem energia,
											; o próximo cenário vai ser o de jogo terminado		
	MOV  [cenario_jogo], R0
	MOV  R0, ESTADO_ATIVO
	MOV  [estado], R0
	MOV  [evento_ativo], R1
	MOV  [APAGA_CENARIO_FRONTAL], R1 		; apaga o cenário frontal

espera_pausa:								; espera que o jogo entre em pausa ou termine
	MOV  R1, [tecla_premida]				; espera que seja detetada uma tecla
	MOV  R2, TECLA_D 						; tecla D
	CMP  R1, R2
	JZ   ciclo_pausa 						; se for premida a tecla D, o jogo entra em pausa
	MOV  R2, TECLA_E 						; tecla E
	CMP  R1, R2
	JZ   ciclo_parado 						; se for premida a tecla E, o jogo é terminado
	JMP  espera_pausa

ciclo_pausa:
	MOV	 R0, CEN_PAUSA							
	MOV  [SELECIONA_CENARIO_FRONTAL], R0	; seleciona o cenário frontal da pausa

	MOV  R0, ESTADO_PAUSA
	MOV  [estado], R0
	MOV  R1, [tecla_premida]				; espera que seja detetada uma tecla
	MOV  R2, TECLA_D 						; tecla D
	CMP  R1, R2
	JZ   sai_ciclo_pausa					; se for premida a tecla D, o jogo sai da pausa
	MOV  R2, TECLA_E 						; tecla E
	CMP  R1, R2
	JZ   ciclo_parado						; se for premida a tecla E, o jogo é terminado
	JMP  ciclo_pausa
sai_ciclo_pausa:
	MOV  R0, ESTADO_ATIVO
	MOV  [estado], R0
	MOV  [evento_ativo], R1

	MOV  R1, 2
	MOV  [APAGA_CENARIO_FRONTAL], R1 		; apaga o cenário frontal

	JMP  espera_pausa						; ao sair da pausa, volta a esperar
											; que o jogo entre em pausa ou termine

ciclo_parado:							; termina o jogo
	MOV  R0, ESTADO_PARADO
	MOV  [estado], R0
	MOV  [evento_ativo], R1
	MOV  [APAGA_ECRÃS], R1				; apaga todos os pixels já desenhados
	MOV  [tecla_continuo], R1 			; informa o processo "rover" de que o jogo
										; foi terminado, e, portanto, é preciso reiniciar o rover
	MOV  [evento_int_0], R1 			; como a variável "estado" indica que o jogo está parado,
										; o processo "meteoro" prepara-se para reiniciar os meteoros
	MOV  [evento_int_1], R1 			; como a variável "estado" indica que o jogo está parado,
										; o processo "míssil" apaga o míssil, se o houver
	MOV  [evento_int_2], R1				; como a variável "estado" indica que o jogo está parado,
										; o processo "energia" mantém a energia e fica à espera do início do novo jogo
	JMP  controlo 						; volta a esperar que a variável cenario_jogo fique a 1 (início do jogo)


; ******************************************************************************
; PROCESSO TECLADO - Varre e lê as teclas do teclado.
;
; ******************************************************************************
PROCESS SP_inicial_teclado			; indicação de que a rotina que se segue é um processo,
									; com indicação do valor para inicializar o SP
teclado:
	MOV  R2, TEC_LIN   				; endereço do periférico das linhas
	MOV  R3, TEC_COL   				; endereço do periférico das colunas
	MOV  R4, 4						; para calcular o valor da tecla, de acordo com a fórmula
	MOV  R5, MÁSCARA				; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

inicializa_teclado:
	MOV  R8, 0						; para processar a coluna
	MOV  R7, LINHA_4_TECLADO_DEC	; primeira linha a testar (de 0 a 3)
	MOV  R6, LINHA_4_TECLADO_BIN	; primeira linha a testar (identificação em binário)

ciclo_teclado:
	YIELD
	MOVB [R2], R6					; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      				; ler do periférico de entrada (colunas)
	AND  R0, R5						; elimina bits para além dos bits 0-3
	MOV  R9, R0
	JNZ  processa_coluna			; se for detetada uma tecla, processa-a
	DEC  R7							; linha acima da atual (de 0 a 3)
	SHR  R6, 1						; linha acima da atual (identificação em binário)
	JNZ  ciclo_teclado				; se houver linha acima, testa-a
	JMP  inicializa_teclado 		; se não houver linha acima

processa_coluna:
	SHR  R9, 1						; o valor da coluna, de 0 a 3, é o número de shifts para
									; a direita que se fazem até este valor ser 0
	JZ   processa_tecla
	INC  R8							; contador (será o valor da coluna, de 0 a 3)
	JMP  processa_coluna

processa_tecla:						; o valor da tecla é igual a 4 * linha + coluna (linha e coluna entre 0 e 3)
	MOV  R9, R7
	MUL  R9, R4
	ADD  R9, R8	 					; valor da tecla premida
	MOV	 [tecla_premida], R9		; informa quem estiver bloqueado neste LOCK
									; que uma tecla foi premida (e o seu valor)

ha_tecla: 							; neste ciclo espera-se até NENHUMA tecla estar premida
	YIELD
	MOV	[tecla_continuo], R9		; informa quem estiver bloqueado neste LOCK
									; que uma tecla está a ser carregada
	MOVB [R2], R6					; escrever no periférico de saída (linhas)
	MOVB R0, [R3]      				; ler do periférico de entrada (colunas)
	AND  R0, R5						; elimina bits para além dos bits 0-3
    CMP  R0, 0						; há tecla premida?
    JNZ  ha_tecla					; se ainda houver uma tecla premida, espera até não haver
    JMP  inicializa_teclado


; ******************************************************************************
; PROCESSO ROVER - Controla o movimento do rover.
;
; ******************************************************************************
PROCESS SP_inicial_rover			; indicação de que a rotina que se segue é um processo,
									; com indicação do valor para inicializar o SP
rover:
	MOV  R1, [evento_ativo]
	MOV  R1, CEN_COLISÃO
	MOV  [SELECIONA_ECRÃ], R1   	; seleciona ecrã do rover
    MOV  R1, LINHA_ROVER	  		; linha do rover
	MOV  R2, COLUNA_ROVER	  		; coluna inicial do rover
	MOV	 R4, DEF_ROVER		  		; endereço da tabela que define o rover
	MOV  [coluna_rover], R2 		; coluna do rover reposta para a inicial
	CALL desenha_boneco				; desenha o rover a partir da tabela
	JMP  espera_tecla_movimentação	; espera que seja premida uma tecla de movimento do rover

retorna_ativo_rover:
	MOV  R3, [evento_ativo]
	MOV  R3, [estado]
	CMP  R3, ESTADO_PAUSA
	JZ   retorna_ativo_rover
	CMP  R3, ESTADO_PARADO
	JZ   rover

espera_tecla_movimentação:
	MOV  R0, [tecla_continuo] 		; espera que seja detetada uma tecla

	MOV  R3, [estado]
	CMP  R3, ESTADO_PAUSA
	JZ   retorna_ativo_rover
	CMP  R3, ESTADO_PARADO
	JZ   rover

	CMP	 R0, TECLA_0				; se a tecla 0 for premida, move o rover para a esquerda
	JZ	 move_rover_esquerda
	CMP	 R0, TECLA_2				; se a tecla 2 for premida, move o rover para a direita
	JZ   move_rover_direita
	JMP  espera_tecla_movimentação	; caso contrário, espera que seja premida uma tecla de movimento do rover

move_rover_esquerda:
	MOV	 R7, -1						; o rover vai-se deslocar para a esquerda (coluna anterior)
	JMP	 ve_limites_horizontal

move_rover_direita:
	MOV	 R7, +1						; o rover vai-se deslocar para a direita (coluna seguinte)

ve_limites_horizontal:
	CALL testa_limites_horizontal	; vê se chegou aos limites do ecrã e, se sim, força R7 a 0
	CMP	 R7, 0						; se R7 estiver a 0, não é para mover o rover
	JZ	 espera_tecla_movimentação  ; se não é para mover o rover, espera pela próxima tecla
	CALL move_rover 				; caso contrário, move o rover
	MOV  R0, 1
	MOV  [evento_int_0], R0 		; sempre que o rover se move, o processo "meteoro" verifica se houve colisão
	YIELD
	JMP  espera_tecla_movimentação 	; espera que seja premida uma tecla de movimento do rover


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
	MOV  R10, 4 			; ecrã do rover
	MOV  [APAGA_ECRÃ], R10  ; apaga o rover
	ADD	 R2, R7				; para desenhar o rover na coluna pretendida (à esquerda ou à direita)
	CALL desenha_boneco 	; desenha o rover a partir da tabela
	MOV  R10, coluna_rover
	MOV  [R10], R2 			; coluna do rover
sai_move_rover:
	POP  R11
	POP  R10
	RET


; ******************************************************************************
; ATRASO - Faz ATRASO iterações, para implementar um atraso no tempo,
;		   de forma não bloqueante.
;
; Retorna:		R10 - Se 0, o atraso chegou ao fim
;
; ******************************************************************************
atraso:
	PUSH R0
	MOV  R10, [contador_atraso]	; obtém valor do contador do atraso
	DEC  R10
	MOV  [contador_atraso], R10	; atualiza valor do contador do atraso
	JNZ  sai
	MOV  R0, ATRASO
	MOV  [contador_atraso], R0	; volta a colocar o valor inicial no contador do atraso
sai:
	POP  R0
	RET


; ******************************************************************************
; PROCESSO ENERGIA - Faz evoluir o valor da energia do rover de forma autónoma.
;
; ******************************************************************************
PROCESS SP_inicial_energia		; indicação de que a rotina que se segue é um processo,
								; com indicação do valor para inicializar o SP
energia:
	MOV  R2, [evento_ativo]

	MOV  R1, ENERGIA_MÁXIMA_DEC	; valor máximo de energia (em decimal)
	MOV  R11, ENERGIA_INICIAL 	; valor inicial da energia (em decimal)
	CALL mostra_energia			; caso contrário, mostra nos displays o valor atual da energia
	JMP  ciclo_energia

retorna_ativo_energia:
	MOV  R2, [evento_ativo] 	; espera que o jogo saia da pausa
								; (a variável LOCK "evento_ativo" é escrita)

	MOV  R9, [estado]
	CMP  R9, ESTADO_PAUSA
	JZ   retorna_ativo_energia
	CMP  R9, ESTADO_PARADO
	JZ   energia


ciclo_energia:
	MOV  R2, [evento_int_2] 	; espera que a variável "evento_int_2" seja
								; escrita pela interrupção ou por um processo
								; o seu valor é quanto se pretende variar a energia

	MOV  R9, [estado]
	CMP  R9, ESTADO_PAUSA
	JZ   retorna_ativo_energia
	CMP  R9, ESTADO_PARADO
	JZ   energia

	MOV  R10, R11 				; cópia da energia anterior
	ADD  R10, R2 				; nova energia (soma da anterior com a variação pretendida)

	CMP  R10, ENERGIA_MÍNIMA
	JLE  energia_zero			; caso a energia atual tenha chegado ao valor da energia mínima (ou menor)
	CMP  R10, R1 		
	JGT  superior_maxima		; caso a energia atual tenha superado o valor da energia máxima
	JMP  muda_energia	 		; caso contrário, o valor da energia é válido para continuar a jogar

superior_maxima:
	MOV  R10, R1 				; repõe o valor da energia atual para o máximo

muda_energia:
	MOV  R11, R10 				; R11 é o argumento da rotina com o valor da energia atual
	CALL mostra_energia 		; mostra a energia atual nos displays
	JMP  ciclo_energia 			; volta a esperar que a variável "evento_int_2" seja escrita

energia_zero: 					; a energia atual chegou ao valor da energia mínima (ou menor)
	MOV  R11, ENERGIA_MÍNIMA	; repõe o valor da energia atual para o mínimo
	CALL mostra_energia 		; mostra a energia atual nos displays

	MOV  R0, SOM_SEM_ENERGIA
	MOV  [TOCA_SOM], R0			; toca o som correspondente ao término do jogo por falta de energia
	MOV  R0, CEN_ENERGIA 		; o jogo terminou porque o rover ficou sem energia
	MOV  [cenario_jogo], R0 	; a variável "cenario_jogo" define qual o cenário frontal de "game over"
	MOV  R0, TECLA_E			; o jogo terminou, logo, é como se a tecla E tivesse sido premida
	MOV  [tecla_premida], R0 	; indica que o jogo terminou
	MOV  [tecla_continuo], R0	; indica que o jogo terminou

	YIELD
	JMP energia					; espera que o jogo recomece


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
; PROCESSO MÍSSIL - Controla o disparo e a evolução do míssil no espaço e
; 					alcance.
;
; ******************************************************************************
PROCESS SP_inicial_míssil			; indicação de que a rotina que se segue é um processo,
									; com indicação do valor para inicializar o SP
míssil:
	MOV  R1, [evento_ativo]
	MOV  R1, SEM_MISSIL 			; no início do jogo, não há míssil
	MOV  [posição_míssil], R1 		; atribuição da constante "SEM_MISSIL" à linha do míssil
	MOV  [posição_míssil+2], R1 	; atribuição da constante "SEM_MISSIL" à coluna do míssil
	MOV  R1, SEM_COLISÃO
	MOV  [colisão_míssil], R1 		; enquanto o míssil não for disparado, não houve colisão com um meteoro

inicializa_míssil:
	MOV  R0, [tecla_premida] 		; espera que seja detetada uma tecla
	MOV  R4, TECLA_1 				; tecla que dispara o míssil
	CMP  R0, R4
	JNZ  inicializa_míssil 			; enquanto não for detetada a tecla que dispara o míssil, continua à espera

	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   inicializa_míssil
	CMP  R0, ESTADO_PARADO
	JZ   míssil

	MOV  R0, DIM_ENERGIA_MÍSSIL 	; diminuição da energia no disparo de um míssil
	MOV  [evento_int_2], R0 		; comunica ao processo "energia" quanto se pretende variar a energia
	MOV  R5, coluna_rover 			; endereço da coluna do rover
	MOV  R1, LINHA_MÍSSIL 			; linha inicial do míssil
	MOV  R2, [R5] 					; coluna do rover
 	ADD  R2, 2 						; coluna do míssil (no centro do rover, ou seja,
									; duas colunas à direita da coluna do mesmo)
	MOV  R3, COR_MÍSSIL 			; cor do míssil
	MOV  R0, ECRÃ_MÍSSIL
	MOV  [SELECIONA_ECRÃ], R0   	; seleciona o ecrã do míssil
	CALL escreve_pixel 				; desenha o míssil
	MOV  R0, SOM_DISPARO
	MOV  [TOCA_SOM], R0				; comando para tocar o som do disparo do míssil
	MOV  R6, DISTÂNCIA_MÍSSIL		; distância que o míssil navegará, no sentido ascendente
	MOV  [posição_míssil], R1 		; atualiza a linha do míssil
	MOV  [posição_míssil+2], R2 	; atualiza a coluna do míssil
	JMP  ciclo_míssil 				; espera que ocorra a interrupção que manda mover o míssil

retorna_ativo_míssil:
	MOV  R0, [evento_ativo]
	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   retorna_ativo_míssil
	CMP  R0, ESTADO_PARADO
	JZ   míssil

ciclo_míssil:
	MOV  R0, [evento_int_1] 		; espera que ocorra a interrupção que manda mover o míssil

	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   retorna_ativo_míssil	
	CMP  R0, ESTADO_PARADO
	JZ   míssil

	MOV  R0, [colisão_míssil] 		; espera que a variável "colisão_míssil" seja escrita
	CMP  R0, 1 						; se houver colisão do míssil com um meteoro, este é apagado
	JZ   apaga_míssil

	DEC  R6 						; caso contrário, a sua distância por navegar é decrementada, visto que se move
	JZ   apaga_míssil 				; se já não deve navegar mais, é apagado
	MOV  R0, ECRÃ_MÍSSIL
	MOV  [APAGA_ECRÃ], R0  			; apaga o ecrã do míssil
	MOV  [SELECIONA_ECRÃ], R0   	; seleciona o ecrã do míssil
	DEC  R1 						; decrementa a linha do míssil, visto que se move para cima
	CALL escreve_pixel 				; desenha o míssil na nova posição

	MOV  [posição_míssil], R1 		; atualiza a linha do míssil
	MOV  [posição_míssil+2], R2 	; atualiza a coluna do míssil

	MOV  R9, 1
	MOV  [evento_int_0], R9 		; passa ao processo meteoro, que verifica se o míssil, na nova posição, colide

	JMP  ciclo_míssil 				; espera que ocorra a interrupção que manda mover o míssil

apaga_míssil:
	MOV  R0, ECRÃ_MÍSSIL
	MOV  [APAGA_ECRÃ], R0  			; seleciona o ecrã do míssil

	MOV  R0, 0
	MOV  [colisão_míssil], R0 		; o míssil é apagado, logo, não colide com nenhum meteoro

	MOV  R0, SEM_MISSIL				; o míssil é apagado, logo, a sua posição passa a indicá-lo
	MOV  [posição_míssil], R0
	MOV  [posição_míssil+2], R0

	JMP  inicializa_míssil 			; espera que seja disparado outro míssil


; ******************************************************************************
; PROCESSO METEORO - Controla as ações e evolução de cada um dos meteoros.
;
; ******************************************************************************
PROCESS SP_inicial_meteoro_0		; indicação de que a rotina que se segue é um processo,
									; com indicação do valor para inicializar o SP
meteoro:
	MOV  R10, R11					; cópia do número de instância do processo
	SHL  R10, 1						; multiplica por 2 porque as tabelas são de WORDS
	MOV  R9, meteoro_SP_tab			; tabela com os SPs iniciais das várias instâncias deste processo
	MOV	 SP, [R9+R10]				; re-inicializa SP deste processo, de acordo com o nº de instância
									; NOTA - cada processo tem a sua cópia própria do SP

	MOV  R1, [evento_ativo]
	MOV  R10, ATRASO_METEOROS		; para que os meteoros não apareçam todos ao mesmo tempo, no início do jogo
	MUL  R10, R11					; valores de múltiplos sucessivos da constante
									; ATRASO_METEOROS para cada instância do processo, pelo
									; que os meteoros aparecem com intervalos constantes entre si
	INC  R10						; para garantir que R10 é positivo


espera_inicializa_meteoro:
	MOV  R0, [evento_int_0] 		; espera que a variável "evento_int_0" seja escrita
	CMP  R0, 0 						; se o seu valor não for 0, não foi escrita
									; pela interrupção, logo, espera até ser
	JNZ  espera_inicializa_meteoro

	; para que, caso o jogo seja pausado ou terminado antes de todos os meteoros
	; aparecerem, estes não apareçam nos ecrãs de pausa ou game over
	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   espera_inicializa_meteoro
	CMP  R0, ESTADO_PARADO
	JZ   meteoro

	DEC  R10
	JNZ  espera_inicializa_meteoro 	; espera R10 ciclos (valor diferente para cada instância do processo)

inicializa_meteoro:
	MOV  [SELECIONA_ECRÃ], R11  	; seleciona o ecrã do meteoro
	CALL meteoro_aleatório 			; atribui a R3 a tabela das tabelas que definem um tipo de meteoros
	MOV  R1, MIN_LINHA				; linha inicial do meteoro
	CALL coluna_aleatória 			; atribui a R2 um valor para a coluna do meteoro
	MOV	 R4, [R3]					; endereço da tabela que define o meteoro de tamanho 1
	CALL desenha_boneco				; desenha o meteoro
	MOV  R5, 0 						; índice para acessar as tabelas dos meteoros dos tamanhos seguintes
	MOV  R7, AUM_TAMANHO			; número de movimentos do meteoro antes de aumentar de tamanho
	JMP  espera_evento 				

retorna_ativo_meteoro:
	MOV  R0, [evento_ativo]

	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   retorna_ativo_meteoro
	CMP  R0, ESTADO_PARADO
	JZ   meteoro

espera_evento:
	MOV  R9, [evento_int_0] 		; espera que a variável "evento_int_0" seja escrita

	MOV  R0, [estado]
	CMP  R0, ESTADO_PAUSA
	JZ   retorna_ativo_meteoro
	CMP  R0, ESTADO_PARADO
	JZ   meteoro

	JMP  deteta_colisoes 			; ao chegar aqui, R0 é ESTADO_ATIVO, logo, haverá um JZ para "ciclo_espera_evento"

ciclo_espera_evento:
	CMP  R9, 1 						; se a variável "evento_int_0" estiver a 1 , significa que não
									; foi escrita pela rotina de interrupção, logo, não é para mover o meteoro
	JEQ   espera_evento 			; espera que a variável "evento_int_0" seja escrita

move_meteoro_baixo:
	INC  R1							; se é para mover o meteoro, incrementa a sua linha
	MOV  R0, LINHAS					; número total de linhas no ecrã
	MOD  R1, R0 					; se o meteoro passar do limite do ecrã, a sua linha passa a 0
	JZ   apaga_meteoro 				; se tiver passado do limite do ecrã, não é aumentado nem movido, nem pode colidir

aumenta_tamanho:
	DEC  R7 						; menos um movimento até o meteoro aumentar de tamanho
	JNZ  chama_move_meteoro 		; enquanto não for zero, não aumenta de tamanho

	MOV  R6, AUMENTOS				; o meteoro aumenta de tamanho AUMENTOS vezes
	SHL  R6, 1 						; logo, ao endereço pode-se somar até 2*AUMENTOS, pois cada WORD tem 2 bytes
	CMP  R5, R6 					; se o valor a somar ao endereço já chegou ao máximo, não aumenta mais de tamanho
	JZ   chama_move_meteoro
	ADD  R5, 2						; para aumentar de tamanho, anda uma WORD (2 bytes) para a frente no endereço da tabela
	MOV  R4, [R3+R5] 				; endereço da nova tabela a utilizar
	MOV  R7, AUM_TAMANHO			; reposição do número de movimentos do meteoro antes de aumentar de tamanho

chama_move_meteoro:
	CALL move_meteoro 				; move o meteoro

deteta_colisoes:
	CALL deteta_colisão_míssil 		; verifica se o meteoro colidiu com um míssil
	CMP  R8, HÁ_COLISÃO 			; se R8 estiver a HÁ_COLISÃO, houve colisão
	JEQ  ciclo_colisão_míssil

	CALL deteta_colisão_rover 		; verifica se o meteoro colidiu com o rover
	CMP  R8, HÁ_COLISÃO 			; se R8 estiver a HÁ_COLISÃO, houve colisão
	JEQ  ciclo_colisão_rover

	CMP  R0, ESTADO_ATIVO
	JEQ   ciclo_espera_evento 		; se R0 for ESTADO_ATIVO, foi dado jump para o "deteta_colisoes" a partir
									; do "espera_evento", pelo que se volta para a continuação desse ciclo
	JMP  espera_evento				; caso contrário, veio do "chama_move_meteoro",
									; pelo que vai para o início do ciclo "espera_evento"

ciclo_colisão_rover:
	MOV  R5, DEF_METEORO_BOM_5 			
	CMP  R4, R5 					; verifica se a colisão foi com um meteoro bom
	JNE  ciclo_colisão_míssil 		; se foi com um meteoro mau, procede-se como se tivesse sido com um míssil
	MOV  R0, SOM_ENERGIA
	MOV  [TOCA_SOM], R0				; comando para tocar o som do aproveitamento da energia de um meteoro bom	
	JMP  apaga_meteoro 				; verifica se o jogo está em curso e apaga o meteoro

ciclo_colisão_míssil:
	MOV  R4, SEM_MISSIL 			; o míssil, se existir, é apagado, logo, a sua posição passa a indicá-lo
	MOV  [posição_míssil], R4
	MOV  [posição_míssil+2], R4

	MOV  [APAGA_ECRÃ], R11 			; apaga o meteoro
	MOV  [SELECIONA_ECRÃ], R11  	; seleciona o ecrã do meteoro
	MOV  R4, DEF_EXPLOSÃO 			; endereço da tabela da explosão
	CALL desenha_boneco 			; desenha a explosão
	MOV  R0, SOM_EXPLOSÃO
	MOV  [TOCA_SOM], R0				; comando para tocar o som da explosão
	MOV  R8, ATRASO_EXPLOSÃO		; constante de atraso da explosão

ciclo_espera_explosão:             	; espera para apagar a explosão
    YIELD

    MOV  R0, [estado]
    CMP  R0, ESTADO_PAUSA			; se o jogo estiver em pausa, espera que saia da pausa para apagar a explosão
    JZ   ciclo_espera_explosão
    CMP  R0, ESTADO_PARADO			; se o jogo for terminado pelo jogador, espera até que volte a estar em jogo
    JZ   meteoro 					

    MOV R0, [evento_int_1]         	; fica no ciclo até que a interrupção 1 seja chamada ATRASO_EXPLOSÃO vezes
    DEC  R8
    JNZ  ciclo_espera_explosão

apaga_meteoro:
	MOV  [APAGA_ECRÃ], R11 			; apaga o ecrã do meteoro
	MOV  R10, ATRASO_METEOROS		; atraso entre a desaparição do meteoro no fundo do ecrã e a aparição de um novo no topo
	JMP  espera_inicializa_meteoro


; ******************************************************************************
; VALOR_ALEATÓRIO - Gera um valor aleatório entre 0 e 7 a partir dos bits 7 a 5
;					provenientes da leitura do periférico PIN.
;
; Retorna:		R2 - Valor aleatório
; ******************************************************************************
valor_aleatório:
	PUSH R0
    MOV  R0, TEC_COL   ; endereço do periférico das colunas
    MOVB R2, [R0]      ; ler do periférico de entrada (colunas)
    SHR  R2, 5
    POP  R0
    RET


; ******************************************************************************
; COLUNA_ALEATÓRIA - Gera um valor aleatório para a coluna de um meteoro.
;
; Retorna:		R2 - Valor para a coluna
;
; ******************************************************************************
coluna_aleatória:
	PUSH R0
	PUSH R1

	MOV  R0, 8 				; número de colunas possíveis
	CALL valor_aleatório	; valor aleatório entre 0 e 7
	MUL  R2, R0 			; valor múltiplo de 8, para a coluna
	INC  R2 				; incremento no valor, para que os meteoros não fiquem no limite esquerdo

    POP  R1
    POP  R0
    RET


; ******************************************************************************
; METEORO_ALEATÓRIO - Decide se o próximo meteoro vai ser bom ou mau.
;
; Retorna:		R3 - Tabela das tabelas que definem os meteoros do tipo
;					 escolhido
;
; ******************************************************************************
meteoro_aleatório:
	PUSH R2
	CALL valor_aleatório		; valor aleatório entre 0 e 7
	CMP  R2, 1
	JGT  meteoro_mau 			; se o valor estiver entre 2 e 7 (6 possibilidades, 75%),
								; o meteoro será mau

meteoro_bom:
	MOV  R3, DEF_METEORO_BOM 	; caso contrário (2 possibilidades, 25%), o meteoro será bom
	JMP  sai_meteoro_aleatório

meteoro_mau:
	MOV  R3, DEF_METEORO_MAU

sai_meteoro_aleatório:
    POP  R2
    RET


; ******************************************************************************
; MOVE_METEORO - Apaga o meteoro da posição atual e desenha-o na nova posição
;
; Argumentos:	R8 - linha do meteoro
;               R9 - coluna do meteoro
;               R10 - tabela que define o meteoro
;
; ******************************************************************************
move_meteoro:
	MOV  [APAGA_ECRÃ], R11 		; apaga o meteoro
	MOV  [SELECIONA_ECRÃ], R11  ; seleciona o ecrã do meteoro
	CALL desenha_boneco			; desenha o meteoro a partir da tabela
	RET


; ******************************************************************************
; DETETA_COLISÃO_MÍSSIL - Deteta se um meteoro colidiu com um míssil.
;
; Argumentos:	R1 - Linha do meteoro
;               R2 - Coluna do meteoro
;               R4 - Tabela do meteoro
;
; Retorna:		R8 - 1, caso tenha havido colisão; 0, caso contrário
;
; ******************************************************************************
deteta_colisão_míssil:
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R7

	MOV  R8, 0 						; até prova em contrário, não houve nenhuma colisão
	MOV  R7, posição_míssil 		; endereço da posição do míssil
	MOV  R5, [R7] 					; linha do míssil
	MOV  R6, [R7+2] 				; coluna do míssil

	CMP  R5, R1 					; se a linha do míssil for inferior à do meteoro, não há colisão
	JLT  sai_deteta_colisão_míssil
	CMP  R6, R2 					; se a coluna do míssil for inferior à do meteoro, não há colisão
	JLT  sai_deteta_colisão_míssil

	MOV  R7, [R4] 					; largura do meteoro
	ADD  R2, R7 					; primeira coluna após o meteoro
	CMP  R6, R2 					; se a coluna do míssil estiver após o meteoro, não há colisão
	JGE  sai_deteta_colisão_míssil
	MOV  R7, [R4+2] 				; altura do meteoro
	ADD  R1, R7 					; primeira linha após o meteoro
	CMP  R5, R1 					; se a linha do míssil estiver após o meteoro, não há colisão
	JGE  sai_deteta_colisão_míssil
	MOV  R8, HÁ_COLISÃO				; se nenhuma das condições anteriores se verificou, há colisão
	MOV  [colisão_míssil], R8 		; notifica o processo "míssil" de que houve colisão

	MOV  R1, DEF_METEORO_MAU_5 		; endereço da tabela do meteoro mau
	CMP  R4, R1 					; se o meteoro em questão for mau, haverá aumento de energia 
	JNE  sai_deteta_colisão_míssil
	MOV  R1, AUM_ENERGIA_MÍSSIL
	MOV  [evento_int_2], R1 		; notifica o processo "energia" de que é para variar a energia, e quanto

sai_deteta_colisão_míssil:
	POP  R7
	POP  R6
	POP  R5
	POP  R2
	POP  R1
	RET


; ******************************************************************************
; DETETA_COLISÃO_ROVER - Deteta se um meteoro colidiu com o rover.
;
; Argumentos:	R1 - Linha do meteoro
;               R2 - Coluna do meteoro
;               R4 - Tabela do meteoro
;
; Retorna:		R8 - 1, caso tenha havido colisão; 0, caso contrário
;
; ******************************************************************************
deteta_colisão_rover:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R5
	PUSH R6
	PUSH R7

	MOV  R5, LINHA_ROVER 			; linha do rover
	MOV  R6, [coluna_rover] 		; coluna do rover
	MOV  R7, DEF_ROVER 				; endereço da tabela do rover
	MOV  R8, 0 						; até prova em contrário, não houve nenhuma colisão

	MOV  R0, [R4] 					; largura do meteoro
	ADD  R2, R0 					; primeira coluna após o meteoro
	CMP  R6, R2 					; se a coluna do rover estiver após o meteoro, não há colisão
	JGE  sai_deteta_colisão_rover
	MOV  R0, [R4+2] 				; altura do meteoro
	ADD  R1, R0 					; primeira linha após o meteoro
	CMP  R5, R1 					; se a linha do rover estiver após o meteoro, não há colisão
	JGE  sai_deteta_colisão_rover

	SUB  R2, R0 					; repõe a coluna do meteoro

	MOV  R0, [R7] 					; largura do rover
	ADD  R6, R0 					; primeira coluna após o rover
	CMP  R6, R2 					; se a coluna do meteoro estiver após o rover, não há colisão
	JLE  sai_deteta_colisão_rover

	MOV  R8, HÁ_COLISÃO				; se nenhuma das condições anteriores se verificou, há colisão
	MOV  R5, DEF_METEORO_BOM_5 		; endereço da tabela do meteoro bom
	CMP  R4, R5 					; se o meteoro em questão for bom, haverá aumento de energia 
	JNZ  destroi_rover 				; caso contrário, o rover é destruído
	MOV  R5, AUM_ENERGIA_METEORO
	MOV  [evento_int_2], R5 		; notifica o processo "energia" de que é para variar a energia, e quanto
	JMP  sai_deteta_colisão_rover

destroi_rover:
	MOV  R1, ECRÃ_ROVER
	MOV  [APAGA_ECRÃ], R1 			; apaga o ecrã do rover
	MOV  [SELECIONA_ECRÃ], R1 		; seleciona o ecrã do meteoro

	MOV  R1, LINHA_ROVER 			; linha do rover (onde ocorrerá a explosão)
	MOV  R2, [coluna_rover] 		; coluna do rover (onde ocorrerá a explosão)
	MOV  R4, DEF_EXPLOSÃO 			; tabela da explosão
	CALL desenha_boneco 			; desenha a explosão

	MOV  R0, SOM_EXPLOSÃO			; som da explosão
	MOV  [TOCA_SOM], R0				; comando para tocar o som da explosão
	MOV  R0, CEN_COLISÃO  			; o jogo terminou porque o rover colidiu
	MOV  [cenario_jogo], R0 		; a variável "cenario_jogo" define qual o cenário frontal de "game over"
	MOV  R0, TECLA_E 				; o jogo terminou, logo, é como se a tecla E tivesse sido premida
	MOV  [tecla_premida], R0 		; indica que o jogo terminou
	MOV  [tecla_continuo], R0		; indica que o jogo terminou

sai_deteta_colisão_rover:
	POP  R7
	POP  R6
	POP  R5
	POP  R2
	POP  R1
	POP  R0
	RET


; ******************************************************************************
; * Rotinas auxiliares
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
	SUB  R6, R3 			; número de linhas a desenhar do boneco

desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]			; obtém a cor do próximo pixel do boneco
	CALL escreve_pixel		; escreve o pixel na linha e coluna definidas
	ADD	 R4, 2				; endereço da cor do próximo pixel (2 porque a cor do pixel é uma word)
    INC  R2 	            ; próxima coluna
    DEC  R5					; menos uma coluna para tratar
    JNZ  desenha_pixels     ; repete até percorrer toda a largura (colunas) do objeto
db_proxima_linha:
	DEC  R6 				; linhas por desenhar
	JZ   sai_desenha_boneco ; todas as linhas já desenhadas?
	INC  R1	 		   	    ; próxima linha
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
; TESTA_LIMITES_VERTICAL - Testa se o boneco chegou aos limites na vertical
;						   do ecrã.
;
; Argumentos:	R1 - linha em que o boneco está
; 				R6 - altura do boneco
;
; Retorna: 		R3 - número de linhas que o boneco ultrapassou do limite inferior do ecrã
;
; ******************************************************************************
testa_limites_vertical:
	PUSH R0

	MOV  R3, R6						; cópia da altura do boneco
	MOV  R0, LINHAS 				; número da linhas do ecrã
	SUB  R0, R1 					; linhas entre o píxel de referência do boneco e o limite inferior do ecrã
	SUB  R3, R0 					; quando for positivo, o boneco passou do limite
	JGT  sai_testa_limites_vertical ; se tiver passado do limite, retorna
	MOV  R3, 0 						; caso contrário, R3 passa a 0 (não passou do limite)

sai_testa_limites_vertical:
	POP  R0
	RET


; ******************************************************************************
; * Rotinas de atendimento a interrupções
; ******************************************************************************

; ******************************************************************************
; ROT_INT_0 - Rotina de atendimento da interrupção 0, desencadeada pelo relógio
; meteoros (usado como base para a temporização do movimento dos meteoros).
; ******************************************************************************
rot_int_0:
	PUSH R0
	MOV  R0, 0
	MOV  [evento_int_0], R0
	POP  R0
	RFE						; Return From Exception (diferente do RET)


; ******************************************************************************
; ROT_INT_1 - Rotina de atendimento da interrupção 1, desencadeada pelo relógio
; míssil (usado como base para a temporização do movimento do míssil).
; ******************************************************************************
rot_int_1:
	MOV [evento_int_1], R0 	; R0 irrelevante
	RFE						; Return From Exception (diferente do RET)


; ******************************************************************************
; ROT_INT_2 - Rotina de atendimento da interrupção 2, desencadeada pelo relógio
; eneriga (usado como base para a temporização da diminuição periódica de
; energia do rover).
; ******************************************************************************
rot_int_2:
	PUSH R0
	MOV R0, DIM_ENERGIA_TEMPO
	MOV [evento_int_2], R0
	POP R0
	RFE						; Return From Exception (diferente do RET)
