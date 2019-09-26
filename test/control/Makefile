.PHONY : everything

everything : main.asm fd.img
	nasm main.asm -o main.bin -I../../lib
	dd if=main.bin of=fd.img conv=notrunc

clean:
	rm main.bin
