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

class PalettePanel :
	public EditPanel
{
public:
	PalettePanel( wxWindow* parent,  wxWindowID id = wxID_ANY );
	~PalettePanel(); 

private:

};

#endif
