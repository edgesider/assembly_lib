.PHONY : everything

everything: img/fd.img compile
	dd if=bin/main.bin of=img/hda.img conv=notrunc

makehd: img/string.txt img/hdb.img
	dd if=img/string.txt of=img/hdb.img conv=notrunc

compile: main.asm
	nasm main.asm -o bin/main.bin -I../../lib
