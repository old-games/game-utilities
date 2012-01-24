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

	int mWidth;													// ширина символа
	int mHeight;												// высота символа
	int mData[ MAXIMUM_SYMBOL_WIDTH * MAXIMUM_SYMBOL_HEIGHT];	// данные символа
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

	size_t			mNum;								// количество_символов
	unsigned int	mCodes[ MAXIMUM_SYMBOLS_IN_FONT ];	// по-умолчанию номер элемента совпадает с кодом
	int				mMaxHeight;							// максимальная высота
	int				mMinHeight;							// минимальная высота
	int				mMaxWidh;							// максимальная ширина
	int				mMinWidth;							// минимальная ширина
	int				mBaseLine;							// базовая линия символа
	int				mCapLine;							// линия заглавных букв
	int				mLowLine;							// линия строчных букв
	int				mBPP;								// бит на пиксель
	Palette         mPalette;							// палитра
	SymbolInfo		mSymbols[ MAXIMUM_SYMBOLS_IN_FONT ];// символы
};

#endif