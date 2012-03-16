/***************************************************************
 * Name:      pch.h
 * Purpose:   Header to create Pre-Compiled Header (PCH)
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-16
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#ifndef UTT_PCH_H_INCLUDED
#define UTT_PCH_H_INCLUDED

#ifndef WX_PRECOMP
    #define WX_PRECOMP
#endif

// wxWidgets headers
#include <wx/wxprec.h>
#include <wx/vector.h>
#include <wx/menu.h>
#include <wx/wfstream.h>
#include <wx/txtstrm.h>
#include <wx/listimpl.cpp>
#include <wx/snglinst.h>
#include <wx/artprov.h>
#include <wx/log.h>
#include <wx/encconv.h>
#include <wx/fontmap.h>
#include <wx/grid.h>
#include <wx/scrolwin.h>
#include <wx/dcbuffer.h>
#include <wx/log.h>
#include <wx/colordlg.h>
#include <wx/rawbmp.h>

// own written but wx compatible
#include "customevents.h"

// standard headers
#include <iostream>
#include <fstream>

// Lua headers
#include <lua.hpp>
#include <oolua.h>

// project headers
#include "uttypes.h"
#include "defaultpals.h"
#include "helpers.h"

// simple dialogs definitions

// Caption: x; Text: y; Additional property: x
#define YESNODIALOGNULL(x, y, z)	wxMessageDialog(NULL, x, y, wxYES_NO | wxCENTRE | z).ShowModal()
// Caption: x; Text: y
#define YESNODIALOG(x, y)			wxMessageDialog(this, x, y, wxYES_NO | wxCENTRE | wxNO_DEFAULT).ShowModal()
// Caption: Are you sure? Text: x
#define AREYOUSURE(x)				YESNODIALOG("Are you sure?", x)

// stream checking definitions
#define STREAM_EOF(x)	(x->GetLastError() == wxSTREAM_EOF)					// x - wxStream
#define READERROR(x)	(x->GetLastError() == wxSTREAM_READ_ERROR)			// x - wxInputStream
#define WRITEERROR(x)	(x->GetLastError() == wxSTREAM_WRITE_ERROR)			// x - wxOutputStream

#define WXK_CONSOLE	0x60
#define WXK_NUM_ONE 0x31
#define WXK_NUM_TWO 0x32

#endif // UTT_PCH_H_INCLUDED
