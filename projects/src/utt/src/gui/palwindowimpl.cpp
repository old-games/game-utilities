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
	for (int i = 0; i < CGA_PALS_NUMBER; ++i)
	{
		mCGAType->Append( wxString::Format("CGA set #%d", i) );
	}
	mCGAType->SetSelection(0);
	PalTypeChanged();
}

PaletteWindowImpl::~PaletteWindowImpl(void)
{
	
}

void PaletteWindowImpl::PalTypeChanged()
{
	mPalPanel->mPalType = mPalType->GetSelection();
	mPalPanel->mCurrentCGAPal = mCGAType->GetSelection();
	mPalPanel->mCGAIntensity = mCGAIntensity->IsChecked();
	bool cgaControls = mPalType->GetSelection() == BPP::bpp2;
	mCGAType->Enable( cgaControls );
	mCGAIntensity->Enable( cgaControls );
	mPalPanel->GeneratePalBitmap();
	mPalPanel->Refresh();
}

void PaletteWindowImpl::OnCommandEvent( wxCommandEvent& event ) 
{ 
	switch( event.GetId() )
	{
		case wxID_PAL_CHOICE:
		case wxID_CGA_CHOICE:
		case wxID_INTENSITY_CHECK:
			PalTypeChanged();
		break;
		
		default:
			wxLogError( wxString::Format( "PaletteWindow: unknown command %d", event.GetId() ) );
	}
	event.Skip();
}

