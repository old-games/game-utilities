/***************************************************************
 * Name:      symboleditgui.cpp
 * Purpose:   Code for SymbolEditGui class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-14
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "symboleditgui.h"

SymbolEditGui::SymbolEditGui(  wxWindow* parent, wxWindowID	 id /* wxID_ANY */ ):
	EditPanelImpl( parent ),
	mSymbolPanel( new SymbolPanel( this, id ) )
{
	EditPanelImpl::SetEditPanel( mSymbolPanel );
	mSymbolPanel->SetScaleRange( 5.0f, 50.0f );
}

SymbolEditGui::~SymbolEditGui(void)
{
}
