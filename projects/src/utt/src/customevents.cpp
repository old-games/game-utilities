/***************************************************************
 * Name:      custumevents.cpp
 * Purpose:   implementation of custom events
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-03-12
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/
 
#include "pch.h"
#include "customevents.h"

wxDEFINE_EVENT( wxEVT_COLOURPICK, ColourPickEvent );

IMPLEMENT_DYNAMIC_CLASS(ColourPickEvent, wxEvent)