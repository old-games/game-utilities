/***************************************************************
 * Name:      luaconsole.cpp
 * Purpose:   luaconsole implementaion
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-11
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "luaconsole.h"
#include "luacontrol.h"

#define LUACONSOLE_ID	999
#define STDOUT_SIZE		640
#define STREAM_FILE		"lua.log"

const wxString sPrompt = "Lua >";

LuaConsole::LuaConsole( wxWindow* parent ):
	wxFrame( parent, LUACONSOLE_ID, "Lua console" ),
	mHistoryCounter( 0 )
{
	wxGridSizer* gSizer1;
	gSizer1 = new wxGridSizer( 1, 1, 0, 0 );

	mOutput = new wxTextCtrl( this, LUACONSOLE_ID, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_AUTO_URL|wxTE_MULTILINE );

	gSizer1->Add( mOutput, 1, wxEXPAND, 5 );

	this->SetSizer( gSizer1 );
	this->Layout();
	
	this->Bind( wxEVT_CLOSE_WINDOW, &LuaConsole::OnCloseWindow, this );
	mOutput->Bind( wxEVT_KEY_DOWN, &LuaConsole::OnKeyDown, this );
	SetPrompt();
}

LuaConsole::~LuaConsole()
{

	mOutput->Unbind( wxEVT_KEY_DOWN, &LuaConsole::OnKeyDown, this );
	this->Unbind( wxEVT_CLOSE_WINDOW, &LuaConsole::OnCloseWindow, this );
}

void LuaConsole::OnCloseWindow( wxCloseEvent& WXUNUSED(event) )
{
	this->Hide();
}

void LuaConsole::OnKeyDown( wxKeyEvent& event )
{
	int n = mOutput->GetNumberOfLines() - 1;
	wxString txt = mOutput->GetLineText( n );
	switch ( event.GetKeyCode() )
	{
		case WXK_RETURN:
			if (txt != sPrompt)
			{
				Do( txt );
			}
		break;

		case WXK_UP:
		case WXK_DOWN:
			HistorySearch( WXK_DOWN == event.GetKeyCode() );
		break;

		case WXK_BACK:
		case WXK_LEFT:
			if ( CanContinueEvent() )
			{
				event.Skip();
			}
		break;

		default:
			if ( !event.ControlDown() )
			{
				CorrectCaret();
			}
			event.Skip();
	}
}

void LuaConsole::InsertText(const wxString& txt)
{
	int n = mOutput->GetNumberOfLines() - 1;
	wxTextPos oldPos = mOutput->GetInsertionPoint();
	wxTextPos r = mOutput->GetLastPosition();
	wxTextPos l = r - mOutput->GetLineText(n).length();
	mOutput->SetInsertionPoint( l );
	mOutput->WriteText( txt );
	mOutput->SetInsertionPoint( oldPos + txt.length() );

}

void LuaConsole::Do(const wxString& command)
{
	ClearLastLine();
	wxString toExecute = command;
	if (command.find( sPrompt ) == 0)
	{
		toExecute = command.substr(sPrompt.length());
	}
	mOutput->AppendText("> " );
	mOutput->AppendText( toExecute );
	mOutput->AppendText("\n" );
	if ( !Lua::Get().run_chunk( toExecute.ToStdString() ) )
	{
		Lua::ShowLastError();
	}
	mCommands.Add( toExecute );
	mHistoryCounter = mCommands.size();
	SetPrompt();
}

void LuaConsole::ClearLastLine()
{
	int n = mOutput->GetNumberOfLines() - 1;
	wxTextPos r = mOutput->GetLastPosition();
	wxTextPos l = r - mOutput->GetLineText(n).length();
	mOutput->Remove( l, r );
}

bool LuaConsole::CanContinueEvent()
{
	int n = mOutput->GetNumberOfLines() - 1;
	wxTextPos current = mOutput->GetInsertionPoint();
	wxTextPos r = mOutput->GetLastPosition();
	wxTextPos l = r - mOutput->GetLineText(n).length() + sPrompt.length();
	return current > l;
}

bool LuaConsole::CorrectCaret()
{
	bool forbid = false;
	int n = mOutput->GetNumberOfLines() - 1;
	wxTextPos current = mOutput->GetInsertionPoint();
	wxTextPos r = mOutput->GetLastPosition();
	wxTextPos l = r - mOutput->GetLineText(n).length() + sPrompt.length();
	if ( current <= l )
	{
		current = l;
		forbid = true;
	}
	mOutput->SetInsertionPoint( current );
	return forbid;
}

void LuaConsole::SetPrompt( const wxString& place /* "" */ )
{
	int n = mOutput->GetNumberOfLines() - 1;
	wxString txt = mOutput->GetLineText( n );
	if ( txt.length() != 0 )
	{
		mOutput->AppendText("\n");
	}
	mOutput->AppendText(sPrompt);
	mOutput->AppendText(place);
}

void LuaConsole::HistorySearch( bool down )
{
	int inc = down ? 1 : -1;
	size_t n = mHistoryCounter + inc;
	if ( n >= mCommands.size() )
	{
		return;
	}
	mHistoryCounter = n;
	ClearLastLine();
	SetPrompt( mCommands[n] );
}
