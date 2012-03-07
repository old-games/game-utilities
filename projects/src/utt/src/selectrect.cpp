/***************************************************************
 * Name:      selectrect.cpp
 * Purpose:   Code for SelectionRectangle class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-06
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "selectrect.h"

SelectionRectangle::SelectionRectangle(  wxScrolledWindow* parent ):
	mParent( parent ),
	mWorkZone( 0, 0, 0, 0 ),
	mPointSize( 1.0f ),
	mMouseDrag( false ),
	mIsZoneValid( false ),
	mStartPoint( -1, -1 ),
	mEndPoint( -1, -1 ),
	mCoordRect( 0, 0, 0, 0 )
{
	//mParent->Bind( wxEVT_LEFT_DOWN, &SelectionRectangle::OnLeftDown, this, mParent->GetId() );
	//mParent->Bind( wxEVT_MOTION, &SelectionRectangle::OnMotion, this, mParent->GetId() );
	//mParent->Bind( wxEVT_LEFT_UP, &SelectionRectangle::OnLeftUp, this, mParent->GetId() );
}

SelectionRectangle::~SelectionRectangle(void)
{
	//mParent->Unbind( wxEVT_LEFT_UP, &SelectionRectangle::OnLeftUp, this, mParent->GetId() );
	//mParent->Unbind( wxEVT_MOTION, &SelectionRectangle::OnMotion, this, mParent->GetId() );
	//mParent->Unbind( wxEVT_LEFT_DOWN, &SelectionRectangle::OnLeftDown, this, mParent->GetId() );
}

void SelectionRectangle::SetWorkZone( const wxRect& rect, wxFloat32 pointSize )
{
	mWorkZone = rect;
	mPointSize = pointSize;
}

wxPoint	SelectionRectangle::GetMousePosition()
{
	wxPoint pos = mParent->ScreenToClient( wxGetMousePosition() );
	return GetMousePosition( pos );
}

wxPoint	SelectionRectangle::GetMousePosition( const wxPoint& pos )
{
	wxPoint result = pos;
	if ( mWorkZone.Contains( pos ) )
	{
		int x, y;
		mParent->GetViewStart (&x, &y);
		result.x += x - mWorkZone.GetLeft();
		result.y += y - mWorkZone.GetTop();
	}
	else
	{
		result.x = -1;
		result.y = -1;
	}
	return result;
}

wxPoint SelectionRectangle::MousePosition2PointCoords( const wxPoint& pos )
{
	wxPoint result = GetMousePosition( pos );
	Position2Coords( result );
	return result;
}

wxPoint SelectionRectangle::MousePosition2PointCoords()
{
	wxPoint result = GetMousePosition();
	Position2Coords( result );
	return result;
}

inline void SelectionRectangle::Position2Coords( wxPoint& point )
{
	if (point.x != -1 && point.y != -1)
	{
		point.x /= mPointSize;
		point.y /= mPointSize;
	}
}


/* virtual */ void SelectionRectangle::OnSelectionLeftDown( wxMouseEvent& event )
{
	wxPoint pos = this->MousePosition2PointCoords( event.GetPosition() );
	bool coorValid = pos.x != -1 && pos.y != -1;
	if ( event.ControlDown() && coorValid)
	{
		mIsZoneValid = true;
		mMouseDrag = true;
		mStartPoint = event.GetPosition();
		mEndPoint = mStartPoint;
		UpdateCoords();
		return;
	}
	else
	{
		if (mIsZoneValid && !mCoordRect.Contains(pos) )
		{
			mIsZoneValid = false;
			mParent->Refresh();
			return;
		}
	}
	event.Skip();
}

/* virtual */ void SelectionRectangle::OnSelectionMotion( wxMouseEvent& event )
{
	if (mMouseDrag)
	{
		wxPoint point = MousePosition2PointCoords( event.GetPosition() );
		if (point.x != -1 && point.y != -1)
		{
			DrawSelection();
			mEndPoint = event.GetPosition();
			UpdateCoords();
			DrawSelection();
		}
	}
	event.Skip();
}

/* virtual */ void SelectionRectangle::OnSelectionLeftUp( wxMouseEvent& event )
{
	if (mMouseDrag)
	{
		DrawSelection();
		mEndPoint = event.GetPosition();
		UpdateCoords();
		mMouseDrag = false;
		mParent->Refresh();
	}
	event.Skip();
}

void SelectionRectangle::DrawSelection()
{
	wxClientDC dc(mParent);
	RenderSelection(dc);
}

void SelectionRectangle::RenderSelection(wxDC& dc)
{
	int x, y;
	mParent->GetViewStart( &x, &y );
	wxPoint view(x, y);
	if (mMouseDrag)
	{
		dc.SetBrush( *wxTRANSPARENT_BRUSH );
		dc.SetPen( *wxWHITE_PEN );
		dc.SetLogicalFunction( wxXOR );
		wxRect rect( mStartPoint, mEndPoint );
		dc.DrawRectangle( rect );
	}
	if (mIsZoneValid)
	{
		mCoordRect = wxRect( mStartCoord, mEndCoord );
		wxRect rect( mCoordRect.GetTopLeft() * mPointSize, (mCoordRect.GetBottomRight() + wxPoint(1, 1)) * mPointSize );
		rect.SetLeftTop( rect.GetLeftTop() - view + mWorkZone.GetLeftTop() );
		dc.SetBrush( *wxTRANSPARENT_BRUSH );
		dc.SetPen( wxPen( *wxRED, 3, wxPENSTYLE_LONG_DASH ) );
		dc.SetLogicalFunction( wxXOR );
		dc.DrawRectangle( rect );
	}	
}

void SelectionRectangle::UpdateCoords()
{
	mStartCoord = MousePosition2PointCoords( mStartPoint );
	mEndCoord = MousePosition2PointCoords( mEndPoint );
}