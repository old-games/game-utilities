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
{
}

LogWindowImpl::~LogWindowImpl(void)
{
}

void LogWindowImpl::WriteLogMessage(const wxString& txt)
{
	mLogTxt->AppendText( txt );
}