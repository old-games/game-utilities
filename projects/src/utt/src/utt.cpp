/***************************************************************
 * Name:      utt.cpp
 * Purpose:   Code for Application Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-16
 * Copyright: Pavlovets Ilia
 * License:
 * Libs used: wxWidgets-last-svn,
 * Soft used: MS VS, Code::Blocks, GCC, 
 **************************************************************/

#include "pch.h"
#include "utt.h"
#include "gui/mainframeimpl.h"
#include "luaconsole.h"

#define WXK_CONSOLE	0x60

IMPLEMENT_APP(UTTApp);

bool UTTApp::OnInit()
{
	MainFrameImpl* frame = new MainFrameImpl();
#ifdef VISUALC
	//frame->SetIcon(wxICON(aaaa)); // To Set App Icon
#endif
	mConsoleFrame = new LuaConsole( frame );
	frame->Init();
	frame->Show();
    return true;
}


wxInt32 UTTApp::OnExit()
{
	this->Unbind( wxEVT_KEY_DOWN, &UTTApp::OnKeyDown, this );
	return wxApp::OnExit();
}


UTTApp::~UTTApp()
{
}

 
void UTTApp::OnKeyDown( wxKeyEvent& event )
{
	switch ( event.GetKeyCode() )
	{
		case WXK_CONSOLE:
			ShowLuaConsole();
		break;

		default:
			event.Skip();
	}
}

void UTTApp::ShowLuaConsole()
{
	bool show = !mConsoleFrame->IsVisible();
	wxLogDebug( show ? "Show console" : "Hide console" );
	mConsoleFrame->Show( show );
}