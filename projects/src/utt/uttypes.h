/***************************************************************
 * Name:      uttypes.h
 * Purpose:   UTT Types
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-24
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#ifndef _UTT_TYPES_H_
#define _UTT_TYPES_H_

//#define MAXIMUM_SYMBOLS_IN_FONT		2048
#define MINIMUM_SYMBOLS_NUM			1
#define MAXIMUM_SYMBOL_WIDTH		64
#define MAXIMUM_SYMBOL_HEIGHT		64

typedef	unsigned char Palette[256][3];
typedef unsigned int LetterBox[ MAXIMUM_SYMBOL_WIDTH * MAXIMUM_SYMBOL_HEIGHT ];

struct SymbolInfo
{

	explicit SymbolInfo():
		mWidth( -1 ),
		mHeight( -1 ),
		mCode( 0 )
	{
		memset(mData, 0, sizeof(mData));
	}
	
	SymbolInfo &operator = ( const SymbolInfo &src );

	int mWidth;													// ������ �������
	int mHeight;												// ������ �������
	LetterBox mData;											// ������ �������
	unsigned int mCode;											// ��� �������, ��� ������� 32 � �.�.
	
private:
	void SetValues(int width, int height, unsigned int code, const LetterBox* data = NULL);

};

typedef wxVector<SymbolInfo> Symbols;


class FontInfo
{
public:

	FontInfo():
		mMaxHeight( -1 ),
		mMinHeight( -1 ),
		mMaxWidh( -1 ),
		mMinWidth( -1 ),
		mBaseLine( -1 ),
		mCapLine( -1 ),
		mLowLine( -1 ),
		mBPP( -1 )
	{
		SetSymbolsNum( MINIMUM_SYMBOLS_NUM );
		memset(mPalette, 0, sizeof(mPalette));
	}
	
	void SetSymbolsNum(size_t n);
	
	size_t GetSymbolsNum()
	{
		return mSymbols.size();
	}
	
	SymbolInfo& GetSymbol(size_t n)
	{
		if ( n < mSymbols.size() )
		{
			return mSymbols[n];
		}
		return sBadSymbol;
	}
	
	Symbols& GetSymbols()
	{
		return mSymbols;
	}
	
	void SetSymbols(const Symbols& src)
	{
		mSymbols = src;
	}
	
	static SymbolInfo	sBadSymbol;

protected:
	int				mMaxHeight;							// ������������ ������
	int				mMinHeight;							// ����������� ������
	int				mMaxWidh;							// ������������ ������
	int				mMinWidth;							// ����������� ������
	int				mBaseLine;							// ������� ����� �������
	int				mCapLine;							// ����� ��������� ����
	int				mLowLine;							// ����� �������� ����
	int				mBPP;								// ��� �� �������
	Palette         mPalette;							// �������
	Symbols			mSymbols;							// �������

};

#endif