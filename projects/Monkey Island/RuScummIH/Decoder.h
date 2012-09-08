// Decoder.h: interface for the CDecoder class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_DECODER_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_)
#define AFX_DECODER_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "Obj.h"
#include "BackgroundObj.h"
#include "ObjectObj.h"
#include "CostumeObj.h"
#include "BMObj.h"
#include "IMv3Obj.h"
#include "OIv3Obj.h"
#include "OIObj.h"
#include "PAObj.h"
#include "CLUTObj.h"
#include "Chunk.h"
#include "CMDParser.h"

class CDecoder  
{
public:
	CDecoder();
	virtual ~CDecoder();

	int Init(CChunk *chunk, CCMDParser *parser,char* errdescr);
	int Run();

private:
	CObj* m_object;
};

#endif // !defined(AFX_DECODER_H__EA64C4BD_CAD4_4EA1_B2B5_E5FBC6D9E6E6__INCLUDED_)
