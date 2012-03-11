/***************************************************************
 * Name:      palettepanel.cpp
 * Purpose:   Code for PalettePanel Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-07
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "palettepanel.h"

static const wxSize	sBitmapSize[BPP::bppNum] =
{
	wxSize(2, 1),		// Mono 2 colours
	wxSize(4, 1),		// CGA 4 colours
	wxSize(8, 2),		// EGA 16 colours
	wxSize(32, 8),		// VGA/SVGA	256 colours
	wxSize(512, 128),	// Highcolor 65 536 colours
	wxSize(256, 256),	// Truecolor 16 777 216 colours
	wxSize(256, 256)	// Truecolor with alpha
};

PalettePanel::PalettePanel(  wxWindow* parent,  wxWindowID id /* wxID_ANY */ ):
	EditPanel( parent, id ),
	mPalType( BPP::bppMono),
	mCurrentCGAPal( 0 ),
	mCGAIntensity( false )
{
	SetAllowScaling( false );
	SetDrawFocus( false );
	SetAlign( utdHCenter | utdVCenter );
	SetScale( 25.0f );
	SetGridEnabled();
	SetGridLogic( wxXOR );
	GeneratePalBitmap();
}

PalettePanel::~PalettePanel(void)
{
}

void PalettePanel::GeneratePalBitmap()
{
	const wxSize& size = sBitmapSize[ mPalType ];
	const size_t bufSize = size.x * size.y;
	Pixel* colorMap = new Pixel[ bufSize ];
	Pixel* srcPal = (Pixel*) sVGApal;
	switch ( mPalType )
	{
		case BPP::bppMono:
			srcPal = (Pixel*) sMonoPal;
		break;
		
		case BPP::bpp2:
			srcPal = mCGAIntensity ? (Pixel*) sICGApal[ mCurrentCGAPal ] : (Pixel*) sCGApal[ mCurrentCGAPal ];
		break;
	}
	if ( mPalType <= BPP::bpp8 )
	{
		memcpy( colorMap, srcPal, BPP::ColourNumber[ mPalType ] * sizeof(Pixel) );
	}
	else
	{
	}
	CreateBitmap( colorMap, size.x, size.y );
	delete[] colorMap;
}