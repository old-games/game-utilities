/***************************************************************
 * Name:      uttypes.h
 * Purpose:   UTT Types
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-24
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#ifndef UTTTYPES_H_INCLUDED
#define UTTTYPES_H_INCLUDED

#define MAXIMUM_SYMBOLS_NUM			16384
#define MINIMUM_SYMBOLS_NUM			1

#define MAXIMUM_SYMBOL_WIDTH		64
#define MAXIMUM_SYMBOL_HEIGHT		64

namespace BPP
{
	enum
	{
		bppMono,
		bpp2,
		bpp4,
		bpp8,
		bpp16,
		bpp24,
		bpp32,
		bppNum
	};

	extern const int Bits[bppNum];
	extern const wxString Names[bppNum];
};

typedef	unsigned char Palette[256][3];
typedef unsigned char Pixel[3];
typedef unsigned char PixelA[4];

typedef Pixel LetterBox[ MAXIMUM_SYMBOL_WIDTH * MAXIMUM_SYMBOL_HEIGHT ];

struct RGBA
{
	RGBA(): R(0), G(0), B(0), A(0xFF)	{};
	int R;
	int G;
	int B;
	int A;
};

struct SymbolInfo
{

	explicit SymbolInfo():
		mWidth( 0 ),
		mHeight( 0 ),
		mCode( 0 ),
		mData( NULL )
	{
	}

	RGBA GetPixel( int x, int y );
	void SetPixel( int x, int y, RGBA color );

	virtual ~SymbolInfo()
	{
		EraseData();
	}
	
	LetterBox* GetData();

	SymbolInfo &operator = ( const SymbolInfo &src );

	int	mWidth;													// ширина символа
	int mHeight;												// высота символа
	unsigned int mCode;											// код символа, для пробела 32 и т.д.
	
protected:

	LetterBox* mData;											// данные символа, в protected - для 
																// контроля за инициализацией

private:

	void SetValues(int width, int height, unsigned int code, const LetterBox* data = NULL);
	void CreateData();
	void EraseData();
	int	 BoxOffset(int x, int y);
};

typedef wxVector<SymbolInfo> Symbols;


class FontInfo
{
public:

	FontInfo():
		mMaxHeight( 0 ),
		mMinHeight( 0 ),
		mMaxWidh( 0 ),
		mMinWidth( 0 ),
		mBaseLine( 0 ),
		mCapLine( 0 ),
		mLowLine( 0 ),
		mBPP( -1 ),
		mFontCodePage( 0 )
	{
		SetSymbolsNum( MINIMUM_SYMBOLS_NUM );
		memset(mPalette, 0, sizeof(mPalette));
	}
	
	void SetSymbolsNum(size_t n);
	
	size_t GetSymbolsNum()
	{
		return mSymbols.size();
	}

	int GetEncoding()
	{
		return mFontCodePage;
	}
	
	void SetEncoding(int n)
	{
		mFontCodePage = n;
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

	int				mMaxHeight;							// максимальная высота
	int				mMinHeight;							// минимальная высота
	int				mMaxWidh;							// максимальная ширина
	int				mMinWidth;							// минимальная ширина
	int				mBaseLine;							// базовая линия символа
	int				mCapLine;							// линия заглавных букв
	int				mLowLine;							// линия строчных букв
	int				mBPP;								// бит на пиксель
	int				mFontCodePage;						// кодировка, относительный параметр, для лучшего представления шрифта
	Palette         mPalette;							// палитра
	Symbols			mSymbols;							// символы

};

#endif	// UTTTYPES_H_INCLUDED