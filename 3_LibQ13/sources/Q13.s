@;----------------------------------------------------------------
@;  DESCRIPCIÓ DEL QUE FA EL CODI
@;----------------------------------------------------------------
@;	Programador/a 1: adria.estrade@estudiants.urv.cat
@;	Programador/a 2: carlota.sarrate@estudiants.urv.cat
@;----------------------------------------------------------------*
.include "Q13.i"
.data
.bss
		.align 2
	quocient: 	.space 4
	modul:      .space 4
.text
	.align 2
	.arm
	
@; add_Q13():	calcula i retorna la suma dels 2 primers operands,
@; 				(num1 --> r0 + num2-->1)	codificats en Coma fixa 1:18:13.
@;				El 3r paràmetre --> r2 (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@;
.global add_Q13
add_Q13:
	push {r1-r4,lr}
	
	adds r3, r0, r1     @; suma amb actualització de flags
	bvs .LIf_maskSum    @; salt si el bit overflow és cert
	mov r4, #0
	b .LEndIf_maskSum
	
	.LIf_maskSum:
		mov r4, #1
	.LEndIf_maskSum:
	strb r4, [r2]       @; guardem valor overflow
	mov r0, r3
	
	pop {r1-r4,pc}

@; sub_Q13():	calcula i retorna la resta dels 2 primers operands,
@; 				(num1 --> r0 - num2--> r1) codificats en Coma fixa 1:18:13.
@;				El 3r paràmetre --> r2 (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;			    1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@;
.global sub_Q13
sub_Q13:
	push {r1-r4,lr}
	
	subs r3, r0, r1     @; resta amb actualització de flags
	bvs .LIf_maskSub    @; salt si el bit overflow és cert
	mov r4, #0
	b .LEndIf_maskSub
	
	.LIf_maskSub:
		mov r4, #1
	.LEndIf_maskSub:
	strb r4, [r2]       @; guardem valor overflow
	mov r0, r3
	
	pop {r1-r4,pc}

@; mul_Q13():	calcula i retorna el producte dels 2 primers operands,
@;  (num1 --> r0 * num2--> r1)	codificats en Coma fixa 1:18:13.
@;				El 3r paràmetre --> r2 (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@;
.global mul_Q13
mul_Q13:
push {r1-r11,lr}
	ldr r3, =0xFFFFFFFF        @; màscara per la part alta (r6)
	ldr r4, =MASK_SIGN         @; màscara per la part baixa (r5) 0x80000000
    mov r9, #0                 @; inicialitzem valor del overflow
	
	smull r5, r6, r0, r1       @; realitzem multiplicació(r5=baixos, r6=alts)
	@; mov r6, r5, lsl #19     @; bits que ja no formaran part resultat multiplicacio
	mov r5, r5, lsr #13        @; desplacem a la dreta part baixa	
	orr r5, r6, lsl #19		   @; afegim a r4 els bits que hem tret de la part baixa
	mov r6, r6, asr #13        @; desplaçem a la dreta la part alta
	and r7, r6, r3          
	and r8, r5, r4
	cmp r6, r3                
	beq .LIf1_maskMul         @; suposa que valor és negatiu (part alta tot F)
	b .LIf2_maskMul           @; suposa que valor és positiu (part alta tot 0)
	.LIf1_maskMul:
		cmp r8, r4            @; comprobar si signe és negatiu
		moveq r10, #1         @; part alta + mascara = mascara part alta
		cmp r7, r3            @; part alta té que ser tot F   
		moveq r11, #1         @; part baixa + mascara = mascara part baixa
		cmp r10, r11  
		movne r9, #1          @; valor no es negatiu -> bits 63 a 31 no= 1
		b .LEndIf2_maskMul
	.LEndIf1_maskMul:
	
	.LIf2_maskMul:
		cmp r8, #0            @; comprobar si signe és positiu
		moveq r10, #1         @; part alta + mascara = mascara part alta
		cmp r7, #0            @; part alta té que ser tot 0 
		moveq r11, #1         @; part baixa + mascara = mascara part baixa
		cmp r10, r11          
		movne r9, #1          @; valor no es positiu -> bits 63 a 31 no= 0
	.LEndIf2_maskMul:
	strb r9, [r2]             @; guardem valor overflow
	mov r0, r5
	pop {r1-r11,pc}

@; div_Q13():	calcula i retorna la divisió dels 2 primers operands,
@; (num1--> r0 /num2-->r1) codificats en Coma fixa 1:18:13.
@;				El 3r paràmetre-->r2 (per referència) retorna l'overflow:
@;				0: no s'ha produït overflow, resultat correcte.
@;				1: hi ha overflow (resultat massa gran) i el que es
@;				   retorna són els bits baixos del resultat.
@;
.global div_Q13
div_Q13:
	push {r1-r7,lr}
	ldr r4, =MASK_SIGN @; màscara de signe 0x80000000
	
	cmp r1, #0            @; control de divisions per 0
	bne .LEndIf_maskDiv   @; num 2 no= 0
	
	.LIf_maskDiv:     @; num2 = 0 -> hi ha overflow i div = 0
		mov r0, #0
		mov r4, #1
		strb r4,[r2]  @; guardem valor overflow
		b .LFiFuncio
	.LEndIf_maskDiv:	
	and r5, r1, r4
	cmp r5, r4         @; comprobació si num2 (denominador) és negatiu
	rsbeq r1, r1, #0   @; valor absolut divisor
	
	@; canviem de lloc les variables per no sobreescriure-les
	mov r6, r0    @; guardem numerador
	mov r7, r2 	  @; guardem adreça 3r paràmetre
	
	@; preparem registres per invocar divmod
	ldr r0, =0x2000  	   @; MAKE_Q13(1) -> 1*2^13
	mov r0, r0, lsl #13    @; ((1) << 13)
	ldr r2, =quocient
	ldr r3, =modul
	bl div_mod
	
	@; preparem registres per invocar mul_Q13
	mov r0, r6      @; retorna el numerador
	ldr r1, [r2] 	@; resultat de la divisió
	mov r2, r7      @; retorna adreça 3r paràmetre
	bl mul_Q13
	
	cmp r5, r4          @; comprobació si num2 (denominador) era negatiu
	rsbeq r0, r0, #0 	@; canvi de signe al resultat
	.LFiFuncio:
	
	pop {r1-r7,pc}	
.end


