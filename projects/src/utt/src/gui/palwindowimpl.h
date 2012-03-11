/***************************************************************
 * Name:      palwindowimpl.h
 * Purpose:   PaletteWindowGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-07
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef PALWDINWOIMPL_H_INCLUDED
#define PALWDINWOIMPL_H_INCLUDED

#include "uttgui.h"
#include "palettepanel.h"

class PaletteWindowImpl :
	public PaletteWindowGui
{
public:
	PaletteWindowImpl( wxWindow* parent );
	~PaletteWindowImpl(void); 

protected:
	virtual void OnCommandEvent( wxCommandEvent& event );
	
private:
	
	void PalTypeChanged();
	
	PalettePanel*	mPalPanel;
};

#endif
