// Chunk.cpp: implementation of the CChunk class.
//
//////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "Chunk.h"
#include "CMDParser.h"

extern CCMDParser	cmd;

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
int CChunk::sizeoffile = 0;
int CChunk::posinfile = 0;

CChunk::CChunk()
{
	m_body = NULL;
	m_has_valid_header = true;
	m_valid_chunk_type = (LPTSTR)malloc(5);
	ZeroMemory(m_valid_chunk_type, 5);
}

CChunk::~CChunk()
{
	delete m_body;
	free(m_valid_chunk_type);
}

int CChunk::Load(LPTSTR path, LPTSTR name)
{
	sizeoffile=0;
	posinfile=0;

	char *file = (char*)malloc(strlen(path)+strlen(name)+2);
	sprintf(file, "%s\\%s",path,name);
	DWORD sz;
	BYTE *body;
	HANDLE hFile= CreateFile(file, GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
	if(hFile==INVALID_HANDLE_VALUE)return(ERR_UNABLE_LOAD_FILE);
	sizeoffile=GetFileSize(hFile, NULL);
	body = (BYTE*)malloc(sizeoffile);
	ReadFile(hFile, body, sizeoffile, &sz, NULL);
	CloseHandle(hFile);

	DWORD err = Init(body);
	
	free(file);
	free(body);

	return(err);
}

int CChunk::Save(LPTSTR path, LPTSTR name)
{
	DWORD err=0;
	
	char *file = (char*)malloc(strlen(path)+strlen(name)+2);
	sprintf(file, "%s\\%s",path,name);
	DWORD sz;
	HANDLE hFile= CreateFile(file, GENERIC_READ|GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
	free(file);
	if(hFile==INVALID_HANDLE_VALUE)return(ERR_UNABLE_SAVE_FILE);
	
	CChunk *obj = this;

	while(obj)
	{
		if(obj->m_header.type==ATLANTIS_ENGINE)
		{
			WriteFile(hFile, obj->m_header.sign, 4, &sz, NULL);
		
			DWORD * ssz = &obj->m_header.size;
			WriteFile(hFile, ((BYTE*)ssz+3), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+2), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+1), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+0), 1, &sz, NULL);
			
			if(obj->m_header.body)
				WriteFile(hFile, obj->m_header.body, _msize(obj->m_header.body), &sz, NULL);
		}
		else if(obj->m_header.type==INDY3_ENGINE)
		{
			DWORD * ssz = &obj->m_header.size;
			WriteFile(hFile, ((BYTE*)ssz+0), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+1), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+2), 1, &sz, NULL);
			WriteFile(hFile, ((BYTE*)ssz+3), 1, &sz, NULL);

			WriteFile(hFile, obj->m_header.sign, 2, &sz, NULL);
			
			if(obj->m_header.body)
				WriteFile(hFile, obj->m_header.body, _msize(obj->m_header.body), &sz, NULL);
		}
		else if(obj->m_header.type==LOOM_EGA_ENGINE)
		{
			if(!m_has_valid_header)
			{
				if(obj->m_header.body)
					WriteFile(hFile, obj->m_header.body, _msize(obj->m_header.body), &sz, NULL);
			}
			else
			{
				DWORD * ssz = &obj->m_header.size;
				WriteFile(hFile, ((BYTE*)ssz+0), 1, &sz, NULL);
				WriteFile(hFile, ((BYTE*)ssz+1), 1, &sz, NULL);
				if(obj->m_header.body)
					WriteFile(hFile, obj->m_header.body, _msize(obj->m_header.body), &sz, NULL);
			}
		}

		obj= obj->m_body;
	}


	CloseHandle(hFile);


	return(0);
}

