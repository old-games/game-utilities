/***************************************************************
 * Name:      luafont.h
 * Purpose:   declaration of lua bindings for font
 * Author:    Pavlovets Ilia (ilia.pavlovets@gmail.com)
 * Created:   2012-02-09
 * Copyright: Pavlovets Ilia 2012 
 * License:
 **************************************************************/

#ifndef LUAFONT_H_INCLUDED
#define LUAFONT_H_INCLUDED

namespace Lua
{
	void FontRegister();
}

//OOLUA_CLASS_NO_BASES( Pixel )
//	OOLUA_NO_TYPEDEFS
//	OOLUA_ONLY_DEFAULT_CONSTRUCTOR
//OOLUA_CLASS_END

OOLUA_CLASS_NO_BASES( RGBA )
    OOLUA_NO_TYPEDEFS
    OOLUA_ONLY_DEFAULT_CONSTRUCTOR
OOLUA_CLASS_END

OOLUA_CLASS_NO_BASES( SymbolInfo )

	OOLUA_ONLY_DEFAULT_CONSTRUCTOR

	OOLUA_NO_TYPEDEFS 

	OOLUA_MEM_FUNC_2( RGBA, GetPixel, int, int )
    OOLUA_MEM_FUNC_3( void, SetPixel, int, int, RGBA )
OOLUA_CLASS_END



#endif // LUAFONT_H_INCLUDED
