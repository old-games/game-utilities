// BackgroundEnObj.cpp: implementation of the CBackgroundEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "BackgroundEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBackgroundEnObj::CBackgroundEnObj()
{

}

CBackgroundEnObj::~CBackgroundEnObj()
{

}

int CBackgroundEnObj::Encode()
{
	CChunk mask;		//�����
	CChunk rmhd;		//������ ���� � �������
	CChunk * obj;		//��������������� ������
	WORD cnt=0;			//���������� �����
	LPTSTR tmp;			//��������� ����������
	DWORD size = 0;		
	CImageCodec codec;	//�����
	int w =0;
	int h =0;			//��������
	int err;			//��������� ������
	CBMP bmp(0,0);		//��������

	//������� ��������� � ���� �������
	/*--OUT*/printf("\tfound background");

	//������ ���� ����������
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	//��������� ���� ����� 0 (��� ������)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//��������� ���� ����� 1 (rmhd)
	if(!m_instructions.GetMaskName(1))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	err= rmhd.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(1));
	if(err)return(err);

	//���������� ���-�� ����� � �nt
	obj= mask.Find("RMIH");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	cnt = obj->GetZPCnt();

	//������ BMP
	/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetIMName(0));
	err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(0), ATLANTIS_ENGINE);
	if(err)return(err);

	//���������� ������ bmp � ��������� ���������� � � ������
	w =  bmp.GetWidth();
	h =  bmp.GetHeight();
	codec.m_width =w;

	//������� ������ �� �����
	/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

	//��������� �� ��������� 8
	if(fmod((float)w,8)!=0)return(ERR_BAD_WIDTH_OR_HEIGHT);

	
	//������� ��������� � ������ �����������
	/*--OUT*/printf("\r\nEncode image");

	//��������� ���� � ������ ����� SMAP - ���������� � ���� �����������
	obj =mask.Find("SMAP");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

	//������� ������������ ��������
	free(obj->m_header.body);
	obj->m_header.size = 0;

	//.........................�������� ��������..............................
	int32 *offsets = new int32[w/8];
	byte* body = (byte*)malloc(1);
	offsets[0]= 4*(w/8)+8;

	for(int x=0; x<w/8; x++)
	{
		byte* dst = codec.Encode(bmp.GetSrc()+8*x,ATLANTIS_ENGINE, h);
		
		body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
		memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
		
		if(x<w/8-1)
			offsets[x+1]= offsets[x]+_msize(dst);
		free(dst);
	}
	obj->m_header.size= (w/8*4)+_msize(body)+8;
	obj->m_header.body = (BYTE*)malloc(obj->m_header.size-8);
	memcpy(obj->m_header.body, offsets, w/8*4);
	memcpy(obj->m_header.body+ w/8*4, body, _msize(body));

	delete[]offsets;
	free(body);

	//.........................�������� ����..............................
	if(m_parser->IsEncodeMask())
	{
		for(int i=0; i<cnt; i++)
		{
			/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetZPName(i));
			err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetZPName(i), ATLANTIS_ENGINE);
			if(err)return(err);
			if((w!=bmp.GetWidth())||(h!=bmp.GetHeight()))return(ERR_BAD_WIDTH_OR_HEIGHT);
			/*--OUT*/printf("\r\n\tEncode image");
			

			//��������� ���� � ������ ����� ZP - ���������� � ���� �����������
			tmp = (LPTSTR)malloc(15);
			sprintf(tmp, "ZP%.2d", i+1);
			obj =mask.Find(tmp);
			free(tmp);
			if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);

			//������� ������������ ��������
			free(obj->m_header.body);
			obj->m_header.size = 0;

			WORD *offsets = new WORD[w/8];
			byte* body = (byte*)malloc(1);
			offsets[0]= 2*(w/8)+8;

			for(int x=0; x<w/8; x++)
			{
				byte* dst = codec.Encode(bmp.GetSrc()+8*x,ATLANTIS_ENGINE_MASK, h);
				
				body = (byte*)realloc(body, offsets[x]-offsets[0] + _msize(dst));
				memcpy(body+offsets[x]-offsets[0], dst, _msize(dst));
				
				if(x<w/8-1)
					offsets[x+1]= offsets[x]+_msize(dst);
				free(dst);
			}
			obj->m_header.size= (w/8*2)+_msize(body)+8;
			obj->m_header.body = (BYTE*)malloc(obj->m_header.size-8);
			memcpy(obj->m_header.body, offsets, w/8*2);
			memcpy(obj->m_header.body+ w/8*2, body, _msize(body));

			delete[]offsets;
			free(body);
		}
	}
	else
	{
		// ���� ���� -m �� ������.
		if((w!=rmhd.GetWidth())||(h!=rmhd.GetHeight()))return(ERR_BAD_WIDTH_NOT_M_PRESENT);
	}
	//////////////////////////////////////////////////////////////////////


	//������������ ������ ����� IM00 = ����� �������� ZP + ������ SMAP + 8 ����
	obj= mask.Find("SMAP");
	size= obj->m_header.size + 8;
	for(int k=1;k<=cnt;k++)
	{
		int i = k;
		char _tmp[5]="";
		sprintf(&_tmp[0], "ZP%.2d", i);
		
		obj=mask.Find(&_tmp[0], TRUE);
		if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
		size+= obj->m_header.size;
	}
	obj= mask.Find("IM00");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	obj->m_header.size = size;


	//������������ ������ ����� RMIM = ����� �������� IM00, RMIH + 8 ����
	size = obj->m_header.size;
	
	obj= mask.Find("RMIH");
	if(!obj)return(ERR_NEEDED_BLOCK_NOT_FOUND);
	size+=obj->m_header.size + 8;
	mask.m_header.size = size;
	/*--OUT*/printf("\r\n\tSaveFile: %s\\RMIM",m_parser->GetDstPath());
	mask.Save(m_parser->GetDstPath(), "RMIM");

	//���������� ��������
	rmhd.SetWidth(w);
	rmhd.SetHeight(h);

	/*--OUT*/printf("\r\n\tSaveFile: %s\\RMHD",m_parser->GetDstPath());
	rmhd.Save(m_parser->GetDstPath(), "RMHD");

	return(0);
}