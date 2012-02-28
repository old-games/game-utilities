/***************************************************************
 * Name:      utt.h
 * Purpose:   Defines Application Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-16
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#ifndef UTTAPP_H_INCLUDED
#define UTTAPP_H_INCLUDED

#include <wx/app.h>

class LuaConsole;
class UTTApp : public wxApp
{
	
public:
	UTTApp():
		mConsoleFrame( NULL )
	{
		this->Bind( wxEVT_KEY_DOWN, &UTTApp::OnKeyDown, this );
	}

	~UTTApp();

	void ShowLuaConsole();

protected:
	virtual bool OnInit();
	virtual int OnExit();
	
private:

	void OnKeyDown( wxKeyEvent& event );
	
	LuaConsole*		mConsoleFrame;
};

DECLARE_APP(UTTApp)
#endif // UTTAPP_H_INCLUDED
