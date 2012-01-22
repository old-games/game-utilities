/***************************************************************
 * Name:      fonteditimpl.cpp
 * Purpose:   Code for FontEditImpl Class
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-01-17
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "fonteditimpl.h"

FontEditImpl::FontEditImpl(  wxWindow* parent ):
	FontEditGui( parent ),
	mCurrentFont( NULL )
{
}

FontEditImpl::~FontEditImpl(void)
{
}

void FontEditImpl::SetFont( const FontInfo& newFont )
{
}