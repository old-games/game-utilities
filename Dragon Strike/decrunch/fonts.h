/*void draw_window(BITMAP* screen,int x,int y,int w,int h){
char buf[200];
replace_filename(buf, argv0, "b1.bmp", sizeof(buf));
BITMAP *b1=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b2.bmp", sizeof(buf));
BITMAP *b2=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b3.bmp", sizeof(buf));
BITMAP *b3=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b4.bmp", sizeof(buf));
BITMAP *b4=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b5.bmp", sizeof(buf));
BITMAP *b5=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b6.bmp", sizeof(buf));
BITMAP *b6=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b7.bmp", sizeof(buf));
BITMAP *b7=load_bmp(buf,NULL);
replace_filename(buf, argv0, "b8.bmp", sizeof(buf));
BITMAP *b8=load_bmp(buf,NULL);

int w2;
if(w%6==0) w2=w/6;
else w2=w/6+1;
for(int i=0;i<w2;i++){
blit(b1,screen,0, 0, x+i*6,y-5,6,5);
blit(b2,screen,0, 0, x+i*6,y+h,6,5);
}
int h2;
if(h%6==0) h2=h/6;
else h2=h/6+1;
for(i=0;i<h2;i++){
blit(b4,screen,0, 0, x+w,y+i*6,5,6);
blit(b3,screen,0, 0, x-5,y+i*6,5,6);
}
blit(b8,screen,0, 0, x-5,y-5,5,5);
blit(b5,screen,0, 0, x+w,y-5,5,5);
blit(b7,screen,0, 0, x-5,y+h,5,5);
blit(b6,screen,0, 0, x+w,y+h,5,5);
}
*/

unsigned char to_rus(unsigned char c){
if(c>=224&&c<=239) return c-64;
if(c>=240) return c-16;
if(c>=192&&c<=223) return c-64;

return c;
}

int load_font(char *filename,BITMAP *font){
BITMAP *tmpfnt;
PALETTE pal;
tmpfnt=load_bmp(filename,pal);
blit(tmpfnt,font,0,0,0,0,256,128);
return 1;
}

void draw_char(BITMAP *where,BITMAP *fnt,int x, int y, char chr){
unsigned char p=to_rus(chr);
masked_blit(fnt,where,(p%32)*8,(p/32)*16,x,y,8,16);
}

//"star" effect
void draw_char2(BITMAP *where,BITMAP *fnt,int x, int y, char chr){
int func_x(int);
int func_y(int);
BITMAP * bmp_save  = create_bitmap(320,200);
BITMAP * bmp_save2 = create_bitmap(320,200);
blit(where,bmp_save,0,0,0,0,320,200); //save image from screen
unsigned char p=to_rus(chr);
int memx[8],memy[8],step[8];

for(int n=0;n<8;n++){
	memx[n]=0,memy[n]=0;step[n]=8-n;
}

int c=0;
while(c<8*15){
//for(int i=0;i<8;i++)
//for(int j=0;j<16;j++){
	for(int n=0;n<8;n++){
		int i=(c+n)%8;
		int j=(c+n)/8;

		int col=getpixel(fnt,(p%32)*8+i,(p/32)*16+j);
		if(col!=makecol(255,0,255)){
			putpixel(screen,x+i+func_x(n),y+j+func_y(n),col);
			if(n==7) putpixel(bmp_save,x+i+func_x(n),y+j+func_y(n),col);
		}
	}
rest(10);
blit(bmp_save,screen,0,0,0,0,320,200);
c++;
}
//blit(bmp_save,where,0,0,x,y,8,16);
//masked_blit(fnt,where,(p%32)*8,(p/32)*16,x,y,8,16);
}

int func_x(int t){
float R = 5, a=3.1415/10;
return R*sin(float(t)*a);
}
int func_y(int t){
float R = 5, a=3.1415/10;
return R*cos(float(t)*a-3.1415/2);
}

