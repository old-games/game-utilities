/***************************************************************
 * Name:      selectrect.h
 * Purpose:   SelectionRectangle declaration
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-06
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef SELECTRECT_H_INCLUDED
#define SELECTRECT_H_INCLUDED

class SelectionRectangle
{
public:
	SelectionRectangle( wxScrolledWindow* parent );
	~SelectionRectangle(void); 

	void SetWorkZone( const wxRect& rect, wxFloat32 pointSize );
	
	// current position of mouse over bitmap
	wxPoint	GetMousePosition();
	// custom position of mouse over bitmap
	wxPoint	GetMousePosition( const wxPoint& pos );
	
	// current position of mouse to pixels coordinates
	wxPoint MousePosition2PointCoords();
	// custom position of mouse to pixels coordinates
	wxPoint MousePosition2PointCoords( const wxPoint& pos );
	
	void Render(wxDC& dc);
	void PaintNow();
	
	bool IsZone()
	{
		return mIsZoneValid;
	}
	
	bool PointInZone(const wxPoint& point)
	{
		return mIsZoneValid && mCoordRect.Contains(point);
	}
	
	void ResetZone()
	{
		mIsZoneValid = false;
	}
	
protected:
	
	virtual void OnLeftDown( wxMouseEvent& event );
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnLeftUp( wxMouseEvent& event );

private:

	void Position2Coords( wxPoint& point );
	void UpdateCoords();
	
	wxScrolledWindow*	mParent;
	wxRect				mWorkZone;
	wxFloat32			mPointSize;
	bool				mMouseDrag;
	bool				mIsZoneValid;
	wxPoint				mStartPoint;
	wxPoint				mEndPoint;
	wxPoint				mStartCoord;
	wxPoint				mEndCoord;
	wxRect				mCoordRect;
	
};

#endif
