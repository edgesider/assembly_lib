.PHONY : everything

everything : main.asm fd.img
	nasm main.asm -o main.bin
	dd if=main.bin of=fd.img conv=notrunc
