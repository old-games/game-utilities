/***************************************************************
 * Name:      logwindow.h
 * Purpose:   LogWindowGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-19
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef LOGWINDOWIMPL_H_INCLUDED
#define LOGWINDOWIMPL_H_INCLUDED

#include "uttgui.h"

class LogWindowImpl :
	public LogWindowGui
{
public:
	LogWindowImpl( wxWindow* parent );
	~LogWindowImpl(void); 

private:

	wxLogTextCtrl*				mLogCtrl;
	wxStreamToTextRedirector	mRedirector;
};

#endif
