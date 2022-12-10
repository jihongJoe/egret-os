/* 入口参数 */
ENTRY(loader)
OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386:i386)
SECTIONS {
	. = 0x0100000;
	.text :{
		*(.muiltboot)
		*(.text*)
		*(.rodata)
	}
	.data :	{
        /* 将构造放到start到end意思就是把所有的对象都构造一遍 */
		/* 至于为何使用 "_" 这是因为通过对.o文件反编译发现, 里面call 的是 _start_ctors */
		_start_ctors = .;
        /* 这部分不要被垃圾回收 */
		KEEP(*(.init_array )); 
        /* init_array 构造函数初始化*/
		KEEP(*(SORT_BY_INIT_PRIORITY( .init_array.* )));
		_end_ctors = .;
		
		*(.data)
	}
	.bss :	{
		*(.bss)
	}
	/DISCARD/ : {
		*(.fini_array*) 
        *(.comment)
	}
}
