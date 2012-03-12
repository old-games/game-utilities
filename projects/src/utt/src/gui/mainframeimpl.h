/***************************************************************
 * Name:      mainframeimpl.h
 * Purpose:   UttMainFrame implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#ifndef MAINFRAMEIMPL_H_INCLUDED
#define MAINFRAMEIMPL_H_INCLUDED

#include "uttgui.h"
#include "fonteditimpl.h"
#include "logwindowimpl.h"
#include "editpanelimpl.h"
#include "palwindowimpl.h"

class MainFrameImpl:
	public UttMainFrame 
{
public:
	MainFrameImpl();
	~MainFrameImpl(void);
	
	void Init();
	void Deinit();

private:

	virtual void OnClose( wxCloseEvent& event );
	virtual void OnMenuSelect( wxCommandEvent& event );
	void OnIdle( wxIdleEvent& );
	void OnShow( wxShowEvent& event );
	void OnColourPickEvent( ColourPickEvent& event );

		
	void AddPane( wxWindow* wnd, const wxString& name );
	void DoFileOpen();
	void DoSelectModule();
	
	FontEditImpl		mFontEditor;
	LogWindowImpl		mLogWindow;
	EditPanelImpl		mEditWindow;
	PaletteWindowImpl	mPalWindow;
};

#endif