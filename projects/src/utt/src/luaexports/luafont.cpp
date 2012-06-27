/***************************************************************
 * Name:      luafont.cpp
 * Purpose:   lua bindings for font
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-09
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "luafont.h"
#include "luacontrol.h"

namespace Lua
{

void FontRegister()
{
	Get().register_class<RGBA>();
	Get().register_class<SymbolInfo>();
}

}   // namespace Lua

//
//	Экспорт класса RGBA
//
EXPORT_OOLUA_FUNCTIONS_4_NON_CONST(RGBA,
								   set_R,
								   set_G,
								   set_B,
								   set_A)

EXPORT_OOLUA_FUNCTIONS_4_CONST(RGBA,
							   get_R,
							   get_G,
							   get_B,
							   get_A)

///
/// Экспорт класса SymbolInfo
///
EXPORT_OOLUA_FUNCTIONS_4_NON_CONST( SymbolInfo, GetPixel, SetPixel, SetData, SetValues )
EXPORT_OOLUA_FUNCTIONS_0_CONST( SymbolInfo )

