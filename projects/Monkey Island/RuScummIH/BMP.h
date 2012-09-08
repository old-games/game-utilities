// BMP.h: interface for the CBMP class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_BMP_H__BA46DC7E_09F6_49B3_933D_40BA3E2F4A8A__INCLUDED_)
#define AFX_BMP_H__BA46DC7E_09F6_49B3_933D_40BA3E2F4A8A__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "stdafx.h"

class CBMP  
{
public:
	CBMP(WORD w, WORD h){m_src=NULL; m_width = w; m_height = h;};
	virtual ~CBMP(){delete m_src;};

	RGBQUAD *GetPalette()
	{
		return(&m_palette[0]);
	}

	int LoadBMP(LPTSTR path, LPTSTR name, int engine_type)
	{
		LPTSTR tmp = (LPTSTR)malloc(strlen(path)+strlen(name)+2);
		sprintf(tmp, "%s\\%s", path, name);

		//Читаем BMP
		BITMAPFILEHEADER bfh;
		BITMAPINFOHEADER bih;
		//RGBQUAD bpal[256];
		ZeroMemory(&bfh, sizeof(bfh));
		ZeroMemory(&bih, sizeof(bih));
		//ZeroMemory(&bpal[0], sizeof(RGBQUAD)*256);
		ZeroMemory(&m_palette[0], sizeof(RGBQUAD)*256);

		DWORD sz=0;
		HANDLE hFile= CreateFile(tmp, GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
		if(hFile==INVALID_HANDLE_VALUE)return(ERR_UNABLE_LOAD_FILE);
		ReadFile(hFile, &bfh, sizeof(bfh), &sz, NULL);
		ReadFile(hFile, &bih, sizeof(bih), &sz, NULL);
		ReadFile(hFile, &m_palette[0], sizeof(RGBQUAD)*256, &sz, NULL);

		m_width= (WORD)bih.biWidth;
		m_height= (WORD)bih.biHeight;

		m_src = (BYTE*)malloc(m_width*m_height);

		::SetFilePointer(hFile, bfh.bfOffBits, 0, FILE_BEGIN);

		switch(engine_type){
			case ATLANTIS_ENGINE:{
				for(int h= m_height-1; h>=0; h--)
				{
					ReadFile(hFile, m_src+h*m_width, m_width, &sz, NULL);
					if(m_width%4)
					{
						BYTE bt[]={0,0,0,0};
						ReadFile(hFile, &bt[0], 4-(m_width%4), &sz, NULL);
					}
				}
				break;}
			case INDY3_ENGINE:{
				for(int h= m_height-1; h>=0; h--)
					for(int w= 0; w< m_width; w++)
					{
						ReadFile(hFile, m_src+(h+w*m_height), 1, &sz, NULL);
					}
				break;}
			case LOOM_EGA_ENGINE:{
				for(int h= m_height-1; h>=0; h--)
					for(int w= 0; w< m_width; w++)
					{
						ReadFile(hFile, m_src+(h+w*m_height), 1, &sz, NULL);
						int ijk=0;
					}
				break;}
			default:{
				CloseHandle(hFile);
				return(ERR_UNSUPPORTED_TYPE);}
		}
		CloseHandle(hFile);

		free(tmp);

   		return(0);
	}


	int SaveBMP(LPTSTR path, LPTSTR name, BYTE * dst)
	{
		LPTSTR tmp = (LPTSTR)malloc(strlen(path)+strlen(name)+2);
		sprintf(tmp, "%s\\%s", path, name);

		BITMAPFILEHEADER bfh={0};
		BITMAPINFOHEADER bih={0};

		bfh.bfType = MAKEWORD('B','M');
		bfh.bfSize = sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER)+256*sizeof(RGBQUAD)+m_width*m_height;
		bfh.bfOffBits = sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER)+256*sizeof(RGBQUAD);

		bih.biSize= sizeof(BITMAPINFOHEADER);
		bih.biWidth= m_width;
		bih.biHeight= m_height;
		bih.biPlanes = 1;
		bih.biBitCount = 8;
		bih.biCompression = BI_RGB;
		if(m_width%4)
			bih.biSizeImage = (m_width+4-(m_width%4))*m_height;
		else
			bih.biSizeImage = m_width*m_height;
		bih.biClrImportant = 0;
		bih.biClrUsed = 0;
		
		HANDLE hFile= CreateFile(tmp, GENERIC_READ|GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
		DWORD sz;
		sz = sizeof(BITMAPFILEHEADER);
		sz = sizeof(BITMAPINFOHEADER);
		sz = sizeof(RGBQUAD);

		WriteFile(hFile, &bfh, sizeof(BITMAPFILEHEADER), &sz, NULL);
		WriteFile(hFile, &bih, sizeof(BITMAPINFOHEADER), &sz, NULL);
		WriteFile(hFile, &m_palette[0], 256*sizeof(RGBQUAD), &sz, NULL);

		BYTE *d = dst;
		d+= m_width*(m_height-1);
		int h= m_height;

		while(h-->0)
		{
			
			WriteFile(hFile, d, m_width, &sz, NULL);
			if(m_width%4)
			{
				BYTE bt[]={0,0,0,0};
				WriteFile(hFile, &bt[0], 4-(m_width%4), &sz, NULL);
			}
			if(h>0)d-=m_width;
		}

		CloseHandle(hFile);

		free(tmp);

		return(0);
	}

	void SetPalette(int i, BYTE R, BYTE G, BYTE B)
	{
			m_palette[i].rgbRed = R;
			m_palette[i].rgbGreen = G;
			m_palette[i].rgbBlue = B;
	}
	void SetWidth(WORD w){m_width = w;};
	void SetHeight(WORD h){m_height = h;};
	WORD GetWidth(){return(m_width);};
	WORD GetHeight(){return(m_height);};

	BYTE *GetSrc(){return(m_src);};

private:
	BYTE *m_src;
	WORD m_width, m_height;
	RGBQUAD m_palette[256];

};

#endif // !defined(AFX_BMP_H__BA46DC7E_09F6_49B3_933D_40BA3E2F4A8A__INCLUDED_)
