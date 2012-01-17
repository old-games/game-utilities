///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec  2 2011)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __UTTGUI_H__
#define __UTTGUI_H__

#include <wx/artprov.h>
#include <wx/xrc/xmlres.h>
#include <wx/string.h>
#include <wx/frame.h>
#include <wx/aui/aui.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/panel.h>

///////////////////////////////////////////////////////////////////////////

#define wxID_MAIN_FRAME 1000

///////////////////////////////////////////////////////////////////////////////
/// Class UttMainFrame
///////////////////////////////////////////////////////////////////////////////
class UttMainFrame : public wxFrame 
{
	private:
	
	protected:
	
	public:
		
		UttMainFrame( wxWindow* parent, wxWindowID id = wxID_MAIN_FRAME, const wxString& title = wxT("UTT"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 1024,768 ), long style = wxDEFAULT_FRAME_STYLE|wxTAB_TRAVERSAL );
		wxAuiManager m_mgr;
		
		~UttMainFrame();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class FontEditGui
///////////////////////////////////////////////////////////////////////////////
class FontEditGui : public wxPanel 
{
	private:
	
	protected:
	
	public:
		
		FontEditGui( wxWindow* parent, wxWindowID id = wxID_ANY, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 837,681 ), long style = wxTAB_TRAVERSAL ); 
		~FontEditGui();
	
};

#endif //__UTTGUI_H__
