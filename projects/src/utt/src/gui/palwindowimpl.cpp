/***************************************************************
 * Name:      palwindowimpl.cpp
 * Purpose:   Code for PaletteWindowImpl class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-07
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"

#include "palettepanel.h"
#include "palwindowimpl.h"

PaletteWindowImpl::PaletteWindowImpl(  wxWindow* parent ):
	PaletteWindowGui( parent )
{
	mPalPanel = new PalettePanel( this, true );
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
	this->Bind( wxEVT_PAINT, &PaletteWindowImpl::OnPaint, this, wxID_PAL_WINDOW_ID );
}

PaletteWindowImpl::~PaletteWindowImpl(void)
{
	this->Unbind( wxEVT_PAINT, &PaletteWindowImpl::OnPaint, this, wxID_PAL_WINDOW_ID );
}

void PaletteWindowImpl::OnPaint( wxPaintEvent& event )
{
	event.Skip();
	UpdateSpins();
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
	UpdateSpins();
}

wxColour PaletteWindowImpl::GetColour(bool right)
{
	wxSpinCtrl* r = right ? mRRSpin : mLRSpin;
	wxSpinCtrl* g = right ? mRGSpin : mLGSpin;
	wxSpinCtrl* b = right ? mRBSpin : mLBSpin;
	return wxColour( r->GetValue(), g->GetValue(), b->GetValue() );
}

void PaletteWindowImpl::SetColour(bool right, const wxColour& colour)
{
	wxSpinCtrl* r = right ? mRRSpin : mLRSpin;
	wxSpinCtrl* g = right ? mRGSpin : mLGSpin;
	wxSpinCtrl* b = right ? mRBSpin : mLBSpin;
	r->SetValue( colour.Red() );
	g->SetValue( colour.Green() );
	b->SetValue( colour.Blue() );
	UpdateColour( right );
}

int	PaletteWindowImpl::FindColour( bool right, const wxColour& colour, bool andSet /* false */)
{
	int res = mPalPanel->FindColour( right, colour, andSet );
	if (res == -1)
	{
		wxLogMessage( wxString::Format("Colour %s not found in global palette", colour.GetAsString() ) );
	}
	return res;
}

void PaletteWindowImpl::UpdateColours()
{
	UpdateColour( false );
	UpdateColour( true );
}

void PaletteWindowImpl::UpdateSpins()
{
	UpdateSpin( false );
	UpdateSpin( true );
}

void PaletteWindowImpl::UpdateColour(bool right)
{
	wxColour colour = GetColour(right);
	mPalPanel->SetColour( right, colour );
}

void PaletteWindowImpl::UpdateSpin(bool right)
{
	SetColour( right, mPalPanel->GetColour(right) );
}

/* virtual */ void PaletteWindowImpl::OnCommandEvent( wxCommandEvent& event )
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

/* virtual */ void PaletteWindowImpl::OnSpinCtrl( wxSpinEvent& event )
{
	event.Skip();
	switch( event.GetId() )
	{
		case wxID_RR_SPIN:
		case wxID_RG_SPIN:
		case wxID_RB_SPIN:
			UpdateColour( true );
		break;

		case wxID_LR_SPIN:
		case wxID_LG_SPIN:
		case wxID_LB_SPIN:
			UpdateColour( false );
		break;

		default:
			wxLogError( wxString::Format( "PaletteWindow: unknown spin id %d", event.GetId() ) );
	}
}
