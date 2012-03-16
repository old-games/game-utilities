/***************************************************************
 * Name:      editpanelimpl.cpp
 * Purpose:   Code for EditPanelImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-29
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "editpanelimpl.h"

EditPanelImpl::EditPanelImpl(  wxWindow* parent ):
	EditPanelGui( parent )
{
	mEditPanel = new EditPanel( this );
	SetEditPanel( mEditPanel );
}

EditPanelImpl::~EditPanelImpl(void)
{
}

void EditPanelImpl::SetBitmap( wxBitmap* bitmap )
{
	mEditPanel->SetBitmap( bitmap );
}

/* virtual */ void EditPanelImpl::OnCommandEvent( wxCommandEvent& event ) 
{ 
	switch (event.GetId())
	{
		case wxID_GRID_CHECK:
			SetGridEnabled();
		break;
		
		case wxID_GRID_MODE:
			SetGridMode();
		break;
		
		case wxID_GRIDCOL_BTN:
			SetGridColour();
		break;
		
		default:
			wxLogError( wxString::Format("EditPanel::OnCommandEvent: unknown command %d", event.GetId()) );
			return;
	}
	mEditPanel->PaintNow();
}

void EditPanelImpl::SetGridEnabled()
{
	mEditPanel->SetGridEnabled( mGridCheck->IsChecked() );
}

void EditPanelImpl::SetGridMode()
{
	switch ( mGridModeChoice->GetSelection() )
	{
		case 0:
			mEditPanel->SetGridLogic( wxCOPY );
		break;

		case 1:
			mEditPanel->SetGridLogic( wxXOR );
		break;
		
		default:
			wxLogError( wxString::Format("EditPanel::SetGridMode: unknown grid draw logic %d", mGridModeChoice->GetSelection()) );
	}
}

void EditPanelImpl::SetGridColour()
{
	wxColourData data;
	data.SetChooseFull(true);
	data.SetColour( mEditPanel->GetGridColour() );
	for (int i = 0; i < 16; i++)
	{
		wxColour colour(i*16, i*16, i*16);
		data.SetCustomColour(i, colour);
	}

	wxColourDialog dialog(this, &data);
	if (dialog.ShowModal() == wxID_OK)
	{
		wxColourData retData = dialog.GetColourData();
		mEditPanel->SetGridColour( retData.GetColour() );
	}
}

void EditPanelImpl::SetEditPanel( EditPanel* editPanel )
{
	if ( !editPanel )
	{
		wxLogError( wxString::Format("EditPanelImpl::SetEditPanel: bad pointer to EditPanel in args") );
		return;
	}

	if ( mEditPanel && mDrawHolder->Detach( mEditPanel ) )
	{
		delete mEditPanel;
	}
	mEditPanel = editPanel;
	mDrawHolder->Add( mEditPanel, 1, wxEXPAND, 5 );
	mEditPanel->SetAlign( utdHCenter | utdVCenter );
	SetGridEnabled();
	SetGridMode();
}
