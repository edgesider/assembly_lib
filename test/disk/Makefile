.PHONY : everything

HDTMP:=../../image_template/hd.img
FDTMP:=../../image_template/fd.img

everything: img/fd.img main.asm
	nasm main.asm -o bin/main.bin -I../../lib
	dd if=bin/main.bin of=img/hda.img conv=notrunc

createimg: $(HDTMP) $(FDTMP)
	cp $(HDTMP) ./img/hda.img
	cp $(HDTMP) ./img/hdb.img
	cp $(FDTMP) ./img/fd.img

writehd: img/string.txt img/hdb.img
	dd if=img/string.txt of=img/hdb.img conv=notrunc
