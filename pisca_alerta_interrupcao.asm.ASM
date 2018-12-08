;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		CONT
		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	#DEFINE	    BOTAO_E	GPIO,GP1 ;DEFININDO AS PORTAS DE ENTRADA CORRESPONDENTES AOS 
	#DEFINE	    BOTAO_D	GPIO,GP2;BOTÕES PARA ESQUERDA,DIREITA E ALERTA
	#DEFINE	    BOTAO_A	GPIO,GP0;RESPECTIVAMENTE
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)
	#DEFINE	    LED_E	GPIO,GP4;DEFININDO AS PORTAS DE SAIDA CORRESPONDENTES 
	#DEFINE	    LED_D	GPIO,GP5;AOS LEDS DA ESQUERDA E DIREITA RESPECTIVAMENTE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP
	
	
	BTFSS	INTCON,GPIF;VERIFICA SE TEM INTERRUPÇÃO NAS PORTAS
	GOTO	TESTA_TIMER;CHAMA A ROTINA DELAY DE 500m
	BCF	INTCON,GPIF;LIMPA FLAG QUE SINALIZA A INTERRUÇÃO NAS PORTAS
	;TESTA EM QUE PORTA OCORREU A INTERRUPÇÃO
	BTFSS	BOTAO_A ;ALERTA ATIVADO?
	GOTO	TESTA_E ;NAO
	BSF	LED_E;ACENDE O LED ESUQUERDO
	BSF	LED_D;ACENDE O LED DIREITO
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	GOTO	SAI_INT;SAI DA INTERRUPÇÃO
TESTA_E
	BTFSS	BOTAO_E;O LED DA ESQUERDA ESTÁ LIGADO?
	GOTO	TESTA_D;NÃO,TESTA O LED DA DIREITA
	BSF	LED_E;SIM, LIGA O LED DA ESQUERDA
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	BCF	LED_D;APAGA O LED DA DIREITA
	GOTO	SAI_INT;SAI DA INTERRUPÇÃO
	
TESTA_D	
	BTFSS	BOTAO_D;O BOTÃO DA DIREITA ESTÁ LIGADO?
	GOTO	SAI_INT;NÃO,ENTÃO SAI DA INTERRUPÇÃO
	BSF	LED_D;SIM,LIGA O BOTÃO DA DIREITA
	CALL	CONF_TIMER;CHAMA A ROTINA DO DELAY
	BCF	LED_E;APAGA P LED DA ESQUERDA
	GOTO	SAI_INT;SAI DA INTERRUPÇÃO
	;verifica se tem interrupção no TIMER0
TESTA_TIMER	
	BTFSS	INTCON,T0IF ; É INTERRUPÇÃO DO TIMER0?
	GOTO	SAI_INT	    ;NÃO, SAI SE AÇÃO
	BCF	INTCON,T0IF;LIMPANDO A FLAG T0IF DA INTERRUPÇÃO
	DECFSZ	CONT;DECREMENTA O CONTADOR DO TIMER0
	GOTO	SAI_INT;SAI DA INTERRUPÇÃO
	BTFSS	BOTAO_A;O BOTÃO DE ALERTA ESTÁ LIGADO?
	GOTO	TESTA_B_E;NÃO, VOLTA E TESTA O BOTÃO DA ESQUERDA
	BTFSS	LED_E;SIM, VERIFICA SE O LED ESTA EM 1
	GOTO	ACENDE_A
	GOTO	APAGA_A
	;DEFINIÇÃO AS ROTINAS UTILIZADAS NO BOTÃO ALERTA (PISCAR OS LEDS DA ESQUERDA E DIREITA)
ACENDE_A
	BSF	LED_E;ACENDE O LED DA ESQUERDA
	BSF	LED_D;ACENDE O LED DA DIREITA
	GOTO	TIMER;CHAMA A ROINA QUE CONTEM O DELAY
	
APAGA_A
	BCF	LED_E;APAGA O LED DA ESQUERDA
	BCF	LED_D;APAGA O LED DA DIREITA
	GOTO	TIMER;CHAMA A ROTINA DO DELAY
	
	
TESTA_B_E
	BTFSS	BOTAO_E;O BOTÃO DA ESQUERDA MUDOU DE ESTADO?
	GOTO	TESTA_B_D;NÃO,TESTA SE OCORREU MUDANÇA DE ESTADO NO BOTÃO DA DIREITA
	BTFSS	LED_E;O LED DA ESQUERDA ESTÁ ACESO?
	GOTO	ACENDE_LED_E;
	GOTO	APAGA_LED_E
ACENDE_LED_E
	BSF	LED_E
	GOTO	TIMER
	
APAGA_LED_E
	BCF	LED_E
	GOTO	TIMER
	
TESTA_B_D
	BTFSS	BOTAO_D;O ESTADO DO BOTÃO DA DIREITA MUDOU?
	GOTO	SAI_INT;NÃO,SAI DA INTERRUPÇÃO
	BTFSS	LED_D;SIM,VERIFICA SE O LED ESTÁ ACESO
	GOTO	ACENDE_LED_D;NÃO, ACENDE O LED DA DIREITA
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
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÁ ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

;CALCULO DO TIMER0 F(X)= TEMPODESEJADO/(256-X)*PRESCALER
;ESTAMOS DEFININDO UM PRESCALER DE 1:32, VOCÊ PODE ERIFICAR ISSO OLHANDO AS
;CONFIGURAÇÃO DO REGISTRADOR OPTION_REG
DELAY_500
	MOVLW	.56 ; VALOR DE X OBTIDO NO CALCULO DA FUNÇÃO F(X)
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
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	;definindo a interrupção global (bit7)
	;definindo a interrupção de estouro do timer0 (bit5)
	;Habilitação de alteração de porta (bit3)
	MOVLW	B'11101000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	; CONFIGURANDO O REGISTRADOR IOC PARA HABILITAR AS INTERRUPÇÕES ESPECIFICAS GP0,1 E 2
	MOVLW	B'00000111'
	MOVWF	IOC
	
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
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



