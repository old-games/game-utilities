// CostumeEnObj.cpp: implementation of the CCostumeEnObj class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "CostumeEnObj.h"
#include "ImageCodec.h"
#include "BMP.h"
//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCostumeEnObj::CCostumeEnObj()
{

}

CCostumeEnObj::~CCostumeEnObj()
{

}

int CCostumeEnObj::Encode()
{
	CChunk mask;		//�����
	CChunk obj;		//��������������� ������
	WORD cnt=0;			//���������� ��������
	LPTSTR tmp;			//��������� ����������
	DWORD size = 0;		
	CImageCodec codec;	//�����
	int w =0;
	int h =0;			//��������
	int err;			//��������� ������
	CBMP bmp(0,0);		//��������

	//������� ��������� � ���� �������
	/*--OUT*/printf("\tfound costume");

	//������ ���� ����������
	err = m_instructions.Load(m_parser->GetSrcPath(), m_parser->GetCurrentFilename());
	if(err)return(err);

	//��������� ���� ����� 0 (��� ������)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	/*--OUT*/printf("\r\n\tLoadFile: %s\\%s",m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	err= mask.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//��������� ���� ����� ��� ��� (� ���� ������� ����� ��������� ��������� � ��� ����� �������)
	if(!m_instructions.GetMaskName(0))return (ERR_INS_FILE_CORRUPT);
	err= obj.Load(m_parser->GetSrcPath(), m_instructions.GetMaskName(0));
	if(err)return(err);

	//���������� ���-�� �������� � �nt
	cnt = mask.GetIMCnt();

	//��������� ������������� �� ���������������� ��, ��� � INS � � �����

	//������� ����������, � ������� ������� ������������ ������.
	BYTE **data = new BYTE*[cnt];
	WORD *dataSz = new WORD[cnt];
	for(int iii = 0; iii < cnt; iii++)
	{
		//������ BMP
		/*--OUT*/printf("\r\n\tLoad BMP: %s\\%s", m_parser->GetSrcPath(), m_instructions.GetIMName(iii));
		err = bmp.LoadBMP(m_parser->GetSrcPath(), m_instructions.GetIMName(iii), ATLANTIS_ENGINE);
		if(err)return(err);

		//���������� ������ bmp � ��������� ���������� � � ������
		w =  bmp.GetWidth();
		h =  bmp.GetHeight();
		codec.m_width =w;

		//������� ������ �� �����
		/*--OUT*/printf("\r\n\twidth: %d\theight: %d", w, h);

		//������� ��������� � ������ �����������
		/*--OUT*/printf("\r\nEncode image");

		//����� ����� �������� � ��������� ��������.

		data[iii] = codec.Encode(bmp.GetSrc(), ATLANTIS_ENGINE_COSTUME, h, mask.GetNumColors());
		dataSz[iii] = _msize(data[iii]);
	}

    //���������� ����� ������ ������������ �������� � ������ ��������� ������
	DWORD sz =0;
	for(int i=0; i<cnt; i++)
	{
		sz+= dataSz[i];
		sz+=12;
	}
	//���������� ������ �� ������ �������� � ������ �����
	//� �������� � ����� ������
	DWORD szTmp = (mask.GetFrame(0)-12)-mask.m_header.body;
	free(obj.m_header.body);
	obj.m_header.size =szTmp+sz;
	obj.m_header.body = (BYTE*)malloc(szTmp+sz);

	//�������� ��� �� ������ �������� � ����� ����
	memcpy(obj.m_header.body, mask.m_header.body, szTmp);
	
	//����� �������� ���������� ��������� � ��������
	DWORD curSz = szTmp;
	for(int i=0; i<cnt; i++)
	{
		memcpy((obj.m_header.body+curSz), (mask.GetFrame(i)-12), 12);
		curSz+=12;
		memcpy((obj.m_header.body+curSz), data[i], dataSz[i]);
		curSz+=dataSz[i];

		//�������� ������ ��������, ������ ������ � ��������� �������
		if(i>0)
		{
			DWORD ooofff = obj.GetOffsetFrame(i-1)+dataSz[i-1]+12;
			obj.SetOffsetFrame(i, obj.GetOffsetFrame(i-1)+dataSz[i-1]+12);
			ooofff = obj.GetOffsetFrame(i);
			int ijk=0;
		}

	}
	obj.m_header.size+= 8;

	//��������� ��� ����� ������� � ���������
	
	tmp = strdup(m_parser->GetCurrentFilename());
	char *pt = strrchr(tmp, '.');
	*pt=0;
	/*--OUT*/printf("\r\n\tSaveFile: %s\\%s",m_parser->GetDstPath(), tmp);
	obj.Save(m_parser->GetDstPath(), tmp);
	free(tmp);

	return(0);
}