/***************************************************************
 * Name:      palwindowimpl.cpp
 * Purpose:   Code for PaletteWindowImpl class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-07
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "palwindowimpl.h"

PaletteWindowImpl::PaletteWindowImpl(  wxWindow* parent ):
	PaletteWindowGui( parent )
{
	mPalPanel = new PalettePanel( this, wxID_PAL_WINDOW_ID );
	mPalHolder->Add( mPalPanel, 1, wxEXPAND, 5 );
	for (int i = 0; i < BPP::bppNum; ++i)
	{
		mPalType->Append(BPP::Names[i]);
	}
	mPalType->SetSelection(0);
}

PaletteWindowImpl::~PaletteWindowImpl(void)
{
	
}
