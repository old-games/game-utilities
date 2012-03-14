/***************************************************************
 * Name:      mainframeimpl.h
 * Purpose:   FontEditGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef FONTEDITIMPL_H_INCLUDED
#define FONTEDITIMPL_H_INCLUDED

#include "uttgui.h"

// TODO: replace when drawpanel will be finished
#include "symbolpanel.h"

class FontEditImpl :
	public FontEditGui
{
public:
	FontEditImpl( wxWindow* parent );
	~FontEditImpl(void);

	void SetFont( const FontInfo& newFont );
	bool ShowSettings();
	bool CreateFont();
	bool CheckChanges();
	bool SaveFont();
	
	SymbolPanel* GetSymbolPanel()
	{
		return mSymbolPanel;
	}

protected:

	void Render(wxDC& dc);
	void OnPaint(wxPaintEvent& event);
	
	virtual void OnBtnClick( wxCommandEvent& event );
private:	

	SymbolPanel*	mSymbolPanel;
	FontInfo*		mCurrentFont;
	int				mCurrentSymbol;
	bool			mHasChanges;
	
	
};

#endif
