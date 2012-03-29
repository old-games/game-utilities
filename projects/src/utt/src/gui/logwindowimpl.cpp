/***************************************************************
 * Name:      logwindowimpl.cpp
 * Purpose:   Code for LogWindowImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-19
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "logwindowimpl.h"

LogWindowImpl::LogWindowImpl(  wxWindow* parent ):
	LogWindowGui( parent ),
	mRedirector( mLogTxt )
{
	mLogCtrl = new wxLogTextCtrl( mLogTxt );
	delete wxLog::SetActiveTarget( mLogCtrl );

	mFileStdStream.open("utt.log");
	mLogChain = new wxLogChain( new wxLogStream(reinterpret_cast<std::ostream*>(&mFileStdStream)) );
}

LogWindowImpl::~LogWindowImpl(void)
{
	delete wxLog::SetActiveTarget( NULL );
}
