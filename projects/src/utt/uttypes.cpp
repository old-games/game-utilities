#include "pch.h"
#include "uttypes.h"


const int BPP::Bits[BPP::bppNum] = 
{
	1,
	2,
	4,
	8,
	16,
	24,
	32
};

const wxString BPP::Names[BPP::bppNum] =
{
	"Monochrome",
	"CGA",
	"EGA",
	"VGA",
	"High color",
	"True color",
	"True color with alpha"
};

SymbolInfo FontInfo::sBadSymbol;

void SymbolInfo::SetValues(int width, int height, unsigned int code, const LetterBox* data /* NULL */)
{
	mWidth = width;
	mHeight = height;
	mCode = code;
	if (data != NULL) 
	{
		CreateData();
		memcpy(mData, data, sizeof( LetterBox ));	
	}
	else
	{
		EraseData();
	}
}

inline SymbolInfo &SymbolInfo::operator = ( const SymbolInfo &src )
{
	this->SetValues(src.mWidth, src.mHeight, src.mCode, src.mData);
	return *this;
}

inline void SymbolInfo::CreateData()
{
	if (mData == NULL)
	{
		static const size_t size = sizeof(LetterBox);
		mData = new LetterBox[size];
		memset( mData, 0, size );
	}
}

inline void SymbolInfo::EraseData()
{
	delete[] mData;
	mData = NULL;
}

inline LetterBox* SymbolInfo::GetData()
{
	CreateData();
	return mData;
}

inline int SymbolInfo::BoxOffset(int x, int y)
{
	int offset = (x * MAXIMUM_SYMBOL_WIDTH) + y;
	if ( offset >= sizeof(LetterBox) )
	{
		wxLogMessage( wxString::Format("SymbolInfo::BoxOffset: coordinates are out of range (X: %d, Y: %d)", x, y) );
		return -1;
	}
	return offset;
}

void SymbolInfo::SetPixel( int x, int y, RGBA color )
{
	int offset = BoxOffset(x, y);
	if ( offset < 0 )
	{
		return;
	}
	Pixel& val = *mData[offset];
	val[0] = color.R;
	val[1] = color.G;
	val[2] = color.B;
}

RGBA SymbolInfo::GetPixel( int x, int y )
{
	RGBA res;
	int offset = BoxOffset(x, y);
	if ( offset < 0 )
	{
		return res;
	}
	Pixel& val = *mData[offset];
	res.R = val[0];
	res.G = val[1];
	res.B = val[2];
	return res;
}

void FontInfo::SetSymbolsNum(size_t n)
{
	if (n >= MINIMUM_SYMBOLS_NUM)
	{
		mSymbols.resize(n);
	}
}

