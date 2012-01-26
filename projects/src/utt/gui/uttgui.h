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
#include <wx/button.h>
#include <wx/sizer.h>
#include <wx/statbox.h>
#include <wx/bitmap.h>
#include <wx/image.h>
#include <wx/icon.h>
#include <wx/bmpbuttn.h>
#include <wx/statbmp.h>
#include <wx/gbsizer.h>
#include <wx/panel.h>
#include <wx/stattext.h>
#include <wx/spinctrl.h>
#include <wx/dialog.h>
#include <wx/choice.h>
#include <wx/grid.h>
#include <wx/textctrl.h>

///////////////////////////////////////////////////////////////////////////

#define wxID_MAIN_FRAME 1000
#define wxID_FONT_EDITOR 1001
#define wxID_CREATE_FONT 1002
#define wxID_SCROLL_SYMBOLS_LEFT_BTN 1003
#define wxID_PREVIEW_SYMBOLS 1004
#define wxID_SCROLL_SYMBOLS_RIGHT_BTN 1005
#define wxID_FONT_SETTINGS_ID 1006
#define wxID_NUM_SPIN_CTRL 1007
#define wxID_SET_CODES_BTN 1008
#define wxID_MAX_HEIGHT_SPIN 1009
#define wxID_MIN_HEIGHT_SPIN 1010
#define wxID_MAX_WIDTH_SPIN 1011
#define wxID_MIN_WIDTH_SPIN 1012
#define wxID_BASE_LINE_SPIN 1013
#define wxID_CAP_LINE_SPIN 1014
#define wxID_LOW_LINE_SPIN 1015
#define wxID_LETTER_CODES_ID 1016
#define wxID_GENERATE_CODES_BTN 1017
#define wxID_CODES_GRID 1018
#define wxID_LOG_WINDOW 1019
#define wxID_LOG_TXT 1020

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
		wxButton* mCreateBtn;
		wxBitmapButton* mScrollSymbolsLeft;
		wxStaticBitmap* mPreviewSymbols;
		wxBitmapButton* mScrollSymbolsRight;
		wxStaticBitmap* m_bitmap4;
		wxStaticBitmap* m_bitmap5;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnBtnClick( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		FontEditGui( wxWindow* parent, wxWindowID id = wxID_FONT_EDITOR, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 640,577 ), long style = wxTAB_TRAVERSAL ); 
		~FontEditGui();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class FontSettingsGui
///////////////////////////////////////////////////////////////////////////////
class FontSettingsGui : public wxDialog 
{
	private:
	
	protected:
		wxStaticText* m_staticText1;
		wxSpinCtrl* mNumSpinCtrl;
		wxStaticText* m_staticText2;
		wxButton* mSetCodesBtn;
		wxStaticText* m_staticText3;
		wxSpinCtrl* mMaxHeightSpinCtrl;
		wxStaticText* m_staticText4;
		wxSpinCtrl* mMinHeightSpinCtrl;
		wxStaticText* m_staticText5;
		wxSpinCtrl* mMaxWidthSpinCtrl;
		wxStaticText* m_staticText6;
		wxSpinCtrl* mMinWidthSpinCtrl;
		wxStaticText* m_staticText8;
		wxSpinCtrl* mBaseLineSpinCtrl;
		wxStaticText* m_staticText9;
		wxSpinCtrl* mCapLineSpinCtrl;
		wxStaticText* m_staticText10;
		wxSpinCtrl* mLowLineSpinCtrl;
		wxButton* mOkBtn;
		wxButton* mCancelBtn;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnSpinCtrl( wxSpinEvent& event ) { event.Skip(); }
		virtual void OnBtnClick( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		FontSettingsGui( wxWindow* parent, wxWindowID id = wxID_FONT_SETTINGS_ID, const wxString& title = wxT("Font settings"), const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 290,363 ), long style = wxCAPTION|wxCLOSE_BOX|wxSTAY_ON_TOP|wxSYSTEM_MENU ); 
		~FontSettingsGui();
	
};

///////////////////////////////////////////////////////////////////////////////
/// Class LetterCodesGui
///////////////////////////////////////////////////////////////////////////////
class LetterCodesGui : public wxDialog 
{
	private:
	
	protected:
		wxStaticBoxSizer* mAutoSizer;
		wxStaticText* m_staticText11;
		wxSpinCtrl* mInitialSpinCtrl;
		wxButton* mGenerateBtn;
		wxStaticText* m_staticText111;
		wxChoice* mPageChoice;
		wxStaticBoxSizer* mBtnsSizer;
		wxButton* mOkBtn;
		wxButton* mCancelBtn;
		wxStaticBoxSizer* mGridSizer;
		wxGrid* mCodesGrid;
		
		// Virtual event handlers, overide them in your derived class
		virtual void OnSize( wxSizeEvent& event ) { event.Skip(); }
		virtual void OnBtnClick( wxCommandEvent& event ) { event.Skip(); }
		virtual void OnCodePageChange( wxCommandEvent& event ) { event.Skip(); }
		
	
	public:
		
		LetterCodesGui( wxWindow* parent, wxWindowID id = wxID_LETTER_CODES_ID, const wxString& title = wxEmptyString, const wxPoint& pos = wxDefaultPosition, const wxSize& size = wxSize( 450,500 ), long style = wxCAPTION|wxCLOSE_BOX|wxRESIZE_BORDER|wxSTAY_ON_TOP|wxSYSTEM_MENU ); 
		~LetterCodesGui();
	
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
