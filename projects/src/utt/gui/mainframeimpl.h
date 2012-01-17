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

class MainFrameImpl:
	public UttMainFrame 
{
public:
	MainFrameImpl();
	~MainFrameImpl(void);
	
private:

	FontEditImpl		mFontEditor;
};

#endif