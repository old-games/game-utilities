// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   LibFile.java

package ru.old_games.veil;

import java.io.*;
import java.util.ArrayList;
import java.util.List;
import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.input.SwappedDataInputStream;

public class LibFile
{

    public List getResources()
    {
        return resources;
    }

    public void setResources(List newResources)
    {
        resources = newResources;
    }

    private int readFatRecord(SwappedDataInputStream sdis)
        throws EOFException, IOException
    {
        int result = -1;
        if(fatRecordSize == 2)
            result = sdis.readUnsignedShort();
        else
            result = sdis.readInt();
        return result;
    }

    private void writeFatRecord(OutputStream os, int value)
        throws IOException
    {
        if(fatRecordSize == 2)
            EndianUtils.writeSwappedShort(os, (short)value);
        else
            EndianUtils.writeSwappedInteger(os, value);
    }

    public LibFile(int fatRecordSize)
    {
        this.fatRecordSize = fatRecordSize;
        resources = new ArrayList();
    }

    public LibFile(byte libFile[], int fatRecordSize, boolean isInteract)
        throws IOException
    {
        this(fatRecordSize);
        this.isInteract = isInteract;
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(libFile));
        int fileSize = libFile.length;
        int fileCount = readFatRecord(sdis);
        if(isInteract)
            fileCount &= 0xffff;
        byte fat[] = new byte[fileCount * fatRecordSize];
        sdis.read(fat);
        SwappedDataInputStream fatIS = new SwappedDataInputStream(new ByteArrayInputStream(fat));
        int filePos = readFatRecord(fatIS);
        int nextFilePos = 0;
        for(int i = 0; i < fileCount; i++)
        {
            if(i < fileCount - 1)
                nextFilePos = readFatRecord(fatIS);
            else
                nextFilePos = fileSize;
            byte oneFileBody[] = new byte[nextFilePos - filePos];
            sdis.read(oneFileBody);
            resources.add(oneFileBody);
            filePos = nextFilePos;
        }

        fatIS.close();
        sdis.close();
    }

    public byte[] composeLibFile()
        throws IOException
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        if(isInteract)
            writeFatRecord(baos, resources.size() + 0xee0000);
        else
            writeFatRecord(baos, resources.size());
        int position = fatRecordSize + resources.size() * fatRecordSize;
        for(int i = 0; i < resources.size(); i++)
        {
            writeFatRecord(baos, position);
            position += ((byte[])resources.get(i)).length;
        }

        for(int i = 0; i < resources.size(); i++)
            baos.write((byte[])resources.get(i));

        baos.close();
        return baos.toByteArray();
    }

    private List resources;
    private int fatRecordSize;
    private boolean isInteract;
}
