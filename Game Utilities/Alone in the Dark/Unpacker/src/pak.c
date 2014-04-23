// seg 55

#include "common.h"
#include "pak.h"
#include "unpack.h"

typedef struct pakInfoStruct // warning: allignement unsafe
{
  long int discSize;
  long int uncompressedSize;
  char compressionFlag;
  char info5;
  short int offset;
};

typedef struct pakInfoStruct pakInfoStruct;

//#define USE_UNPACKED_DATA

/*void readPakInfo(pakInfoStruct* pPakInfo, FILE* fileHandle)
{
  fread(&pPakInfo->discSize,4,1,fileHandle);
  fread(&pPakInfo->uncompressedSize,4,1,fileHandle);
  fread(&pPakInfo->compressionFlag,1,1,fileHandle);
  fread(&pPakInfo->info5,1,1,fileHandle);
  fread(&pPakInfo->offset,2,1,fileHandle);

  pPakInfo->discSize = READ_LE_U32(&pPakInfo->discSize);
  pPakInfo->uncompressedSize = READ_LE_U32(&pPakInfo->uncompressedSize);
  pPakInfo->offset = READ_LE_U16(&pPakInfo->offset);
}

unsigned int PAK_getNumFiles(char* name)
{
  char bufferName[256];
  FILE* fileHandle;
  long int fileOffset;
  char* ptr=0;
  long int size=0;

  strcpy(bufferName, name); // temporary until makeExtention is coded
  strcat(bufferName,".PAK");

  fileHandle = fopen(bufferName,"rb");

  ASSERT(fileHandle);

  fseek(fileHandle,4,SEEK_CUR);
  fread(&fileOffset,4,1,fileHandle);
#ifdef MACOSX
  fileOffset = READ_LE_U32(&fileOffset);
#endif
  fclose(fileHandle);

  return((fileOffset/4)-2);
}*/

int loadPakToPtr(char* name, int index, char* ptr)
{
#ifdef USE_UNPACKED_DATA
  char buffer[256];
  FILE* fHandle;
  int size;

  sprintf(buffer,"%s/%04X.OUT",name,index);

  fHandle = fopen(buffer,"rb");

  if(!fHandle)
    return(0);

  fseek(fHandle,0L,SEEK_END);
  size = ftell(fHandle);
  fseek(fHandle,0L,SEEK_SET);

  fread(ptr,size,1,fHandle);
  fclose(fHandle);

  return(1);
#else
  char* lptr;

  lptr = loadPak(name,index);

  memcpy(ptr,lptr,getPakSize(name,index));

  free(lptr);

  return(1);
#endif
}
/*
int getPakSize(char* name, int index)
{

  char bufferName[256];
  FILE* fileHandle;
  long int fileOffset;
  long int additionalDescriptorSize;
  pakInfoStruct pakInfo;
  char* ptr=0;
  long int size=0;

  strcpy(bufferName, name); // temporary until makeExtention is coded
  strcat(bufferName,".PAK");

  fileHandle = fopen(bufferName,"rb");
  
  if(fileHandle) // a bit stupid, should return NULL right away
  {
    fseek(fileHandle,(index+1)*4,SEEK_SET);

    fread(&fileOffset,4,1,fileHandle);
#ifdef MACOSX
    fileOffset = READ_LE_U32(&fileOffset);
#endif
    fseek(fileHandle,fileOffset,SEEK_SET);

    fread(&additionalDescriptorSize,4,1,fileHandle);
#ifdef MACOSX
    additionalDescriptorSize = READ_LE_U32(&additionalDescriptorSize);
#endif

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
*/
char* loadPak(char* name, int index)
{
#ifdef USE_UNPACKED_DATA
  char buffer[256];
  FILE* fHandle;
  int size;
  char* ptr;

  sprintf(buffer,"%s/%04X.OUT",name,index);

  fHandle = fopen(buffer,"rb");

  if(!fHandle)
    return NULL;

  fseek(fHandle,0L,SEEK_END);
  size = ftell(fHandle);
  fseek(fHandle,0L,SEEK_SET);

  ptr = (char*)malloc(size);

  fread(ptr,size,1,fHandle);
  fclose(fHandle);

  return ptr;
#else
  char bufferName[256];
  char bufferName2[256];//Need for Pak Unpacker
  FILE* fileHandle;
  FILE* outfile;   //Need for Pak Unpacker
  long int fileOffset;
  long int additionalDescriptorSize;
  int num_files;  //Need for Pak Unpacker
  pakInfoStruct pakInfo;
  char* ptr=0;
  int len=0;

  //makeExtention(bufferName, name, ".PAK");
  strcpy(bufferName, name); // temporary until makeExtention is coded
  strcat(bufferName,".PAK");

  fileHandle = fopen(bufferName,"rb");
 fseek(fileHandle,0L,SEEK_END);
  len = ftell(fileHandle);
  fseek(fileHandle,0L,SEEK_SET);
  
  if(fileHandle) // a bit stupid, should return NULL right away
  {
    char nameBuffer[256];
    //Unpacker code BEGIN
	char nameBuffer2[256]; 
	sprintf(nameBuffer2,"%s_%d.out",name,index);
	num_files=PAK_getNumFiles(name);
	outfile=fopen(nameBuffer2,"wb");
	//Unpacker code END
	fseek(fileHandle,(index+1)*4,SEEK_SET);

    fread(&fileOffset,4,1,fileHandle);

#ifdef MACOSX
    fileOffset = READ_LE_U32(&fileOffset);
#endif

    fseek(fileHandle,fileOffset,SEEK_SET);

    fread(&additionalDescriptorSize,4,1,fileHandle);
    fseek(fileHandle,additionalDescriptorSize-4,SEEK_CUR);
    len = ftell(fileHandle);
	printf ("File %x\n",len);
#ifdef MACOSX
    additionalDescriptorSize = READ_LE_U32(&additionalDescriptorSize);
#endif

    readPakInfo(&pakInfo,fileHandle);
	printf ("File %s\n",nameBuffer2);

    if(pakInfo.offset)
    {
      ASSERT(pakInfo.offset<256);

      fread(nameBuffer,pakInfo.offset,1,fileHandle);
#ifdef INTERNAL_DEBUGGER
      printf("Loading %s/%s\n", name,nameBuffer+2);
#endif
    }
    else
    {
      fseek(fileHandle,pakInfo.offset,SEEK_CUR);
    }

    switch(pakInfo.compressionFlag)
    {
    case 0:
      {
        ptr = (char*)malloc(pakInfo.discSize);
        fread(ptr,pakInfo.discSize,1,fileHandle);
		
       // fwrite(ptr,pakInfo.discSize,1,outfile); //Unpacker code
		
		break;
      }
    case 1:
      {
        char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
        fread(compressedDataPtr, pakInfo.discSize, 1, fileHandle);
        ptr = (char *) malloc(pakInfo.uncompressedSize);
        PAK_explode(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize, pakInfo.info5);
    
		//fwrite(ptr,pakInfo.uncompressedSize,1,outfile);//Unpacker code
		free(compressedDataPtr);
        break;
      }
    case 4:
      {
        char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
        fread(compressedDataPtr, pakInfo.discSize, 1, fileHandle);
        ptr = (char *) malloc(pakInfo.uncompressedSize);

        PAK_deflate(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize);
       // fwrite(ptr,pakInfo.uncompressedSize,1,outfile); //Unpacker code
        free(compressedDataPtr);
        break;
      }
    }
    fclose(fileHandle);//Compressed pak-file close
	fclose(outfile); //Uncompressed file close
  }

  return ptr;
#endif
}


