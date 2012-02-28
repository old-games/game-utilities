/***************************************************************
 * Name:      common.cpp
 * Purpose:   implementation of common functions for Lua
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-28
 * Copyright: Pavlovets Ilia
 * License:
 **************************************************************/

#include "pch.h"
#include "luacontrol.h"
#include "gui/selmoduleimpl.h"

static int writeToStdCout(lua_State *L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; ++i)
	{
		std::cout << lua_tostring(L, i);
	}
	return 0;
}

static int writeToLog(lua_State *L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; ++i)
	{
		wxLogMessage( lua_tostring(L, i) );
	}
	return 0;
}

static int selectModuleDialog(lua_State *L)
{
	int n = lua_gettop(L);
	if (n != 1)
	{
		wxLogMessage("selectModuleDialog: function need a table with module names as argument");
		return 0;
	}
	OOLUA::Lua_table modules;
	OOLUA::pull2cpp(L, modules);
	wxArrayString strings;
	{
		int count = 1;
		std::string value;
		while (modules.safe_at( count++, value ))
		{
			strings.Add( wxString(value) );
		}
	}
	if (strings.size() == 0)
	{
		wxLogMessage("selectModuleDialog: empty table received");
		return 0;
	}
	
	SelectModuleImpl dlg(NULL);
	dlg.FillCombo( strings );
	
	wxString result;
	if (dlg.ShowModal() == wxID_OK)
	{
		result = dlg.GetValue();
	}
	
	lua_pushstring(L, result.c_str().AsChar());
	return 1;
}

void Lua::CommonRegister()
{
	lua_register(*gLuaState, "writeToStdCout", writeToStdCout);
	lua_register(*gLuaState, "writeToLog", writeToLog);
	lua_register(*gLuaState, "selectModuleDialog", selectModuleDialog);
}
