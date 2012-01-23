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
	mCurrentFont( NULL )
{
}

FontEditImpl::~FontEditImpl(void)
{
}

void FontEditImpl::SetFont( const FontInfo& newFont )
{
}

bool FontEditImpl::CreateFont()
{
	if (mCurrentFont != NULL)
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

