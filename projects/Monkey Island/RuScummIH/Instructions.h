// Instructions.h: interface for the CInstructions class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_INSTRUCTIONS_H__A1656CDE_218E_4F42_8DAA_B2AE6BA3083D__INCLUDED_)
#define AFX_INSTRUCTIONS_H__A1656CDE_218E_4F42_8DAA_B2AE6BA3083D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "CAtlArray.h"

class CInstructions  
{
public:
	CInstructions();
	virtual ~CInstructions();

	LPTSTR GetType();
	void SetType(LPTSTR type);
	
	int GetBaseIndex();
	void SetBaseIndex(int i);

	LPTSTR GetIMName(int i);
	void AddIMName(LPTSTR name);

	LPTSTR GetZPName(int i);
	void AddZPName(LPTSTR name);


	LPTSTR GetMaskName(int i);
	void AddMaskName(LPTSTR name);

	int GetIMBound();
	int GetZPBound();
	int GetMaskBound();

	int GetXPos();
	int GetYPos();
	void SetXPos(int x);
	void SetYPos(int y);

	int Load(LPTSTR path, LPTSTR name);
	int Save(LPTSTR path, LPTSTR name);

private:
	int SaveAsText(HANDLE hFile);
	int LoadAsText(HANDLE hFile);
	int ReadString(HANDLE hFile, LPTSTR buf, DWORD sz);

	LPTSTR m_type;
	CAtlArray<LPTSTR> m_mask;
	CAtlArray<LPTSTR> m_IM;
	CAtlArray<LPTSTR> m_ZP;

	int m_xPos, m_yPos;
};

#endif // !defined(AFX_INSTRUCTIONS_H__A1656CDE_218E_4F42_8DAA_B2AE6BA3083D__INCLUDED_)