/*char* loadPak(char* name, int index)
{
  char bufferName[256];
  char bufferName2[256];//Need for Pak Unpacker
  FILE* fileHandle;
  FILE* infile;   //Need for Pak Unpacker
  long int fileOffset;
  long int additionalDescriptorSize;
  int num_files;  //Need for Pak Unpacker
  pakInfoStruct pakInfo;
  char* ptr=0;
  int len=0;

  sprintf(bufferName,"%s_0.out",name);
  fileHandle = fopen(bufferName,"rb+");
  
  strcpy(bufferName2, name); // temporary until makeExtention is coded
  strcat(bufferName2,"MY.PAK");

  infile = fopen(bufferName2,"rb+");
 
  if(fileHandle) // a bit stupid, should return NULL right away
  {
    char nameBuffer[256];
    //Unpacker code BEGIN
	char nameBuffer2[256]; 
	//sprintf(nameBuffer2,"%s_%d.out",name,index);
	//num_files=PAK_getNumFiles(name);
	//Unpacker code END
//	fseek(infile,(0+1)*4,SEEK_SET);

  //  fread(&fileOffset,4,1,infile);



    fseek(infile,104,SEEK_SET);

   // fwrite(0x00,1,1,infile);
    fseek(infile,92,SEEK_SET);

    readPakInfo(&pakInfo,infile);
//	printf ("File %s\ndiscsize %d\nuncompressed size %d\nflag %d\ninfo5 %d\noffset %d\n",nameBuffer2,pakInfo.discSize,pakInfo.uncompressedSize,pakInfo.compressionFlag,pakInfo.offset);

    if(pakInfo.offset)
    {
      ASSERT(pakInfo.offset<256);

      fread(nameBuffer,pakInfo.offset,1,infile);
    }
    else
    {
      fseek(infile,pakInfo.offset,SEEK_CUR);
    }

    switch(pakInfo.compressionFlag)
    {
    case 0:
      {
        ptr = (char*)malloc(pakInfo.discSize);
        fread(ptr,pakInfo.discSize,1,infile);
		
        fwrite(ptr,pakInfo.discSize,1,infile); //Unpacker code
		
		break;
      }
    case 1:
      {
        char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
        
		fread(compressedDataPtr, pakInfo.discSize, 1, infile);
        ptr = (char *) malloc(pakInfo.uncompressedSize);
        PAK_explode(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize, pakInfo.info5);
    
		fwrite(ptr,pakInfo.uncompressedSize,1,infile);//Unpacker code
		free(compressedDataPtr);
        break;
      }
    case 4:
      {
        char * compressedDataPtr = (char *) malloc(pakInfo.discSize);
        fread(compressedDataPtr, pakInfo.discSize, 1, infile);
        ptr = (char *) malloc(pakInfo.uncompressedSize);

        PAK_deflate(compressedDataPtr, ptr, pakInfo.discSize, pakInfo.uncompressedSize);
        fwrite(ptr,pakInfo.uncompressedSize,1,infile); //Unpacker code
        free(compressedDataPtr);
        break;
      }
    }
    fclose(fileHandle);//Compressed pak-file close
	fclose(infile); //Uncompressed file close
  }

  return ptr;
}*/
