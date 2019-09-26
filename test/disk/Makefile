.PHONY : everything

everything: fd.img compile
	dd if=main.bin of=fd.img conv=notrunc

makehd: string.txt hd.img
	sh -c "echo 'hello' > string.txt"
	dd if=string.txt of=hd.img conv=notrunc

compile: main.asm
	nasm main.asm -o main.bin -I../../lib

