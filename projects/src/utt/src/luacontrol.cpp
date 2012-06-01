/***************************************************************
 * Name:      luacontrol.cpp
 * Purpose:   Lua implementaions
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-08
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"

#include "luaexports/common.h"
#include "luaexports/luafont.h"
#include "luacontrol.h"

static OOLUA::Script* gLuaState = NULL;
static bool gRebootRequest = false;

OOLUA::Script& Lua::Get()
{
	return *gLuaState;
}

bool Lua::Init()
{
	if (gRebootRequest)
	{
		wxLogMessage("Reboot called but Lua::Done() was not called yet.");
		return false;
	}
	if ( gLuaState != NULL )
	{
		wxLogMessage("Lua::Done() was not called before Lua::Init()");
		Lua::Done();
	}
	gLuaState = new OOLUA::Script();
	CommonRegister();
	FontRegister();
	return gLuaState->run_file("scripts/init.lua");
}

void Lua::Done()
{
    wxLogMessage( "Closing Lua...\n" ); // http://code.google.com/p/oolua/issues/detail?id=29
	delete gLuaState;
    gLuaState = NULL;
	gRebootRequest = false;
}

void Lua::SetRebootFlag()
{
	gRebootRequest = true;
}

bool Lua::GetRebootFlag()
{
	return gRebootRequest;
}

bool Lua::IsOk()
{
	return gLuaState != NULL;
}

void Lua::ShowLastError( )
{
	if ( IsOk() )
	{
		wxLogMessage( wxString( OOLUA::get_last_error(Lua::Get()).c_str() ) );
	}
	else
	{
		wxLogError( "Lua was not initialised." );
	}
}


