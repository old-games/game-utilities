/***************************************************************
 * Name:      utt.cpp
 * Purpose:   Code for Application Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-16
 * Copyright: Pavlovets Ilia
 * License:
 * Libs used: wxWidgets-last-svn,
 * Soft used: MS VS
 **************************************************************/

#include "pch.h"
#include "utt.h"
#include "gui/uttgui.h"

IMPLEMENT_APP(UTTApp);

bool UTTApp::OnInit()
{
	UttMainFrame* frame = new UttMainFrame(0L);
#ifdef VISUALC
	//frame->SetIcon(wxICON(aaaa)); // To Set App Icon
#endif
	frame->Show();
    return true;
}