int CChunk::Parse(BYTE *body)
{
	DWORD offset =0;
	//---------------------------RMIM-----------------------------------------------------
	if(strcmp(&m_header.sign[0],"COST")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"CO")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = ATLANTIS_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else if(strcmp(&m_header.sign[0],"OBCD")==0)
	{
		offset=0;
	}
	else if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"VERB")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"OBNA")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"RMIM")==0)
	{
		offset=0;
	}
	else if(strcmp(&m_header.sign[0],"RMIH")==0)
	{
		m_header.body = (BYTE*)malloc(2);
		memcpy(m_header.body, body, 2);
		offset=2;
	}
	else if(strcmp(&m_header.sign[0],"RMHD")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"OBIM")==0)
	{
		offset=0;
	}
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"CLUT")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"SMAP")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset=m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"IMv3")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-2);
		m_header.type = LOOM_EGA_ENGINE;
		memcpy(m_header.body, body, m_header.size-2);
		offset=m_header.size-2;
	}
	else if(strcmp(&m_header.sign[0],"HDv3")==0)
	{
		m_header.body = (BYTE*)malloc(sizeoffile);
		m_header.size = sizeoffile;
		m_header.type = LOOM_EGA_ENGINE;
		memcpy(m_header.body, body, sizeoffile);
		offset= sizeoffile;
	}
	else if(strcmp(&m_header.sign[0],"MAv3")==0)
	{
		m_header.body = (BYTE*)malloc(sizeoffile);
		m_header.size = sizeoffile;
		m_header.type = LOOM_EGA_ENGINE;
		memcpy(m_header.body, body, sizeoffile);
		offset= sizeoffile;
	}
	else if(strcmp(&m_header.sign[0],"OIv3")==0)
	{
		m_header.body = (BYTE*)malloc(sizeoffile-2);
		//m_header.size = sizeoffile;
		m_header.type = LOOM_EGA_ENGINE;
		memcpy(m_header.body, body, sizeoffile-2);
		offset= sizeoffile;
	}
	else if(strcmp(&m_header.sign[0],"OCv3")==0)
	{
		m_header.body = (BYTE*)malloc(sizeoffile);
		m_header.size = sizeoffile;
		m_header.type = LOOM_EGA_ENGINE;
		memcpy(m_header.body, body, sizeoffile);
		offset= sizeoffile;
	}
	else if(strncmp(&m_header.sign[0],"IM",2)==0)
	{
		offset=0;
	}
	else if(strncmp(&m_header.sign[0],"ZP",2)==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-8);
		memcpy(m_header.body, body, m_header.size-8);
		offset= m_header.size-8;
	}
	else if(strcmp(&m_header.sign[0],"BM")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = INDY3_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else if(strcmp(&m_header.sign[0],"HD")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = INDY3_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else if(strcmp(&m_header.sign[0],"OI")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = INDY3_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else if(strcmp(&m_header.sign[0],"OC")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = INDY3_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else if(strcmp(&m_header.sign[0],"PA")==0)
	{
		m_header.body = (BYTE*)malloc(m_header.size-6);
		m_header.type = INDY3_ENGINE;
		memcpy(m_header.body, body, m_header.size-6);
		offset= m_header.size-6;
	}
	else 
	{
		printf("unsupported block %s\n",m_header.sign);
		return(ERR_UNSUPPORTED_BLOCK);
	}
	//-------------------------------------------------------------------------------------

	if(m_header.type==ATLANTIS_ENGINE)
		posinfile+=(offset+8);
	else if(m_header.type == INDY3_ENGINE)
		posinfile+=(offset+6);
	else if(m_header.type == LOOM_EGA_ENGINE)
		posinfile+=(offset+2);


	if(posinfile<sizeoffile)
	{
		m_body = new CChunk();
		return(m_body->Init(body+offset));
	}
	return(0);

#pragma message ("Разобраться с сравнением блоков, чтобы более короткие не попадали под условие для длинных sign'ов")
}

int CChunk::Init(BYTE * body)
{
	DWORD err = 0;
	if(m_has_valid_header)
	{
		memcpy(m_header.sign, body, 4);
		m_header.size= MAKELONG(MAKEWORD(*(body+7), *(body+6)), MAKEWORD(*(body+5), *(body+4)));
		err= Parse(body+8);
		if(err)
		{
			//Пробуем другой формат Indy3_vga
			m_header.size = 0;
			ZeroMemory(&m_header.sign[0], 5);
			memcpy(&m_header.size, body, 4);
			memcpy(m_header.sign, body+4, 2);
			err= Parse(body+6);
			if(err)
			{
				m_header.size = 0;
				ZeroMemory(&m_header.sign[0], 5);
				//Пробуем фопмат Loom_ega
				//Не имеет заголовка как такового, поэтому формируем ему имя сами
				memcpy(&m_header.size, body, 2);
				memcpy(m_header.sign, cmd.GetCurrentFilename(), strlen(cmd.GetCurrentFilename())>4?4:strlen(cmd.GetCurrentFilename()));
				err= Parse(body+2);
			}
		}
	}
	else
	{
		m_header.size = 0;
		ZeroMemory(&m_header.sign[0], 5);
		//Валидного заголовка нет, поэтому конструируем заголовок из зпдпнных параметров
		int i = strlen(m_valid_chunk_type);
		memcpy(m_header.sign, m_valid_chunk_type, i>4?4:i);
		err= Parse(body);
	}

	/*--OUT*/printf("\r\n\tFound %s", &m_header.sign[0]);
	return(err);
}

CChunk* CChunk::Find(LPTSTR name, BOOL like)
{
	CChunk *obj = this;

	if(like)
	{
		while(obj&&strncmp(obj->m_header.sign,name, strlen(name))!=0)
			obj= obj->m_body;
	}
	else
	{
		while(obj&&strcmp(obj->m_header.sign,name)!=0)
			obj= obj->m_body;
	}

	return(obj);
}


//..............................Интерфейсные функции.................................
WORD CChunk::GetWidth()
{
	WORD w=0;
	if(strcmp(&m_header.sign[0],"RMHD")==0)
		memcpy(&w, (m_header.body), 2);
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy(&w, (m_header.body+12), 2);
	else if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		w= *(m_header.body+4);
		w*=8;
	}
	else if(strcmp(&m_header.sign[0],"OCv3")==0)
	{
		w= *(m_header.body+9);
		w*=8;
	}
	else if(strcmp(&m_header.sign[0],"OC")==0)
	{
		w= *(m_header.body+5);
		w*=8;
	}
	else if(strcmp(&m_header.sign[0],"HD")==0)
	{
		memcpy(&w, m_header.body,2);
	}
	else if(strcmp(&m_header.sign[0],"HDv3")==0)
	{
		memcpy(&w, m_header.body,2);
	}
	else abort();

	return(w);
}

void CChunk::SetWidth(WORD width)
{
	if(strcmp(&m_header.sign[0],"RMHD")==0)
		memcpy((m_header.body), &width, 2);
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy((m_header.body+12), &width, 2);
	else if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		BYTE w = (BYTE)(width/8);
		*(m_header.body+4)=w;
	}
	else if(strcmp(&m_header.sign[0],"OCv3")==0)
	{
		BYTE w = (BYTE)(width/8);
		*(m_header.body+9)=w;
	}
	else if(strcmp(&m_header.sign[0],"OC")==0)
	{
		BYTE w = (BYTE)(width/8);
		*(m_header.body+5)=w;
	}
	else if(strcmp(&m_header.sign[0],"HD")==0)
	{
		memcpy(m_header.body, &width, 2);
	}
	else if(strcmp(&m_header.sign[0],"HDv3")==0)
	{
		memcpy(m_header.body, &width, 2);
	}

	else abort();
}

WORD CChunk::GetHeight()
{
	WORD h=0;
	if(strcmp(&m_header.sign[0],"RMHD")==0)
		memcpy(&h, (m_header.body+2), 2);
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy(&h, (m_header.body+14), 2);
	else if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		h = *(m_header.body+5);
		h*=8;
	}
	else if(strcmp(&m_header.sign[0],"OCv3")==0)
	{
		h = *(m_header.body+0xF);
		h=h&0xF8;
	}
	else if(strcmp(&m_header.sign[0],"OC")==0)
	{
		h = *(m_header.body+11);
		h=h&0xF8;
	}
	else if(strcmp(&m_header.sign[0],"HD")==0)
	{
		memcpy(&h, m_header.body+2,2);
	}
	else if(strcmp(&m_header.sign[0],"HDv3")==0)
	{
		memcpy(&h, m_header.body+2,2);
	}
	else abort();


	return(h);
}

