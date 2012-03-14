/***************************************************************
 * Name:      symbolpanel.h
 * Purpose:   SymbolPanel has to be used to edit font symbol
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef SYMBOLPANEL_H_INCLUDED
#define SYMBOLPANEL_H_INCLUDED

#include "editpanel.h"

class SymbolPanel :
	public EditPanel
{
public:
	SymbolPanel( wxWindow* parent, wxWindowID id = wxID_ANY );
	~SymbolPanel(void); 
	
	void SetFontInfo( FontInfo* info, int symbolNumber );

protected:
		
	
private:

	void UpdateBitmap();

	FontInfo*	mFontInfo;
	bool		mAllowEdit;
	int			mSymbolNumber;
};

#endif
