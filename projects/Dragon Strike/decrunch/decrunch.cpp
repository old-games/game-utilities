//Read graphics from DragonStrike's CMP files with compression format 4
//Written by Dimouse 07.02.10 - 08.02.10

#define ALLEGRO_STATICLINK

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <math.h>

#include "allegro.h"
#include "fonts.h"

using namespace std;

int load_pal2(int n,PALETTE *pal){

	FILE *palfile=fopen("pal.cmp","rb");
	if(!palfile)return 0;

	fseek(palfile,n*256*3,SEEK_SET);
	for(int i=0;i<256;i++){
		int r=fgetc(palfile);
		int g=fgetc(palfile);
		int b=fgetc(palfile);
		(*pal)[i].r=r;
		(*pal)[i].g=g;
		(*pal)[i].b=b;

	}

	/*set_palette(*pal);
	for(i=0;i<256;i++){
		int x=(20*i)%640;
		int y=(20*i)/640;
		y*=20;
		rectfill(screen,x,y,x+20,y+20,makecol((*pal)[i].r,(*pal)[i].g,(*pal)[i].b));
	}
	*/

	fclose(palfile);
	return 1;
}

int load_pal(PALETTE *pal){

fstream f;
f.open("ds_title.pal",ios::in);

	for(int i=0;i<256;i++){
		int r,g,b;
		f>>r>>g>>b;
		(*pal)[i].r=r;
		(*pal)[i].g=g;
		(*pal)[i].b=b;
	}
f.close();

return 1;
}

int read(char filename[20], PALETTE pal){
	FILE *res=fopen(filename,"rb");
	BITMAP *back=create_bitmap(320,200);
	if(!res) return 0;
	fseek(res,0x3,SEEK_SET);

	int x=0;
	while(x<320*200){
			unsigned char c=fgetc(res),d,e;

			if(feof(res)) break;
			if(c==0){ //command 0
				d = fgetc(res);
				int count = d*256+fgetc(res); //count
				e = fgetc(res); //data
				for(int i=0;i<count;i++){
					putpixel(back,x%320,x/320,e);//makecol(pal[e].r,pal[e].g,pal[e].b));
					x++;
				}
			}
			else if(c<0xf&&c>0){ //pixels one by one
				for(int i=0;i<c;i++){
					d = fgetc(res);
					putpixel(back,x%320,x/320,d);//makecol(pal[d].r,pal[d].g,pal[d].b));
					x++;
				}
			}
			else if(c/128){ //command 1
				d = fgetc(res);
				for(int i=0;i<256-c;i++){
					putpixel(back,x%320,x/320,d);//makecol(pal[d].r,pal[d].g,pal[d].b));
					x++;
				}
			}
			stretch_blit(back,screen,0,0,320,200,0,0,640,400);
	}
	PALETTE pal2;
	get_palette(pal2);
	char name[30];
	strcpy(name,filename);
	strcat(name,".bmp");
	save_bitmap(name, back, pal2);
	fclose(res);
	return 1;
}

int save(char filename[20],PALETTE pal){
	char name2[30];
	strcpy(name2,filename);
	strcat(name2,".new");

	FILE *res=fopen(name2,"wb");
	BITMAP *back=create_bitmap(320,200);

	char name[30];
	PALETTE pal2;
	strcpy(name,filename);
	strcat(name,".bmp");
	back=load_bmp(name,pal2);

	int x=1;
	int count=0;
	int size=0;
	select_palette(pal);
	unsigned char c[64001];
	c[0]=getpixel(back,0,0);
	//fputc(c[0],res);
	fputc(0,res);
	fputc(0,res);
	fputc(4,res);
	int end=320*200+1;
	while(x<end){
		count=0;
		c[x]=getpixel(back,x%320,x/320);
		while(c[x]==c[x-1]){
			x++;
			if(x>=end) break;
			c[x]=getpixel(back,x%320,x/320);
			count++;
		}
		if(count==0){ //pix by pix
			c[x]=getpixel(back,x%320,x/320);
			while(c[x]!=c[x-1]){
				x++;
				if(x>=end) break;
				c[x]=getpixel(back,x%320,x/320);
				count++;
			}
			fputc(count,res);
			for(int i=0;i<count;i++)
				fputc(c[x-count+i-1],res);
			size+=count+1;
		}
		else{ //group
			count++;
			if(count<16){
				fputc(256-count,res);
				fputc(c[x-1],res);
				size+=2;
			}
			else{
				fputc(0,res);
				fputc(count/256,res);
				fputc(count%256,res);
				fputc(c[x-1],res);
				size+=4;
			}
			x++;
		}
	}

	fseek(res,0x0,SEEK_SET);
	fputc(size%256,res);
	fputc(size/256,res);
	fclose(res);
	return 1;
}


int main(int argc, char *argv[]){

if(argc!=2){
	printf("Usage: decrunch file.cmp\n");
	return 0;
}

FILE *in=fopen(argv[1],"rb");
if(!in){
	printf("No input file found\n");
	return 0;
}

allegro_init();
install_timer();
install_mouse();
install_keyboard();
set_color_depth(8);
set_gfx_mode(GFX_AUTODETECT_WINDOWED,640,400,0,0);


BITMAP * fnt   = create_bitmap(256,128);
PALETTE pal;
fnt=load_bmp("font_v3.bmp",pal);

outtextxy(screen, fnt, 0, 0, "Graphics utility for DragonStrike. $ Dimouse, 2010.");
outtextxy(screen, fnt, 0, 40, "Press 1 to convert cmp to bmp");
outtextxy(screen, fnt, 0, 60, "Press 2 to convert bmp to cmp");

PALETTE pal2;
load_pal(&pal2);
set_palette(pal2);

while(!keypressed());
	int key = readkey();
	if (key>>8 == KEY_1){ //save bmp
		read(argv[1],pal);
	}
	if (key>>8 == KEY_2){ //save cmp
		save(argv[1],pal);
	}


set_gfx_mode(GFX_TEXT,640,480,0,0);
return 1;
}

END_OF_MAIN();
