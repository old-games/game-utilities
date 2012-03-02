/***************************************************************
 * Name:      editpanel.cpp
 * Purpose:   Code for EditPanel Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02.29
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "editpanel.h"

EditPanel::EditPanel(  wxWindow* parent ):
	DrawPanel( parent ),
	mDrawGrid( true ),
	mGridColour( *wxWHITE ),
	mGridPoints( NULL ),
	mPointsNumber( 0 )
{
}

EditPanel::~EditPanel(void)
{
	delete mGridPoints;
}

void EditPanel::Render(wxDC& dc)
{
	if (mBitmap == NULL)
	{
		return;
	}
	DrawPanel::Render( dc );
	if (mDrawGrid)
	{
		DrawGrid( dc );
	}
}

void EditPanel::SetShowParams()
{
	DrawPanel::SetShowParams();
	delete[] mGridPoints;
	mPointsNumber = 0;
	if (mScale < 2.0f)
	{
		return;
	}
	mPointsNumber = (mWidth * mHeight) * 2;
	mGridPoints = new wxPoint[mPointsNumber + mWidth + mHeight];
	wxFloat32 xstep = (wxFloat32) mShowWidth / (wxFloat32) mWidth;
	wxFloat32 ystep = (wxFloat32) mShowHeight / (wxFloat32) mHeight;
	wxInt32 count = 0;
	for (wxFloat32 y = 0; y < mShowHeight; y += ystep)
	{
		for (wxFloat32 x = 0; x < mShowWidth; x += xstep)
		{
			mGridPoints[count++] = wxPoint((wxCoord) x, 0);
			mGridPoints[count++] = wxPoint((wxCoord) x, mShowHeight);
		}
		mGridPoints[count++] = wxPoint(0, (wxCoord) y);
		mGridPoints[count++] = wxPoint(mShowWidth, (wxCoord) y);
	}
}

void EditPanel::DrawGrid( wxDC& dc )
{
	if (mScale < 2.0f)
	{
		// ничего хорошего не нарисуется, один хрен
		return;
	}
	wxLogMessage( "drawgrid");
	//dc.DrawLines( mPointsNumber, mGridPoints, mPosX, mPosY );
	for (wxInt32 i = 0; i < mPointsNumber; )
	{
		dc.DrawLine( mGridPoints[i++], mGridPoints[i++] );
	}
}