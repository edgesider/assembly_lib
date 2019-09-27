# Bootstrap

**"Pull itself up by its bootstrap".**

由`main.asm`编译出来的`main.bin`可以加载第一个硬盘设备的前面5120个字节到内存的0x8000地址，之后跳转到0x8000处执行。

在`make`之后，`img/fd.img`中会被写入这个bootstrap，然后可以将其他程序写进第一个硬盘设备，在机器从软盘启动（`img/fd.img`）之后，就会自动加载这个程序。

---

The main.bin compiled from main.asm will load first 5120 bytes of hda and then jump to its start.

We need to run `make` to write the bootstrap to `img/fd.img`. After that, others can use `fd.img` as the first boot and write their code to first hard disk. Then their code will work.
