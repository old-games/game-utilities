/*
Public release of Alone in the Dark font editor.
(C) Dimouse
www.Old-Games.Ru

Use Allegro (www.allegro.cc) to compile!
*/

#define ALLEGRO_STATICLINK

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <math.h>
#include "allegro.h"
#include "fonts.h"
using namespace std;

short int height = 0;
short int gap = 0;
short int gap_new;
//short int width_g=0;
short int width_t[256];
short int width_n[256];
//int x_last;
//int y_last;
int flagF=0;

const int screen_x = 160;
const int screen_y = 240;
const int screen_w = 320;
const int screen_h = 200;

//****************************//
int find_width(BITMAP *bmp, unsigned char cc){

int bit1[8];
int bit2[8];
int max_width=0;

/*if(!flagF){ //AiTD2
if(width_t[cc]==15) width_n[cc]=15;
return 1;
}
*/

for(int j=0;j<height;j++){
	int y=height*((cc-32)/(screen_w/16))+j;
	for(int i=0;i<16;i++){
		int x=16*((cc-32)%(screen_w/16))+i;
		if(getpixel(bmp,x,y)==makecol(255,255,255)){
			if(i<8)bit1[i]=1;
			if(i>=8)bit2[i-8]=1;
		}
		else{
			if(i<8)bit1[i]=0;
			if(i>=8)bit2[i-8]=0;
		}
	}
	//int curbit=bit2[7];
	int real_width=0;
	for(i=0;i<8;i++)
		if(bit2[i]){
			real_width=8+i;
		}
	if(real_width==0){
	for(i=0;i<8;i++)
		if(bit1[i]){
			real_width=i;
		}	
	}
	if(real_width>max_width) max_width=real_width;
}

max_width++;

width_n[cc]=max_width;
/*FILE *out=fopen("out_width.txt","ab");
fprintf(out,"char %c, old w = %d new w = %d\n",cc,width_t[cc],max_width);

fclose(out);
*/
return 1;
}

//*******************************//
int change_width(BITMAP *bmp){
	for(int cc=0;cc<256;cc++)
		width_n[cc]=0;
	for(cc=128;cc<176;cc++)
		find_width(bmp,cc);
	for(cc=224;cc<244;cc++)
		find_width(bmp,cc);

	int summ1=0,summ2=0;
	for(cc=32;cc<256;cc++){
		if(width_n[cc]==0)width_n[cc]=width_t[cc];
		summ1+=width_t[cc];
		summ2+=width_n[cc];
	}
	width_n[242]+=8-summ2%8;
	width_n[242]=width_n[242]%8;

	for(cc=32;cc<256;cc++)
		width_t[cc]=width_n[cc];

return 1;
}

//*******************************************//
int read_widths(char filename[20], int offset){
	FILE *res=fopen(filename,"rb");
	fseek(res,offset,SEEK_SET);

FILE *out = fopen("out_w","wb");

	int length=0;
	for(int cc=32;cc<255;cc++){
		short int addr1,addr2;
		addr2 = fgetc(res);
		addr1 = fgetc(res);
		width_t[cc] = addr2/16; //width of char in pixels
		fprintf(out,"char: %c width: %d\n",cc,width_t[cc]);
		length+=width_t[cc];
	}
	width_t[255] = gap*8-length;
fclose(out);
return 1;
}

//****************************************//
int read_all(BITMAP *bmp,char filename[20]){
	FILE *res=fopen(filename,"rb");
	clear(bmp);
	fseek(res,0x08,SEEK_SET);

	for(int j=0;j<height;j++){
		int count=gap;
		int x=0;
		while(count>0){
			unsigned char byte=fgetc(res);
			count--;
			for(int i=0;i<8;i++){
				int ii=i;
				ii=0x80>>ii;
				if(byte&ii) putpixel(bmp,x%screen_w,height*(x/screen_w)+j,makecol(255,255,255));
				x++;			
			}
		}
	}
    fclose(res);
/*
FILE *out=fopen("out4.txt","wb");
fprintf(out,"old width is: %d\n",x);
fclose(out);
*/
	return 1;
}

