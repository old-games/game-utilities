/*
Public release of Master of Orion font editor.
(C) MaxEd & Dimouse
www.Old-Games.Ru

Use Allegro (www.allegro.cc) to compile!
*/

//CB9 - предполагаемый конец адресов.
#define ALLEGRO_STATICLINK

#pragma warning(disable:4312)
#include <allegro.h>
#pragma warning(default:4312)
#include <stdio.h>
#include <string.h>
#include <assert.h>


int main()
{
	unsigned int files[255];
	int num_of_files;
	allegro_init();
	install_timer();
	install_mouse();
	install_keyboard();
	set_color_depth(24);
	set_gfx_mode(GFX_AUTODETECT_WINDOWED,800,500,0,0);
	FILE *f = fopen("fonts.lbx","rb");

	assert(f);
	unsigned char temp[255];
	memset(temp,0,255);
	fread(temp,1,2,f); //Number of files in archive
	num_of_files = temp[0] + temp[1]*256;
	fread(temp,1,6,f); //Skip rubbich
	for (int i=0;i<num_of_files;i++)
	{
		fread(temp,1,4,f); //Number of files in archive
		files[i] = temp[0] + temp[1]*256 + temp[2]*256*256 + temp[3]*256*256*256;
	}

	int file_pos = 2106;
	int i2=0;
	show_mouse(screen);
	int cur_color = 0;

	while(true)
	{
		fseek(f,file_pos,SEEK_SET);
		unsigned char temp[255];
		fread(temp,1,2,f);

		int offset = temp[1]*256 + temp[0];
		fread(temp,1,2,f);
		int offset2 = temp[1]*256 + temp[0];

		const int FILE_START = 0x3A0;
		
		fseek(f,offset+FILE_START,SEEK_SET);
		fread(temp,1,20,f);
		fseek(f,offset+FILE_START,SEEK_SET);
		unsigned char act;
		int x=0,y=0;
		int len = 20;
		/*if (offset2-offset-1 >0)*/ len = offset2-offset-1;
		/*if (offset2-offset==1){
			textprintf(screen,font,150,200+i2,makecol(255,255,255),"New font found");
			i2=i2+20;
		}
        */
		itoa(offset+FILE_START,(char*)temp,16);
		textprintf(screen,font,100,200,makecol(255,255,255),(char*)temp);
		textprintf(screen,font,100,210,makecol(255,255,255),"%i",file_pos);
		textprintf(screen,font,100,220,makecol(255,255,255),"num of char: %i",((file_pos-2106)/2)%96);
		textprintf(screen,font,100,230,makecol(255,255,255),"num of font: %i",((file_pos-2106)/2)/96);
		int max_y = 120, max_x = 0, max_fp = 0;
		for (int i=0;i<len;i++)
		{
			fread(&act,1,1,f);
			max_fp++;
			int p = ftell(f);

			if ((act >> 4) < 0x8)
			{
				double color_percent = (act<<28) >> 28;
				unsigned int length = (act>>4)*10;
				int color = 255 - color_percent * 20;
				rectfill(screen,x,y,x+10,y+length,makecol(color,color,color));
				y+=length;
			}
			else
			{
				unsigned int length = (((act<<28) >> 28) & 0xF) *10;
				if (length!=0)
				{
					y+=length;
				}
				else
				{
					x+=10;
					y=0;		
				}
			}
			//if (y>max_y) max_y=70;//max_y = y;
			if (y>max_y) max_y = 120;
			if (x>max_x) max_x = x;
		}
		max_x = max_x+10;
		//Added by Evil Wizzard request:
		if (max_x <100) max_x= 100;
		char controls[] = "Use arrow keys to scroll letters and mouse to paint. Press SPACE to change color. S - save symbol.";
			line(screen,max_x,0,max_x,max_y,makecol(255,255,0));
			line(screen,0,max_y,max_x,max_y,makecol(255,255,0));
			textprintf(screen,font,0,400,makecol(255,255,255),controls);
			textprintf(screen,font,0,390,makecol(255,255,255),"Current color: ");
			//if (cur_color==WHITE) rectfill(screen,120,390,130,398,makecol(255,255,255));
			//if (cur_color==GRAY) rectfill(screen,120,390,130,398,makecol(230,230,230));
		for (i=0;i<8;i++) //colors select
		{
			int c = 255 - i*20;
			rectfill(screen,120+i*10,390,120+i*10+9,398,makecol(c,c,c));
			if (i==cur_color) rect(screen,120+i*10,390,120+i*10+9,398,makecol(0,255,0));
		}

		const int MOUSE_EVENT = 1;

		int event = 0;
		while(!keypressed())
		{
			if (mouse_b==1)
			{
				if (mouse_x>120 && mouse_x < 120+8*10 && mouse_y >= 390 && mouse_y <= 398)
				{
					cur_color = (mouse_x - 120)/10;
					event = MOUSE_EVENT;
					break;
				}
				int x0 = mouse_x/10;
				int y0 = mouse_y/10;
				if (mouse_y > max_y-1) continue;
				if (mouse_x > max_x-1) continue;
				scare_mouse();
				//if (cur_color==WHITE) rectfill(screen,x0*10,y0*10,(x0+1)*10,(y0+1)*10,makecol(255,255,255));
				//if (cur_color==GRAY) rectfill(screen,x0*10,y0*10,(x0+1)*10,(y0+1)*10,makecol(230,230,230));
				int c = 255-cur_color*20;
				rectfill(screen,x0*10,y0*10,(x0+1)*10,(y0+1)*10,makecol(c,c,c));
				unscare_mouse();
			}

			if (mouse_b==2)
			{
				int x0 = mouse_x/11;
				int y0 = mouse_y/11;
				if (mouse_y > max_y-1) continue;
				if (mouse_x > max_x-1) continue;
				scare_mouse();
				rectfill(screen,x0*10,y0*10,(x0+1)*10,(y0+1)*10,makecol(0,0,0));
				unscare_mouse();
			}
		}

		if (event!=MOUSE_EVENT)
		{
		int k = readkey();
		if (k>>8 == KEY_ESC) break;
		if (k>>8 == KEY_RIGHT) file_pos+=2;
		if (k>>8 == KEY_LEFT) file_pos-=2;
		if (k>>8 == KEY_UP) file_pos-=(file_pos-2106)%(96*2);
		if (k>>8 == KEY_DOWN) file_pos+=96*2-(file_pos-2106)%(96*2);

		if(file_pos<2106) file_pos=2106;

		if (k>>8 == KEY_S)
		{
			fseek(f,offset+FILE_START,SEEK_SET);
			int x = 5, y = 5;
			char new_string[255];
			memset(new_string,0,255);

			int ylen=0;
			int ns_pos = 0;

			int mode = (255-getr(getpixel(screen,5,5)))/20.0;

			while(x<max_x+10)
			{
				int new_mode = (255-getr(getpixel(screen,x,y)))/20.0;
				int red = getr(getpixel(screen,x,y));

				if (mode!=new_mode)
				{
					if (mode!=12) new_string[ns_pos++] = (ylen << 4) + mode;
					else new_string[ns_pos++] = (8 << 4) + ylen;
					ylen = 1;
				}
				else
				{
					ylen++;
				}

				mode = new_mode;

				//putpixel(screen,x,y,makecol(255,0,0));
				y+=10;
				if (y > max_y)
				{
					if (mode!=12) new_string[ns_pos++] = (ylen << 4) + mode;
					ylen = 0;
					new_string[ns_pos++] = (unsigned char)0x80;
					y=5;
					x+=10;
					mode = (255-getr(getpixel(screen,x,y)))/20.0;
				}
			}

			for (int i=strlen(new_string)-1;i>0;i--)
			{
				if (((unsigned char)new_string[i])==0x80 && ((unsigned char)new_string[i-1])==0x80) new_string[i]=0;
				else break;
			}

			fseek(f,0,SEEK_END);
			int file_size = ftell(f);
			fseek(f,0,SEEK_SET);

			int size1 = offset+FILE_START;
			int size2 = file_size - offset-FILE_START - max_fp - 1;
			char *file_part_1 = new char[size1];
			char *file_part_2 = new char[size2];
			
			fread(file_part_1,1,size1,f);
			fseek(f,max_fp+1,SEEK_CUR);
			fread(file_part_2,1,size2,f);

			//FILE *output = fopen("fonts1.lbx","wb+");
			FILE *output = fopen("fonts.lbx","wb+");
			assert(output);
			//int diff = strlen(new_string) - 1 - max_fp - 1;
			int diff = strlen(new_string) - 1 - max_fp;

			for (i=0;i<size1;i++) fputc(file_part_1[i],output);
			for (i=0;i<strlen(new_string);i++) fputc(new_string[i],output);
			for (i=0;i<size2;i++) fputc(file_part_2[i],output);

			for (i=0;i<num_of_files;i++)
			{
				if (files[i]>size1)
				{
					fseek(output,8+4*i,SEEK_SET);
					files[i]+=diff;
					char b1 = (files[i]<<24)>>24;
					char b2 = (files[i]<<16)>>24;
					char b3 = (files[i]<<8)>>24;
					char b4 = (files[i]<<0)>>24;		
					fwrite(&b1,1,1,output);
					fwrite(&b2,1,1,output);
					fwrite(&b3,1,1,output);
					fwrite(&b4,1,1,output);
				}
			}
			 for (i=0;i<576*2;i+=2) /* ????????????????????????????????? */
 {
 fseek(f,0x83a+i,SEEK_SET);
 fread(temp,1,2,f);
 int offset = temp[1]*256 + temp[0];
 if (offset+FILE_START > size1)
 {
 offset += (diff);
 char b1 = (offset<<16)>>24;
 char b2 = (offset<<24)>>24;
 fseek(output,0x83a+i,SEEK_SET);
 int e1 = fwrite(&b2,1,1,output);
 int e2 = fwrite(&b1,1,1,output);
 }
 }

			fclose(output);

			//readkey();
		}
		clear(screen);

		if (k>>8 == KEY_S) textprintf(screen,font,0,410,makecol(255,255,255),"Saved!");
		}
		}
	fclose(f);
    
	set_gfx_mode(GFX_TEXT,800,500,0,0);
	return 0;
}
END_OF_MAIN();