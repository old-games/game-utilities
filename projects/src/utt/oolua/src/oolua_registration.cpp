#include "oolua_registration.h"

namespace OOLUA
{
	namespace INTERNAL
	{
		void set_function_in_table_with_upvalue(lua_State* l, char const * func_name, lua_CFunction func
													, int tableIndex, void* upvalue)
		{
			lua_pushstring(l, func_name);
			lua_pushlightuserdata( l, upvalue );
			lua_pushcclosure(l, func, 1);
			lua_settable(l, tableIndex);
		}
		void set_function_in_table(lua_State* l, char const* func_name,lua_CFunction func,int tableIndex)
		{
			lua_pushstring(l, func_name);
			lua_pushcclosure(l, func, 0);
			lua_settable(l, tableIndex);
		}
		/*
		void set_oolua_userdata_creation_key_value_in_table(lua_State* l ,void* key,lua_CFunction value,int tableIndex)
		{
			lua_pushlightuserdata(l,key);
			//lua_pushlightuserdata(l,key);
			lua_pushboolean(l, 1);
//			lua_pushcfunction(l, value);
			lua_settable(l, tableIndex);
		}
		 */
		
		void set_oolua_userdata_creation_key_value_in_table(lua_State* l ,int tableIndex)
		{
#if OOLUA_CHECK_EVERY_USERDATA_IS_CREATED_BY_OOLUA == 1
			lua_pushlightuserdata(l,l);
			lua_pushboolean(l, 1);
			lua_settable(l, tableIndex);
#else
			(void)l;
			(void)tableIndex;
#endif
		}
		
		void set_key_value_in_table(lua_State* l,char const* key_name,int valueIndex,int tableIndex)
		{
			lua_pushstring(l, key_name);
			lua_pushvalue(l, valueIndex);
			lua_settable(l, tableIndex);
		}
		int check_for_key_in_stack_top(lua_State* l)
		{
			//on entry stack is : table keyString basetable
			lua_pushvalue(l, -2);//table keyString baseTable keyString
			lua_gettable(l, -2);//check for keyString in baseTable
			if( lua_isnil(l,-1) == 1)//table string baseTable valueOrNil
			{
				lua_pop(l,2);//table keyString
				return 0;
			}
			
			lua_remove(l,-2);//table keyString TheValueThatWeWereLookingFor
			return 1;
		}
		
		bool class_name_is_already_registered(lua_State*l, char const* name)
		{
			lua_getfield(l, LUA_REGISTRYINDEX, name);
			if( lua_isnil(l,-1) == 0 )// entryOrNil
			{
				lua_pop(l,1);//pop the table
				return true;
			}
			
			lua_pop(l,1);//pop the null
			return false;
		}
		
	}
}

