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
	fgSizer1 = new wxFlexGridSizer( 4, 1, 0, 0 );
	fgSizer1->AddGrowableCol( 0 );
	fgSizer1->AddGrowableRow( 2 );
	fgSizer1->SetFlexibleDirection( wxBOTH );
	fgSizer1->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	wxStaticBoxSizer* sbSizer4;
	sbSizer4 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Controls:") ), wxVERTICAL );
	
	wxFlexGridSizer* fgSizer2;
	fgSizer2 = new wxFlexGridSizer( 0, 2, 0, 0 );
	fgSizer2->SetFlexibleDirection( wxBOTH );
	fgSizer2->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	mCreateBtn = new wxButton( this, wxID_CREATE_FONT, wxT("Create new..."), wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer2->Add( mCreateBtn, 0, wxALL, 5 );
	
	sbSizer4->Add( fgSizer2, 1, wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer4, 1, wxEXPAND, 5 );
	
	wxStaticBoxSizer* sbSizer11;
	sbSizer11 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Symbols:") ), wxVERTICAL );
	
	sbSizer11->SetMinSize( wxSize( 256,128 ) ); 
	wxGridBagSizer* gbSizer21;
	gbSizer21 = new wxGridBagSizer( 0, 0 );
	gbSizer21->AddGrowableRow( 0 );
	gbSizer21->AddGrowableRow( 2 );
	gbSizer21->SetFlexibleDirection( wxBOTH );
	gbSizer21->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_ALL );
	
	mScrollSymbolsLeft = new wxBitmapButton( this, wxID_SCROLL_SYMBOLS_LEFT_BTN, wxBitmap( to_left_xpm ), wxDefaultPosition, wxDefaultSize, wxBU_AUTODRAW );
	gbSizer21->Add( mScrollSymbolsLeft, wxGBPosition( 0, 0 ), wxGBSpan( 1, 1 ), wxRIGHT|wxEXPAND|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mPreviewSymbols = new wxStaticBitmap( this, wxID_PREVIEW_SYMBOLS, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	gbSizer21->Add( mPreviewSymbols, wxGBPosition( 0, 1 ), wxGBSpan( 1, 1 ), wxALL|wxEXPAND|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	mScrollSymbolsRight = new wxBitmapButton( this, wxID_SCROLL_SYMBOLS_RIGHT_BTN, wxBitmap( to_right_xpm ), wxDefaultPosition, wxDefaultSize, wxBU_AUTODRAW );
	gbSizer21->Add( mScrollSymbolsRight, wxGBPosition( 0, 2 ), wxGBSpan( 1, 1 ), wxEXPAND|wxLEFT|wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL, 5 );
	
	sbSizer11->Add( gbSizer21, 1, wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer11, 1, wxEXPAND, 5 );
	
	wxStaticBoxSizer* mCentralSizer;
	mCentralSizer = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Editor:") ), wxVERTICAL );
	
	mCentralSizer->SetMinSize( wxSize( 256,128 ) ); 
	m_bitmap4 = new wxStaticBitmap( this, wxID_ANY, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	mCentralSizer->Add( m_bitmap4, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer1->Add( mCentralSizer, 1, wxEXPAND, 5 );
	
	wxStaticBoxSizer* sbSizer9;
	sbSizer9 = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Palette:") ), wxVERTICAL );
	
	sbSizer9->SetMinSize( wxSize( 256,64 ) ); 
	m_bitmap5 = new wxStaticBitmap( this, wxID_ANY, wxNullBitmap, wxDefaultPosition, wxDefaultSize, 0 );
	sbSizer9->Add( m_bitmap5, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer1->Add( sbSizer9, 1, wxEXPAND, 5 );
	
	gSizer1->Add( fgSizer1, 1, wxEXPAND, 5 );
	
	this->SetSizer( gSizer1 );
	this->Layout();
	
	// Connect Events
	mCreateBtn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontEditGui::OnBtnClick ), NULL, this );
	mScrollSymbolsLeft->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontEditGui::OnBtnClick ), NULL, this );
}

FontEditGui::~FontEditGui()
{
	// Disconnect Events
	mCreateBtn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontEditGui::OnBtnClick ), NULL, this );
	mScrollSymbolsLeft->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontEditGui::OnBtnClick ), NULL, this );
	
}