void CChunk::SetHeight(WORD height)
{
	if(strcmp(&m_header.sign[0],"RMHD")==0)
		memcpy((m_header.body+2), &height, 2);
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy((m_header.body+14), &height, 2);
	else if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		BYTE h = (BYTE)(height/8);
		*(m_header.body+5)=h;
	}
	else if(strcmp(&m_header.sign[0],"OCv3")==0)
	{
		BYTE h = (BYTE)(height&0xF8);
		*(m_header.body+0xF)=h;
	}
	else if(strcmp(&m_header.sign[0],"OC")==0)
	{
		BYTE h = (BYTE)(height&0xF8);
		*(m_header.body+11)=h;
	}
	else if(strcmp(&m_header.sign[0],"HD")==0)
	{
		memcpy(m_header.body+2,&height,2);
	}
	else if(strcmp(&m_header.sign[0],"HDv3")==0)
	{
		memcpy(m_header.body+2,&height,2);
	}

	else abort();
}

WORD CChunk::GetXPos()
{
	WORD x= 0;
	if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		memcpy(&x, (m_header.body+2), 1);
		x*=8;
	}
	else abort();

	return(x);
}

void CChunk::SetXPos(WORD x)
{
	if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		BYTE xx = (BYTE)(x/8);
		memcpy((m_header.body+2), &xx, 1);
	}
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy((m_header.body+8), &x, 2);
	else abort();
}

