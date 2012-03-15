/***************************************************************
 * Name:      symboleditgui.h
 * Purpose:   SymbolEditGui inherited from EditPanelImpl to use 
				SymboPanel instead of EditPanel
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef SYMBOLEDITGUI_H_INCLUDED
#define SYMBOLEDITGUI_H_INCLUDED

#include "editpanelimpl.h"

// TODO: replace when drawpanel will be finished
#include "symbolpanel.h"

class SymbolEditGui :
	public EditPanelImpl
{
public:
	SymbolEditGui( wxWindow* parent, wxWindowID	 id = wxID_ANY );
	~SymbolEditGui(void); 

	SymbolPanel* GetSymbolPanel()
	{
		return mSymbolPanel;
	}

private:

	SymbolPanel*	mSymbolPanel;

};

#endif
