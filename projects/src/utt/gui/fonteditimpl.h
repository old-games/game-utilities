/***************************************************************
 * Name:      mainframeimpl.h
 * Purpose:   FontEditGui implementation
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
#ifndef FONTEDITIMPL_H_INCLUDED
#define FONTEDITIMPL_H_INCLUDED

#include "uttgui.h"

class FontEditImpl :
	public FontEditGui
{
public:
	FontEditImpl( wxWindow* parent );
	~FontEditImpl(void);
};

#endif
