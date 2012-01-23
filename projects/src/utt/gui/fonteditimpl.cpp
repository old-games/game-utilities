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
	mCurrentFont( NULL ),
	mHasChanges( false )
{
}

FontEditImpl::~FontEditImpl(void)
{
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
	int res = wxMessageDialog(this, "Save changes?", "Font has changes", wxYES_NO | wxCANCEL | wxCENTRE | wxNO_DEFAULT).ShowModal();
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
	ShowSettings();
	return true;
}

bool FontEditImpl::ShowSettings()
{
	if (mCurrentFont == NULL)
	{
		return CreateFont();
	}
	FontSettingsImpl settings( this );
	if ( settings.ShowModal() == wxID_CANCEL )
	{
		return false;
	}
	return true;
}

void FontEditImpl::Render(wxDC& dc)
{
}

void FontEditImpl::OnPaint(wxPaintEvent& event)
{
}

void FontEditImpl::OnBtnClick( wxCommandEvent& event )
{
	switch (event.GetId())
	{
		case wxID_CREATE_FONT:
			CreateFont();
		break;
	}
}

