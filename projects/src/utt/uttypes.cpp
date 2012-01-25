#include "pch.h"
#include "uttypes.h"

SymbolInfo FontInfo::sBadSymbol;

void SymbolInfo::SetValues(int width, int height, unsigned int code, const LetterBox* data /* NULL */)
{
	mWidth = width;
	mHeight = height;
	mCode = code;
	if (!data)
	{
		memset(mData, 0, sizeof( LetterBox ));
	}
	else
	{
		memcpy(mData, data, sizeof( LetterBox ));	
	}
}

inline SymbolInfo &SymbolInfo::operator = ( const SymbolInfo &src )
{
	this->SetValues(src.mWidth, src.mHeight, src.mCode, &src.mData);
	return *this;
}

void FontInfo::SetSymbolsNum(size_t n)
{
	if (n >= MINIMUM_SYMBOLS_NUM)
	{
		mSymbols.resize(n);
	}
}