//**********************************************//
int read_all_grid(BITMAP* bmp, char filename[20]){
	FILE *res=fopen(filename,"rb");
	clear(bmp);
	fseek(res,0x08,SEEK_SET);

	for(int j=0;j<height;j++){
		int count=gap;
		int x=0;
		int cc=32;
		int pos=0;

		while(count>0){
			unsigned char byte=fgetc(res);
			count--;
			for(int i=0;i<8;i++){
				int ii=i;
				ii=0x80>>ii;
				if(byte&ii) putpixel(bmp,x%screen_w,height*(x/screen_w)+j,makecol(255,255,255));
				x++;
				pos++;
				if(flagF){ //AiTD1
				if(pos==width_t[cc]){
					pos=0;
					cc++;
					while(x%16!=0)x++;
				}
				}
				else{ //AiTD2-3
				if(width_t[cc]<=8&&pos==8){
					pos=0;
					cc++;
					while(width_t[cc]==15){
					x+=16;
					cc++;
					}
					while(x%16!=0)x++;
				}
				if(width_t[cc]>8&&pos==16){
					pos=0;
					cc++;
					while(width_t[cc]==15){
					x+=16;
					cc++;
					}
					while(x%16!=0)x++;
				}
				}
			}
		}
	}
    fclose(res);

/*FILE *out=fopen("out4.txt","wb");
fprintf(out,"old width is: %d\n",x);
fclose(out);
*/
	return 1;
}

//**************************//
int convert_grid(BITMAP *bmp){ //grided -> not grided
BITMAP *bmp2 = create_bitmap(screen_w,screen_h);
int xnew=0;

for(int cc=32;cc<256;cc++){
if(flagF||width_t[cc]<15){
for(int j=0;j<height;j++){
	int y=height*((cc-32)/(screen_w/16))+j;
	for(int i=0;i<16;i++){
		int x=16*((cc-32)%(screen_w/16))+i;
		int col=getpixel(bmp,x,y);
		if(i<width_t[cc])putpixel(bmp2,(xnew+i)%screen_w,height*((xnew+i)/screen_w)+j,col);
	}
}
if(flagF)xnew+=width_t[cc];
else{
	if(width_t[cc]<=8) xnew+=8;
	else xnew+=16;
}
}
}

blit(bmp2,bmp,0,0,0,0,screen_w,screen_h);

destroy_bitmap(bmp2);
gap_new=xnew/8;
return 1;
}

//*******************************************//
int save_font(BITMAP *bmp,char filename[20]){
FILE *res=fopen(filename,"wb");

fputc(0x20,res);
fputc(0x0,res);
fputc(height,res);
if(flagF){ //AiTD
	fputc(0x0,res);
	fputc(gap_new,res); //real width!
}
else{ //AiTD II
	fputc(gap_new,res); //real width!
	fputc(0x0,res);
}
fputc(0x0,res);

int offset_new=gap_new*height+0x08;
fputc(offset_new/256,res); //gap*height+0x08
fputc(offset_new%256,res);

for(int j=0;j<height;j++){
	int count=gap_new;
	int x=0;
	while(count>0){
		unsigned char byte=0;
		for(int i=0;i<8;i++){
			int bit=0;
			if(getpixel(bmp,x%screen_w,height*(x/screen_w)+j)==makecol(255,255,255)) bit=1;
			x++;
			byte+=bit<<(7-i);
		}
		fputc(byte,res);
		count--;
	}
}
int coord=0;
for(unsigned char cc=32;cc<255;cc++){ //offsets now
int offset;
if(flagF){ //AiTD1
	offset=256*16*width_t[cc]+coord;
	coord+=width_t[cc];
}
else{ //AiTD II
	if(width_t[cc]==15)
		offset=0xFFFF;
	else{
		offset=256*16*width_t[cc]+coord;
		if(width_t[cc]<=8)coord+=8;
		else coord+=16;
	}
}
if(width_t[cc]!=0){
	fputc(offset/256,res);
	fputc(offset%256,res);
}
}
fclose(res);
return 1;
}

//*******************************//
int read_values(char filename[20]){
FILE *res=fopen(filename,"rb");
if(res==NULL) return -1;

short int tempDx=fgetc(res); //not important
tempDx=tempDx*256 + fgetc(res);
char tmp;
  
height = fgetc(res); // character height
gap=fgetc(res); // size of gap between char bytes (each row of pixels is this gap one from another)
if(gap==0){ //format of AiTD1 or JiTD
	gap = fgetc(res);
	flagF=1;
}
else tmp=fgetc(res);
tmp=fgetc(res);
gap_new=gap;

short int tempAxFlip=fgetc(res); //actually it's an address to char offsets
tempAxFlip=tempAxFlip*256+fgetc(res);

fclose(res);

return tempAxFlip - (tempDx&0xFF)*2; //address begining of char offsets
}

