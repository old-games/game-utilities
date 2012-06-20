#include "class_from_stack.h"
#include "lua_includes.h"
#include "lvd_types.h"

#include <cassert>
//old code which only gives a slight improvement over using objlen
#if OOLUA_CHECK_EVERY_USERDATA_IS_CREATED_BY_OOLUA__NOTUSED == 1

#	if OOLUA_LUA_USES_DEFAULT_CONFIG_FOR_LUA_514 == 1

	union lua_default_alignment{ double u; void *s; long l; } ;

	typedef union LuaUdata 
	{
		lua_default_alignment dummy;
		struct 
		{
			void *next; char tt; char marked;//CommonHeader
			void * metatable;
			void * env;
			size_t len;
		} uv;
	} LuaUdata;

	typedef LuaUdata Internal_Lua_udata;
#	define UD_LENGTH_OOLUA uv.len

#	elif OOLUA_USING_DEFAULT_CONFIG_FOR_LUAJIT_20 == 1

	typedef struct LuaJitGCRef
	{
		LVD::uint32 gcptr32;
	} LuaJitGCRef;

	typedef struct LuaJitGCudata 
	{
		LuaJitGCRef nextgc; LVD::uint8 marked; LVD::uint8 gct;//GCHeader
		LVD::uint8 udtype;
		LVD::uint8 unused2;
		LuaJitGCRef env;
		LVD::uint32 len;
		LuaJitGCRef metatable;
		LVD::uint32 align1;
	} LuaJitGCudata;	

	typedef LuaJitGCudata Internal_Lua_udata;
#	define UD_LENGTH_OOLUA len
#	endif
#endif




namespace OOLUA
{
	namespace INTERNAL
	{
/*		
#if OOLUA_CHECK_EVERY_USERDATA_IS_CREATED_BY_OOLUA == 1

#	if OOLUA_LUA_USES_DEFAULT_CONFIG_FOR_LUA_514 == 1 || OOLUA_USING_DEFAULT_CONFIG_FOR_LUAJIT_20 == 1

		bool __index_is_userdata(lua_State* l,int index,Lua_ud*& ud)
		{
			ud = static_cast<Lua_ud *>(lua_touserdata(l,index));
			if(!ud)return false;
			Internal_Lua_udata* luaUd = (Internal_Lua_udata*)ud;
			--luaUd;
			if(	luaUd->UD_LENGTH_OOLUA != sizeof(Lua_ud) || ud->created_by_state != l )  
			{
				return false;
			}
			else return true;
		}	
*/
		
#if OOLUA_CHECK_EVERY_USERDATA_IS_CREATED_BY_OOLUA == 1 
#	if OOLUA_USERDATA_OPTIMISATION == 1
		bool index_is_userdata(lua_State* l,int index,Lua_ud*& ud)
		{
			ud = static_cast<Lua_ud *>(lua_touserdata(l,index));
			if(!ud)return false;
			if(	lua_rawlen(l,index) != sizeof(Lua_ud) || ud->created_by_state != l )  
			{
				return false;
			}
			else return true;
		}
#	else
		
		bool index_is_userdata(lua_State* l,int index,Lua_ud*& ud)
		{
			ud = static_cast<Lua_ud *>(lua_touserdata(l,index));
			if(!ud)return false;
			if(!lua_getmetatable(l, index)) return false;
			lua_pushlightuserdata(l, l);
			lua_rawget(l,-2);
			bool result = lua_isnil(l,-1) == 0;
			lua_pop(l,2);
			return result;	
		}
		 	
#	endif

/*		
#elif OOLUA_CHECK_EVERY_USERDATA_IS_CREATED_BY_OOLUA == 0
		
		bool index_is_userdata(lua_State* l,int index,Lua_ud*& ud)
		{
			ud = static_cast<Lua_ud *>( lua_touserdata(l, index) );
			return ud != 0;
		}
*/		
#endif


		bool is_requested_type_a_base(lua_State* l,Lua_ud const* stack_ud,Lua_ud* requested_ud,int const& userdata_index)
		{
			return stack_ud->base_checker(l,requested_ud,userdata_index);
		}
		
		void report_error_userdata_is_constant(lua_State* const l, char const* pulling_class_type)
		{
			luaL_error (l, "%s \"%s\" %s", "Tried to pull a none constant"
						,pulling_class_type
						,"pointer from a const pointer"
						);
		}

	}
}