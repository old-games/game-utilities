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
	
public: //Жалко, что вот это не сделал приватным членом, ну да ладно.
	_header m_header;
private:	
	CChunk *m_body;

public:		//Интерфейсные функции управления объектом.
	CChunk *Find(LPTSTR name, BOOL like=FALSE);

	int Load(LPTSTR path, LPTSTR filename);
	int Save(LPTSTR path, LPTSTR filename);

public:		//Интерфейсные функции для доступа к данным
	WORD GetWidth();				//Ширина в пикселях
	WORD GetHeight();				//Высота в пикселях
	WORD GetXPos();					//Положение Х в пикселях
	WORD GetYPos();					//Положение Y в пикселях
	BYTE GetRVal(BYTE i);			//Красный компонент в палитре
	BYTE GetGVal(BYTE i);			//Зеленый компонент в палитре
	BYTE GetBVal(BYTE i);			//Синий компонент в палитре
	WORD GetZPCnt();				//Количество слоев (масок, блоков ZP) на картинку
	WORD GetIMCnt();				//Количество картинок
	WORD GetID();					//Идентификатор блока (всмысле номер объекта, номер комнаты и пр.)
	void SetID(WORD id);					//Идентификатор блока (всмысле номер объекта, номер комнаты и пр.)
	WORD GetNumColors();			//Количество цветов в палитре

	void SetRVal(BYTE i, int col);			//Красный компонент в палитре
	void SetGVal(BYTE i, int col);			//Зеленый компонент в палитре
	void SetBVal(BYTE i, int col);			//Синий компонент в палитре

	BYTE *GetFrame(int index);
	WORD GetOffsetFrame(int index);
	void SetOffsetFrame(int index, WORD val);
	int	 GetPalIndex(int index);
	
	WORD GetOffsetMask();
	void SetOffsetMask(DWORD val);


	void SetWidth(WORD width);		//Установка ширины в пикселях
	void SetHeight(WORD height);	//Установка высоты в пикселях
	void SetXPos(WORD x);			//Установка положения X в пикселях
	void SetYPos(WORD y);			//Установка положения Y в пикселях


private:	//Внутренние функции и данные для распознования объектов
	int Init(BYTE * data);
	int Parse(BYTE * body);

	static int sizeoffile, posinfile;
};

#endif // !defined(AFX_CHUNK_H__68C6ED9C_12E7_4041_BA1B_B9CEA9F2B3C0__INCLUDED_)