WORD CChunk::GetYPos()
{
	WORD y=0;
	if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		memcpy(&y, (m_header.body+3), 1);
		y*=8;
	}
	else abort();

	return(y);
}

void CChunk::SetYPos(WORD y)
{
	if(strcmp(&m_header.sign[0],"CDHD")==0)
	{
		BYTE yy = (BYTE)(y/8);
		memcpy((m_header.body+3), &yy, 1);
	}
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy((m_header.body+10), &y, 2);
	else abort();
}


WORD CChunk::GetZPCnt()
{
	WORD zp=0;
	if(strcmp(&m_header.sign[0],"RMIH")==0)
		memcpy(&zp, m_header.body, 2);
	else if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy(&zp,(m_header.body+4), 2);
	else abort();

	return(zp);
}

WORD CChunk::GetIMCnt()
{
	WORD im=0;
	if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy(&im, (m_header.body+2), 2);
	else if(strcmp(&m_header.sign[0],"COST")==0 || strcmp(&m_header.sign[0],"CO")==0)
	{
		//Определяем кол-во цвето и пропускаем их
		WORD cur = GetNumColors()+2;
		//Заполняем массив смещениями на таблицы смещений на картинки
		WORD offsets[16];
		ZeroMemory(&offsets[0],16*2);
		int j=0; 
		WORD offset;
		WORD prev_offset = 0;
		for(int i=0; i<16; i++)
		{
			memcpy(&offset, (m_header.body+cur+(i*2)), 2);
			if(offset>prev_offset)
			{
				offsets[j]=offset;
				j++;
			}
			prev_offset=offset;
		}
		//подсчитываем кол-во картинок
		int i=1;
		while(offsets[i])
		{
			if(offsets[i+1]>0)
				im+=(offsets[i+1]-offsets[i])/2;
			i++;
		}


	}
	else abort();

	return(im);
}

BYTE *CChunk::GetFrame(int index)
{
	BYTE *dat=NULL;

	if(strcmp(&m_header.sign[0],"COST")==0 || strcmp(&m_header.sign[0],"CO")==0)
	{
		//Получаем смещение на картинку
		LONG off = GetOffsetFrame(index);
		if(!off)return(NULL);
		dat=m_header.body+off;
	}
	else abort();

	return(dat);
}

WORD CChunk::GetOffsetFrame(int index)
{
	LONG off =0;
	if(strcmp(&m_header.sign[0],"COST")==0 || strcmp(&m_header.sign[0],"CO")==0)
	{
		//подсчитываем кол-во картинок
		int cnt = GetIMCnt();
		if(index>cnt)return(0);

		//Определяем кол-во цветов
		int colors = GetNumColors();
		//Заполняем массив смещениями на таблицы смещений на картинки
		WORD offsets[16];
		ZeroMemory(&offsets[0],16*2);
		int j=0; 
		WORD offset;
		WORD prev_offset = 0;
		for(int i=0; i<16; i++)
		{
			memcpy(&offset, (m_header.body+(colors+2)+(i*2)), 2);
			if(offset>prev_offset)
			{
				offsets[j]=offset;
				j++;
			}
			prev_offset=offset;
		}

		//Конструируем смещения на картинки
		WORD *offsets_to_frames = new WORD[cnt];
		for(int j= 0; j< cnt; j++)
		{
			memcpy(&offsets_to_frames[j], (m_header.body+offsets[1]+(j*2)-6),2);
			offsets_to_frames[j]+= 6;
		}
		off= offsets_to_frames[index];
		delete[]offsets_to_frames;
	}
	else abort();

	return(off& 0xFFFF);
}

