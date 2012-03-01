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

	extern const wxInt32 Bits[bppNum];
	extern const wxString Names[bppNum];
};

typedef	wxByte Palette[256][3];
typedef wxByte Pixel[3];
typedef wxByte PixelA[4];

typedef Pixel LetterBox[ MAXIMUM_SYMBOL_WIDTH * MAXIMUM_SYMBOL_HEIGHT ];

struct RGBA
{
	RGBA(): R(0), G(0), B(0), A(0xFF)	{};
	wxByte R;
	wxByte G;
	wxByte B;
	wxByte A;
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

	RGBA GetPixel( wxInt32 x, wxInt32 y );
	void SetPixel( wxInt32 x, wxInt32 y, RGBA color );

	virtual ~SymbolInfo()
	{
		EraseData();
	}
	
	LetterBox* GetData();

	SymbolInfo &operator = ( const SymbolInfo &src );

	wxInt32	mWidth;											// ������ �������
	wxInt32 mHeight;										// ������ �������
	wxUint32 mCode;											// ��� �������, ��� ������� 32 � �.�.
	
protected:

	LetterBox* mData;										// ������ �������, � protected - ��� 
															// �������� �� ��������������

private:

	void SetValues(wxInt32 width, wxInt32 height, wxUint32 code, const LetterBox* data = NULL);
	void CreateData();
	void EraseData();
	wxInt32 BoxOffset(wxInt32 x, wxInt32 y);
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

	wxInt32 GetEncoding()
	{
		return mFontCodePage;
	}
	
	void SetEncoding(wxInt32 n)
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

	wxInt32			mMaxHeight;							// ������������ ������
	wxInt32			mMinHeight;							// ����������� ������
	wxInt32			mMaxWidh;							// ������������ ������
	wxInt32			mMinWidth;							// ����������� ������
	wxInt32			mBaseLine;							// ������� ����� �������
	wxInt32			mCapLine;							// ����� ��������� ����
	wxInt32			mLowLine;							// ����� �������� ����
	wxInt32			mBPP;								// ��� �� �������
	wxInt32			mFontCodePage;						// ���������, ������������� ��������, ��� ������� ������������� ������
	Palette         mPalette;							// �������
	Symbols			mSymbols;							// �������

};

#endif	// UTTTYPES_H_INCLUDED