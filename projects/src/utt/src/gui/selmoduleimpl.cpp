/***************************************************************
 * Name:      selmoduleimpl.cpp
 * Purpose:   Code for SelectModuleGui Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-28
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "selmoduleimpl.h"

SelectModuleImpl::SelectModuleImpl(  wxWindow* parent ):
	SelectModuleGui( parent )
{
}

SelectModuleImpl::~SelectModuleImpl(void)
{
}

void SelectModuleImpl::FillCombo(const wxArrayString& values)
{
	mModulesChoice->Clear();
	mModulesChoice->Append( values );
	mModulesChoice->SetSelection( 0 );
}

wxString SelectModuleImpl::GetValue()
{
	return mModulesChoice->GetString( mModulesChoice->GetSelection() );
}

