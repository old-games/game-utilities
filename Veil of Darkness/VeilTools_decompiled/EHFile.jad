// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   EHFile.java

package ru.old_games.veil;

import java.io.*;
import java.util.Arrays;
import org.apache.commons.io.input.SwappedDataInputStream;

public class EHFile
{

    public EHFile(byte fileData[], int fileNumber)
        throws EOFException, IOException
    {
        type = 0;
        ext = "unk";
        this.fileNumber = 0;
        header = new byte[0];
        data = new byte[0];
        this.fileNumber = fileNumber;
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(fileData));
        sdis.skip(2L);
        type = sdis.read();
        int headerSize = sdis.readUnsignedShort();
        header = Arrays.copyOf(fileData, 5 + headerSize);
        sdis.skip(headerSize);
        data = new byte[fileData.length - 2 - 1 - 2 - headerSize];
        sdis.read(data);
        sdis.close();
    }

    public String getExt()
    {
        return ext;
    }

    public void setExt(String ext)
    {
        this.ext = ext;
    }

    public int getType()
    {
        return type;
    }

    public void setType(int type)
    {
        this.type = type;
    }

    public int getFileNumber()
    {
        return fileNumber;
    }

    public void setFileNumber(int fileNumber)
    {
        this.fileNumber = fileNumber;
    }

    public byte[] getHeader()
    {
        return header;
    }

    public void setHeader(byte header[])
    {
        this.header = header;
    }

    public byte[] getData()
    {
        return data;
    }

    public void setData(byte data[])
    {
        this.data = data;
    }

    public byte[] getReadableData()
    {
        return new byte[0];
    }

    public byte[] getRawData()
    {
        return new byte[0];
    }

    public byte[] getEncodedData()
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try
        {
            baos.write(getHeader());
            baos.write(getData());
            baos.close();
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        return baos.toByteArray();
    }

    public void update(byte abyte0[])
    {
    }

    private int type;
    protected String ext;
    private int fileNumber;
    protected byte header[];
    protected byte data[];
}
