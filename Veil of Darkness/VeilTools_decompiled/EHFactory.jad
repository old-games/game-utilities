// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   EHFactory.java

package ru.old_games.veil;

import java.io.EOFException;
import java.io.IOException;

// Referenced classes of package ru.old_games.veil:
//            ImageFile, FontFile, SoundFile, EHFile

public class EHFactory
{

    public EHFactory()
    {
    }

    public static boolean isEH(byte resource[])
    {
        return resource.length > 2 && resource[0] == 69 && resource[1] == 72;
    }

    public static EHFile getEHFile(byte resource[], int fileNumber)
        throws EOFException, IOException
    {
        if(isEH(resource))
        {
            EHFile result = null;
            switch(resource[2])
            {
            case 1: // '\001'
                result = new ImageFile(resource, fileNumber);
                break;

            case 2: // '\002'
                result = new FontFile(resource, fileNumber);
                break;

            case 4: // '\004'
                result = new SoundFile(resource, fileNumber);
                break;

            case 3: // '\003'
            default:
                result = new EHFile(resource, fileNumber);
                break;
            }
            return result;
        } else
        {
            return null;
        }
    }

    public static final int SIGNATURE_FIRST_BYTE = 69;
    public static final int SIGNATURE_SECOND_BYTE = 72;
    public static final int IMAGE_FILE = 1;
    public static final int FONT_FILE = 2;
    public static final int SOUND_FILE = 4;
}