void CChunk::SetOffsetFrame(int index, WORD val)
{
	LONG off =0;
	if(strcmp(&m_header.sign[0],"COST")==0 || strcmp(&m_header.sign[0],"CO")==0)
	{
		//подсчитываем кол-во картинок
		int cnt = GetIMCnt();
		if(index>cnt)return;

		//Определяем кол-во цветов
		int colors = GetNumColors();
		//Заполняем массив смещениями на таблицы смещений на картинки
		WORD offsets[16];
		ZeroMemory(&offsets[0],16*2);
		int j=0; 
		WORD offset;
		WORD prev_offset = 0;
		for(int i=0; i<16; i++)
		{
			memcpy(&offset, (m_header.body+(colors+2)+(i*2)), 2);
			if(offset>prev_offset)
			{
				offsets[j]=offset;
				j++;
			}
			prev_offset=offset;
		}

		//Запоминаем нужное смещение
		for(int j= 0; j< cnt; j++)
		{
			if(j==index)
			{
				WORD tmp = val-6;
				memcpy((m_header.body+offsets[1]+(j*2)-6), &tmp, 2);
			}
		}
	}
	else abort();
}

WORD CChunk::GetNumColors()
{
	WORD cnt=0;
	if(strcmp(&m_header.sign[0],"COST")==0)
	{
		BYTE cmp;
		memcpy(&cmp, (m_header.body+1), 1);
		cnt= 16;
		if(cmp&1)cnt=32;
	}
	else if (strcmp(&m_header.sign[0],"CO")==0){
		BYTE fmt=m_header.body[1];
		if (fmt==0x58){
			cnt=16;
		}else{
			printf("unsupported costume format");
			abort();
		}
	}
	else abort();

	return(cnt);
}

int CChunk::GetPalIndex(int index)
{
	int idx=0;
	if(strcmp(&m_header.sign[0],"COST")==0 || strcmp(&m_header.sign[0],"CO")==0)
	{
//		BYTE cmp;
		memcpy(&idx, (m_header.body+2+index), 1);
	}
	else abort();

	return(idx);
}


WORD CChunk::GetID()
{
	WORD id=0;
	if(strcmp(&m_header.sign[0],"IMHD")==0)
		memcpy(&id, (m_header.body), 2);
	else if(strcmp(&m_header.sign[0],"OI")==0)
	{
		id = MAKEWORD(*(m_header.body+0), *(m_header.body+1));
	}
	else abort();

	return(id);
}

void CChunk::SetID(WORD id)
{
	if(strcmp(&m_header.sign[0],"OI")==0)
	{
		memcpy(m_header.body, &id, 2);
	}
	else abort();

}

WORD CChunk::GetOffsetMask()
{
	DWORD id=0;
	if(strcmp(&m_header.sign[0],"OI")==0)
	{
		memcpy(&id, m_header.body+2, 4);
	}
	else if(strcmp(&m_header.sign[0],"BM")==0)
	{
		memcpy(&id, m_header.body, 4);
	}
	else abort();

	return(id & 0xFFFF);
}

void CChunk::SetOffsetMask(DWORD val)
{
	if(strcmp(&m_header.sign[0],"OI")==0)
	{
		memcpy(m_header.body+2, &val, 4);
	}
	else if(strcmp(&m_header.sign[0],"BM")==0)
	{
		memcpy(m_header.body, &val, 4);
	}
}



BYTE CChunk::GetRVal(BYTE i)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		return(*(m_header.body+0+(i*3)));
	else if(strcmp(&m_header.sign[0],"PA")==0)
		return(*(m_header.body+2+0+(i*3)));
	else abort();
	return 0;
}

BYTE CChunk::GetGVal(BYTE i)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		return(*(m_header.body+1+(i*3)));
	else if(strcmp(&m_header.sign[0],"PA")==0)
		return(*(m_header.body+2+1+(i*3)));
	else abort();
	return 0;
}

BYTE CChunk::GetBVal(BYTE i)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		return(*(m_header.body+2+(i*3)));
	else if(strcmp(&m_header.sign[0],"PA")==0)
		return(*(m_header.body+2+2+(i*3)));
	else abort();
	return 0;
}

void CChunk::SetRVal(BYTE i, int col)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		*(m_header.body+0+(i*3))= col;
	else if(strcmp(&m_header.sign[0],"PA")==0)
		*(m_header.body+2+0+(i*3))= col;
	else abort();
}

void CChunk::SetGVal(BYTE i, int col)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		*(m_header.body+1+(i*3))= col;
	else if(strcmp(&m_header.sign[0],"PA")==0)
		*(m_header.body+2+1+(i*3))= col;
	else abort();
}

void CChunk::SetBVal(BYTE i, int col)
{
	if(strcmp(&m_header.sign[0],"CLUT")==0)
		*(m_header.body+2+(i*3))= col;
	else if(strcmp(&m_header.sign[0],"PA")==0)
		*(m_header.body+2+2+(i*3))= col;
	else abort();
}

