// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ResourceConverter.java

package ru.old_games.veil;

import java.io.*;
import java.util.*;

// Referenced classes of package ru.old_games.veil:
//            LibFile, EHFactory, EHFile

public class ResourceConverter
{

    public ResourceConverter()
    {
    }

    public static void extract(String fileName, boolean needDebug, boolean isInteract)
        throws IOException
    {
        File file = new File(fileName);
        byte libFileBody[] = new byte[(int)file.length()];
        FileInputStream fis = new FileInputStream(file);
        fis.read(libFileBody);
        fis.close();
        LibFile libFile = new LibFile(libFileBody, 4, isInteract);
        List resources = libFile.getResources();
        File newFile = new File((new StringBuilder(String.valueOf(fileName))).append(".files").toString());
        newFile.mkdir();
        int fileNumber = 0;
        for(Iterator iterator = resources.iterator(); iterator.hasNext();)
        {
            byte resource[] = (byte[])iterator.next();
            String newFileName = (new StringBuilder(String.valueOf(newFile.getAbsolutePath()))).append(File.separator).append(Integer.toHexString(fileNumber)).toString();
            if(EHFactory.isEH(resource))
            {
                try
                {
                    System.out.println((new StringBuilder("Extracting file ")).append(Integer.toHexString(fileNumber)).toString());
                    EHFile ehFile = EHFactory.getEHFile(resource, fileNumber);
                    FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(newFileName))).append(".").append(ehFile.getExt()).toString());
                    fos.write(ehFile.getReadableData());
                    fos.close();
                    if(needDebug)
                    {
                        fos = new FileOutputStream((new StringBuilder(String.valueOf(newFileName))).append(".raw").toString());
                        fos.write(ehFile.getRawData());
                        fos.close();
                        fos = new FileOutputStream((new StringBuilder(String.valueOf(newFileName))).append(".").append(ehFile.getType()).append(".eh").toString());
                        fos.write(ehFile.getEncodedData());
                        fos.close();
                    }
                }
                catch(IOException e)
                {
                    System.err.println((new StringBuilder("Error while unpacking file #")).append(Integer.toHexString(fileNumber)).toString());
                    e.printStackTrace();
                }
            } else
            {
                FileOutputStream fos = new FileOutputStream(newFileName);
                fos.write(resource);
                fos.close();
            }
            fileNumber++;
        }

    }

    public static void update(String fileName)
        throws IOException
    {
        File file = new File(fileName);
        byte libFileBody[] = new byte[(int)file.length()];
        FileInputStream fis = new FileInputStream(file);
        fis.read(libFileBody);
        fis.close();
        LibFile libFile = new LibFile(libFileBody, 4, false);
        List resources = libFile.getResources();
        File newFile = new File((new StringBuilder(String.valueOf(fileName))).append(".files").toString());
        int fileNumber = 0;
        for(int i = 0; i < resources.size(); i++)
        {
            byte resource[] = (byte[])resources.get(i);
            String newFileName = (new StringBuilder(String.valueOf(newFile.getAbsolutePath()))).append(File.separator).append(Integer.toHexString(fileNumber)).toString();
            if(EHFactory.isEH(resource))
                try
                {
                    EHFile ehFile = EHFactory.getEHFile(resource, fileNumber);
                    File newFilePng = new File((new StringBuilder(String.valueOf(newFileName))).append(".").append(ehFile.getExt()).toString());
                    if(newFilePng.exists())
                    {
                        FileInputStream pngFileStream = new FileInputStream(newFilePng);
                        byte pngBytes[] = new byte[(int)newFilePng.length()];
                        pngFileStream.read(pngBytes);
                        pngFileStream.close();
                        EHFile newEhFile = EHFactory.getEHFile(resource, fileNumber);
                        newEhFile.update(pngBytes);
                        if(!Arrays.equals(ehFile.getRawData(), newEhFile.getRawData()))
                        {
                            System.out.println((new StringBuilder("Have to update file ")).append(Integer.toHexString(fileNumber)).toString());
                            resources.set(i, newEhFile.getEncodedData());
                        }
                    }
                }
                catch(IOException e)
                {
                    System.err.println((new StringBuilder("Error while unpacking file #")).append(Integer.toHexString(fileNumber)).toString());
                    e.printStackTrace();
                }
            fileNumber++;
        }

        byte result[] = libFile.composeLibFile();
        FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(fileName))).append(".new").toString());
        fos.write(result);
        fos.close();
    }
}
