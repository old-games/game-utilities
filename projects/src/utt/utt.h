/***************************************************************
 * Name:      familyguide.h
 * Purpose:   Defines Application Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2011-05-15
 * Copyright: Pavlovets Ilia (www.familysoft.ru)
 * License:
 **************************************************************/

#ifndef UTTAPP_H
#define UTTAPP_H

#include <wx/app.h>
#include <fstream>

class UTTApp : public wxApp
{
	
    public:
		UTTApp()
		{
		}

        virtual bool OnInit();
};

DECLARE_APP(UTTApp)
#endif // UTTAPP_H
