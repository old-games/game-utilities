/***************************************************************
 * Name:      mainframeimpl.h
 * Purpose:   FontEditGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef FONTEDITIMPL_H_INCLUDED
#define FONTEDITIMPL_H_INCLUDED

#include "uttgui.h"

#define MAXIMUM_SYMBOLS_IN_FONT		2048
#define MAXIMUM_SYMBOL_WIDTH		64
#define MAXIMUM_SYMBOL_HEIGHT		64

typedef	unsigned char Palette[256][3];

struct SymbolInfo
{
	SymbolInfo():
		mWidth( -1 ),
		mHeight( -1 )
	{
		memset(mData, 0, sizeof(mData));
	}

	int mWidth;													// ������ �������
	int mHeight;												// ������ �������
	int mData[ MAXIMUM_SYMBOL_WIDTH * MAXIMUM_SYMBOL_HEIGHT];	// ������ �������
};

struct FontInfo
{
	FontInfo():
		mNum( 0 ),
		mMaxHeight( -1 ),
		mMinHeight( -1 ),
		mMaxWidh( -1 ),
		mMinWidth( -1 ),
		mBaseLine( -1 ),
		mCapLine( -1 ),
		mLowLine( -1 ),
		mBPP( -1 )
	{
		memset(mCodes, 0, sizeof(mCodes));
		memset(mPalette, 0, sizeof(mPalette));
	}

	size_t			mNum;								// ����������_��������
	unsigned int	mCodes[ MAXIMUM_SYMBOLS_IN_FONT ];	// ��-��������� ����� �������� ��������� � �����
	int				mMaxHeight;							// ������������ ������
	int				mMinHeight;							// ����������� ������
	int				mMaxWidh;							// ������������ ������
	int				mMinWidth;							// ����������� ������
	int				mBaseLine;							// ������� ����� �������
	int				mCapLine;							// ����� ��������� ����
	int				mLowLine;							// ����� �������� ����
	int				mBPP;								// ��� �� �������
	Palette         mPalette;							// �������
	SymbolInfo		mSymbols[ MAXIMUM_SYMBOLS_IN_FONT ];// �������
};

class FontEditImpl :
	public FontEditGui
{
public:
	FontEditImpl( wxWindow* parent );
	~FontEditImpl(void);

	void SetFont( const FontInfo& newFont );
	bool ShowSettings();
	bool CreateFont();

protected:

	void Render(wxDC& dc);
	void OnPaint(wxPaintEvent& event);
	
	virtual void OnBtnClick( wxCommandEvent& event );
private:	

	FontInfo*	mCurrentFont;
};

#endif
