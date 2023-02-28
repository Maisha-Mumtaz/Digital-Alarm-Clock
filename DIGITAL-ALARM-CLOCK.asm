; THIS IS THE FINAL ONE
; TO BE USED WITH HARDWARE
		ORG 00H
		MOV SP,#70H ; moving stack pointer to 70H 
		MOV PSW,#00H
		RS EQU P3.4
		RW EQU P3.5
		ENBL EQU P3.6
		MOV DPTR,#KCODE0 ; address of starting of lookup table
	
		BUZZ EQU P3.0 ; buzzer in port P3.0
		SETB BUZZ ; the buzzer is active low
		DISP EQU P0
		DISP7 EQU P0.7 ; display busy checker D7

		;CLOCK STARTING VALUES IN BANK-0 R1 to R7
		AMPM EQU R1
		CR0 EQU R2 ;msb of hour
		CR1 EQU R3 ;lsb of hour
		CR2 EQU R4 ;msb of minute
		CR3 EQU R5 ;lsb of minute
		CR4 EQU R6 ;msb of second
		CR5 EQU R7 ;lsb of second
		
		MOV 11H,#3 ;NUMBER OF SNOOZE
		ALRM_DUR EQU 10 ; address for storing alarm duration
		
		AD EQU 15
		MOV ALRM_DUR,#AD ;SECONDS OF ALARM RING, value to be stored in ALRM_DUR
;;;;;;;;;;;;;;;;DISPLAY INITIALIZATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		MOV A,#38H
		LCALL COMMAND
		LCALL DELAY
		MOV A,#0EH
		LCALL COMMAND
		LCALL DELAY
		MOV A,#01
		LCALL COMMAND
		LCALL DELAY
		MOV A ,#06H
		LCALL COMMAND
		LCALL DELAY
		MOV A ,#0CH
		LCALL COMMAND
		LCALL DELAY
;;;;;;;;;;;;;;;;;;;;;;;;COLON;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this part just clears the screen and adds two colons for separating hr, min and sec
ER1:		MOV A ,#1H ;CLEARING SCREEN
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#KCODE0
		LCALL ADDCOLON
;;;;;;;;;;;;;;;START TIME SELECTION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		MOV A ,#80H 
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#STARTTIME ;point data pointer to prompt address
		LCALL PROMPT
		
		MOV A ,#0C0H ; taking cursor to next line
		LCALL COMMAND
		LCALL DELAY
CLKHM:		LCALL KEYPAD ; take hr msb
		CLR C	
		MOV A,B	
		CJNE A,#2,CHECKHM ; checking for invalid input
CHECKHM:	JC CHU_1 ; input smaller than 2 is valid, small number(A)-2 gives carry
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKHM ; go back to taking this input again
CHU_1:		MOV CR5,B
		
CLKHL:		LCALL KEYPAD ; take hr lsb
		MOV A,CR5
		CJNE A,#1,CHU2 ; checking for invalid input
		CLR C
		MOV A,B
		CJNE A,#3,CHECKHL ; checking for invalid input
CHECKHL:	JC CHU2_2	
AGHLLLL:	MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKHL
		
CHU2:		MOV A,B
		CJNE A,#10,YY
		SJMP AGHLLLL
YY:		JNC AGHLLLL
		XRL A,#0
		JZ AGHLLLL
CHU2_2:		MOV CR4,B
			
			
		MOV A ,#0C3H 
		LCALL COMMAND
		LCALL DELAY
CLKMM:		LCALL KEYPAD  ; 0-5
		CLR C
		MOV A,B
		CJNE A,#6,CHECKMM  ; checking for invalid input
CHECKMM:	JC CHU3
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKMM
CHU3:		MOV CR3,B

CLKML:		LCALL KEYPAD
		MOV A,B
		CJNE A,#10,YY1  ; checking for invalid input
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKML
YY1:		JNC CLKML
		MOV CR2,B
		
			
		MOV A ,#0C6H 
		LCALL COMMAND
		LCALL DELAY
CLKSM:		LCALL KEYPAD
		CLR C
		MOV A,B
		CJNE A,#6D,CHECKSM  ; checking for invalid input
CHECKSM:	JC CHU4
AGHSSS:		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKSM		
CHU4:		MOV CR1,B



CLKSL:		LCALL KEYPAD 
		MOV A,B
		CJNE A,#10,YY3
HWWW:		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKSL
YY3:		JNC HWWW		
		MOV CR0,B
		
		
CLKAP:		LCALL KEYPAD ;AM/PM
		MOV A,B
		CJNE A,#10,APGAIN
		SJMP OIJE
