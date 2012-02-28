/***************************************************************
 * Name:      luaconsole.h
 * Purpose:   Console frame to Lua
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-11
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#ifndef LUACONSOLE_H_INCLUDED
#define LUACONSOLE_H_INCLUDED

class LuaConsole: public wxFrame
{
public:
	LuaConsole( wxWindow* parent );
	~LuaConsole();
	
	void Do(const wxString& command);
protected:
	void OnCloseWindow( wxCloseEvent& event );
	void OnKeyDown( wxKeyEvent& event );

	wxTextCtrl*		mOutput;
	
private:
	
	void SetPrompt( const wxString& place = "" );
	void InsertText(const wxString& txt);
	void ClearLastLine();
	void HistorySearch( bool down );
	bool CorrectCaret();
	bool CanContinueEvent();
	
	wxArrayString	mCommands;
	int				mHistoryCounter;
};

#endif // LUACONSOLE_H_INCLUDED
