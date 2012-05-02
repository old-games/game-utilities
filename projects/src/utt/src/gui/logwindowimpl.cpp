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
	wxPanel( parent, wxID_ANY, wxDefaultPosition, wxSize( 500, 100 )  ),
	mRedirector( mLogTxt )
{
	this->SetMinSize( wxSize( 500, 100 ) );
	wxGridSizer* gSizer2;
	gSizer2 = new wxGridSizer( 1, 1, 0, 0 );
	mLogTxt = new wxTextCtrl( this, wxID_ANY, wxEmptyString, wxDefaultPosition, wxDefaultSize, wxTE_AUTO_URL|wxTE_MULTILINE|wxTE_READONLY );
	gSizer2->Add( mLogTxt, 1, wxEXPAND, 5 );
	this->SetSizer( gSizer2 );
	this->Layout();


	mLogCtrl = new wxLogTextCtrl( mLogTxt );
	delete wxLog::SetActiveTarget( mLogCtrl );

	mFileStdStream.open("utt.log");
	mLogChain = new wxLogChain( new wxLogStream(reinterpret_cast<std::ostream*>(&mFileStdStream)) );
}

LogWindowImpl::~LogWindowImpl(void)
{
	delete wxLog::SetActiveTarget( NULL );
}