APGAIN:		CJNE A,#11,AMAGAIN
		SJMP OIJE
AMAGAIN:	MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP CLKAP
OIJE:		MOV AMPM,B
		MOV DPTR,#M_ADRS ; showing 'M' for AM/PM
		MOV A,#0
		LCALL SHOW

		
X:		LCALL KEYPAD 
		MOV A,#0DH
		CJNE A,B,XX ; check if ERASE is pressed, if yes, take input again
		LJMP ER1
XX:		MOV A,#0CH
		CJNE A,B,STAYEN ; check if ENTER is pressed, if yes, move forward
		SJMP HEREEE
STAYEN:		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP X	   ; if not, check again for ERASE/ENTER press
		
;;;;;;;;;;;;;;;ADD ALARM?;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this part asks if we want to set alarm or not
; if we do, we have to take alarm time as input
; if not, the clock will act as a basic digital clock					
HEREEE:		MOV A ,#1H ;CLEARING SCREEN
		LCALL COMMAND
		LCALL DELAY
		
		MOV A ,#80H 
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#LRM ;point data pointer to message address
		LCALL PROMPT
		
		MOV A ,#0C0H 
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#OPTION ; shows you the two options, 1.Yes 2.No
		LCALL PROMPT
		
ALARM_GET:	LCALL KEYPAD
		MOV R0,B
		MOV A,#1
		XRL A,R0
		JZ YEP ; if 1 pressed, go to alarm input section, if not, move to clock counter
		MOV A,#2 ; if 2 is pressed comparison
		XRL A,R0
		JZ CHOLO
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP ALARM_GET
		
		
CHOLO:		MOV 30H,#0 ; this line stores invalid values in the alarm locations
		MOV 31H,#0 ; so that, this number matches non of the numbers on the clock
		MOV 32H,#0 ; and prevents false alarm
		MOV 33H,#0
		MOV 34H,#0
		MOV 35H,#0
		MOV 36H,#0
		
		MOV 40H,#0 ; backup memory locations for the alarm
		MOV 41H,#0
		MOV 42H,#0
		MOV 43H,#0
		MOV 44H,#0
		MOV 45H,#0
		MOV 46H,#0
		
		JZ SHAMNE ; if A-0, 2 is pressed, move to clock counter
SHAMNE:		LJMP AROSHAMNE ; address was out of range for JZ
;;;;;;;;;;;;;;;ALARM TIME SELECTION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; alarm values are stored in 30h-36h and 40h-46h backup
YEP:		MOV A ,#1H ;CLEARING SCREEN
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#KCODE0
		LCALL ADDCOLON
		MOV A ,#80H 
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#ALARMTIME ;point data pointer to message address
		LCALL PROMPT
		
		MOV A ,#0C0H 
		LCALL COMMAND
		LCALL DELAY
AHM:		LCALL KEYPAD
		CLR C	
		MOV A,B	
		CJNE A,#2,CHECKHM1 ; checking for invalid input
CHECKHM1:	JC CHU_11
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP AHM
CHU_11:		MOV 30H,B
		MOV 40H,B
		
AHL:		LCALL KEYPAD
		MOV A,30H
		CJNE A,#1,CHU22 ; checking for invalid input
		CLR C
		MOV A,B
		CJNE A,#3,CHECKHL1 ; checking for invalid input
CHECKHL1:	JC CHU22_2	
AHLLL222:	MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP AHL
CHU22:		MOV A,B
		CJNE A,#10,YY4 ; checking for invalid input
		SJMP AHLLL222
YY4:		JNC AHLLL222
		XRL A,#0
		JZ AHLLL222
CHU22_2:	MOV 31H,B
		MOV 41H,B
		
			
		MOV A ,#0C3H 
		LCALL COMMAND
		LCALL DELAY
AMM:		LCALL KEYPAD
		CLR C
		MOV A,B
		CJNE A,#6,CHECKMM1 ; checking for invalid input
CHECKMM1:	JC CHU33
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP AMM
CHU33:		MOV 32H,B
		MOV 42H,B
		
AML:		LCALL KEYPAD
		MOV A,B
		CJNE A,#10,YY6 ; checking for invalid input
AMMM:		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP AML
YY6:		JNC AMMM
		MOV 33H,B
		MOV 43H,B
			
		MOV A ,#0C6H 
		LCALL COMMAND
		LCALL DELAY
ASM:		LCALL KEYPAD
		CLR C
		MOV A,B
		CJNE A,#6D,CHECKSM1  ; checking for invalid input
