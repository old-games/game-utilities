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
	mSymbolNumber( 0 ),
	mActiveLine( -1 ),
	mDragLine( false ),
	mDragPoint( -1, -1 )
{
	for (int i = 0; i < clNum; ++i)
	{
		mLines[i] = new ControlLine( this );
	}
}

SymbolPanel::~SymbolPanel(void)
{
	for (int i = 0; i < clNum; ++i)
	{
		delete mLines[i];
	}
}

void SymbolPanel::SetFontInfo( FontInfo* info, int symbolNumber )
{
	mFontInfo = info;
	mSymbolNumber = symbolNumber;
	UpdateBitmap();
	UpdateControlLines();
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

void SymbolPanel::UpdateControlLines()
{
	SymbolInfo& sym = mFontInfo->GetSymbol( mSymbolNumber );
	mLines[ clSymbolWidth ]->SetParameters( wxVERTICAL, *wxRED, 3, wxSOLID, "Symbol width" );
	mLines[ clSymbolWidth ]->SetValue( sym.mWidth );
}

/* virtual */ void SymbolPanel::Render( wxDC& dc )
{
	EditPanel::Render( dc );
	for (int i = 0; i < clNum; ++i)
	{
		mLines[i]->DrawControlLine( dc );
	}
}

void SymbolPanel::DrawAdditionalLine( wxDC& dc, int x )
{
}

/* virtual */ void SymbolPanel::SetShowParams()
{
	EditPanel::SetShowParams();
	for (int i = 0; i < clNum; ++i)
	{
		mLines[i]->SetOffsetXY( mPosX, mPosY, mShowWidth, mShowHeight, mScale );
	}
}

/* virtual */ void SymbolPanel::OnMotion( wxMouseEvent& event )
{
	if ( !mDragLine && !mDrawing )
	{
		mActiveLine = -1;
		for (int i = 0; i < clNum; ++i)
		{
			if ( mLines[i]->CheckMouse() )
			{
				mActiveLine = i;
				this->SetCursor( *wxCROSS_CURSOR );
				this->SetToolTip( mLines[i]->GetToolTip() );
			}
		}
		if ( mActiveLine == -1 )
		{
			this->SetToolTip( "" );
			this->SetCursor( wxNullCursor );
		}
	}
	else
	{
		if (mActiveLine != -1)
		{
			wxPoint pos = MousePosition2PointCoords( event.GetPosition(), false );
			if (pos.x != -1 && pos.y != -1 && pos != mDragPoint )
			{
				mLines[mActiveLine]->SetValue( pos );
				PaintNow();
				mDragPoint = pos;
				return;
			}
		}
	}
	EditPanel::OnMotion(event);
	event.Skip();
}

/* virtual */ void SymbolPanel::OnBtnDown( wxMouseEvent& event )
{
	if ( mActiveLine != -1 && event.LeftDown() )
	{
    	mDragLine = true;
		return;
	}
	EditPanel::OnBtnDown(event);
	event.Skip();
}

/* virtual */ void SymbolPanel::OnBtnUp( wxMouseEvent& event )
{
	mDragLine = false;
	mActiveLine = -1;
	EditPanel::OnBtnUp(event);
	event.Skip();
}