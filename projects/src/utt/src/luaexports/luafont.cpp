/***************************************************************
 * Name:      luafont.cpp
 * Purpose:   lua bindings for font 
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-09
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "luacontrol.h"

void Lua::FontRegister()
{
	Lua::Get().register_class<RGBA>();
	Lua::Get().register_class<SymbolInfo>();
}

EXPORT_OOLUA_NO_FUNCTIONS(RGBA)

///
/// Ёкспорт класса SymbolInfo
///
EXPORT_OOLUA_FUNCTIONS_2_NON_CONST( SymbolInfo, GetPixel, SetPixel )
EXPORT_OOLUA_FUNCTIONS_0_CONST( SymbolInfo )