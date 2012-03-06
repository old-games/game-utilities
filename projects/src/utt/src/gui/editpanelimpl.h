/***************************************************************
 * Name:      editpanelimpl.h
 * Purpose:   EditPanelGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-29
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef EDITPANELIMPL_H_INCLUDED
#define EDITPANELIMPL_H_INCLUDED

#include "uttgui.h"
#include "editpanel.h"

class EditPanelImpl:
	public EditPanelGui
{
public:
	EditPanelImpl( wxWindow* parent );
	~EditPanelImpl(void); 

	void SetBitmap( wxBitmap* bitmap );

protected:

	virtual void OnCommandEvent( wxCommandEvent& event );

private:

	void SetGridEnabled();
	void SetGridMode();
	void SetGridColour();

	EditPanel	mEditPanel;
};

#endif
