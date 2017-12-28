TITLE Disk-Scheduling Algorithms   (DiskSchedulingAlgorithms.asm)

COMMENT~

 Author: Alon Butbul
 Program Description: 
	- The program will demonstrate Disk-Scheduling in three different algorithms.
		+FCFS
		+SSTF
		+SCAN
	- The user will input the initial position of the disk head and the program will
     output the total amount of head movement required by each algorithm.
 Creation date: 11/23/2016
 Submitted: -----------
 All rights reserved (C)
~

INCLUDE Irvine32.INC

PDWORD TYPEDEF PTR DWORD ;User defined type

.DATA

MESSAGE     BYTE  "Hello user, this is a demonstration of disk-scheduling algorithms."                   ,0DH,0AH ;End of line characters 
			BYTE  "The program will report the total amount of head movement required by each algorithm.",0DH,0AH ;End of line characters
			BYTE  "Please enter the initial position (between 0 to 4999): "                              ,0       ;Null terminating string (the zero)
RESULT_F	BYTE  "Total head movment from the FCFS algorithm is: "										 ,0
RESULT_S	BYTE  "Total head movment from the SCAN algorithm is: "										 ,0
RESULT_L	BYTE  "Total head movment from the LOOK algorithm is: "										 ,0
DISPLAY_A	BYTE  "Would you like to display the array elements? Press Y/N: "							 ,0
ANSWER      BYTE  ? ;Uninitialized byte 

ARRAY       DWORD 1000 DUP(0) 		;Array to hold the numbers generated, 1200 bytes all initialized to 0
ARRAY_PTR   PDWORD ARRAY 			;A pointer to the array
ARRAY_LEN	DWORD LENGTHOF ARRAY	;To save the length of the array ;ARRAY_LEN = ($ - ARRAY)/4

HEADsTART   DWORD ? ;The location of the head given by the user
HEADmOVMENT DWORD 0 ;The result from the start HEADsTART minus the  array 

.CODE 

MAIN PROC

	CALL RANDOMIZE   ;Sets seed - Suppose to be called only once at the begging of the program 
	
	MOV  EAX, 0      ;In EAX will be the range for the RandomRange 
	MOV  EBX, 0    
	MOV  ECX, ARRAY_LEN ;By default ECX is the counter for the loop
	MOV  EDX, 0
	MOV  ESI, 0

	;Get the random numbers first:  
	CALL FILL_ARRAY
	;User input for the head start:
	CALL WELCOME
	;Displaying elements:
	CALL DIAPLAY_ELEMENTS
	;Calculate the head movements: 
	CALL FCFS 
	CALL BUBBLESORT
	CALL SCAN
	CALL LOOK
	
EXIT 
MAIN ENDP

;---------------------------------------------------
FILL_ARRAY PROC
;	
;  
; Receives: None
; Returns: None
;---------------------------------------------------
	PUSH EBP
	MOV EBP, ESP
	
FILL:
	
	MOV  EAX, 4999   ;In EAX will be the range for the RandomRange
	CALL RANDOMRANGE ;What will actually generate the number inside the range specified in EAX
	
	MOV  ARRAY[ESI], EAX ; Copy the value generated in EAX into the array
	ADD   ESI, TYPE DWORD ; Add 4 for the next element in the array

	LOOP FILL
	
	CALL CRLF
	POP EBP
	RET
FILL_ARRAY ENDP

;---------------------------------------------------
DIAPLAY_ELEMENTS PROC
;	
; Displaying the elements according to the user choose 
; Receives: None 
; Returns: None 
;---------------------------------------------------
	PUSH EBP
	MOV  EBP, ESP
	
	CALL CRLF
	MOV EDX, OFFSET DISPLAY_A
	CALL WRITESTRING
	
	CALL READCHAR
	CMP AL, 59h ;Y
	JE DISPLAY 
	CMP AL, 79h ;y
	JE DISPLAY
	CMP AL, 4Eh ;N
	JE EXITP
	CMP AL, 6Eh ;n
	JE EXITP
	
DISPLAY:	
	CALL PRINT

EXITP:	
	POP EBP
	RET
DIAPLAY_ELEMENTS ENDP 

;---------------------------------------------------
WELCOME PROC 
;	
; Shows the welcome screen
; Receives: None 
; Returns: None
;---------------------------------------------------
	PUSH EBP
	MOV	 EBP, ESP
	
	MOV  EDX, OFFSET MESSAGE  
	CALL WRITESTRING ;Displaying the message
	
    CALL READINT        ;Excepting user input into EAX
	MOV  HEADsTART, EAX ;Save the value from EAX to a variable

	POP EBP
	RET 
	
