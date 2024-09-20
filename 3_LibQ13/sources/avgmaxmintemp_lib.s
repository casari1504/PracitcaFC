@;----------------------------------------------------------------
@;  avgmaxmintemp.s: rutines de càlcul de valors mitjans, màxims
@; 	i mínims d'una taula de temperatures, expressades en graus
@; 	Celsius o Fahrenheit, en format Q13 (coma fixa 1:18:13).
@;----------------------------------------------------------------
@;	Programador/a 1: adria.estrade@estudiants.urv.cat
@;	Programador/a 2: carlota.sarrate@estudiants.urv.cat
@;----------------------------------------------------------------*/

.include "avgmaxmintemp.i"
 
.data
.bss
		.align 2
	avg: 	.space 4
	modul:  .space 4
.text
	.align 2
	.arm
@;avgmaxmin_city(): calcula la temperatura mitjana, màxima i mínima d'una
@;				ciutat d'una taula de temperatures, amb una fila per ciutat i
@;				una columna per mes, expressades en graus Celsius en format Q13.
@;ENTRADA
@;	ttemp[][12]	->	taula de temperatures, amb 12 columnes i nrows files  r0 
@;	nrows		->	número de files de la taula 						  r1
@;	id_city		->	índex de la fila (ciutat) a processar                 r2
@;	*mmres		->	adreça de l'estructura t_maxmin que retornarà els     r3
@;							resultats de temperatures màximes i mínimes
.global avgmaxmin_city	
avgmaxmin_city:	
	push {r1-r12, lr}
	
		mov r4, #12             
		mul r5, r2, r4            
		ldr r4,[r0, r5, lsl #2]   @; inicialitzem valor avg (carreguem primera tempratura)
		                          @; r4 = adreca + (i*col+j)*tamany(bytes) -> r0 + (r2*12+0) * byte
		mov r6, r4	        @; inicialitzem valor max = avg
		mov r7, r4          @; inicialitzem valor min = avg
		mov r8, #1          @; inicialitzem i (fins i < 12)	
		mov r11, #0         @; inicialitza posció index del màxim
		mov r12, #0	        @; inicialitza posció index del mínim
		
		mov r9, r0   @; canviem de posició els registres per deixar r0 lliures
		mov r0, r4   @; r0 = avg
		
		.LForCity:	
			add r5, #1
			ldr r1,[r9, r5, lsl #2]   @; calculem mitjana (sumem temperatures)
			bl add_Q13
			
			cmp r7, r1 	    @; comprobem nou mínim
			movgt r7, r1    @; actualitzem nou mínim  a < b
			movgt r12, r8   @; actualitzem index mínim
			
			cmp r6, r1 	    @; comprobem nou màxim
			movlt r6, r1    @; actualitzem nou màxim  a > b 
			movlt r11, r8   @; actualitzem index màxim

			add r8, #1		@; actualitzem i
			cmp r8, #12     @; condició final bucle
			blt .LForCity
		.LForCityEnd: 			  
				  
		mov r8, r3                  @; r8 passa a ser mmres
		mov r9, r0                  @; r9=r0(total avg)

		str r7 ,[r8, #MM_TMINC]    @; carregar temperatura min en Cº
		str r6 ,[r8, #MM_TMAXC]    @; carregar temperatura max en Cº
		strh r12 ,[r8, #MM_IDMIN]  @; índex temperatura mínima
		strh r11 ,[r8, #MM_IDMAX]  @; índex temperatura màxima
		
		mov r0, r7
		bl Celsius2Fahrenheit
		str r0 ,[r8, #MM_TMINF]    @; carregar temperatura min en Fº
		
		mov r0, r6
		bl Celsius2Fahrenheit
		str r0 ,[r8, #MM_TMAXF]    @; carregar temperatura max en Fº

		mov r3, r8          @;tornem mmres a slot original
		
		@; calular mitjana  (dividim per 12)				
		cmp r9, #0           @; si r9<0 canviem signe
		rsblt r0,r9, #0 
		movge r0,r9
		ldr r1, =0x18000     @; nombre de files ((12) << 13)
		bl div_Q13 
		
		cmp r9,#0 
		rsblt r0,r0,#0       @; canviem el signe si r9<0 

	pop {r1-r12, pc}

@; avgmaxmin_month(): calcula la temperatura mitjana, màxima i mínima d'un mes
@;				d'una taula de temperatures, amb una fila per ciutat i una
@;				columna per mes, expressades en graus Celsius en format Q13.
@;	Paràmetres:
@;		ttemp[][12]	->	taula de temperatures, amb 12 columnes i nrows files r0
@;		nrows		->	número de files de la taula (mínim 1 fila)           r1
@;		id_month	->	índex de la columna (mes) a processar                r2
@;		*mmres		->	adreça de l'estructura t_maxmin que retornarà els    r3
@;						resultats de temperatures màximes i mínimes
@;	Resultat:	temperatura mitjana, expressada en graus Celsius, en format Q13.
.global avgmaxmin_month	
avgmaxmin_month:
	push {r1-r12, lr}
		
		mov r10, r0   @; canviem de posició el registres per deixar r0 lliure
		mov r4,r1     @; r4= nrows
		
		ldr r0,[r10, r2, lsl #2]   @; inicialitzem valor avg
		mov r6, r0	  @; inicialitzem valor max = avg
		mov r7, r0    @; inicialitzem valor min = avg
		mov r5, #12
		mov r8, #1    @; inicialitzem i (fins i < 12)
		mov r11, #0   @; poscio index del maxim
		mov r12, #0	  @; poscio index del minim
		.LForMonth:		
			mla r9, r8, r5, r2
			ldr r1,[r10, r9, lsl #2] @; calculem mitjana (sumem temperatures)
			bl add_Q13
			
			cmp r7, r1  	 @; comprobem nou mínim
			movgt r7, r1     @; actualitzem nou minim  a < b
			movgt r12, r8    @; actualitzem index mínim
			
			cmp r6, r1       @; comprobem nou màxim
			movlt  r6, r1    @; actualitzem nou màxim  a > b 
			movlt  r11, r8   @; actualitzem index màxim

			add r8, #1		 @; actualitzem i
			cmp r8, r4       @; condició final bucle
			blt .LForMonth
		.LForMonthEnd:
		
		mov r5, r3                 @; r5 passa a ser mmres
		mov r8, r0                 @; r8=r0 (total avg)
		
		str r7 ,[r5, #MM_TMINC]    @; carregar temperatura min en Cº
		str r6 ,[r5, #MM_TMAXC]    @; carregar temperatura max en Cº
		strh r12 ,[r5, #MM_IDMIN]  @; índex temperatura mínima
		strh r11 ,[r5, #MM_IDMAX]  @; índex temperatura màxima
		
		mov r0, r7
		bl Celsius2Fahrenheit
		str r0 ,[r5, #MM_TMINF]    @; carregar temperatura min en Fº
		
		mov r0, r6
		bl Celsius2Fahrenheit
		str r0 ,[r5, #MM_TMAXF]    @; carregar temperatura min en Fº
		
		mov r3, r5          @;tornem mmres a slot original
		
		@; calular mitjana  (dividim per nrows)
		cmp r8,#0           @; si r8<0 canviem signe
		rsblt r0,r8,#0
		movge r0,r8
		mov r1, r4, lsl #13        @; r1=( r4(nrows) << 13 ) 
		bl div_Q13 
		
		cmp r8,#0 
		rsblt r0,r0,#0    @; canviem el signe si r4<0 i retorn valor avg per r0 
	
	pop {r1-r12, pc}
.end



