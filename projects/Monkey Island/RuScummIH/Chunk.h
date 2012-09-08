// Chunk.h: interface for the CChunk class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CHUNK_H__68C6ED9C_12E7_4041_BA1B_B9CEA9F2B3C0__INCLUDED_)
#define AFX_CHUNK_H__68C6ED9C_12E7_4041_BA1B_B9CEA9F2B3C0__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class CChunk  
{
public:
	CChunk();
	virtual ~CChunk();

	bool m_has_valid_header;
	LPTSTR m_valid_chunk_type;
private:

	struct _header{
		LPTSTR	sign;
		DWORD	size;
		BYTE*	body;
		BYTE	type;
		_header(){sign = (LPTSTR)malloc(5); ZeroMemory(sign, 5); body=NULL; type=ATLANTIS_ENGINE;}
		~_header(){free(sign); free(body);}
	};
	
public: //�����, ��� ��� ��� �� ������ ��������� ������, �� �� �����.
	_header m_header;
private:	
	CChunk *m_body;

public:		//������������ ������� ���������� ��������.
	CChunk *Find(LPTSTR name, BOOL like=FALSE);

	int Load(LPTSTR path, LPTSTR filename);
	int Save(LPTSTR path, LPTSTR filename);

public:		//������������ ������� ��� ������� � ������
	WORD GetWidth();				//������ � ��������
	WORD GetHeight();				//������ � ��������
	WORD GetXPos();					//��������� � � ��������
	WORD GetYPos();					//��������� Y � ��������
	BYTE GetRVal(BYTE i);			//������� ��������� � �������
	BYTE GetGVal(BYTE i);			//������� ��������� � �������
	BYTE GetBVal(BYTE i);			//����� ��������� � �������
	WORD GetZPCnt();				//���������� ����� (�����, ������ ZP) �� ��������
	WORD GetIMCnt();				//���������� ��������
	WORD GetID();					//������������� ����� (������� ����� �������, ����� ������� � ��.)
	void SetID(WORD id);					//������������� ����� (������� ����� �������, ����� ������� � ��.)
	WORD GetNumColors();			//���������� ������ � �������

	void SetRVal(BYTE i, int col);			//������� ��������� � �������
	void SetGVal(BYTE i, int col);			//������� ��������� � �������
	void SetBVal(BYTE i, int col);			//����� ��������� � �������

	BYTE *GetFrame(int index);
	WORD GetOffsetFrame(int index);
	void SetOffsetFrame(int index, WORD val);
	int	 GetPalIndex(int index);
	
	WORD GetOffsetMask();
	void SetOffsetMask(DWORD val);


	void SetWidth(WORD width);		//��������� ������ � ��������
	void SetHeight(WORD height);	//��������� ������ � ��������
	void SetXPos(WORD x);			//��������� ��������� X � ��������
	void SetYPos(WORD y);			//��������� ��������� Y � ��������


private:	//���������� ������� � ������ ��� ������������� ��������
	int Init(BYTE * data);
	int Parse(BYTE * body);

	static int sizeoffile, posinfile;
};

#endif // !defined(AFX_CHUNK_H__68C6ED9C_12E7_4041_BA1B_B9CEA9F2B3C0__INCLUDED_)
