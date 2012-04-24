/***************************************************************
 * Name:      mainframeimpl.cpp
 * Purpose:   Code for MainFrameImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "mainframeimpl.h"
#include "luacontrol.h"

#include "fonteditimpl.h"
#include "logwindowimpl.h"
#include "editpanelimpl.h"
#include "palwindowimpl.h"
#include "symbolpanel.h"

MainFrameImpl::MainFrameImpl(void):
	UttMainFrame(0L),
	mFontEditor( new FontEditImpl( this ) ),
	mLogWindow( new LogWindowImpl( this ) ),
	mEditWindow( new EditPanelImpl( this ) ),
	mPalWindow( new PaletteWindowImpl( this ) )
{
	m_mgr.SetFlags( wxAUI_MGR_ALLOW_FLOATING		|
					wxAUI_MGR_ALLOW_ACTIVE_PANE		|
					wxAUI_MGR_TRANSPARENT_DRAG		|
					wxAUI_MGR_TRANSPARENT_HINT		|
					wxAUI_MGR_HINT_FADE				|
					wxAUI_MGR_LIVE_RESIZE              );

	this->AddPane(mFontEditor, "Font editor");
	this->AddPane(mLogWindow, "Log window");
	this->AddPane(mEditWindow, "Image editor");
	this->AddPane(mPalWindow, "Palette window");

	wxImage::AddHandler(new wxPNGHandler);
	this->Bind( wxEVT_IDLE, &MainFrameImpl::OnIdle, this );
	this->Bind( wxEVT_SHOW, &MainFrameImpl::OnShow, this );
	mEditWindow->GetEditPanel()->Bind( wxEVT_COLOURPICK, &MainFrameImpl::OnColourPickEvent, this );
	mFontEditor->GetSymbolPanel()->Bind( wxEVT_COLOURPICK, &MainFrameImpl::OnColourPickEvent, this );

	// test
	wxBitmap* bmp = new wxBitmap();
	bmp->LoadFile("D:/test.png", wxBITMAP_TYPE_PNG);
	//bmp->LoadFile("D:/bad.bmp", wxBITMAP_TYPE_BMP);
	mEditWindow->SetBitmap( bmp );
}

MainFrameImpl::~MainFrameImpl(void)
{
	this->Unbind( wxEVT_SHOW, &MainFrameImpl::OnShow, this );
	this->Unbind( wxEVT_IDLE, &MainFrameImpl::OnIdle, this );
}

void MainFrameImpl::OnColourPickEvent( ColourPickEvent& event )
{
	if ( event.GetButton() != wxMOUSE_BTN_LEFT && event.GetButton() != wxMOUSE_BTN_RIGHT )
	{
		return;
	}
	bool right = event.GetButton() == wxMOUSE_BTN_RIGHT;
	switch ( event.GetAction() )
	{
		case ColourPickEvent::cpeSetThisColour:
			mPalWindow->SetColour(right, event.GetColour() );
		break;

		case ColourPickEvent::cpeFindThisColour:
			mPalWindow->FindColour(right, event.GetColour(), true );
		break;

		default:
			wxLogError( wxString::Format( "MainFrameImpl::OnColourPickEvent: unknown action %d", event.GetAction() ) );
			return;
	}
	event.Skip();
}

void MainFrameImpl::AddPane( wxWindow* wnd, const wxString& name )
{
	wxAuiPaneInfo paneInfo;
	wxString _name = name;
	_name.Replace(" ", "");
	_name.MakeLower();
	paneInfo.Name( _name );
	paneInfo.Caption( name );
	paneInfo.Gripper( false );
	paneInfo.Dockable( true );
	paneInfo.Floatable( true );
	paneInfo.MinimizeButton( true );
	paneInfo.MaximizeButton( true );
	paneInfo.PinButton( true );
	paneInfo.CloseButton( true );
	wnd->InvalidateBestSize();
	paneInfo.MinSize( wnd->GetMinSize() );
	paneInfo.MaxSize( wnd->GetMaxSize() );
	paneInfo.BestSize( wnd->GetBestSize() );
	static bool where = false;
	if (where)
		paneInfo.Bottom();
	else
		paneInfo.Left();
	where = !where;
	paneInfo.Layer(1);
	m_mgr.InsertPane( wnd, paneInfo, wxAUI_INSERT_DOCK);
}

void MainFrameImpl::OnIdle( wxIdleEvent& )
{
	if (Lua::GetRebootFlag())
	{
		Lua::Done();
		Lua::Init();
	}
}

void MainFrameImpl::OnShow( wxShowEvent& event )
{
	event.Skip();
	m_mgr.Update();
}

void MainFrameImpl::Init()
{
	wxLogMessage( "Initiating UTT" );
	if (!Lua::Init())
	{
		Lua::ShowLastError();
	}
}

void MainFrameImpl::Deinit()
{
	Lua::Done();
	wxLogMessage( "UTT exits" );
}

void MainFrameImpl::DoFileOpen()
{
	if (!Lua::Get().call( "getExtensions" ) )
	{
		Lua::ShowLastError();
		return;
	}
	std::string result;
	OOLUA::pull2cpp(Lua::Get(), result);
	wxString extensions( result );

	wxFileDialog openFileDialog(this, "Open file", "./", "", extensions, wxFD_OPEN|wxFD_FILE_MUST_EXIST);
	if (openFileDialog.ShowModal() == wxID_CANCEL)
	{
		return;
	}
	if ( !Lua::Get().call( "openFile", openFileDialog.GetPath().ToStdString() ) )
	{
		Lua::ShowLastError();
		return;
	}

}

void MainFrameImpl::DoSelectModule()
{
	if ( !Lua::Get().call( "selectModule" ) )
	{
		Lua::ShowLastError();
		return;
	}
}


void MainFrameImpl::OnClose( wxCloseEvent& event )
{
	this->Deinit();
	event.Skip();
}

void MainFrameImpl::OnMenuSelect( wxCommandEvent& event )
{
	switch ( event.GetId() )
	{
		case wxID_FILE_OPEN:
			DoFileOpen();
		break;

		case wxID_FILE_SELECT:
			DoSelectModule();
		break;

		default:
			wxLogMessage( wxString::Format("Unknown command from main menu: %d", event.GetId()) );
		break;
	}
}
