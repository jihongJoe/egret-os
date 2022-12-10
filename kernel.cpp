#include "types.h"

const int screen_width=80,screen_height=25;
// 这里给显存地址(0xb8000)写数据即可
int used;
void print_char(char c,int x,int y){
    static unsigned short* VideoMemory=(unsigned short*)0xb8000;
    int idx = y*screen_width+x;
    VideoMemory[idx]=(VideoMemory[idx] & 0xFF00)|c;
    used++;
}

void clear_screen(){
	//rows
	for(int y=0;y<screen_height;y++){
		//cols
		for(int x=0;x<screen_width;x++){
			print_char(x,y,'\0');
		}
	}
}

void print_string(char *str){
	//y-->rows,x-->cols
	static int x=0,y=0;
	
	//写入字符串，取或0xff00的意思是我们需要把屏幕高四位拉低，
	//否则就是黑色的字体，黑色的字体黑色的屏幕是啥也看不到的
	for(int i=0;str[i]!='\0';++i){
		//fistly check letter
		switch(str[i]){
			case '\n':
				y++;//checkout rows not output!!!
				x=0;
				break;
            case '\t':
				x+=4;
				break;
			default:
				//firstly,check pos
				if(x>=screen_width){
					y++;
					x=0;
				}
				if(y>=screen_height){
					clear_screen();	
					x=0;
					y=0;
				}
				//wait x,y outcome ,then output str[i] !!!
				//very important algorithm processs!!!	
				print_char(str[i],x,y);
				x++;
		}
	}
}


//操作系统构造函数委托方法
typedef void(*constructor)();
//全局定义构造委托
constructor start_ctors;
//全局定义析构委托
constructor end_ctors;

//轮询函数，并且执行
extern "C" void system_constructors(){
	for(constructor* i= &start_ctors; i != &end_ctors; i++){
		(*i)();
	}
}


// warning: ISO C++11 does not allow conversion from string literal to 'char *' [-Wwritable-strings]
// 这是由于下面定义方法是C, 使用extern "C" 表示是C语言
// void kernelMain(void * multiboot_structure, unsigned int magicnumber){
extern "C" void kernelMain(void* multiboot_structure, unsigned int magicnumber){ 
    print_string((char*)"welcome to egret os!");
    while(1);
}