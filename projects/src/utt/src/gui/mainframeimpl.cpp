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

MainFrameImpl::MainFrameImpl(void):
	UttMainFrame(0L),
	mFontEditor( this ),
	mLogWindow( this ),
	mEditWindow( this )
{
	m_mgr.AddPane(&mFontEditor, wxDOWN, "Font editor");
	m_mgr.AddPane(&mLogWindow, wxUP, "Log");
	m_mgr.AddPane(&mEditWindow, wxALL, "Image editor");
	m_mgr.Update();
	wxImage::AddHandler(new wxPNGHandler);
	// test
	wxBitmap* bmp = new wxBitmap();
	bmp->LoadFile("D:/microsoft.png", wxBITMAP_TYPE_PNG);
	mEditWindow.SetBitmap( bmp );
}

MainFrameImpl::~MainFrameImpl(void)
{
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
	if (! Lua::Get().call( "getExtensions" ) )
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