#-------------------------------------------------------------------------------
# Example Makefile to build a library and to test the functions of each module
# Authors: Santiago Romaní, Pere Millán
# Date: May 2020, March 2021, March 2022, March 2023, February 2024
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Programador/a 1: adria.estrade@estudiants.urv.cat
# Programador/a 2: carlota.sarrate@estudiants.urv.cat
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# options for code generation
#-------------------------------------------------------------------------------
ARCH	:= -march=armv5te -mlittle-endian
INCL    := -I./include
ASFLAGS	:= $(ARCH) $(INCL) -g
CCFLAGS	:= -Wall -gdwarf-3 -O0 $(ARCH) $(INCL)
LDFLAGS := -z max-page-size=0x8000 -Lp_lib

#-------------------------------------------------------------------------------
# make commands
#-------------------------------------------------------------------------------
geotemp.elf : build/avgmaxmintemp.o build/geotemp.o build/data.o
	arm-none-eabi-ld $(LDFLAGS) build/avgmaxmintemp.o build/data.o build/geotemp.o \
						p_lib/CelsiusFahrenheit.o p_lib/libfoncompus.a p_lib/startup.o -o geotemp.elf
						
build/geotemp.o : source/geotemp.c include/Q13.h include/divmod.h include/CelsiusFahrenheit.h \
    include/avgmaxmintemp.h include/geotemp.h include/data.h 
	arm-none-eabi-gcc $(ASFLAGS) -c source/geotemp.c -o build/geotemp.o
	
build/data.o : source/data.c include/Q13.h include/geotemp.h include/data.h
	arm-none-eabi-gcc $(ASFLAGS) -c source/data.c -o build/data.o

build/avgmaxmintemp.o : source/avgmaxmintemp.s include/avgmaxmintemp.i include/CelsiusFahrenheit.h
	arm-none-eabi-as $(ASFLAGS) -c source/avgmaxmintemp.s -o build/avgmaxmintemp.o

test_geotemp.elf : p_lib/startup.o p_lib/CelsiusFahrenheit.o p_lib/libfoncompus.a build/test_geotemp.o build/avgmaxmintemp.o 
	arm-none-eabi-ld $(LDFLAGS) build/test_geotemp.o build/avgmaxmintemp.o p_lib/startup.o p_lib/CelsiusFahrenheit.o p_lib/libfoncompus.a -o test_geotemp.elf

build/test_geotemp.o : tests/test_geotemp.c include/avgmaxmintemp.h include/Q13.h 
	arm-none-eabi-gcc $(CCFLAGS) -c tests/test_geotemp.c -o build/test_geotemp.o

#-------------------------------------------------------------------------------
# clean commands
#-------------------------------------------------------------------------------
clean : 
	@rm -fv build/*
	@rm -fv *.elf


#-----------------------------------------------------------------------------
# run commands
#-----------------------------------------------------------------------------
run : geotemp.elf
	arm-eabi-insight geotemp.elf &


#-----------------------------------------------------------------------------
# debug commands
#-----------------------------------------------------------------------------
debug : test_geotemp.elf
	arm-eabi-insight test_geotemp.elf &
