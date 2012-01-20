///////////////////////////////////////////////////////////////////////////
// C++ code generated with wxFormBuilder (version Dec  2 2011)
// http://www.wxformbuilder.org/
//
// PLEASE DO "NOT" EDIT THIS FILE!
///////////////////////////////////////////////////////////////////////////

#include "pch.h"

#include "uttgui.h"

#include "../icon/to_left.xpm"
#include "../icon/to_right.xpm"

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
	this->SetMinSize( wxSize( 640,480 ) );
	
	wxGridSizer* gSizer1;
	gSizer1 = new wxGridSizer( 1, 1, 0, 0 );
	
	wxFlexGridSizer* fgSizer1;
	fgSizer1 = new wxFlexGridSizer( 3, 1, 0, 0 );
	fgSizer1->AddGrowableCol( 0 );
	fgSizer1->AddGrowableRow( 1 );
	fgSizer1->SetFlexibleDirection( wxBOTH );
	fgSizer1->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	wxStaticBoxSizer* sbSizer11;
	sbSizer11 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Symbols:") ), wxVERTICAL );
	
	sbSizer11->SetMinSize( wxSize( 256,128 ) ); 
	wxGridBagSizer* gbSizer21;
	gbSizer21 = new wxGridBagSizer( 0, 0 );
	gbSizer21->AddGrowableCol( 1 );
	gbSizer21->AddGrowableRow( 0 );
	gbSizer21->AddGrowableRow( 2 );
	gbSizer21->SetFlexibleDirection( wxBOTH );
	gbSizer21->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	mScrollSymbolsLeft1 = new wxBitmapButton( this, wxID_SCROLL_SYMBOLS_LEFT_BTN, wxBitmap( to_left_xpm ), wxDefaultPosition, wxDefaultSize, wxBU_AUTODRAW );
	gbSizer21->Add( mScrollSymbolsLeft1, wxGBPosition( 0, 0 ), wxGBSpan( 1, 1 ), wxRIGHT|wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mPreviewSymbols1 = new wxStaticBitmap( this, wxID_PREVIEW_SYMBOLS, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	gbSizer21->Add( mPreviewSymbols1, wxGBPosition( 0, 1 ), wxGBSpan( 1, 1 ), wxALL|wxEXPAND|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	mScrollSymbolsRight1 = new wxBitmapButton( this, wxID_SCROLL_SYMBOLS_RIGHT_BTN, wxBitmap( to_right_xpm ), wxDefaultPosition, wxDefaultSize, wxBU_AUTODRAW );
	gbSizer21->Add( mScrollSymbolsRight1, wxGBPosition( 0, 2 ), wxGBSpan( 1, 1 ), wxEXPAND|wxLEFT, 5 );
	
	sbSizer11->Add( gbSizer21, 1, wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer11, 1, wxEXPAND, 5 );
	
	wxStaticBoxSizer* sbSizer7;
	sbSizer7 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Editor:") ), wxVERTICAL );
	
	sbSizer7->SetMinSize( wxSize( 256,128 ) ); 
	m_bitmap4 = new wxStaticBitmap( this, wxID_ANY, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	sbSizer7->Add( m_bitmap4, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer7, 1, wxEXPAND, 5 );
	
	wxStaticBoxSizer* sbSizer9;
	sbSizer9 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Palette:") ), wxVERTICAL );
	
	sbSizer9->SetMinSize( wxSize( 256,64 ) ); 
	m_bitmap5 = new wxStaticBitmap( this, wxID_ANY, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	sbSizer9->Add( m_bitmap5, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer9, 1, wxEXPAND, 5 );
	
	gSizer1->Add( fgSizer1, 1, wxEXPAND, 5 );
	
	this->SetSizer( gSizer1 );
	this->Layout();
}

FontEditGui::~FontEditGui()
{
}

LogWindowGui::LogWindowGui( wxWindow* parent, wxWindowID id, const wxPoint& pos, const wxSize& size, long style ) : wxPanel( parent, id, pos, size, style )
{
	wxGridSizer* gSizer2;
	gSizer2 = new wxGridSizer( 1, 1, 0, 0 );
	
	mLogTxt = new wxTextCtrl( this, wxID_LOG_TXT, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_AUTO_URL|wxTE_MULTILINE|wxTE_READONLY );
	gSizer2->Add( mLogTxt, 1, wxEXPAND, 5 );
	
	this->SetSizer( gSizer2 );
	this->Layout();
}

LogWindowGui::~LogWindowGui()
{
}
