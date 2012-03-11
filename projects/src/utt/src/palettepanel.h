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
	PalettePanel( wxWindow* parent,  wxWindowID id = wxID_ANY );
	~PalettePanel(); 

private:

	void GeneratePalBitmap();
	
	int		mPalType;
	int		mCurrentCGAPal;
	bool	mCGAIntensity;
};

#endif
