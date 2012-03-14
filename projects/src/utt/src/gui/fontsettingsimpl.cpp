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
	return codesDlg.ShowModal() != wxID_CANCEL;
}

void FontSettingsImpl::OnBtnClick( wxCommandEvent& event )
{
	switch (event.GetId())
	{
		case wxID_SET_CODES_BTN:
			ShowLetterCodes();
		break;
		
		default:
			wxLogMessage( wxString::Format( "FontSettingsImpl::OnBtnClick: unknown id %d", event.GetId() ) );
	}
	event.Skip();
}

void FontSettingsImpl::OnSpinCtrl( wxSpinEvent& event ) 
{ 
	int value = event.GetInt();
	switch (event.GetId())
	{
		case wxID_NUM_SPIN_CTRL:
			mFontInfo->SetSymbolsNum( (size_t) value );
		break;
		
		case wxID_MAX_WIDTH_SPIN:
			mFontInfo->SetMaxWidth( value );
		break;
		
		case wxID_MAX_HEIGHT_SPIN:
			mFontInfo->SetMaxHeight( value );
		break;
		
		case wxID_MIN_WIDTH_SPIN:
			mFontInfo->SetMinWidth( value );
		break;

		case wxID_MIN_HEIGHT_SPIN:
			mFontInfo->SetMinHeight( value );
		break;
		
		case wxID_BASE_LINE_SPIN:
			mFontInfo->SetBaseLine( value );
		break;

		case wxID_CAP_LINE_SPIN:
			mFontInfo->SetCapLine( value );
		break;

		case wxID_LOW_LINE_SPIN:
			mFontInfo->SetLowLine( value );
		break;
		
		default:
			wxLogMessage( wxString::Format( "FontSettingsImpl::OnSpinCtrl: unknown id %d", event.GetId() ) );
	}
	UpdateSpinRanges();
	event.Skip(); 
}

void FontSettingsImpl::SetValuesToControls()
{
	mNumSpinCtrl->SetValue( mFontInfo->GetSymbolsNum() );
	mNumSpinCtrl->SetRange( MINIMUM_SYMBOLS_NUM, MAXIMUM_SYMBOLS_NUM );
	
	mMaxWidthSpinCtrl->SetValue( mFontInfo->GetMaxWidth() );
	mMaxWidthSpinCtrl->SetRange( 2, MAXIMUM_SYMBOL_WIDTH );
	mMaxHeightSpinCtrl->SetValue( mFontInfo->GetMaxHeight() );
	mMaxHeightSpinCtrl->SetRange( 2, MAXIMUM_SYMBOL_HEIGHT );
	
	mMinWidthSpinCtrl->SetValue( mFontInfo->GetMinWidth() );
	mMinHeightSpinCtrl->SetValue( mFontInfo->GetMinHeight() );
	mBaseLineSpinCtrl->SetValue( mFontInfo->GetBaseLine() );
	mCapLineSpinCtrl->SetValue( mFontInfo->GetCapLine() );
	mLowLineSpinCtrl->SetValue( mFontInfo->GetLowLine() );
	UpdateSpinRanges();
}

void FontSettingsImpl::UpdateSpinRanges()
{
	mMinWidthSpinCtrl->SetRange( 0, mFontInfo->GetMaxWidth() );
	mMinHeightSpinCtrl->SetRange( 0, mFontInfo->GetMaxHeight() );

	mBaseLineSpinCtrl->SetRange( mFontInfo->GetMinHeight(), mFontInfo->GetMaxHeight() );
	mCapLineSpinCtrl->SetRange( mFontInfo->GetMinHeight(), mFontInfo->GetMaxHeight() );
	mLowLineSpinCtrl->SetRange( mFontInfo->GetMinHeight(), mFontInfo->GetMaxHeight() );
}
