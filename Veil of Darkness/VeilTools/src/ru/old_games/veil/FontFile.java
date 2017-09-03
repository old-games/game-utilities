// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FontFile.java

package ru.old_games.veil;

import java.awt.Color;
import java.awt.Point;
import java.awt.image.*;
import java.io.*;
import java.util.Arrays;
import javax.imageio.ImageIO;
import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.input.SwappedDataInputStream;
import ru.old_games.centurion.LZW;

// Referenced classes of package ru.old_games.veil:
//            EHFile

public class FontFile extends EHFile
{

    public byte[] getRawData()
    {
        return rawFont;
    }

    public byte[] getReadableData()
    {
        byte pallete[] = preparePallete(transparencyColor, getFileNumber());
        IndexColorModel icm = new IndexColorModel(8, 256, pallete, 0, true);
        int maxHeight = charCount * (charHeight + 2);
        int maxWidth = 10;
        byte fontImage[] = new byte[maxWidth * maxHeight];
        for(int y = 0; y < maxHeight; y++)
        {
            fontImage[y * maxWidth + 0] = 2;
            fontImage[y * maxWidth + 9] = 2;
        }

        int rowNumber = 0;
        for(int y = 0; y < maxHeight; y++)
        {
            if(rowNumber == charHeight + 1 || rowNumber == 0)
            {
                for(int x = 0; x < maxWidth; x++)
                    fontImage[y * maxWidth + x] = 2;

            }
            if(++rowNumber > charHeight + 1)
                rowNumber = 0;
        }

        try
        {
            SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(rawFont));
            for(int i = 0; i < charCount; i++)
            {
                for(int j = 0; j < charHeight; j++)
                {
                    for(int k = 0; k < 8; k++)
                    {
                        byte onePixel = sdis.readByte();
                        fontImage[10 * (charHeight + 2) * i + (k + 1) + (j + 1) * 10] = onePixel;
                    }

                }

            }

            sdis.close();
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        for(int i = 0; i < charWidth.length; i++)
        {
            int position = i * 10 * (charHeight + 2) + charWidth[i];
            fontImage[position] = 1;
        }

        DataBufferByte dataBuffer = new DataBufferByte(fontImage, fontImage.length);
        SampleModel sm = icm.createCompatibleSampleModel(maxWidth, maxHeight);
        WritableRaster raster = Raster.createWritableRaster(sm, dataBuffer, new Point(0, 0));
        BufferedImage bufferedImage = new BufferedImage(maxWidth, maxHeight, 13, icm);
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

    private static byte[] preparePallete(int transparencyColor, int fileNumber)
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

        try
        {
            byte shortPallete[] = new byte[768];
            for(int i = 0; i < shortPallete.length / 3; i++)
            {
                shortPallete[i * 3 + 0] = (byte)i;
                shortPallete[i * 3 + 1] = (byte)i;
                shortPallete[i * 3 + 2] = (byte)i;
            }

            InputStream fis = FontFile.class.getResourceAsStream("res/COLORS");
            fis.skip(3217L);
            fis.read(shortPallete, 48, 48);
            for(int i = 16; i < 32; i++)
            {
                pallete[i * 4 + 0] = (byte)(shortPallete[i * 3 + 0] << 2);
                pallete[i * 4 + 1] = (byte)(shortPallete[i * 3 + 1] << 2);
                pallete[i * 4 + 2] = (byte)(shortPallete[i * 3 + 2] << 2);
                pallete[i * 4 + 3] = -1;
            }

            fis.skip(960L);
            fis.read(shortPallete, 384, 48);
            fis.close();
            if(fileNumber == 23)
            {
                for(int i = 128; i < 144; i++)
                {
                    pallete[i * 4 + 0] = (byte)(shortPallete[i * 3 + 0] << 2);
                    pallete[i * 4 + 1] = (byte)(shortPallete[i * 3 + 1] << 2);
                    pallete[i * 4 + 2] = (byte)(shortPallete[i * 3 + 2] << 2);
                }

            }
            if(fileNumber == 24)
            {
                for(int i = 144; i < 160; i++)
                {
                    pallete[i * 4 + 0] = (byte)(shortPallete[(i - 16) * 3 + 0] << 2);
                    pallete[i * 4 + 1] = (byte)(shortPallete[(i - 16) * 3 + 1] << 2);
                    pallete[i * 4 + 2] = (byte)(shortPallete[(i - 16) * 3 + 2] << 2);
                }

            }
            if(fileNumber == 25)
            {
                for(int i = 160; i < 176; i++)
                {
                    pallete[i * 4 + 0] = (byte)(shortPallete[(i - 32) * 3 + 0] << 2);
                    pallete[i * 4 + 1] = (byte)(shortPallete[(i - 32) * 3 + 1] << 2);
                    pallete[i * 4 + 2] = (byte)(shortPallete[(i - 32) * 3 + 2] << 2);
                }

            }
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        pallete[4] = 0;
        pallete[5] = -1;
        pallete[6] = 0;
        pallete[7] = -1;
        pallete[8] = 0;
        pallete[9] = 0;
        pallete[10] = -1;
        pallete[11] = -1;
        pallete[transparencyColor * 4 + 3] = 0;
        return pallete;
    }

    public FontFile(byte fileData[], int fileNumber)
        throws EOFException, IOException
    {
        super(fileData, fileNumber);
        charCount = 0;
        charHeight = 0;
        transparencyColor = 0;
        charWidth = new byte[0];
        rawFont = new byte[0];
        ext = "png";
        if(getHeader().length < 135)
            throw new IOException("Not a font file - not enough letters found!");
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(getHeader()));
        sdis.skip(2L);
        sdis.skip(1L);
        sdis.skip(2L);
        charWidth = new byte[getHeader().length - 2 - 1 - 2 - 7];
        sdis.read(charWidth);
        charCount = sdis.readUnsignedShort();
        charHeight = sdis.readUnsignedByte();
        sdis.skip(1L);
        transparencyColor = sdis.readUnsignedByte();
        sdis.close();
        rawFont = LZW.decompress(getData(), 0, getData().length, 254, false);
        int height = charHeight * charCount;
        int width = rawFont.length / height;
        if(width * height != rawFont.length)
            throw new IOException("Not a font file - can't calculate correct width*height!");
        else
            return;
    }

