.PHONY : everything

everything : libtest

libtest: compile_lib fd.img
	dd if=lib_test.bin of=fd.img conv=notrunc

compile_lib: lib_test.asm
	nasm lib_test.asm -o lib_test.bin

controltest: fd.img compile_control
	dd if=test_control.bin of=fd.img conv=notrunc

compile_control: test_control.asm
	nasm test_control.asm -o test_control.bin

clean:
	rm test_control.bin lib_test.bin
