# 依赖的公共模块
# GCCPARAMS = -m32 -W -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
GPPPARAMS = -m32 -Iinclude -fno-use-cxa-atexit -fleading-underscore -fno-exceptions -fno-builtin -nostdlib -fno-rtti -fno-pie
ASPARAMS = --32
LDPARAMS = -melf_i386 -no-pie


objects = loader.o kernel.o

# $@ 取所有输出文件
# $< 取第一个依赖
# 使用命令 make kernel.o 就会运行对应的 `clang++ -c -o kernel.o kernel.cpp`
# 使用命令 make loader.o 就会运行对应的 `as -o loader.o loader.s`
# g++ 使用-m32指定生成32位文件
# as  使用--32指定生成32位文件
%.o: %.cpp
	g++ ${GPPPARAMS} -o $@ -c $<

%.o: %.s
	as ${ASPARAMS} -o $@ $<

# 这里先执行make clean, 然后在执行make mykernel.bin
all: clean mykernel.bin
	echo "build successed"

# ld -T的意思是 运行普通ld脚本
# 这里执行 make mykernel.bin会生成mykernel.bin
mykernel.bin: linker.ld ${objects}
	ld ${LDPARAMS} -T $< -o $@ ${objects}


install: mykernel.bin
	sudo cp $< /boot/mykernel.bin

# 执行make clean 将全部的中间文件进行删除
clean: 
	rm -rf *.o *.out *.bin *.iso iso

# 制作启动工具 执行make mykernel.iso
mykernel.iso : mykernel.bin
	mkdir -p iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout=8\n\
	set default=0\n\
	menuentry "my os" {\n\
		multiboot /boot/mykernel.bin\n\
		boot\n\
	}' > iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso

