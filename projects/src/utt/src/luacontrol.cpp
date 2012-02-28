/***************************************************************
 * Name:      luacontrol.cpp
 * Purpose:   Lua implementaions
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-08
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "luacontrol.h"

OOLUA::Script* Lua::gLuaState = NULL;		// пока что сделал указателем, пока OOLUA не доделан

bool Lua::Init()
{
	gLuaState = new OOLUA::Script();
	lua_register(*gLuaState, "writeToStdCout", writeToStdCout);
	lua_register(*gLuaState, "writeToLog", writeToLog);
	
#ifdef _LUAJIT_H
	luaopen_jit(Lua::gLuaState);
#endif
	FontRegister();
	return gLuaState->run_file("scripts/init.lua");
}

void Lua::Done()
{
    wxLogMessage( "Closing Lua...\n" );
    //delete gLuaState;	// TODO: сделать в стеке, когда баг будет решён
}

void Lua::ShowLastError( )
{
	wxLogMessage( wxString( OOLUA::get_last_error(*Lua::gLuaState).c_str() ) );
}

static int Lua::writeToStdCout(lua_State *L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; ++i)
	{
		std::cout << lua_tostring(L, i);
	}
	return 0;
}

static int Lua::writeToLog(lua_State *L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; ++i)
	{
		wxLogMessage( lua_tostring(L, i) );
	}
	return 0;
}

///
/// Экспорт класса FILE в Lua
///
//EXPORT_OOLUA_NO_FUNCTIONS(FILE)

///
/// Экспорт класса Objects::BaseObject в Lua
///
//EXPORT_OOLUA_FUNCTIONS_3_NON_CONST(Objects::BaseObject, Update, SaveState, LoadState)
//EXPORT_OOLUA_FUNCTIONS_0_CONST(Objects::BaseObject)

///
/// Экспорт интерфейса Objects::IDrawable в Lua
///
//EXPORT_OOLUA_FUNCTIONS_1_NON_CONST(Objects::IDrawable, Draw)
//EXPORT_OOLUA_FUNCTIONS_0_CONST(Objects::IDrawable)

