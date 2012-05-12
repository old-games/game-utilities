///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Feb  9 2012)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#ifndef __SIMPLEGUI_H__
#define __SIMPLEGUI_H__

#include <wx/artprov.h>
#include <wx/xrc/xmlres.h>
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/icon.h>
#include <wx/bmpbuttn.h>
#include <wx/string.h>
#include <wx/gdicmn.h>
#include <wx/font.h>
#include <wx/colour.h>
#include <wx/settings.h>
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/panel.h>

///////////////////////////////////////////////////////////////////////////

#define wxID_BITMAP_RIBBON 2000
#define wxID_SCROLLLEFT_BTN 2001
#define wxID_SCROLLRIGHT_BTN 2002

///////////////////////////////////////////////////////////////////////////////
/// Class BitmapRibbonGui
///////////////////////////////////////////////////////////////////////////////
class BitmapRibbonGui : public wxPanel 
{
	private:
	
	protected:
		wxBitmapButton* mScrollLeftBtn;
		wxBoxSizer* mBitmapsHolder;
		wxBitmapButton* mScrollRightBtn;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnButtonClick( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		BitmapRibbonGui( wxWindow* parent, wxWindowID id = wxID_BITMAP_RIBBON, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 500,100 ), long style = wxTAB_TRAVERSAL ); 
		~BitmapRibbonGui();
	
};

#endif //__SIMPLEGUI_H__
