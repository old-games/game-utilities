// CMDParser.h: interface for the CCMDParser class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_CMDPARSER_H__8AFF35D8_8392_4E5C_9CCC_DD190B5172B1__INCLUDED_)
#define AFX_CMDPARSER_H__8AFF35D8_8392_4E5C_9CCC_DD190B5172B1__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "CAtlArray.h"

class CCMDParser  
{
public:
	CCMDParser();
	virtual ~CCMDParser();
	BOOL ParseOk(int argc, char* argv[]);

	LPTSTR GetNextFilename();
	LPTSTR GetSrcPath();
	LPTSTR GetDstPath();
	int GetFilesCount();

	/*int GetX();
	int GetY();
	void SetX(int x);
	void SetY(int y);*/

	LPTSTR GetCurrentFilename();

	BOOL IsEncodeMask();


	BYTE m_operation;
	BYTE m_special_stop;
	BOOL m_encodemask;
	
private:
	BOOL FindAllFiles();
	LPTSTR m_filename;
	LPTSTR m_srcPath;
	LPTSTR m_dstPath;
	CAtlArray <LPTSTR>m_files;
	int current;
	/*int m_x;
	int m_y;*/

};

#endif // !defined(AFX_CMDPARSER_H__8AFF35D8_8392_4E5C_9CCC_DD190B5172B1__INCLUDED_)
