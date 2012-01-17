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
	mFontEditor( this )
{
	m_mgr.AddPane(&mFontEditor, wxLEFT, "Font editor");
}

MainFrameImpl::~MainFrameImpl(void)
{
}
