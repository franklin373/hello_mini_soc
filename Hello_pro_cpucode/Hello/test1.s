	AREA    JJJ101, CODE, READONLY
	ARM

	export ram_test2_assembly
ram_test2_assembly
	mov r0,#0xff
	mov r1,#0x40000000
	strb r0,[r1,#0]
	mov r0,#0x75
	strb r0,[r1,#1]
;	NOP
	mov r0,#3
	strb r0,[r1,#2]
	mov r0,#4
	strb r0,[r1,#3]
	mov r0,#0x40000000
	ldr r0,[r0,#0]
	bx lr



	END
