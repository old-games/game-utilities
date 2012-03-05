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

class EditPanel :
	public DrawPanel
{
public:

	EditPanel( wxWindow* parent );
	virtual ~EditPanel(void); 
	void SetGridColour(const wxColour& color);
	void SetGridLogic(wxInt32 logic);

protected:

	virtual void Render(wxDC& dc);
	void DrawGrid( wxDC& dc );
	virtual void SetShowParams();
	
private:
	
	void ClearGridPoints();
	
	bool		mDrawGrid;
	wxColour	mGridColour;
	wxPoint*	mGridPoints;
	wxInt32		mPointsNumber;
	wxPen		mGridPen;
	wxInt32		mGridLogic;

};

#endif
