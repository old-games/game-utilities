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
	EditPanelGui( parent ),
	mEditPanel( this )
{
	mDrawHolder->Add( &mEditPanel, 1, wxEXPAND, 5 );
	mEditPanel.SetAlign( utdHCenter | utdVCenter );
}

EditPanelImpl::~EditPanelImpl(void)
{
}

void EditPanelImpl::SetBitmap( wxBitmap* bitmap )
{
	mEditPanel.SetBitmap( bitmap );
}