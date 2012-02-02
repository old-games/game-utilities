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

DrawPanel::DrawPanel(  wxWindow* parent ):
	wxScrolledWindow( parent ),
	mBitmap( NULL )
{
}

DrawPanel::~DrawPanel(void)
{
}

void DrawPanel::CreateBitmap( Pixel* buffer, int width, int height )
{
	DestroyBitmap();
	wxImage image( width, height, buffer, true );
	mBitmap = new wxBitmap( image );
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
}

void DrawPanel::Render(wxDC& dc)
{
	
}