FontSettingsGui::FontSettingsGui( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxDialog( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxDefaultSize, wxDefaultSize );
	
	wxGridSizer* gSizer3;
	gSizer3 = new wxGridSizer( 1, 1, 0, 0 );
	
	wxFlexGridSizer* fgSizer3;
	fgSizer3 = new wxFlexGridSizer( 10, 2, 0, 0 );
	fgSizer3->AddGrowableCol( 1 );
	fgSizer3->AddGrowableRow( 9 );
	fgSizer3->SetFlexibleDirection( wxBOTH );
	fgSizer3->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText1 = new wxStaticText( this, wxID_ANY, wxT("Total symbols:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText1->Wrap( -1 );
	fgSizer3->Add( m_staticText1, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	mNumSpinCtrl = new wxSpinCtrl( this, wxID_NUM_SPIN_CTRL, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 1, 2048, 128 );
	fgSizer3->Add( mNumSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText2 = new wxStaticText( this, wxID_ANY, wxT("Codes:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText2->Wrap( -1 );
	fgSizer3->Add( m_staticText2, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mSetCodesBtn = new wxButton( this, wxID_SET_CODES_BTN, wxT("..."), wxDefaultPosition, wxDefaultSize, wxBU_EXACTFIT );
	fgSizer3->Add( mSetCodesBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	m_staticText3 = new wxStaticText( this, wxID_ANY, wxT("Max height:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText3->Wrap( -1 );
	fgSizer3->Add( m_staticText3, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mMaxHeightSpinCtrl = new wxSpinCtrl( this, wxID_MAX_HEIGHT_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mMaxHeightSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText4 = new wxStaticText( this, wxID_ANY, wxT("Min height:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText4->Wrap( -1 );
	fgSizer3->Add( m_staticText4, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mMinHeightSpinCtrl = new wxSpinCtrl( this, wxID_MIN_HEIGHT_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mMinHeightSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText5 = new wxStaticText( this, wxID_ANY, wxT("Max width:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText5->Wrap( -1 );
	fgSizer3->Add( m_staticText5, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mMaxWidthSpinCtrl = new wxSpinCtrl( this, wxID_MAX_WIDTH_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mMaxWidthSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText6 = new wxStaticText( this, wxID_ANY, wxT("Min width:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText6->Wrap( -1 );
	fgSizer3->Add( m_staticText6, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mMinWidthSpinCtrl = new wxSpinCtrl( this, wxID_MIN_WIDTH_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mMinWidthSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText8 = new wxStaticText( this, wxID_ANY, wxT("Base line:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText8->Wrap( -1 );
	fgSizer3->Add( m_staticText8, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mBaseLineSpinCtrl = new wxSpinCtrl( this, wxID_BASE_LINE_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mBaseLineSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText9 = new wxStaticText( this, wxID_ANY, wxT("Capitals line:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText9->Wrap( -1 );
	fgSizer3->Add( m_staticText9, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mCapLineSpinCtrl = new wxSpinCtrl( this, wxID_CAP_LINE_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mCapLineSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	m_staticText10 = new wxStaticText( this, wxID_ANY, wxT("Lower line"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText10->Wrap( -1 );
	fgSizer3->Add( m_staticText10, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mLowLineSpinCtrl = new wxSpinCtrl( this, wxID_LOW_LINE_SPIN, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 10, 0 );
	fgSizer3->Add( mLowLineSpinCtrl, 0, wxALL|wxEXPAND, 5 );
	
	mOkBtn = new wxButton( this, wxID_OK, wxT("OK"), wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer3->Add( mOkBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mCancelBtn = new wxButton( this, wxID_CANCEL, wxT("Cancel"), wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer3->Add( mCancelBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	gSizer3->Add( fgSizer3, 1, wxEXPAND, 5 );
	
	this->SetSizer( gSizer3 );
	this->Layout();
	
	this->Centre( wxBOTH );
	
	// Connect Events
	mNumSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mSetCodesBtn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontSettingsGui::OnBtnClick ), NULL, this );
	mMaxHeightSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMinHeightSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMaxWidthSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMinWidthSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mBaseLineSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mCapLineSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mLowLineSpinCtrl->Connect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
}

FontSettingsGui::~FontSettingsGui()
{
	// Disconnect Events
	mNumSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mSetCodesBtn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( FontSettingsGui::OnBtnClick ), NULL, this );
	mMaxHeightSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMinHeightSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMaxWidthSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mMinWidthSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mBaseLineSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mCapLineSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	mLowLineSpinCtrl->Disconnect( wxEVT_COMMAND_SPINCTRL_UPDATED, wxSpinEventHandler( FontSettingsGui::OnSpinCtrl ), NULL, this );
	
}

LetterCodesGui::LetterCodesGui( wxWindow* parent, wxWindowID id, const wxString& title, const wxPoint& pos, const wxSize& size, long style ) : wxDialog( parent, id, title, pos, size, style )
{
	this->SetSizeHints( wxSize( 450,500 ), wxDefaultSize );
	
	wxGridSizer* gSizer4;
	gSizer4 = new wxGridSizer( 1, 1, 0, 0 );
	
	wxFlexGridSizer* fgSizer4;
	fgSizer4 = new wxFlexGridSizer( 3, 1, 0, 0 );
	fgSizer4->AddGrowableCol( 0 );
	fgSizer4->AddGrowableRow( 2 );
	fgSizer4->SetFlexibleDirection( wxBOTH );
	fgSizer4->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	mAutoSizer = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Auto:") ), wxHORIZONTAL );
	
	wxFlexGridSizer* fgSizer5;
	fgSizer5 = new wxFlexGridSizer( 1, 5, 0, 0 );
	fgSizer5->AddGrowableCol( 3 );
	fgSizer5->AddGrowableRow( 0 );
	fgSizer5->SetFlexibleDirection( wxBOTH );
	fgSizer5->SetNonFlexibleGrowMode( wxFLEX_GROWMODE_SPECIFIED );
	
	m_staticText11 = new wxStaticText( this, wxID_ANY, wxT("Initial:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText11->Wrap( -1 );
	fgSizer5->Add( m_staticText11, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mInitialSpinCtrl = new wxSpinCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxSP_ARROW_KEYS, 0, 2048, 32 );
	fgSizer5->Add( mInitialSpinCtrl, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	mGenerateBtn = new wxButton( this, wxID_GENERATE_CODES_BTN, wxT("Generate..."), wxDefaultPosition, wxDefaultSize, 0 );
	fgSizer5->Add( mGenerateBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL, 5 );
	
	m_staticText111 = new wxStaticText( this, wxID_ANY, wxT("Codepage:"), wxDefaultPosition, wxDefaultSize, 0 );
	m_staticText111->Wrap( -1 );
	fgSizer5->Add( m_staticText111, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT, 5 );
	
	wxString mPageChoiceChoices[] = { wxT("local"), wxT("cp-1251"), wxT("cp-866"), wxT("koi8-r") };
	int mPageChoiceNChoices = sizeof( mPageChoiceChoices ) / sizeof( wxString );
	mPageChoice = new wxChoice( this, wxID_ANY, wxDefaultPosition, wxDefaultSize, mPageChoiceNChoices, mPageChoiceChoices, 0 );
	mPageChoice->SetSelection( 0 );
	fgSizer5->Add( mPageChoice, 0, wxALIGN_CENTER_VERTICAL|wxALIGN_RIGHT|wxALL, 5 );
	
	mAutoSizer->Add( fgSizer5, 1, wxEXPAND|wxALIGN_CENTER_VERTICAL, 5 );
	
	fgSizer4->Add( mAutoSizer, 1, wxEXPAND, 5 );
	
	mBtnsSizer = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Controls:") ), wxHORIZONTAL );
	
	wxGridSizer* gSizer5;
	gSizer5 = new wxGridSizer( 1, 2, 0, 0 );
	
	mOkBtn = new wxButton( this, wxID_OK, wxT("OK"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer5->Add( mOkBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	mCancelBtn = new wxButton( this, wxID_CANCEL, wxT("Cancel"), wxDefaultPosition, wxDefaultSize, 0 );
	gSizer5->Add( mCancelBtn, 0, wxALL|wxALIGN_CENTER_VERTICAL|wxALIGN_CENTER_HORIZONTAL, 5 );
	
	mBtnsSizer->Add( gSizer5, 1, wxEXPAND, 5 );
	
	fgSizer4->Add( mBtnsSizer, 1, wxEXPAND, 5 );
	
	mGridSizer = new wxStaticBoxSizer( new wxStaticBox( this, wxID_ANY, wxT("Letters:") ), wxVERTICAL );
	
	mCodesGrid = new wxGrid( this, wxID_CODES_GRID, wxDefaultPosition, wxDefaultSize, 0 );
	
	// Grid
	mCodesGrid->CreateGrid( 0, 0 );
	mCodesGrid->EnableEditing( true );
	mCodesGrid->EnableGridLines( true );
	mCodesGrid->EnableDragGridSize( false );
	mCodesGrid->SetMargins( 0, 0 );
	
	// Columns
	mCodesGrid->EnableDragColMove( false );
	mCodesGrid->EnableDragColSize( true );
	mCodesGrid->SetColLabelSize( 30 );
	mCodesGrid->SetColLabelAlignment( wxALIGN_CENTRE, wxALIGN_CENTRE );
	
	// Rows
	mCodesGrid->EnableDragRowSize( true );
	mCodesGrid->SetRowLabelSize( 80 );
	mCodesGrid->SetRowLabelAlignment( wxALIGN_CENTRE, wxALIGN_CENTRE );
	
	// Label Appearance
	
	// Cell Defaults
	mCodesGrid->SetDefaultCellAlignment( wxALIGN_LEFT, wxALIGN_TOP );
	mGridSizer->Add( mCodesGrid, 1, wxALL|wxEXPAND, 5 );
	
	fgSizer4->Add( mGridSizer, 1, wxALIGN_CENTER_HORIZONTAL|wxALIGN_CENTER_VERTICAL|wxEXPAND, 5 );
	
	gSizer4->Add( fgSizer4, 1, wxALL|wxEXPAND|wxFIXED_MINSIZE, 5 );
	
	this->SetSizer( gSizer4 );
	this->Layout();
	
	this->Centre( wxBOTH );
	
	// Connect Events
	this->Connect( wxEVT_SIZE, wxSizeEventHandler( LetterCodesGui::OnSize ) );
	mGenerateBtn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( LetterCodesGui::OnBtnClick ), NULL, this );
	mPageChoice->Connect( wxEVT_COMMAND_CHOICE_SELECTED, wxCommandEventHandler( LetterCodesGui::OnCodePageChange ), NULL, this );
	mOkBtn->Connect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( LetterCodesGui::OnBtnClick ), NULL, this );
}

LetterCodesGui::~LetterCodesGui()
{
	// Disconnect Events
	this->Disconnect( wxEVT_SIZE, wxSizeEventHandler( LetterCodesGui::OnSize ) );
	mGenerateBtn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( LetterCodesGui::OnBtnClick ), NULL, this );
	mPageChoice->Disconnect( wxEVT_COMMAND_CHOICE_SELECTED, wxCommandEventHandler( LetterCodesGui::OnCodePageChange ), NULL, this );
	mOkBtn->Disconnect( wxEVT_COMMAND_BUTTON_CLICKED, wxCommandEventHandler( LetterCodesGui::OnBtnClick ), NULL, this );
	
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
