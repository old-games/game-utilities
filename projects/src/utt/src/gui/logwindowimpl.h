/***************************************************************
 * Name:      logwindow.h
 * Purpose:   Log window
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-19
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef LOGWINDOWIMPL_H_INCLUDED
#define LOGWINDOWIMPL_H_INCLUDED

#include "uttgui.h"

class LogWindowImpl : public wxPanel
{
public:
	LogWindowImpl( wxWindow* parent );
	~LogWindowImpl(void);

private:

	wxTextCtrl*					mLogTxt;
	wxLogTextCtrl*				mLogCtrl;
	wxStreamToTextRedirector	mRedirector;

	std::ofstream				mFileStdStream;
	wxLogChain*					mLogChain;

};

#endif
