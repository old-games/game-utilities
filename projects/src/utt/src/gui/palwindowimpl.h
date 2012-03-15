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
	wxColour GetColour(bool right);
	void SetColour(bool right, const wxColour& colour);
	int	FindColour( bool right, const wxColour& colour, bool andSet = false );

protected:
	virtual void OnCommandEvent( wxCommandEvent& event );
	virtual void OnSpinCtrl( wxSpinEvent& event );
	
private:
	
	void OnPaint( wxPaintEvent& event );
	void PalTypeChanged();
	void UpdateColour(bool right);
	void UpdateSpin(bool right);
	void UpdateColours();
	void UpdateSpins();
	
	PalettePanel*	mPalPanel;
};

#endif
