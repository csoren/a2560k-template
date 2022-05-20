	SECTION "code",CODE	; Everything following this line will be
				; put in the section "code"

Hello::				; Define and export (::) the symbol "Hello"
				; This is the entry point of the Hello()
				; function

	move.l  #.hello,d0	; d0 (return value) = address of string
	rts			; return to C

.hello	DC.B    "Hello",0	; define a null-terminated C string, assign
				; its address to the local label ".hello"

