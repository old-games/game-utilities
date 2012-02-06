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
	mBitmap( NULL ),
	mWidth( 0 ),
	mHeight( 0 )
{
	this->SetBackgroundStyle( wxBG_STYLE_PAINT );
	this->SetDoubleBuffered( true );
	this->Bind( wxEVT_PAINT, &DrawPanel::OnPaint, this, id );
	//this->Bind( wxEVT_SIZE, &DrawPanel::OnSize, this, id );
	//this->Bind( wxEVT
}

DrawPanel::~DrawPanel(void)
{
	this->Unbind( wxEVT_PAINT, &DrawPanel::OnPaint, this, this->GetId() );
}

void DrawPanel::CreateBitmap( Pixel* buffer, int width, int height )
{
	DestroyBitmap();
	wxImage image( width, height, (unsigned char*) buffer, true );
	mBitmap = new wxBitmap( image );
	mWidth = width;
	mHeight = height;
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
	//mdc.DrawBitmap( *mBitmap, 0, 0 );
	mdc.SelectObject( *mBitmap );
	dc.StretchBlit(0, 0, clientSize.GetWidth(), clientSize.GetHeight(), &mdc, 0, 0, mWidth, mHeight);
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

void DrawPanel::OnSize(wxSizeEvent& event)
{
	//wxAutoBufferedPaintDC dc(this);
	//Render( event.GetDC );
}