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

#define GRID_EDGE	6.0f		// the value after the grid will be shown

EditPanel::EditPanel(  wxWindow* parent ):
	DrawPanel( parent ),
	mDrawGrid( true ),
	mGridColour( *wxGREEN ),
	mGridPoints( NULL ),
	mPointsNumber( 0 ),
	mGridPen( mGridColour ),
	mGridLogic( wxXOR )
{

}

EditPanel::~EditPanel(void)
{
	ClearGridPoints();
}

inline void EditPanel::ClearGridPoints()
{
	if ( mPointsNumber != 0 )
	{
		delete[] mGridPoints;
		mPointsNumber = 0;
	}
}

void EditPanel::SetGridColour(const wxColour& color)
{
	mGridColour = color;
	mGridPen.SetColour( mGridColour );
}

void EditPanel::SetGridLogic(wxInt32 logic)
{
	mGridLogic = logic;
}

/* virtual */ void EditPanel::Render(wxDC& dc)
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

/* virtual */ void EditPanel::SetShowParams()
{
	DrawPanel::SetShowParams();
	ClearGridPoints();
	if (mScale < GRID_EDGE)
	{
		// ничего хорошего не нарисуется, один хрен
		return;
	}
	wxSize bounds = this->GetClientSize();
	bool correctX = false;
	bool correctY = false;
	if (bounds.GetWidth() > mShowWidth)
	{
		bounds.SetWidth( mShowWidth );
		correctX = true;
	}
	if (bounds.GetHeight() > mShowHeight)
	{
		bounds.SetHeight( mShowHeight );
		correctY = true;
	}
	wxFloat32 fscale = floor(mScale);
	wxFloat32 cscale = ceil(mScale);
	wxCoord gridWidth = bounds.GetWidth();
	wxCoord gridHeight = bounds.GetHeight();
	wxCoord width = 1 + ceil( (wxFloat32) gridWidth / mScale );
	wxCoord height = 1 + ceil( (wxFloat32) gridHeight / mScale );
	if (width < 2 || height < 2)
	{
		return;
	}
	mPointsNumber = (width + height) * 2;
	mGridPoints = new wxPoint[mPointsNumber];
	wxInt32 count = 0;
	wxFloat32 lx = 0, ly = 0;
	wxInt32 startX = 0, startY = 0;
	bounds = this->GetClientSize();
	if (correctX)
	{
		startX = mPosX + mScale; // ( bounds.GetWidth() / 2 - mShowWidth / 2 ) + mScale;
		lx += startX;
	}
	if (correctY)
	{
		startY = mPosY + mScale; // ( bounds.GetHeight() / 2 - mShowHeight / 2 ) + mScale;
		ly += startY;
	}
	for (wxCoord y = 0; y < height; ++y)
	{
		mGridPoints[count++] = wxPoint(startX, ly);
		mGridPoints[count++] = wxPoint(startX + gridWidth, ly);
		ly += mScale;
	}
	for (wxCoord x = 0; x < width; ++x)
	{
		mGridPoints[count++] = wxPoint(lx, startY);
		mGridPoints[count++] = wxPoint(lx, startY + gridHeight);
		lx += mScale;
	}
}

void EditPanel::DrawGrid( wxDC& dc )
{
	if (mPointsNumber == 0)
	{
		return;
	}
	dc.SetPen( mGridPen );
	dc.SetLogicalFunction( (wxRasterOperationMode) mGridLogic );
	wxInt32 horPos = this->GetScrollPos( wxHORIZONTAL );
	wxInt32 vertPos = this->GetScrollPos( wxVERTICAL );
	wxFloat32 horFloat = (wxFloat32) horPos / mScale;
	wxFloat32 vertFloat = (wxFloat32) vertPos / mScale;
	wxInt32 horizCorr = ( (wxFloat32) horPos - ( ceil(horFloat) * mScale ) + mScale);
	wxInt32 vertCorr = ( (wxFloat32) vertPos - ( ceil(vertFloat) * mScale ) + mScale); 
	wxPoint corrPoint( horizCorr, vertCorr );
	for (wxInt32 i = 0; i < mPointsNumber; )
	{
		wxPoint& first = mGridPoints[i++];
		wxPoint& second = mGridPoints[i++];
		dc.DrawLine( first - corrPoint, second - corrPoint );
	}
}