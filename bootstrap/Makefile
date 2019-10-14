.PHONY : everything

HDTMP:=../image_template/hd.img
FDTMP:=../image_template/fd.img

everything: main.asm img/fd.img img/hd.img bin/
	nasm main.asm -o bin/main.bin
	dd if=bin/main.bin of=img/fd.img conv=notrunc
	dd if=bin/loader.bin of=img/hd.img conv=notrunc

createimg: $(HDTMP) $(FDTMP)
	cp $(HDTMP) ./img/hd.img
	cp $(FDTMP) ./img/fd.img

test: main.asm img/fd.img img/hd.img bin/
	nasm main.asm -o bin/main.bin
	nasm test_loader/loader.asm -o test_loader/loader.bin -I../lib
	dd if=bin/main.bin of=img/fd.img conv=notrunc
	dd if=test_loader/loader.bin of=img/hd.img conv=notrunc
