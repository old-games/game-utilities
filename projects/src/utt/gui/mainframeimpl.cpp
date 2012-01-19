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

MainFrameImpl::MainFrameImpl(void):
	UttMainFrame(0L),
	mFontEditor( this ),
	mLogWindow( this )
{
	m_mgr.AddPane(&mFontEditor, wxLEFT, "Font editor");
	m_mgr.AddPane(&mLogWindow, wxLEFT, "Log");
	m_mgr.Update();
}

MainFrameImpl::~MainFrameImpl(void)
{
}