//*****************************//
int main(int argc, char *argv[]){
char filename[20]="font.out";

allegro_init();
install_timer();
install_mouse();
install_keyboard();
set_color_depth(32);
set_gfx_mode(GFX_AUTODETECT_WINDOWED,640,480,0,0);

BITMAP * fnt   = create_bitmap(256,128);
BITMAP * back  = create_bitmap(640,480);
BITMAP * back2 = create_bitmap(320,200);
PALETTE pal;
fnt=load_bmp("font_v3.bmp",pal);
clear(back2);
clear(back);

outtextxy(back, fnt, 0, 0, "Font utility for Alone in the Dark games. $ Dimouse, 2009-2011.");
outtextxy(back, fnt, 0, 16, "Нажмите соответствующую клавишу.");
outtextxy(back, fnt, 0, 32, "1) Прочитать фонт из файла font.out и расположить его по сетке");
outtextxy(back, fnt, 0, 48, "2) Прочитать фонт из файла font.out без сетки");
outtextxy(back, fnt, 0, 64, "3) Сохранить в виде картинки font.bmp");
outtextxy(back, fnt, 0, 80, "4) Загрузить новый фонт из fontnew.bmp");
outtextxy(back, fnt, 0, 96, "5) Сменить ширину символов в шрифте (только на русские буквы)");
outtextxy(back, fnt, 0, 112,"6) Конвертировать картинку по сетке в картинку без сетки");
outtextxy(back, fnt, 0, 128,"7) Сохранить новый шрифт в font.new");
outtextxy(back, fnt, 0, 144,"ESC) Выход");
if(flagF)outtextxy(back, fnt, 0, 460,"Формат AiTD1/JiTD");
else outtextxy(back, fnt, 0, 460,"Формат AiTD2/AiTD3");

rect(back, screen_x-1,screen_y-1,screen_x+screen_w,screen_y+screen_h,makecol(0,0,255));

blit(back,screen,0,0,0,0,640,480);

int exit=0;
int char_offset = read_values(filename);

if(char_offset == -1){
	outtextxy(screen, fnt, 0, 480-16,"Нет файла font.out! Нажмите любую клавишу, чтобы выйти!");
	while(!keypressed()){
	}
	exit=1;
}
else
read_widths(filename,char_offset);

int flagG=-1;
int flagN=0;

while(!exit){
	if(keypressed()){
		rectfill(screen,0,480-16,640,480,makecol(0,0,0));
		int key = readkey();
		if (key>>8 == KEY_ESC) exit=1;
		if (key>>8 == KEY_1){ //read font.out grided
			read_all_grid(back2, filename);
			blit(back2,screen,0,0,screen_x,screen_y,screen_w,screen_h);
			flagG=1;
		}
		if (key>>8 == KEY_2){ //read font.out not grided
			read_all(back2, filename);
			blit(back2,screen,0,0,screen_x,screen_y,screen_w,screen_h);
			flagG=0;
		}
		if (key>>8 == KEY_3){ //save font.bmp
			get_palette(pal);
			save_bitmap("font.bmp", back2, pal);
		}
		if (key>>8 == KEY_4){ //load fontnew.bmp
			FILE *test=fopen("fontnew.bmp","rw");
			if(test==NULL){
				outtextxy(screen, fnt, 0, 480-16,"Нет файла fontnew.bmp!");
			}
			else{
				fclose(test);
				back2=load_bmp("fontnew.bmp",pal);
				blit(back2,screen,0,0,screen_x,screen_y,screen_w,screen_h);
				flagG=1;
				flagN=1;
			}
		}	
		if (key>>8 == KEY_5){ //change widths
			if(flagN)
			change_width(back2);
			else outtextxy(screen, fnt, 0, 480-16,"Вы должны открыть fontnew.bmp сначала");
		}	
		if (key>>8 == KEY_6){ //convert grid -> no grid
			if(flagG==1){
			convert_grid(back2);
			blit(back2,screen,0,0,screen_x,screen_y,screen_w,screen_h);
			flagG=0;
			}
			else outtextxy(screen, fnt, 0, 480-16,"Это возможно только в режиме сетки");
		}	
		if (key>>8 == KEY_7){ //save font
			if(flagG==0){
			save_font(back2,"font.new");
			outtextxy(screen, fnt, 0, 480-16,"Новый шрифт сохранен успешно!");
			}
			else outtextxy(screen, fnt, 0, 480-16,"Это возможно только в режиме без сетки");
		}
/*		if (key>>8 == KEY_8){ //find widths
			for(int cc=128;cc<176;cc++)
			find_width(back2,cc);
			for(cc=224;cc<244;cc++)
			find_width(back2,cc);
		}
*/
	}
}

set_gfx_mode(GFX_TEXT,640,480,0,0);
return 1;
}

END_OF_MAIN();