CHECKSM1:	JC CHU44
		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP ASM
		
		
CHU44:		MOV 34H,B
		MOV 44H,B
		
ASL:		LCALL KEYPAD
		MOV A,B
		CJNE A,#10,YY7  ; checking for invalid input
ASLLA:		MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP ASL
YY7:		JNC ASLLA
		MOV 35H,B
		MOV 45H,B
		
AAP:		LCALL KEYPAD ;AM/PM
		MOV A,B
		CJNE A,#10,APGAIN1  ; checking for invalid input
		SJMP OIJE1
APGAIN1:	CJNE A,#11,AMAGAIN1  ; checking for invalid input
		SJMP OIJE1
AMAGAIN1:	MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP AAP
OIJE1:		MOV 36H,B
		MOV 46H,B
		MOV DPTR,#M_ADRS
		MOV A,#0
		LCALL SHOW
		
		
X2:		LCALL KEYPAD ; check if ERASE/ENTER is pressed
		MOV A,#0DH
		CJNE A,B,XX2
		LJMP YEP
XX2:		MOV A,#0CH
		CJNE A,B,STAYEN2 ; check if ENTER is pressed, if yes, move forward
		SJMP AROSHAMNE
STAYEN2:	MOV A,#10H
		LCALL COMMAND
		LCALL DELAY
		SJMP X2
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
AROSHAMNE:	MOV A ,#1H ;CLEARING SCREEN
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#KCODE0
		LCALL ADDCOLON
		
		MOV A ,#80H 
		LCALL COMMAND
		LCALL DELAY
		
		MOV A,#0
		MOV DPTR,#DIGI
		LCALL PROMPT
		
		MOV DPTR,#KCODE0
		
		MOV A ,#0C9H 
		LCALL COMMAND
		LCALL DELAY
		MOV DPTR,#M_ADRS
		MOV A,#0
		LCALL SHOW
;;;;;;;;;;;;;;;;STOP and SNOOZE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		SETB P2.3 ;SNOOZE
		SETB P2.2 ;STOP
		CLR P2.7 ;OP
;;;;;;;;;;;;;;;;;;;;TIME SHOWING;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; showing the current time	
		MOV DPTR,#KCODE0
		CLR A
AGHM:		MOV A ,#0C0H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR5
		LCALL SHOW
	
AGHL:		MOV A ,#0C1H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR4
		LCALL SHOW
	; colon will be after this position
AGMM:		MOV A ,#0C3H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR3
		LCALL SHOW
	
AGML:		MOV A ,#0C4H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR2
		LCALL SHOW
	; colon will be after this position
AGSM:		MOV A ,#0C6H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR1
		LCALL SHOW
	
AGSL:		MOV A ,#0C7H ;DON'T ERASE
		LCALL COMMAND
		LCALL DELAY
		MOV A,CR0
		LCALL SHOW
		
AGAP:		MOV A,AMPM
		LCALL SHOW
;;;;;;;;;;;;;;;;;;;;CLOCK OPERATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		LCALL DELAYG ; 1 second delay optimized for hardware


CONT:		MOV B,30H
		MOV A,CR5
		CJNE A,B, JAH
		
		MOV B,31H
		MOV A,CR4
		CJNE A,B, JAH
		
		MOV B,32H
		MOV A,CR3
		CJNE A,B, JAH
		
		MOV B,33H
		MOV A,CR2
		CJNE A,B, JAH
		
		MOV B,34H
		MOV A,CR1
		CJNE A,B, JAH
		
		MOV B,35H
		MOV A,CR0
		CJNE A,B, JAH
		
		MOV B,36H
		MOV A,AMPM
		CJNE A,B, JAH
		
		CLR BUZZ
		INC R0
JAH:		JB BUZZ, MOVE
		JNB P2.2, STOPBUZZ ;button has been pressed, JNB=true
		MOV A,#0H
		CJNE A,11H,OKAY ;11h contains how many times snooze will activate
		SJMP STOPBUZZ
		
OKAY:		JB P2.3, LAAF ; P2.3 low when snooze is pressed
		LCALL SNOOZE
LAAF:		DJNZ ALRM_DUR,MOVE ; decrease the alarm duration by 1 second
		LCALL SNOOZE ; if snooze/stop were not pressed during alarm ring, it goes to autosnooze
		SJMP MOVE
		
STOPBUZZ:	SETB BUZZ
	;WHEN YOU PRESS STOP, THE ALARM REGISTERS GET THE ORIGINAL ALARM TIME AGAIN ERASING THE SNOOZE TIMES
		MOV 30H,40H
		MOV 31H,41H
		MOV 32H,42H
		MOV 33H,43H
		MOV 34H,44H
		MOV 35H,45H
		MOV 36H,46H
