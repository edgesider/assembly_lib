.PHONY : everything

HDTMP:=../../image_template/hd.img

everything : main.asm img/hd.img
	nasm main.asm -o bin/main.bin -I../../lib
	dd if=bin/main.bin of=img/hd.img conv=notrunc

createimg: $(HDTMP)
	cp $(HDTMP) ./img/hd.img
