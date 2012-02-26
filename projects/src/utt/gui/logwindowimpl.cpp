/***************************************************************
 * Name:      logwindowi,pl.cpp
 * Purpose:   Code for LogWindowImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-19
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "logwindowimpl.h"

LogWindowImpl::LogWindowImpl(  wxWindow* parent ):
	LogWindowGui( parent )
//	mRedirector( mLogTxt )
{	
	freopen ("log","w",stdout);
	std::filebuf* fb = new std::filebuf();
	fb->open ("log", std::ios::ate);
	std::ostream* os = new std::ostream(fb);
	os->rdbuf( mLogTxt );
	mRedirector = new wxStreamToTextRedirector( mLogTxt, os);
	mLogCtrl = new wxLogTextCtrl( mLogTxt );
	delete wxLog::SetActiveTarget( mLogCtrl );

}

LogWindowImpl::~LogWindowImpl(void)
{
}
