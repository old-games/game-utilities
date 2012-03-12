/***************************************************************
 * Name:      palettepanel.h
 * Purpose:   PalettePanel has to be used to select colour
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-07
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef PALETTEPANEL_H_INCLUDED
#define PALETTEPANEL_H_INCLUDED

#include "editpanel.h"

class PaletteWindowImpl;

class PalettePanel :
	public EditPanel
{

friend class PaletteWindowImpl;

public:
	PalettePanel( wxWindow* parent, bool changeGlobalColours = true, wxWindowID id = wxID_ANY );
	~PalettePanel(); 

	const wxColour& GetColour( bool right );
	void SetColour( bool right, const wxColour& colour );
	
protected:

	virtual void OnBtnDown( wxMouseEvent& event );
	virtual void Render(wxDC& dc);

private:

	void GeneratePalBitmap();
	void GetBitmapColour( bool right );
	void SetBitmapColour( bool right );
	void CorrectColourPosition( bool right );
	void SetGlobalColours();
	
	int			mPalType;
	int			mCurrentCGAPal;
	bool		mCGAIntensity;
	wxPoint		mLeftPos;
	wxPoint		mRightPos;
	wxColour	mLeftColour;
	wxColour	mRightColour;
	bool		mChangeGlobals;
};

#endif
