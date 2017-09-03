// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   SoundFile.java

package ru.old_games.veil;

import java.io.*;
import java.util.Arrays;
import org.apache.commons.io.input.SwappedDataInputStream;

// Referenced classes of package ru.old_games.veil:
//            EHFile

public class SoundFile extends EHFile
{

    public byte[] getRawData()
    {
        return getData();
    }

    public byte[] getReadableData()
    {
        byte result[] = Arrays.copyOfRange(data, 4, data.length);
        return result;
    }

    public SoundFile(byte fileData[], int fileNumber)
        throws EOFException, IOException
    {
        super(fileData, fileNumber);
        ext = "voc";
        if(getHeader().length != 5)
            throw new IOException("Not a sound file - header not empty!");
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(getData()));
        int bodySize = sdis.readInt();
        if(bodySize != getData().length - 4)
        {
            throw new IOException("wrong [body size] for Sound file");
        } else
        {
            sdis.close();
            return;
        }
    }

    private static final int DEFAULT_HEADER_SIZE = 5;
}
