///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec  2 2011)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "pch.h"

#include "uttgui.h"

///////////////////////////////////////////////////////////////////////////

UttMainFrame::UttMainFrame( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxFrame( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxSize( 640,480 ), wxDefaultSize );
	m_mgr.SetManagedWindow(this);
	
	
	m_mgr.Update();
	this->Centre( wxBOTH );
}

UttMainFrame::~UttMainFrame()
{
	m_mgr.UnInit();
	
}

FontEditGui::FontEditGui( wxWindow* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style ) : wxPanel( parent, id, pos, size, style )
{
}

FontEditGui::~FontEditGui()
{
}
