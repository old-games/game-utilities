// stdafx.h : include file for standard system include files,
//  or project specific include files that are used frequently, but
//      are changed infrequently
//

#if !defined(AFX_STDAFX_H__9E858F38_3B60_465E_A2E4_E35C41DF3AFC__INCLUDED_)
#define AFX_STDAFX_H__9E858F38_3B60_465E_A2E4_E35C41DF3AFC__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include <windows.h>
#include <malloc.h>
#include <stdio.h>
#include "scummsys.h"
//#include <ATLbase.h>
//#include <ATLArray.h>
//#include <atlcoll.h>
#include <math.h>
#include <conio.h>
#include <vector>
using namespace std;

#define _CRT_SECURE_NO_WARNINGS	1

#define ERR_UNSUPPORTED_BLOCK	10
#define ERR_NEEDED_BLOCK_NOT_FOUND	20   //decoder
#define ERR_UNABLE_LOAD_FILE	30  //decoder
#define ERR_UNABLE_SAVE_FILE	35  //decoder
#define ERR_UNABLE_PARSE_FILE	37  //encoder

#define ERR_NULL_OBJECT	40 
#define ERR_UNSUPPORTED_TYPE 50 
#define ERR_BAD_WIDTH_OR_HEIGHT 60  //encoder
#define ERR_BAD_WIDTH_NOT_M_PRESENT 70 //encoder
#define ERR_BAD_X_OR_Y 80 //encoder

#define ERR_INS_FILE_CORRUPT 90 //encoder
#define ERR_NOT_INS_FILE 100 //encoder

#define ERR_PALETTE_FILE_CORRUPT 110 //encoder

#define ATLANTIS_ENGINE			10
#define ATLANTIS_ENGINE_MASK	15
#define INDY3_ENGINE			20
#define LOOM_EGA_ENGINE			30
#define ATLANTIS_ENGINE_COSTUME 25


// TODO: reference additional headers your program requires here

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__9E858F38_3B60_465E_A2E4_E35C41DF3AFC__INCLUDED_)
