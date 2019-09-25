.PHONY : everything

everything : compile fd.img
	dd if=lib_test.bin of=fd.img conv=notrunc

compile: lib_test.asm
	nasm lib_test.asm -o lib_test.bin -DLIB_TEST
