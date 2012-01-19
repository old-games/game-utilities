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
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/icon.h>
#include <wx/bmpbuttn.h>
#include <wx/button.h>
#include <wx/statbmp.h>
#include <wx/gbsizer.h>
#include <wx/sizer.h>
#include <wx/statbox.h>
#include <wx/panel.h>
#include <wx/textctrl.h>

///////////////////////////////////////////////////////////////////////////

#define wxID_MAIN_FRAME 1000
#define wxID_FONT_EDITOR 1001
#define wxID_SCROLL_SYMBOLS_LEFT_BTN 1002
#define wxID_PREVIEW_SYMBOLS 1003
#define wxID_SCROLL_SYMBOLS_RIGHT_BTN 1004
#define wxID_LOG_WINDOW 1005
#define wxID_LOG_TXT 1006

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
		wxBitmapButton* mScrollSymbolsLeft1;
		wxStaticBitmap* mPreviewSymbols1;
		wxBitmapButton* mScrollSymbolsRight1;
		wxStaticBitmap* m_bitmap4;
		wxStaticBitmap* m_bitmap5;
	
	public:
		
		FontEditGui( wxWindow* parent, wxWindowID id = wxID_FONT_EDITOR, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 617,434 ), long style = wxTAB_TRAVERSAL ); 
		~FontEditGui();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class LogWindowGui
///////////////////////////////////////////////////////////////////////////////
class LogWindowGui : public wxPanel 
{
	private:
	
	protected:
		wxTextCtrl* mLogTxt;
	
	public:
		
		LogWindowGui( wxWindow* parent, wxWindowID id = wxID_LOG_WINDOW, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,300 ), long style = wxTAB_TRAVERSAL ); 
		~LogWindowGui();
	
};

#endif //__UTTGUI_H__