WELCOME ENDP 

;---------------------------------------------------
FCFS PROC
;	
; Calculating the head movement using the FCFS algorithm,
; FCFS - First Come First Serve . 
; Receives: none 
; Returns: EAX = sum of head movements
;---------------------------------------------------
	PUSH EBP
	MOV	 EBP, ESP
	
	MOV  ECX, ARRAY_LEN ;Counter for the loop	
	SUB  ECX, 1			;Subtract one not to exceed the array size
	MOV  ESI, 0         ;The index for the array
	
	MOV  EBX, HEADsTART ;EBX has the user input for head start

	SUB EBX, ARRAY[ESI] ;ARRAY[0] 
	JNS CONTINUE	    ;An instruction to check if sign-flag turned on (jump if not signed)
	
	NEG EBX			    ;The instruction to apply depending on the case 
	
CONTINUE:
	
	ADD HEADmOVMENT, EBX ;The result is the head movement

CALClOOP:
	
	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI+4]
	
	JNS INNER ;An instruction to check if sign-flag turned on (jump if not signed)

	NEG EBX	  ;The instruction to apply depending on the case 

INNER:	
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	ADD ESI, TYPE DWORD

	LOOP CALClOOP 

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CALL CRLF

	MOV  EDX, OFFSET RESULT_F
	CALL WRITESTRING ;Displaying the message

	MOV EAX, HEADmOVMENT
	CALL WRITEDEC
	
	CALL CRLF
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	POP EBP
	RET ;Return control to the calling proc
	
FCFS ENDP

;---------------------------------------------------
SCAN PROC
;	
; Calculating the head movement using the SCAN algorithm 
; Receives: Array of element 
; Returns: EAX = sum of head movements
;---------------------------------------------------
	PUSH EBP
	MOV	 EBP, ESP
	
	MOV HEADmOVMENT, 0 ;To save a new value from that proc
	MOV ECX, ARRAY_LEN
	SUB ECX, 1
	
	MOV ESI, 0
	
	COMMENT~
	There are 3 situaions to tack care of
	The first if the head start is 0 or the first element in the array.
	The second if the head start is between 0 and 4999, what will make the program
	go to both ends.
	The third is if head start is 4999 or the last element in the array.~
	
	;START
	CMP HEADsTART, 0
	JE ZERO
	MOV EBX, ARRAY[0]
	CMP HEADsTART, EBX
	JE L_ZERO 
	
	;END
	MOV ESI, 999 * TYPE ARRAY 
	CMP HEADsTART, 4999 
	JE BACK
	MOV EBX, ARRAY[ESI] 
	CMP HEADsTART, EBX
	JE BACK_L
	
	;MIDDLE
	JMP MIDDLE ;If it will get to here it's defiantly in between 
	
ZERO:

	MOV EBX, HEADsTART ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI];ARRAY[0] 
	NEG EBX			   ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement

L_ZERO:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI+4]

	NEG EBX	  ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	ADD ESI, TYPE DWORD

	LOOP L_ZERO 
	
	;Adding the last value which is the end of the line sequence:
	MOV EBX, 4999		
	SUB EBX, ARRAY[ESI]
	ADD HEADmOVMENT, EBX
	
	JMP EXIT_SCAN

MIDDLE:

	CALL SEARCH ;To find the next request 
	
	;Case 1:
	CMP ECX, 0
	JE NOT_FOUND_TOP
	
	;Case 2:
	CMP ECX, ARRAY_LEN
	JE NOT_FOUND_BOTTOM
	
	;Case 3:
	JMP MIDDLE_UP

NOT_FOUND_TOP:
	
	COMMENT~
	If ECX is 0 that means that search proc tried to find in the list the key the user entered and it
	did not find it, BUT the key is greater than the list and smaller than the last element which is 
	4999.~
	
	;Calculating backward using the "back" section in the proc  
	MOV ECX, ARRAY_LEN ;ECX is 0 therefore need to assign back the (length - 1)
	SUB ECX, 1
	
	JMP BACK

NOT_FOUND_BOTTOM:
	
	SUB ECX, 1
	JMP ZERO 
	
