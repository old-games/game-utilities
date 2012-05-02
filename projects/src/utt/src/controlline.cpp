/***************************************************************
 * Name:      controlline.cpp
 * Purpose:   Code for ControlLine class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-15
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "controlline.h"

ControlLine::ControlLine( wxScrolledWindow* parent ):
	mParent( parent ),
	mInitiated( false ),
	mOrientation( wxVERTICAL ),
	mColour( *wxBLACK ),
	mWidth( 3 ),
	mStyle( wxSOLID ),
	mValue( 0 ),
	mPosX( 0 ),
	mPosY( 0 ),
	mZoneWidth( 0 ),
	mZoneHeight( 0 ),
	mScale( 0.0f ),
	mCursor( wxNullCursor ),
	mToolTip( "line" )
{
}

ControlLine::~ControlLine(void)
{
}

void ControlLine::SetParameters( int orientation, const wxColour& colour,  int width, int style, const wxString& txt )
{
	wxASSERT( orientation == wxVERTICAL || orientation == wxHORIZONTAL );
	mOrientation = orientation;
	mColour = colour;
	mWidth = width;
	mStyle = style;
	mToolTip = txt;
	mCursor = wxCursor( mOrientation == wxVERTICAL ? wxCURSOR_SIZEWE : wxCURSOR_SIZENS );
	mInitiated = true;
}

void ControlLine::SetValue( int value )
{
	mValue = value;
}

void ControlLine::SetValue( const wxPoint& pos )
{
	mValue = mOrientation == wxVERTICAL ? pos.x : pos.y;
}

bool ControlLine::CheckMouse()
{
	if ( !mInitiated )
	{
		return false;
	}
	wxPoint first, second;
	CalcPoints( first, second );
	
	int half = mWidth / 2;
	first.x -= half;
	second.x += half;
	first.y	-= half;
	second.y += half;
	wxRect rect( first, second );
	wxPoint mouse = mParent->ScreenToClient( wxGetMousePosition() );
	return rect.Contains( mouse );
}

void ControlLine::CalcPoints( wxPoint& first, wxPoint& second)
{
	int val = mValue * mScale;
	if ( mOrientation == wxVERTICAL )
	{
		first.x = val;
		second.x = val;
		first.y = 0;
		second.y = mZoneHeight;
	}
	else
	{
		first.y = val;
		second.y = val;
		first.x = 0;
		second.x = mZoneWidth;
	}

	wxPoint view( mPosX, mPosY );
	view -= mParent->GetViewStart();
	first += view;
	second += view;
}

void ControlLine::DrawControlLine( wxDC& dc )
{
	if ( !mInitiated )
	{
		return;
	}
	wxPen pen( mColour, mWidth, mStyle );
	dc.SetPen( pen );
	dc.SetLogicalFunction( wxXOR );
	wxPoint first, second;
	CalcPoints( first, second );
	
	wxPoint drawPos( mPosX, mPosY );
	first -= drawPos;
	second -= drawPos;

	dc.DrawLine( first, second );
}

void ControlLine::SetOffsetXY( wxCoord sx, wxCoord sy, wxCoord zwidth, wxCoord zheight, wxDouble scale )
{
	mPosX = sx;
	mPosY = sy;
	mZoneWidth = zwidth;
	mZoneHeight = zheight;
	mScale = scale;
}
