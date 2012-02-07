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

DrawPanel::DrawPanel(  wxWindow* parent, int id ):
	wxScrolledWindow( parent, id ),
	mAlign( utdExpand | utdHCenter | utdVCenter | utdExactFit),
	mXAspectRatio( 0.0f ),
	mYAspectRatio( 0.0f ),
	mShowWidth( 0 ),
	mShowHeight( 0 ),
	mPosX( 0 ),
	mPosY( 0 ),
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
}

void DrawPanel::CreateBitmap( Pixel* buffer, int width, int height )
{
	DestroyBitmap();
	wxImage image( width, height, (unsigned char*) buffer, true );
	mBitmap = new wxBitmap( image );
	mWidth = width;
	mHeight = height;
	SetShowParams();
}

void DrawPanel::DestroyBitmap()
{
	delete mBitmap;
	mBitmap = NULL;
}

void DrawPanel::SetBuffer( Pixel* buffer )
{
	if ( !mBitmap->IsOk() )
	{
		return;
	}
	CreateBitmap( buffer, mWidth, mHeight );
	PaintNow();
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
	dc.StretchBlit(mPosX, mPosY, mShowWidth, mShowHeight, &mdc, 0, 0, mWidth, mHeight);
}

void DrawPanel::OnPaint(wxPaintEvent& event)
{
	wxAutoBufferedPaintDC dc(this);
	Render( dc );
}

void DrawPanel::PaintNow()
{
	wxClientDC dc(this);
	Render(dc);
}

inline void DrawPanel::SetShowParams()
{
	wxSize clientSize = this->GetClientSize();
	mShowWidth = mWidth; 
	mShowHeight = mHeight;
	mPosX = 0;
	mPosY = 0;
	if ( mAlign != utdNone )
	{
		int halfHeight = clientSize.GetHeight() / 2;
		int halfWidth = clientSize.GetWidth() / 2;
		
		if ( mAlign & utdExactFit != 0 )
		{
			mXAspectRatio = (float) clientSize.GetWidth() / (float) mWidth;
			mYAspectRatio = (float) clientSize.GetHeight() / (float) mHeight;
			if ( clientSize.GetWidth() < mWidth )
			{
				mShowWidth *= mXAspectRatio;
				mShowHeight *= mXAspectRatio;
			}		
			if ( clientSize.GetHeight() < mHeight )
			{
				mShowWidth *= mYAspectRatio;
				mShowHeight *= mYAspectRatio;
			}			
		}
		
		if ( mAlign & utdExpand != 0 )
		{ here we stopped
			mXAspectRatio = (float) mWidth / (float) clientSize.GetWidth();
			mYAspectRatio = (float) mHeight / (float) clientSize.GetHeight();
			if ( clientSize.GetWidth() > mWidth )
			{
				mShowWidth = clientSize.GetWidth() * mXAspectRatio;
				mShowHeight = mXAspectRatio;
			}		
			if ( clientSize.GetHeight() > mHeight )
			{
				mShowWidth = mYAspectRatio;
				mShowHeight = mYAspectRatio;
			}			
		}
		
		if ( mAlign & utdHCenter != 0 )
		{
			mPosX = halfWidth - mShowWidth / 2;
		}
		if ( mAlign & utdVCenter != 0 )
		{
			mPosY = halfHeight - mShowHeight / 2;
		}
	}
}

void DrawPanel::OnSize(wxSizeEvent& event)
{
	event.Skip();
	SetShowParams();
}