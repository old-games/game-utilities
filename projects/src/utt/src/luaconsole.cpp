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
#include <wx/tokenzr.h>

const wxString  sPrompt = ">";
const wxString  sHistoryFile = "luahistory.utt";
const size_t    sMaxCommands = 100;

LuaConsole::LuaConsole( wxWindow* parent ):
	wxFrame( parent, wxID_ANY, "Lua console" ),
	mHistoryCounter( 0 )
{
	wxGridSizer* gSizer1;
	gSizer1 = new wxGridSizer( 1, 1, 0, 0 );

	mOutput = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_AUTO_URL|wxTE_MULTILINE );

	gSizer1->Add( mOutput, 1, wxEXPAND, 5 );

	this->SetSizer( gSizer1 );
	this->Layout();

	this->Bind( wxEVT_CLOSE_WINDOW, &LuaConsole::OnCloseWindow, this );
	mOutput->Bind( wxEVT_KEY_DOWN, &LuaConsole::OnKeyDown, this );
	SetPrompt();
	LoadHistory();
}

LuaConsole::~LuaConsole()
{
    SaveHistory();
	mOutput->Unbind( wxEVT_KEY_DOWN, &LuaConsole::OnKeyDown, this );
	this->Unbind( wxEVT_CLOSE_WINDOW, &LuaConsole::OnCloseWindow, this );
}

void LuaConsole::OnCloseWindow( wxCloseEvent& WXUNUSED(event) )
{
	this->Hide();
}

void LuaConsole::OnKeyDown( wxKeyEvent& event )
{
	wxInt32 n = mOutput->GetNumberOfLines() - 1;
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
	CheckCommandDoublicate( toExecute );
	mCommands.Add( toExecute );
	mHistoryCounter = mCommands.size();
	SetPrompt();
    SaveHistory();
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
	wxInt32 inc = down ? 1 : -1;
	size_t n = mHistoryCounter + inc;
	if ( n >= mCommands.size() )
	{
		return;
	}
	mHistoryCounter = n;
	ClearLastLine();
	SetPrompt( mCommands[n] );
}

bool LuaConsole::CheckCommandDoublicate( const wxString& command )
{
    bool res = false;
    for (size_t i = 0; i < mCommands.size(); ++i )
    {
        if ( command == mCommands[i] )
        {
            mCommands.RemoveAt(i--);
            res = true;
        }
    }
    return res;
}

void LuaConsole::LoadHistory()
{
    wxFFile file;

    if (!file.Open( sHistoryFile ))
    {
        return;
    }
    wxString all;
    if (!file.ReadAll( &all ))
    {
        wxLogMessage("LuaConsole::LoadHistory: error while loading Lua commands history");
    }
    else
    {
        mCommands = wxStringTokenize(all, "\r\n");
    }
    mHistoryCounter = mCommands.size();
    file.Close();
    wxLogDebug(wxString::Format( "LuaConsole::LoadHistory() ok! %d commands loaded.", mCommands.size()) );
}

void LuaConsole::SaveHistory()
{
    wxFile file(sHistoryFile, wxFile::write );
    if (!file.IsOpened())
    {
        wxLogError(wxString::Format("LuaConsole::SaveHistory: can't create %s to save commands history", sHistoryFile));
        return;
    }
    size_t i = mCommands.size() > sMaxCommands ? mCommands.size() - sMaxCommands : 0;
    for (; i < mCommands.size(); ++i)
    {
        file.Write( mCommands[i] + "\n");
    }
    file.Close();
    wxLogDebug("LuaConsole::SaveHistory() ok!");
}
