/***************************************************************
 * Name:      drawpanel.cpp
 * Purpose:   DrawPanel class code
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-02
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "drawpanel.h"

DrawPanel::DrawPanel(  wxWindow* parent, wxInt32 id ):
	wxScrolledWindow( parent, id ),
	mAlign( utdNone ),
	mXAspectRatio( 0.0f ),
	mYAspectRatio( 0.0f ),
	mShowWidth( 0 ),
	mShowHeight( 0 ),
	mPosX( 0 ),
	mPosY( 0 ),
	mScale( 3.0f ),
	mScaledWidth( 0 ),
	mScaledHeight( 0 ),
	mBitmap( NULL ),
	mWidth( 0 ),
	mHeight( 0 )
{
	this->SetBackgroundStyle( wxBG_STYLE_PAINT );
	this->SetDoubleBuffered( true );
	this->Bind( wxEVT_PAINT, &DrawPanel::OnPaint, this, id );
	this->Bind( wxEVT_SIZE, &DrawPanel::OnSize, this, id );
}

DrawPanel::~DrawPanel(void)
{
	this->Unbind( wxEVT_SIZE, &DrawPanel::OnSize, this, this->GetId() );
	this->Unbind( wxEVT_PAINT, &DrawPanel::OnPaint, this, this->GetId() );
	DestroyBitmap();
}

void DrawPanel::CreateBitmap( Pixel* buffer, wxInt32 width, wxInt32 height )
{
	DestroyBitmap();
	wxImage image( width, height, (wxByte*) buffer, true );
	mBitmap = new wxBitmap( image );
	ApplyBitmap();
}

void DrawPanel::SetBitmap( wxBitmap* bitmap )
{
	if ( !bitmap->IsOk() )
	{
		wxLogError("DrawPanel.SetBitmap: bad bitmap!");
		return;
	}
	DestroyBitmap();
	mBitmap = bitmap;
	ApplyBitmap();
}

void DrawPanel::ApplyBitmap()
{
	if ( !mBitmap || !mBitmap->IsOk() )
	{
		wxLogError("DrawPanel.ApplyBitmap: bad bitmap!");
		return;
	}
	mWidth = mBitmap->GetWidth();
	mHeight = mBitmap->GetHeight();
	SetScale( mScale );
	SetShowParams();
}

void DrawPanel::DestroyBitmap()
{
	delete mBitmap;
	mBitmap = NULL;
}

void DrawPanel::SetBuffer( Pixel* buffer )
{
	if ( !mBitmap || !mBitmap->IsOk() )
	{
		return;
	}
	DestroyBitmap();
	wxImage image( mWidth, mHeight, (wxByte*) buffer, true );
	mBitmap = new wxBitmap( image );
	PaintNow();
}

void DrawPanel::SetScale( wxFloat32 scale )
{
	mScale = scale;
	mScaledWidth = (wxFloat32) mWidth * mScale;	
	mScaledHeight = (wxFloat32) mHeight * mScale;
}

void DrawPanel::Render(wxDC& dc)
{
	if (mBitmap == NULL)
	{
		return;
	}
	wxMemoryDC mdc;
	mdc.SelectObject( *mBitmap );
	dc.Clear();
	wxInt32 x = GetScrollPos(wxHORIZONTAL);
	wxInt32 y = GetScrollPos(wxVERTICAL);
	dc.StretchBlit(mPosX - x, mPosY - y, mShowWidth, mShowHeight, &mdc, 0, 0, mWidth, mHeight);
}

void DrawPanel::OnPaint( wxPaintEvent& WXUNUSED(event) )
{
	wxAutoBufferedPaintDC dc(this);
	Render( dc );
}

void DrawPanel::PaintNow()
{
	wxClientDC dc(this);
	Render(dc);
}

inline void DrawPanel::CalculateScrollBars()
{
	wxCoord clw = 0;
	wxCoord clh = 0;
	this->GetClientSize( &clw, &clh );
	wxInt32 x = GetScrollPos(wxHORIZONTAL);
	wxInt32 y = GetScrollPos(wxVERTICAL);
	const wxInt32 unitSize = 2;
	SetScrollbars(unitSize, unitSize, mShowWidth / unitSize, mShowHeight / unitSize, x, y);
}

inline void DrawPanel::SetShowParams()
{
	mShowWidth = mScaledWidth; 
	mShowHeight = mScaledHeight;

	wxCoord clw = 0;
	wxCoord clh = 0;
	this->GetClientSize( &clw, &clh );
	mPosX = 0;
	mPosY = 0;
	if ( mAlign != utdNone )
	{
		wxInt32 halfHeight = clh / 2;
		wxInt32 halfWidth = clw / 2;
		
		mXAspectRatio = (float) clw / (float) mScaledWidth;
		mYAspectRatio = (float) clh / (float) mScaledHeight;

		if ( (mAlign & utdExactFit) != 0)
		{
			float modifier = 1.000f;
			if ( clw < mWidth && clh < mScaledHeight )
			{
				modifier = clw > clh ? mYAspectRatio : mXAspectRatio;
			}
			else
			{
				if ( clw < mScaledWidth )
				{
					modifier = mXAspectRatio;
				}		
				if ( clh < mScaledHeight )
				{
					modifier = mYAspectRatio;
				}
			}
			mShowWidth *= modifier;
			mShowHeight *= modifier;
		}
		
		if ( (mAlign & utdExpand) != 0 )
		{
			if (clw > mScaledWidth && clh > mScaledHeight)
			{
				float modifier = mYAspectRatio > mXAspectRatio ? mXAspectRatio : mYAspectRatio;
				mShowWidth *= modifier;
				mShowHeight *= modifier;
			}
		}
		
		if ( (mAlign & utdStretch) != 0 )
		{ 
			mShowHeight = clh;
			mShowWidth = clw;
		}
		
		if ( (mAlign & utdHCenter) != 0 )
		{
			mPosX = halfWidth - mShowWidth / 2;
		}
		if ( (mAlign & utdVCenter) != 0 )
		{
			mPosY = halfHeight - mShowHeight / 2;
		}
		if ( (mAlign & utdLeft) != 0 )
		{
			mPosX = 0;
		}
		if ( (mAlign & utdRight) != 0 )
		{
			mPosX = clw - mShowWidth;
		}
		if ( (mAlign & utdUp) != 0 )
		{
			mPosY = 0;
		}
		if ( (mAlign & utdDown) != 0 )
		{
			mPosY = clh - mShowHeight;
		}
	}
	CalculateScrollBars();
}

void DrawPanel::OnSize(wxSizeEvent& event)
{
	event.Skip();
	if (mBitmap == NULL)
	{
		return;
	}
	SetShowParams();
}