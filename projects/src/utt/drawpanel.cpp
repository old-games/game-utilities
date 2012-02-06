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
	mKeepAspectRatio( true ),
	mAlign( utdExpand | utdHCenter | utdVCenter ),
	mXAspectRatio( 0.0f ),
	mYAspectRatio( 0.0f ),
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
	SetAspectRatio();
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
	wxSize clientSize = this->GetClientSize();
	wxMemoryDC mdc;
	mdc.SelectObject( *mBitmap );
	int showWidth = mWidth; 
	int showHeight = mHeight;
	int posX = 0;
	int posY = 0;
	if (mKeepAspectRatio)
	{
		showWidth *= mXAspectRatio;
		showHeight *= mYAspectRatio;
	}
	if ( mAlign != utdNone )
	{
		int halfHeight = clientSize.GetHeight() / 2;
		int halfWidth = clientSize.GetWidth() / 2;
		if ( mAlign & utdHCenter != 0 )
		{
			posX = halfWidth - showWidth / 2;
		}
		if ( mAlign & utdVCenter != 0 )
		{
			posY = halfHeight - showHeight / 2;
		}
	}
	dc.Clear();
	dc.StretchBlit(posX, posY, showHeight, showWidth, &mdc, 0, 0, mWidth, mHeight);
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

inline void DrawPanel::SetAspectRatio()
{
}

void DrawPanel::OnSize(wxSizeEvent& event)
{
	event.Skip();
	wxSize clientSize = this->GetClientSize();
	mXAspectRatio = (float) clientSize.GetHeight() / (float) clientSize.GetWidth();
	mYAspectRatio = (float) clientSize.GetWidth() / (float) clientSize.GetHeight();
}