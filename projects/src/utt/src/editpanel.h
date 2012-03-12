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
	public DrawPanel, public SelectionRectangle
{

friend class EditPanelImpl;

public:

	EditPanel( wxWindow* parent,  wxWindowID id = wxID_ANY  );
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

	void SetDrawFocus( bool b )
	{
		mDrawFocus = b;
	}
	
	static wxColour		gGlobalLeftColour;
	static wxColour		gGlobalRightColour;

protected:

	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void OnMotion( wxMouseEvent& event );
	virtual void OnBtnUp( wxMouseEvent& event );
	virtual void OnFocus( wxFocusEvent& );

	virtual void Render(wxDC& dc);
	virtual void SetShowParams();

	void DrawGrid( wxDC& dc );
	void PlacePixel( const wxPoint& pos, const wxColour& color );
	bool GetPixel( const wxPoint& pos, wxColour& color );
	
private:
	
	void ClearGridPoints();
	
	bool		mDrawGrid;
	bool		mDrawFocus;
	wxColour	mGridColour;
	wxPoint*	mGridPoints;
	wxInt32		mPointsNumber;
	wxPen		mGridPen;
	wxInt32		mGridLogic;
	bool		mDrawing;
	wxColour	mCurrentColour;
	wxPoint		mPreviousPoint;

};

#endif