/*int gettext(BITMAP *where, BITMAP *font, int x,int y, int type, char *text){
//type=0 get isalpha (only english characters)
//type=1 get number
//type=2 get everything
int end=0;
int pos=0;
//char text[20];
while(!end){
if (keypressed()){
	int k,k2;
	k = readkey();
	k2=k>>8;
	if(k2==KEY_ESC){
		end=-1;
	}
	else if(k2==KEY_ENTER){
		end=1;
	}
	else if(k2==KEY_BACKSPACE){
		text[pos]='\0';
		draw_char(where,font,x+pos*8,y,' ');
		pos--;
	}
	else{
	if(type==0&&pos<19){
	if(k>=0x30&&k<=0x39){
	text[pos]=k;
	text[pos+1]='\0';
	draw_char(where,font,x+pos*8,y,k);
	pos++;
	}}
	if(type==1&&pos<19){
	if(k>=0x41&&k<=0x7a){
	text[pos]=k;
	text[pos+1]='\0';
	draw_char(where,font,x+pos*8,y,k);
	pos++;
	}}
	if(type==2&&pos<19){
	text[pos]=k;
	text[pos+1]='\0';
	draw_char(where,font,x+pos*8,y,k);
	pos++;
	}}
}}
if(end==-1) return 0; //user termination
if(end==1){
//	strcpy(*string,"111");
//return text;
return 1;
}
return 0;
}
*/

showtext(BITMAP *source,BITMAP *where,int frame){
for(int i=0;i<320;i++)
for(int j=0;j<200;j++){
	int col=getpixel(source,i,j);
	if(col!=makecol(255,0,255)){
		int x=320+float(frame*(i-320)/50);
		int y=200+float(frame*(j-200)/50);
		putpixel(where,x,y,col);
	}
}
return 1;
}

void outtextxy(BITMAP *where, BITMAP *font, int x,int y, char* string){
char* word="аааааввв";
int len=strlen(string);
int x0 = (78 - len) / 2;

for(int i=0;i<len;i++){
	//if(string[i]>10)string[i]=10;
	draw_char(where,font,x+(i+x0)*8,y,string[i]);
}
}

void outtextxy2(BITMAP *where, BITMAP *font, int x,int y, char* string){
//especially for dialog function
//char* word="аааааввв";
int len=strlen(string);
const int width=29;

for(int i=0;i<len;i++){
draw_char(where,font,x+(i%width)*8,y+(i/width)*15,string[i]);
}
}

void logtext(BITMAP* screen, BITMAP* font, char* text){
for(int i=0;i<5;i++)
blit(screen,screen,5,470+(4-i)*20,5,470+(5-i)*20,544,21);

rectfill(screen, 5,470,544,490,makecol(50,0,0)); //clear log
rect    (screen, 5,470,544,490,makecol(200,0,0));
outtextxy(screen, font, 15,472, text);
}

/*void draw_help(BITMAP* screen, BITMAP* font){
//this function draws help on commands
//char* text1="Все буквы английские";
char text1[40]="Letters are in english";
char text2[40]="Пропуск хода P";
char text3[40]="Следующий предмет N";
char text4[40]="Говорить T";
char text5[40]="Использовать Пробел";
char text6[40]="Скилл S";
char text7[40]="Взять B";
char text8[40]="Инвентарь I";
//char* text9="Отдать Г";

rectfill(screen, 550,150,794,595,makecol(0,13,63));
//rect    (screen, 551,150,794,515,25+32);
draw_window(screen, 555,150,235,440);

outtextxy(screen, font, 565,175 , text1);
outtextxy(screen, font, 565,195 , text2);
outtextxy(screen, font, 565,215 , text3);
outtextxy(screen, font, 565,235 , text4);
outtextxy(screen, font, 565,255, text5);
outtextxy(screen, font, 565,275, text6);
outtextxy(screen, font, 565,295, text7);
outtextxy(screen, font, 565,315, text8);
//outtextxy(screen, font, 610,335, text9);

}

void draw_inv_help(BITMAP* screen, BITMAP* font){
//this function draws help on inventory dialog commands
char text1[40]="Все буквы английские";
char text2[40]="Вверх-вниз выбор";
char text3[40]="Выбросить D";
char text4[40]="Использовать U";
char text5[40]="Отдать G";
char text6[40]="Переместить M";
char text7[40]="Описание O";
char text8[40]="Выход Esc";

rectfill(screen, 550,150,794,595,makecol(0,13,63));
draw_window(screen, 555,150,235,440);

//rect    (screen, 605,150,794,515,25+32);

outtextxy(screen, font, 565,175 , text1);
outtextxy(screen, font, 565,195 , text2);
outtextxy(screen, font, 565,215 , text3);
outtextxy(screen, font, 565,235 , text4);
outtextxy(screen, font, 565,255, text5);
outtextxy(screen, font, 565,275, text6);
outtextxy(screen, font, 565,295, text7);
outtextxy(screen, font, 565,315, text8);

}
*/