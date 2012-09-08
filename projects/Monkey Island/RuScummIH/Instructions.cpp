// Instructions.cpp: implementation of the CInstructions class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "Instructions.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
CInstructions::CInstructions()
{
	m_type=NULL;
	m_xPos= -1;
	m_yPos= -1;
};

CInstructions::~CInstructions()
{
	free(m_type);
	for(DWORD i=0; i<m_IM.GetCount(); i++)
	{
		free(m_IM[i]);
	}
	for(DWORD i=0; i<m_ZP.GetCount(); i++)
	{
		free(m_ZP[i]);
	}
	for(DWORD i=0; i<m_mask.GetCount(); i++)
	{
		free(m_mask[i]);
	}
	m_IM.RemoveAll();
	m_ZP.RemoveAll();
	m_mask.RemoveAll();
};

LPTSTR CInstructions::GetType()
{
	return(m_type);
};

void CInstructions::SetType(LPTSTR type)
{
	m_type=strdup(type);
};

LPTSTR CInstructions::GetIMName(int i)
{
	if ((unsigned)i>(m_IM.GetCount()-1))return(NULL);
	return(m_IM[i]);
};

void CInstructions::AddIMName(LPTSTR name)
{
	m_IM.Add(strdup(name));
};


LPTSTR CInstructions::GetZPName(int i)
{
	if ((unsigned)i>(m_ZP.GetCount()-1))return(NULL);
	return(m_ZP[i]);
};

void CInstructions::AddZPName(LPTSTR name)
{
	m_ZP.Add(strdup(name));
};

LPTSTR CInstructions::GetMaskName(int i)
{
	if ((unsigned)i>(m_mask.GetCount()-1))return(NULL);
	return(m_mask[i]);
};

void CInstructions::AddMaskName(LPTSTR name)
{
	m_mask.Add(strdup(name));
};

int CInstructions::GetIMBound()
{
	return(m_IM.GetCount()-1);
};

int CInstructions::GetZPBound()
{
	return(m_ZP.GetCount()-1);
};

int CInstructions::GetMaskBound()
{
	return(m_mask.GetCount()-1);
};

int CInstructions::GetXPos()
{
	return(m_xPos);
};
int CInstructions::GetYPos()
{
	return(m_yPos);
};
void CInstructions::SetXPos(int x)
{
	m_xPos = x;
};
void CInstructions::SetYPos(int y)
{
	m_yPos = y;
};


int CInstructions::Load(LPTSTR path, LPTSTR name)
{

	char *file = (char*)malloc(strlen(path)+strlen(name)+2);
	sprintf(file, "%s\\%s",path,name);
	HANDLE hFile= CreateFile(file, GENERIC_READ|GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
	free(file);
	if(hFile==INVALID_HANDLE_VALUE)return(ERR_UNABLE_LOAD_FILE);
	DWORD ssszzz;
	char buf[6]="";
	ReadFile(hFile, &buf[0], 5, &ssszzz, NULL);
	if(strcmp(&buf[0], "INS\r\n")!=0)
	{
		CloseHandle(hFile);
		return(ERR_NOT_INS_FILE);
	}

	int err =LoadAsText(hFile);

	CloseHandle(hFile);

	return(err);
};

int CInstructions::Save(LPTSTR path, LPTSTR name)
{
	char *file = (char*)malloc(strlen(path)+strlen(name)+2);
	sprintf(file, "%s\\%s",path,name);
	HANDLE hFile= CreateFile(file, GENERIC_READ|GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, 0, NULL);
	free(file);
	if(hFile==INVALID_HANDLE_VALUE)return(ERR_UNABLE_SAVE_FILE);

	DWORD ssszzz;
	WriteFile(hFile, "INS\r\n", 5, &ssszzz, NULL);

	int err= SaveAsText(hFile);

	CloseHandle(hFile);
	
	return(err);
};

int CInstructions::SaveAsText(HANDLE hFile)
{
	DWORD a = 0;
	DWORD sz;
	char buf[MAX_PATH]="";

	//1. body of type
	sprintf(&buf[0], "%s\r\n", m_type);
	WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);

	//2. number of mask
	a = m_mask.GetCount();
	sprintf(&buf[0], "%d\r\n", a);
	WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
				
	for(DWORD i=0; i<m_mask.GetCount(); i++)
	{
		//3. body of mask name
		sprintf(&buf[0], "%s\r\n", m_mask[i]);
		WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	}

	//4. number of IM
	a = m_IM.GetCount();
	sprintf(&buf[0], "%d\r\n", a);
	WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	
	for(DWORD i=0; i<m_IM.GetCount(); i++)
	{
		//5. body of image name
		sprintf(&buf[0], "%s\r\n", m_IM[i]);
		WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	}

	//6. number of ZP
	a = m_ZP.GetCount();
	sprintf(&buf[0], "%d\r\n", a);
	WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	
	for(DWORD i=0; i<m_ZP.GetCount(); i++)
	{
		//7. body of layer name
		sprintf(&buf[0], "%s\r\n", m_ZP[i]);
		WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	}

	if((strcmp(m_type,"OBIM")==0)||(strcmp(m_type,"OI")==0))
	{
		//8. записываем x
		a = m_xPos;
		sprintf(&buf[0], "x:%d\r\n", a);
		WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
		
		//9. записываем x
		a = m_yPos;
		sprintf(&buf[0], "y:%d\r\n", a);
		WriteFile(hFile, &buf[0], strlen(&buf[0]), &sz, NULL);
	}

	return(0);
}

