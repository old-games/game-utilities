/***************************************************************
 * Name:      fonteditimpl.cpp
 * Purpose:   Code for FontEditImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "fonteditimpl.h"
#include "fontsettingsimpl.h"

FontEditImpl::FontEditImpl(  wxWindow* parent ):
	FontEditGui( parent ),
	mSymbolEditor( new SymbolEditGui( this ) ),
	mCurrentFont( NULL ),
	mCurrentSymbol( 0 ),
	mHasChanges( false )
{
	mCentralSizer->Add( mSymbolEditor, 1, wxEXPAND, 5 );
	this->Layout();
}

FontEditImpl::~FontEditImpl(void)
{
	delete mCurrentFont;
}

void FontEditImpl::SetFont( const FontInfo& newFont )
{
}

bool FontEditImpl::CheckChanges()
{
	if (!mHasChanges)
	{
		return true;
	}
	wxInt32 res = wxMessageDialog(this, "Save changes?", "Font has changes", wxYES_NO | wxCANCEL | wxCENTRE | wxCANCEL_DEFAULT).ShowModal();
	if (res == wxID_OK)
	{
		return SaveFont();
	}
	return true;
}

bool FontEditImpl::SaveFont()
{
	return true;
}

bool FontEditImpl::CreateFont()
{
	if ( mCurrentFont != NULL && !CheckChanges() )
	{
		return false;
	}
	mCurrentFont = new FontInfo();
	if ( ShowSettings() )
	{	
		mCurrentSymbol = 0;
		mSymbolEditor->GetSymbolPanel()->SetFontInfo( mCurrentFont, mCurrentSymbol );
		return true;
	}
	return false;
}

bool FontEditImpl::ShowSettings()
{
	if (mCurrentFont == NULL) 
	{
		return CreateFont();
	}
	
	FontSettingsImpl settings( this, mCurrentFont );
	return settings.ShowModal() != wxID_CANCEL;
}

void FontEditImpl::Render(wxDC& dc)
{
}

void FontEditImpl::OnPaint(wxPaintEvent& event)
{
	event.Skip();
}

void FontEditImpl::OnBtnClick( wxCommandEvent& event )
{
	switch (event.GetId())
	{
		case wxID_CREATE_FONT:
			CreateFont();
		break;
	}
	event.Skip();
}