    public void update(byte pngData[])
    {
        byte pallete[] = preparePallete(transparencyColor, getFileNumber());
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

        byte oldRawFont[] = rawFont;
        byte newFont[] = new byte[0];
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
            newFont = baos.toByteArray();
        }
        catch(IOException e)
        {
            e.printStackTrace();
        }
        ByteArrayOutputStream baosFake = new ByteArrayOutputStream();
        try
        {
            baosFake.write(newFont);
            baosFake.close();
        }
        catch(IOException e1)
        {
            e1.printStackTrace();
        }
        newFont = baosFake.toByteArray();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        int fontLength = newFont.length / 10 / (charHeight + 2);
        for(int i = 0; i < fontLength; i++)
        {
            for(int y = 0; y < charHeight; y++)
            {
                for(int x = 0; x < 8; x++)
                {
                    int color = newFont[x + 1 + (y + 1 + i * (charHeight + 2)) * 10];
                    baos.write(color);
                }

            }

        }

        try
        {
            baos.close();
        }
        catch(IOException e1)
        {
            e1.printStackTrace();
        }
        rawFont = baos.toByteArray();
        charWidth = new byte[fontLength];
        for(int i = 0; i < fontLength; i++)
        {
            for(int k = 0; k <= 9; k++)
            {
                int color = newFont[k + i * (charHeight + 2) * 10];
                if(color == 1)
                    charWidth[i] = (byte)k;
            }

        }

        if(!Arrays.equals(oldRawFont, rawFont))
            try
            {
                byte packedData[] = LZW.compress(rawFont, 0, rawFont.length, 254, false);
                setData(packedData);
                byte oldHeader[] = getHeader();
                baos = new ByteArrayOutputStream();
                baos.write(oldHeader, 0, 3);
                int newHeaderLength = charWidth.length + 7;
                EndianUtils.writeSwappedShort(baos, (short)newHeaderLength);
                baos.write(charWidth);
                EndianUtils.writeSwappedShort(baos, (short)charWidth.length);
                baos.write(oldHeader, oldHeader.length - 5, 5);
                baos.close();
                setHeader(baos.toByteArray());
            }
            catch(IOException e)
            {
                e.printStackTrace();
            }
    }

    private static final int DEFAULT_HEADER_SIZE = 135;
    private static final int SYMBOL_WIDTH = 8;
    int charCount;
    int charHeight;
    private int transparencyColor;
    private byte charWidth[];
    private byte rawFont[];
}
