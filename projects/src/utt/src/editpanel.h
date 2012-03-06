/***************************************************************
 * Name:      editpanel.h
 * Purpose:   modified DrawPanel for edit image
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-29
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef EDITPANEL_H_INCLUDED
#define EDITPANEL_H_INCLUDED

#include "drawpanel.h"
#include "selectrect.h"

class EditPanel :
	public DrawPanel
{

friend class EditPanelImpl;

public:

	EditPanel( wxWindow* parent );
	virtual ~EditPanel(void); 
	
	void SetGridColour(const wxColour& color);
	const wxColour& GetGridColour()
	{
		return mGridColour;
	}
	
	void SetGridLogic(wxInt32 logic);
	
	void SetGridEnabled(bool b = true)
	{
		mDrawGrid = b;
	}

protected:

	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnBtnUp( wxMouseEvent& event );

	// inherited functions	
	virtual void Render(wxDC& dc);
	void DrawGrid( wxDC& dc );
	virtual void SetShowParams();

	
private:
	
	void ClearGridPoints();
	void OnFocus(wxFocusEvent& );
	void PlacePixel( const wxPoint& pos, const wxColour& color );
	
	bool		mDrawGrid;
	wxColour	mGridColour;
	wxPoint*	mGridPoints;
	wxInt32		mPointsNumber;
	wxPen		mGridPen;
	wxInt32		mGridLogic;
	bool		mDrawing;
	wxColour	mCurrentColour;
	wxPoint		mPreviousPoint;

	SelectionRectangle	mSelection;
};

#endif
