.PHONY : everything

HDTMP:=../../image_template/hd.img
FDTMP:=../../image_template/fd.img

everything: main.asm img/hd.img
	nasm main.asm -o bin/main.bin -I../../lib
	dd if=bin/main.bin of=img/hd.img conv=notrunc

createimg: $(HD_TMP)
	cp $(HDTMP) ./img/hd.img

clean:
	rm main.bin
