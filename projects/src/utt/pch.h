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

// basic wxWidgets headers
#include <wx/wxprec.h>

#include <wx/menu.h>
#include <wx/wfstream.h>
#include <wx/txtstrm.h>
#include <wx/listimpl.cpp>
#include <wx/snglinst.h>
#include <wx/artprov.h>
#include <wx/log.h>

// simple dialogs definitions
#define YESNODIALOGNULL(x, y, z)	wxMessageDialog(NULL, x, y, wxYES_NO | wxCENTRE | z).ShowModal()
#define YESNODIALOG(x, y)			wxMessageDialog(this, x, y, wxYES_NO | wxCENTRE | wxNO_DEFAULT).ShowModal()
#define AREYOUSURE(x)				YESNODIALOG("Are you sure?", x)

// stream checking definitions
#define STREAM_EOF(x)	(x->GetLastError() == wxSTREAM_EOF)					// x - wxStream
#define READERROR(x)	(x->GetLastError() == wxSTREAM_READ_ERROR)			// x - wxInputStream
#define WRITEERROR(x)	(x->GetLastError() == wxSTREAM_WRITE_ERROR)			// x - wxOutputStream

#endif // UTT_PCH_H_INCLUDED