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
	wxSize(256, 256),	// Highcolor 65 536 colours
	wxSize(256, 256),	// Truecolor 16 777 216 colours
	wxSize(256, 256)	// Truecolor with alpha
};

static const wxFloat32	sSquares[BPP::bppNum] =
{
	50.0f,
	40.0f,
	25.0f,
	20.0f,
	3.0f,
	3.0f,
	3.0f
};

PalettePanel::PalettePanel(  wxWindow* parent, bool changeGlobalColours /* true */,  wxWindowID id /* wxID_ANY */ ):
	EditPanel( parent, id ),
	mPalType( BPP::bppMono),
	mCurrentCGAPal( 0 ),
	mCGAIntensity( false ),
	mLeftPos(0, 0),
	mRightPos(1, 0),
	mChangeGlobals( changeGlobalColours )
{
	SetAllowScaling( false );
	SetDrawFocus( false );
	SetAlign( utdHCenter | utdVCenter );
	SetScale( 12.0f );
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
		SetGridEnabled( );
	}
	else
	{
		Pixel* dstPal = colorMap;
		for (int y = 0; y < size.y; ++y)
		{
			Pixel& pix = * (srcPal++) ;
			wxColour col( pix[0], pix[1], pix[2] );
			for (int x = 0; x < size.x; ++x)
			{
				int lightness = 64 + x / 2;
				wxColour newCol = col.ChangeLightness( lightness );
				Pixel& dst = * (dstPal++) ;
				dst[0] = newCol.Red();		
				dst[1] = newCol.Green();
				dst[2] = newCol.Blue();
			}
		}
		SetGridEnabled( false );
	}
	CreateBitmap( colorMap, size.x, size.y );
	delete[] colorMap;
	CorrectColourPosition( false );
	CorrectColourPosition( true );
	SetScale( sSquares[ mPalType ] );
}

void PalettePanel::CorrectColourPosition( bool right )
{
	wxPoint& pos = right ? mRightPos : mLeftPos;
	if (pos.x >= mBitmap->GetWidth())
	{
		pos.x = mBitmap->GetWidth() - 1;
	}
	if (pos.y >= mBitmap->GetHeight())
	{
		pos.y = mBitmap->GetHeight() - 1;
	}
	GetBitmapColour( right );
}

void PalettePanel::SetGlobalColours()
{
	if (!mChangeGlobals)
	{
		return;
	}
	EditPanel::gGlobalLeftColour = mLeftColour;
	EditPanel::gGlobalRightColour = mRightColour;
}

void PalettePanel::GetBitmapColour( bool right )
{
	wxColour& colour = right ? mRightColour : mLeftColour;
	wxPoint& pos = right ? mRightPos : mLeftPos;
	if (this->GetPixel( pos , colour ))
	{
		this->GetParent()->Refresh();
		SetGlobalColours();
	}
}

void PalettePanel::SetBitmapColour( bool right )
{
	wxColour& colour = right ? mRightColour : mLeftColour;
	wxPoint& pos = right ? mRightPos : mLeftPos;
	PlacePixel( pos, colour );
}

const wxColour& PalettePanel::GetColour( bool right )
{
	return right ? mRightColour : mLeftColour;
}

void PalettePanel::SetColour( bool right, const wxColour& colour)
{
	if (right)
	{
		mRightColour = colour;
	}
	else
	{
		mLeftColour = colour;
	}
	SetBitmapColour( right );
}

int	PalettePanel::FindColour( bool right, const wxColour& colour, bool andSet /* false */ )
{
	int res = -1;
	wxMemoryDC temp_dc;
	temp_dc.SelectObject(*mBitmap);
	wxColour compare;
	wxPoint pos( -1, -1 );
	for ( int y = 0; y < mHeight && res == -1; ++y )
	{
		for ( int x = 0; x < mWidth; ++x )
		{	
			if ( temp_dc.GetPixel( x, y, &compare ) && compare == colour )
			{
				res = (y * mWidth) + x;
				pos.x = x;
				pos.y = y;
				break;
			}
		}
	}
	if (res != -1 && andSet)
	{
		if ( right )
		{
			mRightPos = pos;
		}
		else
		{
			mLeftPos = pos;
		}
		GetBitmapColour( right );
	}
	return res;
}

/* virtual */ void PalettePanel::OnBtnDown( wxMouseEvent& event )
{
	if ( !event.LeftIsDown() && !event.RightIsDown() )
	{
		return;
	}
	wxPoint pos = MousePosition2PointCoords( event.GetPosition() );
	if ( pos.x == -1 || pos.y == -1 )
	{
		return;
	}
	if ( event.RightIsDown() )
	{
		mRightPos = pos;
	}
	else
	{
		mLeftPos = pos;
	}
	GetBitmapColour( event.RightIsDown() );
	PaintNow();
}


/* virtual */ void PalettePanel::Render(wxDC& dc)
{
	EditPanel::Render( dc );
	int x, y;
	this->GetViewStart( &x, &y );
	wxPoint view(mPosX - x, mPosY - y);
	wxSize size( mScale + 2, mScale + 2);
	dc.SetBrush( *wxTRANSPARENT_BRUSH );
	dc.SetLogicalFunction( wxCOPY );
	wxPen pen( *wxGREEN, 3, wxLONG_DASH );
	for (int i = 0; i < 2; ++i)
	{
		wxPoint pos = i == 0 ? mLeftPos : mRightPos;
		wxPoint from( (pos.x * mScale) - 1, (pos.y * mScale) - 1 );
		if ( i > 0 )
		{
			pen.SetColour( *wxRED );
			if (mLeftPos == mRightPos)
			{
				from.x -= 2;
				from.y -= 2;
				size += wxSize(4, 4);
			}
		}
		dc.SetPen( pen );
		dc.DrawRectangle( view + from, size );
	}
}