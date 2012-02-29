/***************************************************************
 * Name:      luacontrol.h
 * Purpose:   Lua declaration and controls
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-08
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#ifndef LUACONTROL_H_INCLUDED
#define LUACONTROL_H_INCLUDED

#include "uttypes.h"
#include "luaexports/common.h"
#include "luaexports/luafont.h"

namespace Lua
{
    bool Init();
    void Done();
    OOLUA::Script&	Get();

	void ShowLastError();
}

//
/////
///// Декларация класса FILE для Lua
/////
//OOLUA_CLASS_NO_BASES(FILE)
//    OOLUA_NO_TYPEDEFS
//    OOLUA_ONLY_DEFAULT_CONSTRUCTOR
//OOLUA_CLASS_END
//
/////
///// Декларация класса 
/////
//OOLUA_CLASS_NO_BASES(Objects::BaseObject)
//
//    OOLUA_TYPEDEFS Abstract OOLUA_END_TYPES
//
//    OOLUA_MEM_FUNC_1(bool, Update, float)
//    OOLUA_MEM_FUNC_1(bool, SaveState, in_out_p<FILE*>)
//    OOLUA_MEM_FUNC_1(bool, LoadState, in_out_p<FILE*>)
//OOLUA_CLASS_END
//
/////
///// Декларация интерфейса 
/////
//OOLUA_CLASS_NO_BASES(Objects::IDrawable)
//
//    OOLUA_TYPEDEFS Abstract OOLUA_END_TYPES
//
//    OOLUA_MEM_FUNC_0(bool, Draw)
//OOLUA_CLASS_END


#endif // LUACONTROL_H_INCLUDED
