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
	mHasChanges( false ),
	mDrawPanel( this, wxID_FONT_EDITOR ),
	mTimer( this, 3000 )
{
	mCentralSizer->Add( &mDrawPanel, 1, wxEXPAND, 5 );
	this->Layout();
	//
	const int mx = 800;
	const int my = 256;
	tmp = new Pixel[mx * my];
	int count = 0;
	int col = 0;
	for (int y = 0; y < my; ++y)
	{
		for (int x = 0; x < mx; ++x)
		{
			Pixel& color = tmp[count++];
			color[0] = col;
			color[1] = col;
			color[2] = col;
		}
		++col;
	}
	mDrawPanel.CreateBitmap( tmp, mx, my );
	this->Bind( wxEVT_TIMER, &FontEditImpl::OnTimer, this, 3000 );
	//mTimer.Start( 40 );
}

FontEditImpl::~FontEditImpl(void)
{
	delete mCurrentFont;
	mTimer.Unbind( wxEVT_TIMER, &FontEditImpl::OnTimer, this, 3000 );
	delete[] tmp;
}

void FontEditImpl::OnTimer( wxTimerEvent& event )
{
	int count = 0;
	for (int y = 0; y < 256; ++y)
	{
		for (int x = 0; x < 256; ++x)
		{
			Pixel& color = tmp[count++];
			color[0]++;
			color[1]--;
			color[2]++;
		}
	}
	mDrawPanel.SetBuffer( tmp );
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
	
	FontSettingsImpl settings( this, mCurrentFont );
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
	event.Skip();
}

