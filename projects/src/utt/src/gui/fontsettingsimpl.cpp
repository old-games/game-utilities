/***************************************************************
 * Name:      fontsettingsimpl.cpp
 * Purpose:   Code for FontSettingsImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-23
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "fontsettingsimpl.h"
#include "lettercodesimpl.h"

FontSettingsImpl::FontSettingsImpl(  wxWindow* parent, FontInfo* finfo ):
	FontSettingsGui( parent ),
	mFontInfo( finfo )
{
	SetValuesToControls();
}

FontSettingsImpl::~FontSettingsImpl(void)
{
}

bool FontSettingsImpl::ShowLetterCodes()
{
	LetterCodesImpl codesDlg( this, mFontInfo );
	if ( codesDlg.ShowModal() == wxID_CANCEL )
	{
		return false;
	}
	return true;
}

void FontSettingsImpl::OnBtnClick( wxCommandEvent& event )
{
	switch (event.GetId())
	{
		case wxID_SET_CODES_BTN:
			ShowLetterCodes();
		break;
	}
}

void FontSettingsImpl::OnSpinCtrl( wxSpinEvent& event ) 
{ 
	switch (event.GetId())
	{
		case wxID_NUM_SPIN_CTRL:
			mFontInfo->SetSymbolsNum( (size_t) mNumSpinCtrl->GetValue() );
		break;
	}
	event.Skip(); 
}

void FontSettingsImpl::SetValuesToControls()
{
	mNumSpinCtrl->SetValue( mFontInfo->GetSymbolsNum() );
	mNumSpinCtrl->SetRange( MINIMUM_SYMBOLS_NUM, MAXIMUM_SYMBOLS_NUM );
}
