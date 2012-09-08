//-f:OBIM_0017 -d -s:d:\abwork\ruscumm\work\dumps\disk_0001\lecf\lflf_0001\Room -p:d:\abwork\ruscumm\work\dumps\disk_0001\lecf\lflf_0001\Room
//-f:BM -d -s:d:\abwork\ruscumm\work_old\dumps\lf_0001\Ro -p:d:\abwork\ruscumm\work_old\dumps\lf_0001\Ro
//-f:*.* -d -s:d:\abwork\ruscumm\work_old\dumps\lf_0004\Ro -p:d:\abwork\ruscumm\work_old\dumps\lf_0001\Ro

#include "stdafx.h"

#include "CMDParser.h"
#include "Chunk.h"
#include "Decoder.h"
#include "Encoder.h"
CCMDParser	cmd;

int main(int argc, char* argv[])
{

	CChunk*		chunk; chunk=NULL;
	CDecoder*	decoder; decoder= NULL;
	CEncoder*	encoder; encoder=NULL;
	int err;

	if(cmd.ParseOk(argc, argv))
	{
		for(int i=0; i< cmd.GetFilesCount(); i++)
		{
			delete decoder; decoder=NULL;
			delete encoder; encoder=NULL;
			delete chunk; chunk=NULL;
			int operation = cmd.m_operation;
			char errdescr[100]={0};
			if(operation==1)
			{
				//Decode
				/*--OUT*/printf("\r\n=============================== DECODE ==========================");
				chunk = new CChunk();
				/*--OUT*/printf("\r\nLoad file: %s\\%s", cmd.GetSrcPath(), cmd.GetNextFilename());
				err= chunk->Load(cmd.GetSrcPath(), cmd.GetCurrentFilename());
				
				if(!err)
				{
					decoder = new CDecoder();
					/*--OUT*/printf("\r\nInitialize decoder");
					err = decoder->Init(chunk, &cmd, errdescr);
					if(!err)
						err= decoder->Run();
				}
			}
			else if(operation==2)
			{
				//Encode
				printf("\r\n=============================== ENCODE ==========================");
				/*--OUT*/printf("\r\nLoad file: %s\\%s", cmd.GetSrcPath(), cmd.GetNextFilename());
				encoder = new CEncoder();
				/*--OUT*/printf("\r\nInitialize encoder");
				err = encoder->Init(&cmd,errdescr);
				if(!err)
					err= encoder->Run();
			}

			switch(err){
				case 0: break;
				case ERR_UNSUPPORTED_BLOCK:
					/*--OUT*/printf("\tunsupported block %s",errdescr);
					break;
				case ERR_NEEDED_BLOCK_NOT_FOUND:
					/*--OUT*/printf("\tNeed block absent");
					break;
				case ERR_UNABLE_LOAD_FILE:
					/*--OUT*/printf("\r\n\tUnable load file");
					break;
				case ERR_UNABLE_SAVE_FILE:
					/*--OUT*/printf("\r\n\tUnable save file");
				case ERR_UNABLE_PARSE_FILE:
					/*OUT*/printf("\r\n\tunable parse ins file");
					break;
				case ERR_NULL_OBJECT:
					/*--OUT*/printf("\tunsupported type of target chunk");
					break;
				case ERR_UNSUPPORTED_TYPE:
					/*--OUT*/printf("\tunsupported type of target chunk %s",errdescr);
					break;
				case ERR_BAD_WIDTH_OR_HEIGHT:
					/*OUT*/printf("\r\n\tBad width or height");
					break;
				case ERR_BAD_WIDTH_NOT_M_PRESENT:
					/*OUT*/printf("\r\n\tBad width or height was changed but key -m not present");
					break;
				case ERR_BAD_X_OR_Y:
					/*OUT*/printf("\r\n\tBad position of object");
					break;
				case ERR_INS_FILE_CORRUPT:
					/*OUT*/printf("\r\n\tNot enought information into ins file");
					break;
				case ERR_NOT_INS_FILE:
					/*--OUT*/printf("\r\n\tNot ins file");
					break;
				case ERR_PALETTE_FILE_CORRUPT:
					/*OUT*/printf("\r\n\tUnsupported palette file format");
					break;
				default:
					/*--OUT*/printf("\r\n\tUnknown error: %.4d", err);
					break;
			}
			if(cmd.m_special_stop==1)
			{
				if((err!=0)&&(err!= ERR_NOT_INS_FILE)&&(err!= ERR_UNSUPPORTED_BLOCK))
					_getch();
			}
			else
			{
				if(err)
					_getch();
			}
		}
	}

	printf("\r\n================================= DONE =====================================\r\n");
	getch();
	return 0;
}