#include "lua_ref.h"

#include "oolua_config.h"
#include "oolua_error.h"

namespace OOLUA
{
	namespace INTERNAL 
	{
		bool if_enabled_compare_states_and_react(lua_State* lua,lua_State* other)
		{
#if OOLUA_RUNTIME_CHECKS_ENABLED == 1
			if( lua != other )
			{
#	if OOLUA_USE_EXCEPTIONS ==1
				lua_pushstring(lua, "Can not push a valid Lua reference from one lua_State to a different state");
				throw OOLUA::Runtime_error(lua);
#	endif
#	if OOLUA_STORE_LAST_ERROR ==1
				lua_pushfstring(lua,"Can not push a valid Lua reference from one lua_State to a different state"); 
				OOLUA::INTERNAL::set_error_from_top_of_stack_and_pop_the_error(lua);
#	endif
#	if OOLUA_DEBUG_CHECKS == 1
				//	assert(0 && "Can not push a valid Lua reference from one lua_State to a different state");
#	endif
#	if OOLUA_USE_EXCEPTIONS == 0
				return false;
#	endif
			}
#else
			(void)lua;
			(void)other;
#endif
			return true;
		}
		
		
		void pull_handle_invalid(lua_State* const lua,int id)
		{
#if OOLUA_STORE_LAST_ERROR == 1 || 	OOLUA_USE_EXCEPTIONS ==1
			lua_pushfstring(lua,
							"pulling incorrect type from stack. This is a Lua registry reference to id%d, stack contains %s"
							,id
							,lua_typename(lua,lua_type(lua, -1)));	
#	if OOLUA_USE_EXCEPTIONS ==1
			throw OOLUA::Runtime_error(lua,(OOLUA::ERROR::PopTheStack*)0);
#	else // OOLUA_STORE_LAST_ERROR ==1								
			OOLUA::INTERNAL::set_error_from_top_of_stack_and_pop_the_error(lua);
#	endif
#elif OOLUA_DEBUG_CHECKS == 1
			assert(0 && "pulling incorrect type from stack");
#endif
		}
	}
}