MIDDLE_UP:;----------------------------------------------------------------
	
	COMMENT~
	At this point, if the assambler got to here ECX is not 0 and ESI pointing to the next element.
	Now, calculate the #'s going up and than down to the last element.~
	
	PUSH ESI ;To use the last position of ESI
	PUSH ECX ;To save the count for the calculation
	SUB ECX, 1
	
	MOV EBX, HEADsTART  ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI] ;ARRAY[search] 
	NEG EBX			    ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement


MIDDLE_UP_L:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI+4]
	
	NEG EBX	  ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	ADD ESI, TYPE DWORD

	LOOP MIDDLE_UP_L 
	
	;Adding the last value which is the end of the line sequence:
	MOV EBX, 4999
	SUB EBX, ARRAY[ESI]
	ADD HEADmOVMENT, EBX
	
MIDDLE_DOWN:;----------------------------------------------------------------

	;Restoring the values:
	POP ECX
	POP ESI 

	MOV EDX, ARRAY_LEN
	SUB EDX, ECX
	MOV ECX, EDX 
	SUB ECX, 1
	
	SUB ESI, TYPE DWORD
	
	;Going backward with the count:
	MOV EBX, 4999 ;4999
	SUB EBX, ARRAY[ESI]
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	
MIDDLE_DOWN_L:
	
	JMP BACK_L

BACK:;----------------------------------------------------------------

	MOV EBX, HEADsTART ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI];ARRAY[last element] 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement

BACK_L:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI - 4]
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	SUB ESI, TYPE DWORD

	LOOP BACK_L
	
EXIT_SCAN:
	
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CALL CRLF

	MOV  EDX, OFFSET RESULT_S
	CALL WRITESTRING ;Displaying the message

	MOV EAX, HEADmOVMENT
	CALL WRITEDEC
	
	CALL CRLF
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	POP EBP
	RET ;Return control to the calling proc 
SCAN ENDP

;---------------------------------------------------
LOOK PROC
;	
; Calculating the head movement using the LOOK algorithm 
; Receives: none 
; Returns: EAX = sum of head movements
;---------------------------------------------------
	PUSH EBP
	MOV	 EBP, ESP
	
	MOV HEADmOVMENT, 0 ;To save a new value from that proc
	MOV ECX, ARRAY_LEN
	SUB ECX, 1
	
	MOV ESI, 0
	
	COMMENT~
	There are 3 situations to tack care of
	The first if the head start is 0 or the first element in the array.
	The second if the head start is between 0 and 4999, what will make the program
	go to both ends.
	The third is if head start is 4999 or the last element in the array.~
	
	;START
	CMP HEADsTART, 0
	JE ZERO
	MOV EBX, ARRAY[0]
	CMP HEADsTART, EBX
	JE L_ZERO 
	
	;END
	MOV ESI, 999 * TYPE ARRAY 
	CMP HEADsTART, 4999 
	JE BACK
	MOV EBX, ARRAY[ESI] 
	CMP HEADsTART, EBX
	JE BACK_L
	
	;MIDDLE
	JMP MIDDLE ;If it will get to here it's defiantly in between 
	
ZERO:

	MOV EBX, HEADsTART ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI];ARRAY[0] 
	NEG EBX			   ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement

L_ZERO:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI+4]

	NEG EBX	  ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	ADD ESI, TYPE DWORD

	LOOP L_ZERO 
	
	JMP EXIT_SCAN

MIDDLE:

	CALL SEARCH ;To find the next request 
	
	;Case 1:
	CMP ECX, 0
	JE NOT_FOUND_TOP
	
	;Case 2:
	CMP ECX, ARRAY_LEN
	JE NOT_FOUND_BOTTOM
	
	;Case 3:
	JMP MIDDLE_UP

NOT_FOUND_TOP:
	
	COMMENT~
	If ECX is 0 that means that search proc tried to find in the list the key the user entered and it
	did not find it, BUT the key is greater than the list and smaller than the last element which is 
	4999.~
	
	;Calculating backward using the "back" section in the proc  
	MOV ECX, ARRAY_LEN ;ECX is 0 therefore need to assign back the (length - 1)
	SUB ECX, 1
	
	JMP BACK

NOT_FOUND_BOTTOM:
	
	SUB ECX, 1
	JMP ZERO 
	
MIDDLE_UP:;----------------------------------------------------------------
	
	COMMENT~
	At this point, if the assambler got to here ECX is not 0 and ESI pointing to the next element.
	Now, calculate the #'s going up and than down to the last element.~
	
	PUSH ESI ;To use the last position of ESI
	PUSH ECX ;To save the count for the calculation
	SUB ECX, 1
	
	MOV EBX, HEADsTART  ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI] ;ARRAY[search] 
	NEG EBX			    ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement


