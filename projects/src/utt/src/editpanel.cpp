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

#define GRID_EDGE	10.0f		// the value after the grid will be shown

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
	wxLogMessage( "recalcgrid");
	if ( mPointsNumber != 0 )
	{
		delete[] mGridPoints;
		mPointsNumber = 0;
	}
	if (mScale < GRID_EDGE)
	{
		// ничего хорошего не нарисуется, один хрен
		return;
	}
	wxSize bounds = this->GetClientSize();
	wxCoord width = (wxFloat32) bounds.GetWidth() / mScale;
	wxCoord height = (wxFloat32) bounds.GetHeight() / mScale;
	mPointsNumber = ( (width + 1) * (height + 1) ) * 2;
	mGridPoints = new wxPoint[mPointsNumber];
	wxFloat32 xstep = 0;
	wxFloat32 ystep = 0;
	wxInt32 count = 0;
	wxInt32 lx = 0, ly = 0;
	for (wxCoord y = 0; y < height; ++y)
	{
		lx = 0;
		for (wxCoord x = 0; x < width; ++x)
		{
			mGridPoints[count++] = wxPoint(lx, 0);
			mGridPoints[count++] = wxPoint(lx, mShowHeight);
			lx += (wxInt32) mScale;
		}
		mGridPoints[count++] = wxPoint(0, ly);
		mGridPoints[count++] = wxPoint(mShowWidth, ly);
		ly += (wxInt32) mScale;
	}
}

void EditPanel::DrawGrid( wxDC& dc )
{
	if (mPointsNumber == 0)
	{
		return;
	}
	wxLogMessage( wxString::Format("drawgrid: points %d", mPointsNumber ) );
	//dc.DrawLines( mPointsNumber, mGridPoints, mPosX, mPosY );
	dc.SetPen( *wxWHITE_PEN );
	for (wxInt32 i = 0; i < mPointsNumber; )
	{
		dc.DrawLine( mGridPoints[i++], mGridPoints[i++] );
	}
}