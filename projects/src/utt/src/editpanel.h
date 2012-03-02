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

protected:

	virtual void Render(wxDC& dc);
	void DrawGrid( wxDC& dc );
	virtual void SetShowParams();
	
private:

	bool		mDrawGrid;
	wxColour	mGridColour;
	wxPoint*	mGridPoints;
	wxInt32		mPointsNumber;

};

#endif