MIDDLE_UP_L:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI+4]
	
	NEG EBX	  ;The instruction to apply depending on the case 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	ADD ESI, TYPE DWORD

	LOOP MIDDLE_UP_L 
	
MIDDLE_DOWN:;----------------------------------------------------------------

	;Restoring the values:
	POP ECX
	POP ESI 

	MOV EDX, ARRAY_LEN
	SUB EDX, ECX
	MOV ECX, EDX 
	SUB ECX, 1
	
	SUB ESI, TYPE DWORD
	
	;Going backward with the count:
	MOV EBX, 4999 
	SUB EBX, ARRAY[ESI]
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	
MIDDLE_DOWN_L:
	
	JMP BACK_L

BACK:;----------------------------------------------------------------

	MOV EBX, HEADsTART ;EBX has the user input for head start
	SUB EBX, ARRAY[ESI];ARRAY[last element] 
	
	ADD HEADmOVMENT, EBX ;The result is the head movement

BACK_L:	

	MOV EBX, ARRAY[ESI]
	SUB EBX, ARRAY[ESI - 4]
	
	ADD HEADmOVMENT, EBX ;The result is the head movement
	SUB ESI, TYPE DWORD

	LOOP BACK_L
	
EXIT_SCAN:

	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CALL CRLF

	MOV  EDX, OFFSET RESULT_L
	CALL WRITESTRING ;Displaying the message

	MOV EAX, HEADmOVMENT
	CALL WRITEDEC
	
	CALL CRLF
	;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	POP EBP
	RET ;Return control to the calling proc
LOOK ENDP

;-------------------------------------------------------
BUBBLESORT PROC USES EAX ECX ESI,

; Sort an array of 32-bit signed integers in ascending
; order, using the bubble sort algorithm.
; Receives: pointer to array, array size
; Returns: nothing
;-------------------------------------------------------

	;pArray: PTR DWORD, ; pointer to array
	;Count :     DWORD  ; array size

	;mov ecx,Count
	MOV  ECX, ARRAY_LEN
	DEC  ECX 		    ; decrement count by 1

L1: PUSH ECX		    ; save outer loop count
	MOV  ESI, ARRAY_PTR ; point to first value

L2: MOV  EAX,     [ESI] ; get array value
	CMP  [ESI+4], EAX   ; compare a pair of values
	JG L3 			    ; if [ESI] <= [ESI+4], no exchange
	XCHG EAX,   [ESI+4] ; exchange the pair
	MOV  [ESI], EAX

L3: ADD  ESI, 4 		; move both pointers forward
	LOOP L2 		    ; inner loop
	POP  ECX 		    ; retrieve outer loop count
	LOOP L1 		    ; else repeat outer loop

L4: RET

BUBBLESORT ENDP

;----------------------------------------------------
PRINT PROC USES EAX ECX ESI
; Prints all the elements inside the array
; Receives: None
; Returns: None 
;---------------------------------------------------
	PUSH EBP
	MOV EBP, ESP 
	
	MOV ECX, ARRAY_LEN
	MOV ESI, 0
	
ARR_PRINT: ; Array print 
	MOV EAX, ARRAY[ESI]
	CALL WRITEDEC
	CALL CRLF
	
	ADD ESI, TYPE DWORD 
	LOOP ARR_PRINT
	
	CALL CRLF
	
	POP EBP
	RET
PRINT ENDP

;-----------------------------------------------------
SEARCH PROC
; Searching for the position where the next request 
; suppose to be executed 
;  
; Receives: Array
; Returns: ESI pointing to the next request
;		   ECX shows counting number 
;-----------------------------------------------------	
	PUSH EBP
	MOV	 EBP, ESP

	MOV EBX, HEADsTART
	MOV ECX, ARRAY_LEN
	MOV ESI, 0
	
SEARCH_L:

	CMP ARRAY[ESI], EBX
	JAE  FINISH 		;Jump if above or equal
	
	ADD ESI, TYPE DWORD ;Adding 4 for the next element

	LOOP SEARCH_L
	
	SUB ESI, 4 			;Keep ESI pointing to the last element
	
FINISH: 				;ESI has the right element to point to 

	POP EBP
	RET 				;Return control to the calling proc 
SEARCH ENDP 

	END MAIN