/***************************************************************
 * Name:      lettercodesimpl.h
 * Purpose:   LetterCodesGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-23
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#ifndef LETTERCODESIMPL_H_INCLUDED
#define LETTERCODESIMPL_H_INCLUDED

#include "uttgui.h"

class LetterCodesImpl :
	public LetterCodesGui
{
public:
	LetterCodesImpl( wxWindow* parent, FontInfo* finfo );
	~LetterCodesImpl(void);
	void GenerateCodes();
	void UpdateTable();
	
protected:

	virtual void OnBtnClick( wxCommandEvent& event );
	virtual void OnCodePageChange( wxCommandEvent& event );
	
private:
		FontInfo*	mFontInfo;
		Symbols		mSymbolsCopy;
};

#endif
