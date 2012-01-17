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
#include "gui/mainframeimpl.h"

IMPLEMENT_APP(UTTApp);

bool UTTApp::OnInit()
{
	MainFrameImpl* frame = new MainFrameImpl();
#ifdef VISUALC
	//frame->SetIcon(wxICON(aaaa)); // To Set App Icon
#endif
	frame->Show();
    return true;
}
 