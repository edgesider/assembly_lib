everything: main.asm img/fd.img img/hd.img bin/
	nasm main.asm -o bin/main.bin -I../lib
	dd if=bin/main.bin of=img/fd.img conv=notrunc
	dd if=bin/loader.bin of=img/hd.img conv=notrunc

test: main.asm img/fd.img img/hd.img bin/
	nasm main.asm -o bin/main.bin -I../lib
	nasm test_loader/loader.asm -o test_loader/loader.bin -I../lib
	dd if=bin/main.bin of=img/fd.img conv=notrunc
	dd if=test_loader/loader.bin of=img/hd.img conv=notrunc
