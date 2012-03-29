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

class SymbolPanel;

class SymbolEditGui :
	public EditPanelImpl
{
public:
	SymbolEditGui( wxWindow* parent );
	~SymbolEditGui(void);

	SymbolPanel* GetSymbolPanel()
	{
		return mSymbolPanel;
	}

private:

	SymbolPanel*	mSymbolPanel;

};

#endif
