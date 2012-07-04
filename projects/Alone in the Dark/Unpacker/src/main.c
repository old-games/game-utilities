#include <stdio.h>
#include <string.h>
#include "pak.h"
#include "unpack.h"

#pragma comment(lib, "zdll.lib")

typedef struct pakInfoStruct // warning: allignement unsafe
{
  long int discSize;
  long int uncompressedSize;
  char compressionFlag;
  char info5;
  short int offset;
};

typedef struct pakInfoStruct pakInfoStruct;

void readPakInfo(pakInfoStruct* pPakInfo, FILE* fileHandle)
{
  fread(&pPakInfo->discSize,4,1,fileHandle);
  fread(&pPakInfo->uncompressedSize,4,1,fileHandle);
  fread(&pPakInfo->compressionFlag,1,1,fileHandle);
  fread(&pPakInfo->info5,1,1,fileHandle);
  fread(&pPakInfo->offset,2,1,fileHandle);
}

unsigned int PAK_getNumFiles(char* name)
{
//  char bufferName[256];
  FILE* fileHandle;
  long int fileOffset;
  char* ptr=0;
  long int size=0;

 // strcpy(bufferName, name); // temporary until makeExtention is coded
  
  fileHandle = fopen(name,"rb");
  fseek(fileHandle,4,SEEK_CUR);
  fread(&fileOffset,4,1,fileHandle);
  fclose(fileHandle);

  return((fileOffset/4)-2);
}

int getPakSize(char* name, int index)
{
 // char bufferName[256];
  FILE* fileHandle;
  long int fileOffset;
  long int additionalDescriptorSize;
  pakInfoStruct pakInfo;
  char* ptr=0;
  long int size=0;

 // strcpy(bufferName, name); // temporary until makeExtention is coded
  fileHandle = fopen(name,"rb");
  if(fileHandle) // a bit stupid, should return NULL right away
  {
    fseek(fileHandle,(index+1)*4,SEEK_SET);

    fread(&fileOffset,4,1,fileHandle);
    fseek(fileHandle,fileOffset,SEEK_SET);
    fread(&additionalDescriptorSize,4,1,fileHandle);
    readPakInfo(&pakInfo,fileHandle);
    fseek(fileHandle,pakInfo.offset,SEEK_CUR);

    if(pakInfo.compressionFlag == 0) // uncompressed
    {
      size = pakInfo.discSize;
    }
    else if(pakInfo.compressionFlag == 1) // compressed
    {
      size = pakInfo.uncompressedSize;
    }
    else if(pakInfo.compressionFlag == 4)
    {
      size = pakInfo.uncompressedSize;
    }
    fclose(fileHandle);
  }
  return size;
}

int main(int argc, char** argv)
{
	char pakname[256];
    char unpakname[256];
	char nameBuffer[256];
	unsigned int num_files;
	int index;
	long int fileOffset;
    long int additionalDescriptorSize;
	pakInfoStruct pakInfo;
    unsigned char* ptr=0;
	FILE* pakfile;
	FILE* outfile;
	printf("Alone in the dark PAK Unpacker v.021\n");
	printf("Programming: Alias (mailto:alias@211.ru)\n");
	printf("Input name of PAK-file: ");
	scanf("%s", pakname);
    pakfile = fopen(pakname, "rb");

	if(!pakfile)
	{
		printf("Error: file %s not found", pakname);
		exit(1);
	}
	num_files = PAK_getNumFiles(pakname);
	for(index = 0; index <= num_files; index++)
		{
			sprintf(unpakname,"%s_%d.out", pakname, index);
			outfile = fopen(unpakname, "wb");
            fseek(pakfile,(index+1)*4,SEEK_SET);
            fread(&fileOffset,4,1,pakfile);            
            fseek(pakfile,fileOffset,SEEK_SET);
            fread(&additionalDescriptorSize,4,1,pakfile);
			if(additionalDescriptorSize != 0)
			{
				
			    fseek(pakfile,additionalDescriptorSize-4,SEEK_CUR);
			}
    
			readPakInfo(&pakInfo,pakfile);
			if(pakInfo.offset)
			{
				fread(pakfile,pakInfo.offset,1,pakfile);
			}
			else
			{
				fseek(pakfile,pakInfo.offset,SEEK_CUR);
			}
			switch(pakInfo.compressionFlag)
			{
			case 0:
				{
					ptr = (char*)malloc(pakInfo.discSize);
                    fread(ptr,pakInfo.discSize,1,pakfile);
		            fwrite(ptr,pakInfo.discSize,1,outfile); //Unpacker code
	                break;
				}
			case 1:
				{
					char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
                    fread(compressedDataPtr, pakInfo.discSize, 1, pakfile);
                    ptr = (char *) malloc(pakInfo.uncompressedSize);
                    PAK_explode(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize, pakInfo.info5);
    
		            fwrite(ptr,pakInfo.uncompressedSize,1,outfile);//Unpacker code
		            free(compressedDataPtr);
                    break;
               }
           case 4:
               {
                    char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
                    fread(compressedDataPtr, pakInfo.discSize, 1, pakfile);
                    ptr = (char *) malloc(pakInfo.uncompressedSize);
                    PAK_deflate(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize);
                    fwrite(ptr,pakInfo.uncompressedSize,1,outfile); //Unpacker code
                    free(compressedDataPtr);
                    break;
              }
			
			   fclose(outfile);
			}
		}
	printf("File %s succesfully unpacked", pakname);
	fclose(pakfile);
}