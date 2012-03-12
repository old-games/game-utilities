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

wxColour	EditPanel::gGlobalLeftColour = *wxBLACK;
wxColour	EditPanel::gGlobalRightColour = *wxWHITE;

EditPanel::EditPanel(  wxWindow* parent,  wxWindowID id ):
	DrawPanel( parent, id ),
	SelectionRectangle( this ),
	mDrawGrid( true ),
	mDrawFocus( true ),
	mGridColour( *wxGREEN ),
	mGridPoints( NULL ),
	mPointsNumber( 0 ),
	mGridPen( mGridColour ),
	mGridLogic( wxXOR ),
	mDrawing( false ),
	mCurrentColour( *wxBLACK ),
	mPreviousPoint( -1, -1)
{
}

EditPanel::~EditPanel(void)
{
	ClearGridPoints();
}

/* virtual */ void EditPanel::OnFocus( wxFocusEvent& )
{
	this->PaintNow();
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
	if (!mBitmap || !mBitmap->IsOk())
	{
		return;
	}
	DrawPanel::Render( dc );
	if (mDrawGrid)
	{
		DrawGrid( dc );
	}
	if (mDrawFocus)
	{
		wxRect rect = this->GetClientRect();
		if (rect.GetWidth() > mShowWidth)
		{
			rect.SetWidth( mShowWidth );
		}
		if (rect.GetHeight() > mShowHeight)
		{
			rect.SetHeight( mShowHeight );
		}
		dc.SetLogicalFunction(wxCOPY);
		dc.SetBrush( *wxTRANSPARENT_BRUSH );
		wxPen borderPen( this->HasFocus() ? *wxRED : *wxWHITE, 3, wxDOT_DASH );
		dc.SetPen( borderPen );
		dc.DrawRectangle( mPosX, mPosY, rect.GetWidth(), rect.GetHeight() );
	}
	RenderSelection( dc );
}

/* virtual */ void EditPanel::SetShowParams()
{
	DrawPanel::SetShowParams();
	SetWorkZone( wxRect(mPosX, mPosY, mShowWidth, mShowHeight), mScale );
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
	int count = 0;
	wxFloat32 lx = 0, ly = 0;
	wxCoord startX = 0, startY = 0;
	bounds = this->GetClientSize();
	
	if (correctX)
	{
		startX = mPosX + mScale; 
		lx += startX;
	}
	else
	{
		gridWidth += ceil(mScale);
	}
	
	if (correctY)
	{
		startY = mPosY + mScale; 
		ly += startY;
	}
	else
	{
		gridHeight += ceil(mScale);
	}
	
	wxCoord endX = startX + gridWidth, endY = startY + gridHeight;
	
	for (wxCoord y = 0; y < height; ++y)
	{
		mGridPoints[count++] = wxPoint(startX, ly);
		mGridPoints[count++] = wxPoint(endX, ly);
		ly += mScale;
	}
	for (wxCoord x = 0; x < width; ++x)
	{
		mGridPoints[count++] = wxPoint(lx, startY);
		mGridPoints[count++] = wxPoint(lx, endY);
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
	dc.SetLogicalFunction( wxCOPY );
}

void EditPanel::PlacePixel( const wxPoint& pos, const wxColour& color )
{
	if (mScale < 1.0f)
	{
		wxLogMessage( "Unable to edit image with such scale.");
		mDrawing = false;
		return;
	}

	wxMemoryDC temp_dc;
	temp_dc.SelectObject(*mBitmap);
	temp_dc.SetPen( wxPen(color) );
	temp_dc.DrawPoint ( pos );
	PaintNow();
}

bool EditPanel::GetPixel( const wxPoint& pos, wxColour& color )
{
	wxMemoryDC temp_dc;
	temp_dc.SelectObject(*mBitmap);
	return temp_dc.GetPixel( pos , &color );
}

/* virtual */ void EditPanel::OnBtnDown( wxMouseEvent& event )
{
	if ( event.AltDown() && ( event.LeftDown() || event.RightDown() ) )
	{
		wxPoint pos = MousePosition2PointCoords( event.GetPosition() );
		wxColour colour;
		if ( pos.x != -1 && pos.y != -1 && GetPixel(pos, colour) )
		{
			ColourPickEvent ev( colour, event.GetButton() );
			if ( wxEvtHandler::ProcessEvent( ev ) )		
			{
				return;
			}
		}
	}
	if (event.LeftDown())
	{
		OnSelectionLeftDown( event );
	}

	if ( event.ControlDown() || event.ShiftDown() || event.AltDown() )
	{
		event.Skip();
		return;
	}
	
	wxPoint pos = MousePosition2PointCoords( event.GetPosition() );
	if (pos.x == -1 || pos.y == -1 || PointInZone( pos ) || !this->HasFocus() )
	{
		event.Skip();
		return;
	}
	ResetZone();
	mCurrentColour = event.LeftIsDown() ? gGlobalLeftColour : gGlobalRightColour;
	mPreviousPoint = pos;
	mDrawing = true;
	PlacePixel( pos, mCurrentColour );
	event.Skip();
}

/* virtual */ void EditPanel::OnMotion( wxMouseEvent& event )
{
	OnSelectionMotion( event );
	if (!mDrawing)
	{
		event.Skip();
		return;
	}
	wxPoint pos = MousePosition2PointCoords( event.GetPosition() );
	if (pos == mPreviousPoint || pos.x == -1 || pos.y == -1)
	{
		event.Skip();
		return;
	}
	mPreviousPoint = pos;
	PlacePixel( pos, mCurrentColour );
	event.Skip();
}

/* virtual */ void EditPanel::OnBtnUp( wxMouseEvent& event )
{
	if (event.LeftUp())
	{
		OnSelectionLeftUp( event );
	}
	mDrawing = false;
	mPreviousPoint.x = -1;
	mPreviousPoint.y = -1;
	event.Skip();
}
