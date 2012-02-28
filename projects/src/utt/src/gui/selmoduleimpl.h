/***************************************************************
 * Name:      selmoduleimpl.h
 * Purpose:   SelectModuleGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-28
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef SELMODULEIMPL_H_INCLUDED
#define SELMODULEIMPL_H_INCLUDED

#include "uttgui.h"

class SelectModuleImpl :
	public SelectModuleGui
{
public:
	SelectModuleImpl( wxWindow* parent );
	~SelectModuleImpl(void); 

	void FillCombo(const wxArrayString& values);
	wxString GetValue();
private:

};

#endif
