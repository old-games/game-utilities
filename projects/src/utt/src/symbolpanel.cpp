/***************************************************************
 * Name:      symbolpanel.cpp
 * Purpose:   Code for SymbolPanel class  
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "symbolpanel.h"

SymbolPanel::SymbolPanel(  wxWindow* parent, wxWindowID id /* wxID_ANY */):
	EditPanel( parent, id ),
	mFontInfo( NULL ),
	mAllowEdit( true ),
	mSymbolNumber( 0 )
{
}

SymbolPanel::~SymbolPanel(void)
{
}

void SymbolPanel::SetFontInfo( FontInfo* info, int symbolNumber )
{
	mFontInfo = info;
	mSymbolNumber = symbolNumber;
	UpdateBitmap();
}

void SymbolPanel::UpdateBitmap()
{
	if ( !mFontInfo )
	{
		DestroyBitmap();
		return;
	}
	SymbolInfo& sym = mFontInfo->GetSymbol( mSymbolNumber );
	if (&sym == &FontInfo::sBadSymbol)
	{
		wxLogMessage( wxString::Format("SymbolPanel::UpdateBitmap: can't update bitmap for symbol %d", mSymbolNumber) );
		return;
	}
	DestroyBitmap();
	int width = mFontInfo->GetMaxWidth();
	int height = mFontInfo->GetMaxHeight();
	Pixel* buffer = new Pixel[ width * height ];
	Helpers::CropBuffer( buffer, width, height, (Pixel*) sym.GetData(), MAXIMUM_SYMBOL_WIDTH, MAXIMUM_SYMBOL_HEIGHT );
	wxImage image( width, height, (wxByte*) buffer, true );
	mBitmap = new wxBitmap( image );
	delete[] buffer;
	
	ApplyBitmap();

}