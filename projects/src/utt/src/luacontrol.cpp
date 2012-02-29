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

static OOLUA::Script* gLuaState = NULL;		

OOLUA::Script& Lua::Get()
{
	return *gLuaState;
}

bool Lua::Init()
{
	if ( gLuaState != NULL )
	{
		wxLogMessage("Lua::Done() was not called before Lua::Init()");
		Lua::Done();
	}
	gLuaState = new OOLUA::Script();
#ifdef _LUAJIT_H
	luaopen_jit(Lua::gLuaState);
#endif
	CommonRegister();	
	FontRegister();
	return gLuaState->run_file("scripts/init.lua");
}

void Lua::Done()
{
    wxLogMessage( "Closing Lua...\n" );
    delete gLuaState;	
    gLuaState = NULL;
}

void Lua::ShowLastError( )
{
	wxLogMessage( wxString( OOLUA::get_last_error(Lua::Get()).c_str() ) );
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

