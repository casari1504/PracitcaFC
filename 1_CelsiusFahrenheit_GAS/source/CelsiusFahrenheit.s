@;----------------------------------------------------------------
@;  CelsiusFahrenheit.s: rutines de conversió de temperatura en 
@;						 format Q13 (Coma Fixa 1:18:13). 
@;----------------------------------------------------------------
@;	santiago.romani@urv.cat
@;	pere.millan@urv.cat
@;	(Març 2021, Març 2022, Març 2023, Febrer 2024)
@;----------------------------------------------------------------
@;	Programador/a 1: adria.estrade@estudiants.urv.cat
@;	Programador/a 2: carlota.sarrate@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "Q13.i"


.text
		.align 2
		.arm

@; Celsius2Fahrenheit(): converteix una temperatura en graus Celsius a la
@;						temperatura equivalent en graus Fahrenheit, utilitzant
@;						valors codificats en Coma Fixa 1:18:13.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input * 9/5) + 32.0;
	.global Celsius2Fahrenheit
Celsius2Fahrenheit:
		push {r1-r4,lr}
			ldr r1,=0x399A @; 1,8*8192(2^13)=14746
			ldr r2,=0x40000 @; 32*2^13
			
			smull r3,r4, r0,r1			
			mov r3, r3, lsr #13 @; quan es multiplica s'ha de dividir per 2^n 
								@;--> arm no pot dividir, movem bits	
			orr r3, r4, lsl #19 									
			add r0,r2,r3
			
		pop {r1-r4,pc}

@; Fahrenheit2Celsius(): converteix una temperatura en graus Fahrenheit a la
@;						temperatura equivalent en graus Celsius, utilitzant
@;						valors codificats en Coma Fixa 1:18:13.
@;	Entrada:
@;		input 	-> R0
@;	Sortida:
@;		R0 		-> output = (input - 32.0) * 5/9;
	.global Fahrenheit2Celsius
Fahrenheit2Celsius:
		push {r1-r4, lr}
			ldr r1,=0x11C7  @;0,56 (5/9) * 2^13 
			ldr r2,=0x40000 @; 32*2^13
			
			sub r0, r2
			smull r3,r4,r0, r1
			mov r3, r3, lsr #13
			orr r3, r4, lsl #19 
			
			mov r0,r3			
		pop {r1-r4, pc}
.end
