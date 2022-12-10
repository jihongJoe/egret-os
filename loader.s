/* ; 对于BootLoader来讲, 他不知道什么是kernel, 他只按照设定位置开始运行程序, 所以我们需要将kernel程序写入到指定的位置 0x1badb002 没有原因, 太爷爷们的规定
注意: .开头不会被翻译成机器指令, 而是给汇编器一种特殊知识, 称之为汇编指示,或者委操作 */
.set MAGIC, 0x1badb002  /*GRUB魔术块*/
.set FLAGS, (1<<0 | 1<<1)  /*;GRUB标志块*/
.set CHECKSUM, -(MAGIC + FLAGS)  /*;校验块*/

/* ; Boot程序按照Mutileboot 规范来编译内核，才可以被GRUB引导 */
.section .multboot
    .long MAGIC
    .long FLAGS
    .long CHECKSUM

/*  */
.section .text /* 代码段 */

/* 引用外部函数, 调用时候可以遍历所有文件找到该函数 
    这里之所以需要增加一个_kernel的"_" 是因为在ld时找不到函数所在, 这是因为kernel.cpp文件在经过编译之后
    已经变成了call   87 <_kernelMain+0x9>, 所以这里需要使用_kernelMain来引入
    查看命令 objdump -d kernel.o
*/
.extern _kernelMain 
.extern _system_constructors /* 引用外部函数, 调用时候可以遍历所有文件找到该函数 */
.global loader /* .global 表示全局可见 */

/* AT&T 和 Intel对寄存器使用不一样, Intel不加符号, 而At&T使用% 
    下面先把两个寄存器数据(eax, ebx)压栈, 然后调用函数 kernelMain, 并且将两个参数传递给这个函数
*/
loader: 
    mov $kernel_stack, %esp
    call _system_constructors
    push %eax 
    push %ebx 
    call _kernelMain /* 这里就是引导执行这个函数, 这个函数在kernel.cpp里面定义 */

/* 
    cli ; 将IF置0，屏蔽掉“可屏蔽中断”，当可屏蔽中断到来时CPU不响应，继续执行原指令
    hlt ; 本指令是处理器“暂停”指令。
    jmp _stop ; 命令跳转指令
 */
_stop:
    cli 
    hlt 
    jmp _stop

/* ; 未初始化变量端 */
.section .bss

/*  这个段开辟空间是2M */
.space 2*1024*1024 

/*  */
kernel_stack:
