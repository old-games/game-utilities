// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   ImageFile.java

package ru.old_games.veil;

import java.awt.Color;
import java.awt.Point;
import java.awt.image.*;
import java.io.*;
import java.util.Arrays;
import javax.imageio.ImageIO;
import org.apache.commons.io.input.SwappedDataInputStream;
import ru.old_games.centurion.LZW;

// Referenced classes of package ru.old_games.veil:
//            EHFile

public class ImageFile extends EHFile
{

    public byte[] getRawData()
    {
        return rawSprite;
    }

    public byte[] getReadableData()
    {
        byte pallete[] = preparePallete(transparencyColor);
        IndexColorModel icm = new IndexColorModel(8, 256, pallete, 0, true);
        DataBufferByte dataBuffer = new DataBufferByte(rawSprite, rawSprite.length);
        SampleModel sm = icm.createCompatibleSampleModel(width, height);
        WritableRaster raster = Raster.createWritableRaster(sm, dataBuffer, new Point(0, 0));
        BufferedImage bufferedImage = new BufferedImage(width, height, 13, icm);
        bufferedImage.setData(raster);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try
        {
            ImageIO.write(bufferedImage, "png", baos);
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        return baos.toByteArray();
    }

    private static byte[] preparePallete(int transparencyColor)
    {
        byte pallete[] = new byte[1024];
        for(int i = 0; i < 16; i++)
        {
            for(int j = 0; j < 16; j++)
            {
                pallete[(i + j * 16) * 4 + 0] = (byte)(j + i * 16);
                pallete[(i + j * 16) * 4 + 1] = (byte)(j + i * 16);
                pallete[(i + j * 16) * 4 + 2] = (byte)(j + i * 16);
                pallete[(i + j * 16) * 4 + 3] = -1;
            }

        }

        pallete[transparencyColor * 4 + 3] = 0;
        return pallete;
    }

    public ImageFile(byte fileData[], int fileNumber)
        throws EOFException, IOException
    {
        super(fileData, fileNumber);
        spriteCount = 0;
        spriteHeight = 0;
        transparencyColor = 0;
        width = 0;
        height = 0;
        rawSprite = new byte[0];
        ext = "png";
        if(getHeader().length != 12)
            throw new IOException("Not a sprite file - header should be 7 bytes long!");
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(getHeader()));
        sdis.skip(2L);
        sdis.skip(1L);
        sdis.skip(2L);
        spriteCount = sdis.readUnsignedShort();
        spriteHeight = sdis.readUnsignedByte();
        sdis.skip(1L);
        transparencyColor = sdis.readUnsignedByte();
        sdis.close();
        rawSprite = LZW.decompress(getData(), 0, getData().length, 254, false);
        height = spriteHeight * spriteCount;
        width = rawSprite.length / height;
        if(width * height != rawSprite.length)
            throw new IOException("Not a sprite file - can't calculate correct width*height!");
        else
            return;
    }

    public void update(byte pngData[])
    {
        byte pallete[] = preparePallete(transparencyColor);
        int realPallete[] = new int[pallete.length / 4];
        for(int i = 0; i < realPallete.length; i++)
        {
            int red = pallete[i * 4 + 0] >= 0 ? ((int) (pallete[i * 4 + 0])) : 256 + pallete[i * 4 + 0];
            int green = pallete[i * 4 + 1] >= 0 ? ((int) (pallete[i * 4 + 1])) : 256 + pallete[i * 4 + 1];
            int blue = pallete[i * 4 + 2] >= 0 ? ((int) (pallete[i * 4 + 2])) : 256 + pallete[i * 4 + 2];
            int alfa = pallete[i * 4 + 3] >= 0 ? ((int) (pallete[i * 4 + 3])) : 256 + pallete[i * 4 + 3];
            Color oneColor = new Color(red, green, blue, alfa);
            realPallete[i] = oneColor.getRGB();
        }

        byte oldRawSprite[] = rawSprite;
        try
        {
            ByteArrayInputStream bais = new ByteArrayInputStream(pngData);
            BufferedImage bufferedImage = ImageIO.read(bais);
            int pixels[] = new int[bufferedImage.getWidth() * bufferedImage.getHeight()];
            bufferedImage.getRGB(0, 0, bufferedImage.getWidth(), bufferedImage.getHeight(), pixels, 0, bufferedImage.getWidth());
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            for(int i = 0; i < pixels.length; i++)
            {
                int realColor = 0;
                boolean colorFound = false;
                int onePixel = pixels[i];
                for(int j = 0; j < realPallete.length; j++)
                    if(!colorFound && realPallete[j] == onePixel)
                    {
                        realColor = j;
                        colorFound = true;
                    }

                baos.write(realColor);
            }

            baos.close();
            rawSprite = baos.toByteArray();
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        if(!Arrays.equals(oldRawSprite, rawSprite))
            try
            {
                byte packedData[] = LZW.compress(rawSprite, 0, rawSprite.length, 254, false);
                setData(packedData);
            }
            catch(IOException e)
            {
                e.printStackTrace();
            }
    }

    private static final int DEFAULT_HEADER_SIZE = 12;
    private int spriteCount;
    private int spriteHeight;
    private int transparencyColor;
    private int width;
    private int height;
    private byte rawSprite[];
}
