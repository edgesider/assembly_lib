.PHONY : everything

HDTMP:=../../image_template/hd.img
FAT12TMP=../../image_template/hd_fat12.img
FDTMP:=../../image_template/fd.img

everything: img/fd.img main.asm
	nasm main.asm -o bin/main.bin -I../../lib
	dd if=bin/main.bin of=img/hda.img conv=notrunc

createimg: $(HDTMP) $(FDTMP) $(FAT12TMP)
	cp $(HDTMP) ./img/hda.img
	cp $(FAT12TMP) ./img/hdb.img
	cp $(FDTMP) ./img/fd.img
