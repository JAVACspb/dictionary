ASM=nasm
ASMFLAGS=-f elf64
LD=ld

run: clean main

main: main.o dict.o lib.o
	$(LD) -o $@ $^

main.o: main.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
	
dict.o: dict.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
	
lib.o: lib.asm
	$(ASM) $(ASMFLAGS) -o $@ $<
	
clean:
	rm -rf *.o main
	
.PHONY: clean run
