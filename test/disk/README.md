# disk.asm

## Build

```bash
make createimg # create hda.img, hdb.img, fd.img to img folder
make writehd # this command will write content of string.txt to start of hd.img
make # compile and write to fd.img
```
## Run

```bash
./qemu.sh
```

or

```bash
bochs -q
```
