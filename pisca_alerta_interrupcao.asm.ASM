;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		CONT
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	#DEFINE	    BOTAO_E	GPIO,GP1 ;DEFININDO AS PORTAS DE ENTRADA CORRESPONDENTES AOS 
	#DEFINE	    BOTAO_D	GPIO,GP2;BOT�ES PARA ESQUERDA,DIREITA E ALERTA
	#DEFINE	    BOTAO_A	GPIO,GP0;RESPECTIVAMENTE
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	#DEFINE	    LED_E	GPIO,GP4;DEFININDO AS PORTAS DE SAIDA CORRESPONDENTES 
	#DEFINE	    LED_D	GPIO,GP5;AOS LEDS DA ESQUERDA E DIREITA RESPECTIVAMENTE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04		;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	
	BTFSS	INTCON,GPIF;VERIFICA SE TEM INTERRUP��O NAS PORTAS
	GOTO	TESTA_TIMER;CHAMA A ROTINA DELAY DE 500m
	BCF	INTCON,GPIF;LIMPA FLAG QUE SINALIZA A INTERRU��O NAS PORTAS
	;TESTA EM QUE PORTA OCORREU A INTERRUP��O
	BTFSS	BOTAO_A ;ALERTA ATIVADO?
	GOTO	TESTA_E ;NAO
	BSF	LED_E;ACENDE O LED ESUQUERDO
	BSF	LED_D;ACENDE O LED DIREITO
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	GOTO	SAI_INT;SAI DA INTERRUP��O
TESTA_E
	BTFSS	BOTAO_E;O LED DA ESQUERDA EST� LIGADO?
	GOTO	TESTA_D;N�O,TESTA O LED DA DIREITA
	BSF	LED_E;SIM, LIGA O LED DA ESQUERDA
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	BCF	LED_D;APAGA O LED DA DIREITA
	GOTO	SAI_INT;SAI DA INTERRUP��O
	
TESTA_D	
	BTFSS	BOTAO_D;O BOT�O DA DIREITA EST� LIGADO?
	GOTO	SAI_INT;N�O,ENT�O SAI DA INTERRUP��O
	BSF	LED_D;SIM,LIGA O BOT�O DA DIREITA
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	BCF	LED_E;APAGA P LED DA ESQUERDA
	GOTO	SAI_INT;SAI DA INTERRUP��O
	;verifica se tem interrup��o no TIMER0
TESTA_TIMER	
	BTFSS	INTCON,T0IF ; � INTERRUP��O DO TIMER0?
	GOTO	SAI_INT	    ;N�O, SAI SE A��O
	BCF	INTCON,T0IF;LIMPANDO A FLAG T0IF DA INTERRUP��O
	DECFSZ	CONT;DECREMENTA O CONTADOR DO TIMER0
	GOTO	SAI_INT;SAI DA INTERRUP��O
	BTFSS	BOTAO_A;O BOT�O DE ALERTA EST� LIGADO?
	GOTO	TESTA_B_E;N�O, VOLTA E TESTA O BOT�O DA ESQUERDA
	BTFSS	LED_E;SIM, VERIFICA SE O LED ESTA EM 1
	GOTO	ACENDE_A
	GOTO	APAGA_A
	;DEFINI��O AS ROTINAS UTILIZADAS NO BOT�O ALERTA (PISCAR OS LEDS DA ESQUERDA E DIREITA)
ACENDE_A
	BSF	LED_E;ACENDE O LED DA ESQUERDA
	BSF	LED_D;ACENDE O LED DA DIREITA
	GOTO	TIMER;CHAMA A ROINA QUE CONTEM O DELAY
	
APAGA_A
	BCF	LED_E;APAGA O LED DA ESQUERDA
	BCF	LED_D;APAGA O LED DA DIREITA
	GOTO	TIMER;CHAMA A ROTINA DO DELAY
	
	
TESTA_B_E
	BTFSS	BOTAO_E;O BOT�O DA ESQUERDA MUDOU DE ESTADO?
	GOTO	TESTA_B_D;N�O,TESTA SE OCORREU MUDAN�A DE ESTADO NO BOT�O DA DIREITA
	BTFSS	LED_E;O LED DA ESQUERDA EST� ACESO?
	GOTO	ACENDE_LED_E;
	GOTO	APAGA_LED_E
ACENDE_LED_E
	BSF	LED_E
	GOTO	TIMER
	
APAGA_LED_E
	BCF	LED_E
	GOTO	TIMER
	
TESTA_B_D
	BTFSS	BOTAO_D;O ESTADO DO BOT�O DA DIREITA MUDOU?
	GOTO	SAI_INT;N�O,SAI DA INTERRUP��O
	BTFSS	LED_D;SIM,VERIFICA SE O LED EST� ACESO
	GOTO	ACENDE_LED_D;N�O, ACENDE O LED DA DIREITA
	GOTO	APAGA_LED_D;SIM,APAGA O LED DA DIREITA
ACENDE_LED_D
	BSF	LED_D
	GOTO	TIMER
	
APAGA_LED_D
	BCF	LED_D
	GOTO	TIMER
TIMER
	CALL	CONF_TIMER
	
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

;CALCULO DO TIMER0 F(X)= TEMPODESEJADO/(256-X)*PRESCALER
;ESTAMOS DEFININDO UM PRESCALER DE 1:32, VOC� PODE ERIFICAR ISSO OLHANDO AS
;CONFIGURA��O DO REGISTRADOR OPTION_REG
DELAY_500
	MOVLW	.56 ; VALOR DE X OBTIDO NO CALCULO DA FUN��O F(X)
	MOVWF	TMR0;QUE DEVE SER PASSADO PARA O TIMER0	
	RETURN
CONF_TIMER
	MOVLW	.70;VALOR AJUSTADO DO CONTADOR COM O INTUITO DE CALIBRAR O TEMPO 
	MOVWF	CONT;DO DELAY
	CALL	DELAY_500
	RETURN

	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	
	BANK1			;ALTERA PARA O BANCO 1
	; definindo as portas (GP1,GP2,GP3) como entradas
	; definindo as portas (GP4, GP5) como saidas
	MOVLW	B'00000111'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000100'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	;definindo a interrup��o global (bit7)
	;definindo a interrup��o de estouro do timer0 (bit5)
	;Habilita��o de altera��o de porta (bit3)
	MOVLW	B'11101000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	; CONFIGURANDO O REGISTRADOR IOC PARA HABILITAR AS INTERRUP��ES ESPECIFICAS GP0,1 E 2
	MOVLW	B'00000111'
	MOVWF	IOC
	
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	NOP

	GOTO MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END