int CInstructions::LoadAsText(HANDLE hFile)
{
	DWORD a;
	char buf[MAX_PATH]="";

	//1.
	if(ReadString(hFile, &buf[0], MAX_PATH)>0)m_type= strdup(buf);else return(ERR_UNABLE_PARSE_FILE);
	
	//2-3.
	if(ReadString(hFile, &buf[0], MAX_PATH)>0)
	{
		a = atoi(buf);
		for(DWORD i=0; i<a; i++)
			if(ReadString(hFile, &buf[0], MAX_PATH)>0)m_mask.Add(strdup(buf));else return(ERR_UNABLE_PARSE_FILE);
	}
	else return(ERR_UNABLE_PARSE_FILE);

	//4-5
	if(ReadString(hFile, &buf[0], MAX_PATH)>0)
	{
		a = atoi(buf);
		for(DWORD i=0; i<a; i++)
			if(ReadString(hFile, &buf[0], MAX_PATH)>0)m_IM.Add(strdup(buf));else return(ERR_UNABLE_PARSE_FILE);
	}
	else return(ERR_UNABLE_PARSE_FILE);
	
	//6-7
	if(ReadString(hFile, &buf[0], MAX_PATH)>0)
	{
		a = atoi(buf);
		for(DWORD i=0; i<a; i++)
			if(ReadString(hFile, &buf[0], MAX_PATH)>0)m_ZP.Add(strdup(buf));else return(ERR_UNABLE_PARSE_FILE);
	}
	else return(ERR_UNABLE_PARSE_FILE);

	if((strcmp(m_type,"OBIM")==0)||(strcmp(m_type,"OI")==0))
	{
		//8.
		if(ReadString(hFile, &buf[0], MAX_PATH)>0)
		{
			char *bf=strchr(&buf[0], ':');
			if(bf)
			{
				bf++;
				m_xPos= atoi(bf);
			}
		}
		else return(ERR_UNABLE_PARSE_FILE);

		//9.
		if(ReadString(hFile, &buf[0], MAX_PATH)>0)
		{
			char *bf=strchr(&buf[0], ':');
			if(bf)
			{
				bf++;
				m_yPos= atoi(bf);
			}
		}
		else return(ERR_UNABLE_PARSE_FILE);
	}


	return(0);
}

int CInstructions::ReadString(HANDLE hFile, LPTSTR buf, DWORD size)
{
	DWORD sz;
	char ch[2]="";

	ZeroMemory(buf, size);

	int i=0;
	ReadFile(hFile, &ch[0], 1, &sz, NULL);
	if(strcmp(&ch[0],"\r")!=0)
		do
		{
			if(strcmp(&ch[0],"\r")!=0)
			{
				strcat(buf, &ch[0]);
				i++;
			}
			ReadFile(hFile, &ch[0], 1, &sz, NULL);
		}while(strcmp(&ch[0],"\n")!=0);

	return(i);
}