; next portion basically does the 6 digit clock counter
		
MOVE:		CJNE CR0,#9, NEXT ;9
		CJNE CR1,#5, NEXT2 ;5
		CJNE CR2,#9, NEXT3 ;9
		CJNE CR3,#5, NEXT4 ;5
		CJNE CR5,#1, NEXT5 ;1
		CJNE CR4,#1, BOOM ;1
		
		MOV A,AMPM
		XRL A,#00000001B
		MOV AMPM,A
		
BOOM:		CJNE CR4,#2, NEXTX
		
BHAG:		MOV CR0,#0H ; for sec lsb
		MOV CR1,#0H ; for sec msb
		MOV CR2,#0H ; for min lsb
		MOV CR3,#0H ; for min msb
		MOV CR4,#1H ; for hr lsb
		MOV CR5,#0H ; for hr msb
	
		LJMP AGHM
	
NEXT:		INC CR0
		LJMP AGSL
NEXT2: 		INC CR1
		MOV CR0,#0
		LJMP AGSM
NEXT3:		INC CR2
		MOV CR1,#0
		MOV CR0,#0
		LJMP AGML
NEXT4:		INC CR3
		MOV CR2,#0
		MOV CR1,#0
		MOV CR0,#0
		LJMP AGMM
NEXT5:		CJNE CR4,#9,NEXTX
		INC CR5
		MOV CR4,#0
		MOV CR3,#0
		MOV CR2,#0
		MOV CR1,#0
		MOV CR0,#0

		LJMP AGHM
NEXTX:		INC CR4
		MOV CR3,#0
		MOV CR2,#0
		MOV CR1,#0
		MOV CR0,#0
		LJMP AGHL
;;;;;;;;;;;;;;;;;;;;;SUB ROUTINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set to 10 seconds for code demonstration
SNOOZE:		SETB BUZZ ; clear buzzer when snooze is pressed
		CLR PSW.3
		MOV A,CR1
		CJNE A,#5, PERANAI
		MOV A,CR2
		INC A ; increment current time's MSB by 1
		MOV 33H,A
		MOV A,#0
		SJMP SHUSH
PERANAI:	INC A
SHUSH:		MOV 34H,A
		MOV A,CR0
		MOV 35H,A
		MOV ALRM_DUR,#AD;SECONDS OF ALARM RING
		DEC 11H
		RET
;...............................................................		
SHOW:		MOVC A,@A+DPTR
		LCALL DISPLAY
		LCALL DELAY
		RET
;...............................................................
; modified to keep the number value of input in register B
KEYPAD:
	SETB PSW.4
	SETB P2.0
	SETB P2.1
	SETB P2.2
	SETB P2.3
K1: 	CLR P2.4 ;OP
	CLR P2.5 ;OP
	CLR P2.6 ;OP
	CLR P2.7 ;OP
	MOV A, P2 ;read all columns.ensure all keys open
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B,K1 ;check till all keys released
K2: 	ACALL DELAY ;call 20ms delay
	MOV A, P2 ;see if any key is pressed
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, OVER ;key pressed, await closure
	SJMP K2 ;check is key pressed
OVER: 	ACALL DELAY ;wait 20ms debounce time
	MOV A, P2 ;check key closure
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, OVER1 ;key pressed, find row
	SJMP K2 ;if none, keep polling
OVER1: 	CLR P2.4 ;OP
	SETB P2.5 ;OP
	SETB P2.6 ;OP
	SETB P2.7 ;OP
	MOV A, P2 ;read all columns
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, ROW_0 ;key row 0, find the column
	SETB P2.4 ;OP
	CLR P2.5 ;OP
	SETB P2.6 ;OP
	SETB P2.7 ;OP
	MOV A, P2 ;reall all columns
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, ROW_1 ;key row 1, find the column
	SETB P2.4 ;OP
	SETB P2.5 ;OP
	CLR P2.6 ;OP
	SETB P2.7 ;OP
	MOV A, P2 ;read all columns
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, ROW_2 ;key row 2, find column
	SETB P2.4 ;OP
	SETB P2.5 ;OP
	SETB P2.6 ;OP
	CLR P2.7 ;OP
	MOV A, P2 ;read all columns
	ANL A, #00001111B ;mask unused bits
	CJNE A, #00001111B, ROW_3 ;key row 3, find column
	LJMP K2 ;if none, false input, repeat
