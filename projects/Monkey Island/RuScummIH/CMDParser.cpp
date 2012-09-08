// CMDParser.cpp: implementation of the CCMDParser class.
//
//////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "CMDParser.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CCMDParser::CCMDParser()
{
	m_operation = 0;    //0-nothing, 1-decode, 2-encode
	m_special_stop = 0; //0-stop all, 1-stop only on 2 errors
	m_srcPath = NULL;
	m_dstPath = NULL;
	m_filename=NULL;
	current=-1;
	m_encodemask= FALSE;
}

CCMDParser::~CCMDParser()
{
	free(m_srcPath);
	free(m_dstPath);
	free(m_filename);
}

BOOL CCMDParser::IsEncodeMask()
{
	return(m_encodemask);
}

LPTSTR CCMDParser::GetNextFilename()
{
	if(m_files.GetCount()<=0)return NULL;
	current++;
	return(m_files[current]);
}

LPTSTR CCMDParser::GetCurrentFilename()
{
	if(m_files.GetCount()<=0)return NULL;

	return(m_files[current>=0?current:0]);
}

LPTSTR CCMDParser::GetSrcPath()
{
	return m_srcPath;
}

LPTSTR CCMDParser::GetDstPath()
{
	return m_dstPath;
}

int CCMDParser::GetFilesCount()
{
	return m_files.GetCount()>0?m_files.GetCount():1;
}

/*int CCMDParser::GetX()
{
	return(m_x);
};

int CCMDParser::GetY()
{
	return(m_y);
};

void CCMDParser::SetX(int x)
{
	m_x = x;
};

void CCMDParser::SetY(int y)
{
	m_y = y;
};*/


BOOL CCMDParser::FindAllFiles()
{
	//Ищем все имена по шаблону в заданной маске
	LPTSTR path = (LPTSTR)malloc(strlen(m_srcPath)+strlen(m_filename)+2);
	sprintf(path, "%s\\%s", m_srcPath, m_filename);
	WIN32_FIND_DATA wfd;
 	HANDLE hFile= FindFirstFile(path, &wfd);
	if(hFile==INVALID_HANDLE_VALUE)
	{
		printf("File %s not found\r\n", m_filename);
		return FALSE;
	}
	
	//Добавляем в массив первый найденный файл и последующие найденные
	if(strcmp(wfd.cFileName,".")!=0)m_files.Add(strdup(wfd.cFileName));
	while(FindNextFile(hFile, &wfd))
		if(strcmp(wfd.cFileName,"..")!=0)m_files.Add(strdup(wfd.cFileName));
	
	FindClose(hFile);
	free(path);

	return(TRUE);
}

BOOL CCMDParser::ParseOk(int argc, char* argv[])
{
	BOOL ok=TRUE;
	//Разбираем командную строку
	for(int i=1; i<argc; i++)
	{
		switch(MAKEWORD('-',*(argv[i]+1))){
			case MAKEWORD('-', 'f'):
			case MAKEWORD('-', 'F'):
				if(!m_filename)
					if(strlen(argv[i])>3)
						m_filename = strdup(argv[i]+3);
					else 
					{
						printf("Bad parameter for key -f\r\n");
						ok=FALSE;
					}
				else 
					printf("Please, specify only one filename!\r\n");
				break;
			case MAKEWORD('-', 'h'):
			case MAKEWORD('-', 'H'):m_special_stop=1; break;
			case MAKEWORD('-', 'd'):
			case MAKEWORD('-', 'D'):m_operation=1; break;
			case MAKEWORD('-', 'e'):
			case MAKEWORD('-', 'E'):m_operation=2; break;
			case MAKEWORD('-', 's'):
			case MAKEWORD('-', 'S'):
				if(!m_srcPath)
					if(strlen(argv[i])>3)
						m_srcPath = strdup(argv[i]+3);
					else 
					{
						printf("Bad parameter for key -s\r\n");
						ok=FALSE;
					}
				break;
			case MAKEWORD('-', 'p'):
			case MAKEWORD('-', 'P'):
				if(!m_dstPath)
					if(strlen(argv[i])>3)
						m_dstPath = strdup(argv[i]+3);
					else 
					{
						printf("Bad parameter for key -s\r\n");
						ok=FALSE;
					}
				break;
			case MAKEWORD('-', 'm'):
			case MAKEWORD('-', 'M'):
				m_encodemask= TRUE;
				break;
			default: 
				printf("Unknown key %s\r\n", argv[i]);
				ok=FALSE;
		}
	}
	if(!m_filename)
	{
		printf("Please, specify source file\r\n");
		ok=FALSE;
	}
	if(!m_srcPath&&ok)
	{
		m_srcPath = (char*)malloc(MAX_PATH);
		GetCurrentDirectory(MAX_PATH, m_srcPath);
	}
	if(!m_dstPath&&ok)
	{
		m_dstPath = (char*)malloc(MAX_PATH);
		GetCurrentDirectory(MAX_PATH, m_dstPath);
	}
	if(!m_operation)
	{
		printf("Please, specify action!\r\n");
		ok=FALSE;
	}
	/*if(m_operation==2&&!m_type)
	{
		printf("Please, specify type of target chunk!\r\n");
		ok=FALSE;
	}*/

	if(m_srcPath)
	{
		LPTSTR tmp= (m_srcPath+strlen(m_srcPath)-1);
		while(*tmp=='\\')*tmp--=0;
	}
	
	if(m_dstPath)
	{
		LPTSTR tmp= (m_dstPath+strlen(m_dstPath)-1);
		while(*tmp=='\\')*tmp--=0;
	}

	//Производим обработку введенного имени и делаем выводы;
	if(ok)ok=FindAllFiles();
	
	if(argc<2)
	{
		printf("Ver. 9.7.40b \r\n");
		printf("Programmed by Pavel A. Rumyantsev\r\n");
		printf("usage:\r\n");
		printf("ruscummih {-f:filename}{-d or -e} [-m] [s:path] [p:path]\r\n");
		printf("\t-f:filename\t- specify the source file name\r\n");
		printf("\t-d\t- decode chunk in the source file\r\n");
		printf("\t-e\t- encode BMP in the source file\r\n");
		printf("\t-m\t- encode mask\r\n");
		printf("\t-s:path\t- path to the source folder\n");
		printf("\t-p:path\t- path to the destination folder\n");
	}
	return(ok);
}