ROW_0: 	MOV DPTR, #KCODE0 ;set DPTR=start of row 0
	MOV R7,#0
	SJMP FIND ;find column.key belongs to
ROW_1:	MOV DPTR, #KCODE1 ;set DPTR=start of row 1
	MOV R7,#4
	SJMP FIND ;find column.key belongs to
ROW_2: 	MOV DPTR, #KCODE2 ;set DPTR=start of row 2
	MOV R7,#8
	SJMP FIND ;find column.key belongs to
ROW_3: 	MOV DPTR, #KCODE3 ;set DPTR=start of row 3
	MOV R7,#0CH
FIND: 	RRC A ;see if any CY bit is low
	JNC MATCH ;if zero, get the ASCII code
	INC R7
	INC DPTR ;point to the next column address
	SJMP FIND ;keep searching
MATCH: 	CLR A ;set A=0 (match found)
	MOVC A, @A+DPTR ;get ASCII code from table
	ACALL DISPLAY ;call display subroutine
	ACALL DELAY ;give LCD some time
	MOV B,R7
	CLR PSW.4
	RET
;........................................................................................
; for showing message prompts
PROMPT:		CLR A 
		MOVC A,@A+DPTR ;move the content of the address pointed by A+DPTR to A
		JZ NEXT1 ;jump to FINISH if the content of A=0, end of string
		LCALL DISPLAY ;display subroutine
		LCALL DELAY ;delay
		INC DPTR ;increase DPTR to show the next character
		LJMP PROMPT ;repeat
NEXT1:		RET
;..........................................................................................	
COMMAND:
		LCALL READY
		MOV DISP,A
		CLR RS
		CLR RW
		SETB ENBL
		LCALL DELAY
		CLR ENBL
		RET
;...........................................................................................	
DISPLAY:	
		LCALL READY
		MOV DISP,A
		SETB RS
		CLR RW
		SETB ENBL 
		LCALL DELAY
		CLR ENBL
		RET
;..........................................................................................
READY: 
		SETB DISP7
		CLR RS
		SETB RW

WAIT:
		CLR ENBL
		ACALL DELAY
		SETB ENBL
		JB DISP7, WAIT
		RET
;............................................................................................
DELAY:		SETB PSW.3
		MOV R3,#25
AGAIN_2:	MOV R4,#25
AGAIN: 		DJNZ R4, AGAIN
		DJNZ R3, AGAIN_2
		CLR PSW.3
		RET
; this is the one second delay
		
DELAYG:		MOV     R0,#20d      ; set loop count to 20
		MOV TMOD,#00000001B
		
loop:   	CLR     TR0          ; start each loop with the timer stopped
        	CLR     TF0          ; and the overflow flag clear. setup
        	MOV     TH0,#4Fh     ; timer 0 to overflow in 50 ms, start the
        	MOV     TL0,#00h     ; timer, wait for overflow, then repeat
        	SETB    TR0          ; until the loop count is exhausted
        	JNB     TF0,$
        	DJNZ    R0,loop
		RET
; delay for keypad		
DELAYK: 	SETB PSW.3
		MOV R3, #50 ;50 or higher for fast CPUs
HERE2: 		MOV R4, #255 ;R4=255
HERE: 		DJNZ R4, HERE ;stay untill R4 becomes 0
		DJNZ R3, HERE2
		CLR PSW.3
		RET	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;adds colon for separation of hr, min and sec
ADDCOLON:	MOV A ,#0C2H ; 
		LCALL COMMAND
		LCALL DELAY
		MOV A,#16D
		MOVC A,@A+DPTR
		LCALL DISPLAY
		LCALL DELAY
	
		MOV A ,#0C5H ; position of second colon
		LCALL COMMAND
		LCALL DELAY
		MOV A,#16D
		MOVC A,@A+DPTR
		LCALL DISPLAY
		LCALL DELAY
		RET
;******************************************************************************
;lookup table
KCODE0:	DB "0"
	DB "1"
	DB "2"
	DB "3"
KCODE1:	DB "4"
	DB "5"
	DB "6"
	DB "7"
KCODE2:	DB "8"
	DB "9"
	DB "A"
	DB "P"
KCODE3:	DB "."
	DB "Y"
	DB "E"
	DB "F"
;----------------
	DB ":"
M_ADRS:	DB "M"
STARTTIME:	DB "ENTER START TIME:",0
ALARMTIME:	DB "SET ALARM TIME:",0
LRM:		DB "SET ALARM?",0
OPTION:		DB "(1)YES (2)NO",0
DIGI:		DB "Digital Clock",0
END