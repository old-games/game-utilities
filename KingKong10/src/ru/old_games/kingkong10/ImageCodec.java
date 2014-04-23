package ru.old_games.kingkong10;

import java.awt.Point;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.IndexColorModel;
import java.awt.image.Raster;
import java.awt.image.SampleModel;
import java.awt.image.WritableRaster;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import javax.imageio.ImageIO;

import net.sf.image4j.codec.bmp.BMPDecoder;
import net.sf.image4j.codec.bmp.BMPEncoder;

import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.input.CountingInputStream;
import org.apache.commons.io.input.SwappedDataInputStream;
import org.apache.commons.lang3.math.NumberUtils;

public class ImageCodec {

	private static int maxWidth = 320;
	private static int maxHeight = 200;

	public static void main(String[] args) throws EOFException, IOException {
		if (args.length < 2) {
			System.out.println("nothing to decode.");
		} else {
			if (args[0].equals("/1" )) {
				//    /1 MAINSCR.000
				//    /1 OPTION
				System.out.println("decoding rle image: "+args[1]);
				decode1(args[1]);				
			}
			if (args[0].equals("/2" )) {
				//    /2 MAINSCR.001
				System.out.println("decoding rle image: "+args[1]);
				decode2(args[1]);				
			}
			if (args[0].equals("/3" )) {
				//    /3 OPTIONW
				//    /3 CORQ
				System.out.println("decoding rle image: "+args[1]);
				decode3(args[1]);				
			}
			if (args[0].equals("/4" )) {
				//    /4 MUSICSND OPTION
				System.out.println("decoding rle image: "+args[1]);
				decode4(args[1], args[2]);				
			}
			if (args[0].equals("/5" )) {
				//    /5 TRYAGAIN
				System.out.println("decoding rle image: "+args[1]);
				decode5(args[1]);				
			}
			if (args[0].equals("/6" )) {
				//    /6 TWP00.PZM
				System.out.println("decoding rle animation: "+args[1]);
				decode6(args[1]);				
			}

			if (args[0].equals("/e1" )) {
				//    /e1 MAINSCR.000.bmp MAINSCR.000 
				//    /e1 OPTION.bmp OPTION
				System.out.println("encoding rle image: "+args[1]);
				encode1(args[1], args[2]);				
			}

			if (args[0].equals("/e2" )) {
				//    /e2 MAINSCR.001.bmp 
				System.out.println("encoding rle image: "+args[1]);
				encode2(args[1], false);				
			}

			if (args[0].equals("/er2" )) {
				//    /e2 MAINSCR.001.bmp 
				System.out.println("encoding rle image: "+args[1]);
				encode2(args[1], true);				
			}

			if (args[0].equals("/e3" )) {
				//    /e3 OPTIONW.0.bmp OPTIONW.1.bmp OPTIONW.2.bmp  
				System.out.println("encoding rle image: "+args[1]+"...");
				encode3(args);				
			}

			if (args[0].equals("/e4" )) {
				//    /e4 MUSICSND.bmp OPTION
				System.out.println("encoding rle image: "+args[1]);
				encode4(args[1], args[2]);				
			}			

			if (args[0].equals("/e5" )) {
				//    /e5 TRYAGAIN.0.bmp TRYAGAIN.1.bmp TRYAGAIN
				System.out.println("encoding rle image: "+args[1]);
				encode5(args[1], args[2], args[3]);				
			}			

			if (args[0].equals("/e6" )) {
				//    /e6 TWP.CFG
				System.out.println("encoding rle animation: "+args[1]);
				encode6(args[1]);				
			}			
		}
	}
	
	private static void decode1(String fileName) throws EOFException, IOException {
		File srcFile = new File(fileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(srcFile));

		int rleMarker = sdis.readUnsignedByte();		
		int imgEndPosition = sdis.readInt();
		
		int currentPosition = 1+4;
		byte[] data = new byte[imgEndPosition - currentPosition];
		sdis.readFully(data);
		
		byte[] pal = new byte[3*256];
		sdis.readFully(pal);
	
		sdis.close();
		
		int[] colors = pal2color(pal);
		
		byte[] decodedImage = rleDecode(data, rleMarker);

		BufferedImage image = new BufferedImage(maxWidth, maxHeight, BufferedImage.TYPE_INT_RGB);

		sdis = new SwappedDataInputStream(new ByteArrayInputStream(decodedImage));
		for (int currentY = 0; currentY < maxHeight; currentY++) {
			for (int currentX = 0; currentX < maxWidth; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(srcFile.getAbsolutePath()+".bmp"));		
	}

	private static void decode2(String rleFileName) throws IOException {
		File rleFile = new File(rleFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(rleFile));

		int rleMarker = sdis.readUnsignedByte();		
		int imgEndPosition = sdis.readInt();
		
		int currentPosition = 1+4;
		byte[] data = new byte[imgEndPosition - currentPosition];
		sdis.readFully(data);
		
		sdis.close();
		
		int[] colors = new int[256];
		for (int i=0; i<colors.length; i++) {
			colors[i] = 0xFF000000 | (i * 0x10000 + i * 0x100 + i);			
		}
		
		byte[] decodedImage = rleDecode(data, rleMarker);
		
		FileOutputStream fos = new FileOutputStream(new File(rleFile.getAbsolutePath()+".raw"));
		fos.write(decodedImage);
		fos.close();

		BufferedImage image = new BufferedImage(maxWidth, maxHeight, BufferedImage.TYPE_INT_RGB);

		sdis = new SwappedDataInputStream(new ByteArrayInputStream(decodedImage));
		for (int currentY = 0; currentY < maxHeight; currentY++) {
			for (int currentX = 0; currentX < maxWidth; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(rleFile.getAbsolutePath()+".bmp"));		
	}

	private static void decode3(String rleFileName) throws IOException {
		File rleFile = new File(rleFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(rleFile));

		int rleMarker = sdis.readUnsignedByte();		
		int palPosition = sdis.readInt();
		
		int currentPosition = 1+4;

		byte[] data = new byte[palPosition - currentPosition];
		sdis.readFully(data);

		sdis.close();

		int[] colors = new int[256];
		for (int i=0; i<colors.length; i++) {
			colors[i] = 0xFF000000 | (i * 0x10000 + i * 0x100 + i);			
		}
		
		ArrayList<OneFrame> result = rleDecodeSequence(data,rleMarker);
		//System.out.println(result.size());
		for (int i=0; i<result.size(); i++) {
			OneFrame frame = result.get(i);
			
			FileOutputStream fos = new FileOutputStream(new File(rleFile.getAbsolutePath()+"."+i+".raw"));
			fos.write(frame.getImage());
			fos.close();

			
			BufferedImage image = new BufferedImage(frame.getWidth(), frame.getHeight(), BufferedImage.TYPE_INT_RGB);
			sdis = new SwappedDataInputStream(new ByteArrayInputStream(frame.getImage()));
			
			for (int currentY = 0; currentY < frame.getHeight(); currentY++) {
				for (int currentX = 0; currentX < frame.getWidth(); currentX++) {
					image.setRGB(currentX, currentY, colors[sdis.readUnsignedByte()]);
				}			
			}

			BMPEncoder.write(image, new File(rleFile.getAbsolutePath()+"."+i+".bmp"));		
		}
	}

	private static void decode4(String rleFileName, String palDonorFileName) throws IOException {
		File rleFile = new File(rleFileName);
		File palFile = new File(palDonorFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(palFile));

		sdis.skip(1);		
		int imgEndPosition = sdis.readInt();
		
		int currentPosition = 1+4;
		byte[] data = new byte[imgEndPosition - currentPosition];
		sdis.readFully(data);
		
		byte[] pal = new byte[3*256];
		sdis.readFully(pal);
	
		sdis.close();
		
		int[] colors = pal2color(pal);
		
		sdis = new SwappedDataInputStream(new FileInputStream(rleFile));

		int width = sdis.readUnsignedShort();
		int height = sdis.readUnsignedShort();
		
		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		for (int i=0; i<height; i++) {
			for (int j=0; j<width; j++) {
				image.setRGB(j, i, colors[sdis.readUnsignedByte()]);				
			}
		}
		
		BMPEncoder.write(image, new File(rleFile.getAbsolutePath()+".bmp"));
		
		sdis.close();
	}

	private static void decode5(String srcFileName) throws IOException {
		File srcFile = new File(srcFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(srcFile));
		
		sdis.skip(0x2D7D7);
		
		int width = sdis.readUnsignedShort();
		int height = sdis.readUnsignedShort();
		
		byte[] frame = new byte[width*height];
		sdis.readFully(frame);

		int width2 = sdis.readUnsignedShort();
		int height2 = sdis.readUnsignedShort();

		byte[] frame2 = new byte[width2*height2];
		sdis.readFully(frame2);
		
		byte[] pal = new byte[256*3];
		sdis.readFully(pal);
		
		sdis.close();
		
		int[] colors = pal2color(pal);
		
		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);

		sdis = new SwappedDataInputStream(new ByteArrayInputStream(frame));
		for (int currentY = 0; currentY < height; currentY++) {
			for (int currentX = 0; currentX < width; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(srcFile.getAbsolutePath()+".0"+".bmp"));		

		image = new BufferedImage(width2, height2, BufferedImage.TYPE_INT_RGB);

		sdis = new SwappedDataInputStream(new ByteArrayInputStream(frame2));
		for (int currentY = 0; currentY < height2; currentY++) {
			for (int currentX = 0; currentX < width2; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(srcFile.getAbsolutePath()+".1"+".bmp"));		
		
	}

	private static void decode6(String fileName) throws EOFException, IOException {
		File srcFile = new File(fileName);
		String dirName = FilenameUtils.getFullPath(srcFile.getAbsolutePath())+FilenameUtils.getBaseName(srcFile.getAbsolutePath())+File.separator;

		File dir = new File(dirName);
		if (dir.exists() && !dir.isDirectory()) {
			throw new IOException("file \""+dirName+"\" exists, can't create folder");
		}
		dir.mkdir();
		
		Map<Integer, Integer> emptyFrames = new TreeMap<Integer, Integer>();
		
		IndexColorModel icm = null;
		
		int videoMemSize = 0x10000;
		byte[] videoMem = new byte[videoMemSize];
		Arrays.fill(videoMem, (byte)0);

		CountingInputStream counter = new CountingInputStream(new FileInputStream(srcFile));
		SwappedDataInputStream sdis = new SwappedDataInputStream(counter);

		// file header
		int frameCount = sdis.readInt();
		System.out.println("frames[4b]: "+frameCount);
		
		int frameWidth = sdis.readUnsignedShort();
		int frameHeight = sdis.readUnsignedShort();
		System.out.println("video dimensions [2b+2b]: "+frameWidth+"x"+frameHeight);
		
		sdis.skip(0x0C);
		System.out.println("skip 0x0C bytes (fullFileSize 4b, unknown 8b)");
		
		int currentFrameNumber = 0;
		
		int emptyFramesNumber = 0;
		int lastNormalFrame = -1;
		
		while (currentFrameNumber < frameCount) {
			System.out.println("=== frame #"+currentFrameNumber);

			// frame header
			int paletteInfo = sdis.readUnsignedByte();
			boolean hasPalette = false;
			if (paletteInfo == 0x80) {
				hasPalette = true;
			}
			System.out.println("has palette: "+hasPalette);

			int videoMemStartOffset = sdis.readInt();
			System.out.println("videoMemStartOffset[4b] = "+videoMemStartOffset);

			int compressedFrameSize = sdis.readInt();
			System.out.println("compressedFrameSize[4b] = "+compressedFrameSize);

			// Palette
			if (hasPalette) {
				byte[] pal = new byte[256*3];
				sdis.readFully(pal);
				
				pal = pal6to8(pal);
				
				icm = new IndexColorModel(8, 0x100, pal, 0, false);

				System.out.println("Palette read, size: 256*3");
			}

			// compressed frame
			if (compressedFrameSize > 0) {
				
				if (emptyFramesNumber > 0) {
					emptyFrames.put(lastNormalFrame, emptyFramesNumber);
				}
				
				int rleMarker = sdis.readUnsignedByte();
				System.out.println("rle marker[1b] = "+rleMarker);

				int compressedBlockSize = sdis.readInt();
				System.out.println("compressedBlockSize[4b] = "+compressedBlockSize);

				byte[] compressedFrame = new byte[compressedFrameSize-1-4];
				sdis.readFully(compressedFrame);

				byte[] decodedImage = rleDecode(compressedFrame, rleMarker);
				System.out.println("decoded image length: "+decodedImage.length);

				SwappedDataInputStream temp = new SwappedDataInputStream(new ByteArrayInputStream(decodedImage));
				int spriteWidth = temp.readUnsignedShort();
				int spriteHeight = temp.readUnsignedShort();
				temp.close();
				System.out.println("sprite dimensions: "+spriteWidth+"x"+spriteHeight);
				
				int oneRowOffset = frameWidth - spriteWidth;
				System.out.println("skip "+oneRowOffset+" pixels after every row of sprite");

				int currentVideoMemPosition = videoMemStartOffset;
				int currentSpritePosition = 4;

				while (currentSpritePosition < decodedImage.length) {
					int currentRowPosition = 0;
					while (currentRowPosition < spriteWidth) {
						if (decodedImage[currentSpritePosition] != 0) {
							videoMem[currentVideoMemPosition] = decodedImage[currentSpritePosition];					
						}
						currentSpritePosition++;
						currentVideoMemPosition++;
						currentRowPosition++;
					}
					currentVideoMemPosition += oneRowOffset;
				}

				DataBufferByte dataBuffer = new DataBufferByte(videoMem, frameWidth*frameHeight);
				SampleModel sm = icm.createCompatibleSampleModel(frameWidth, frameHeight);
				WritableRaster raster = Raster.createWritableRaster(sm, dataBuffer, new Point(0,0));

				BufferedImage image = new BufferedImage(frameWidth, frameHeight, BufferedImage.TYPE_BYTE_INDEXED, icm);
				image.setData(raster);
				
				System.out.println("image in memory was built");

				ImageIO.write(image, "bmp", new File(dirName+Integer.toString(currentFrameNumber)+".bmp"));
				System.out.println("file "+dirName+Integer.toString(currentFrameNumber)+".bmp saved.");
				
				lastNormalFrame = currentFrameNumber;
				emptyFramesNumber = 0;
			} else {
				System.out.println("empty frame, skip");
				emptyFramesNumber++;
			}
			currentFrameNumber++;
		}
		sdis.close();
		if (emptyFramesNumber > 0) {
			emptyFrames.put(lastNormalFrame, emptyFramesNumber);
		}

		System.out.println("=== animation decoded successfully");
		
		File cfgFile = new File(FilenameUtils.getFullPath(srcFile.getAbsolutePath())+FilenameUtils.getBaseName(srcFile.getAbsolutePath())+".cfg");
		BufferedWriter cfgWriter = new BufferedWriter(new FileWriter(cfgFile));
		
		cfgWriter.write(FilenameUtils.getBaseName(FilenameUtils.getPathNoEndSeparator(dirName)));
		cfgWriter.newLine();
		
		if (emptyFrames.size() > 0) {
			Set<Integer> keys = emptyFrames.keySet();
			Iterator<Integer> iterator = keys.iterator();
			while(iterator.hasNext()) {
				Integer keyFrame = iterator.next();
				Integer emptyNumber = emptyFrames.get(keyFrame);
				
				cfgWriter.write(keyFrame.toString());
				cfgWriter.newLine();
				
				cfgWriter.write(emptyNumber.toString());
				cfgWriter.newLine();
				
				cfgWriter.newLine();
			}
		}
		cfgWriter.close();
		
		System.out.println("=== configuration file \""+cfgFile.getName()+"\" created");
		
		
	}

	private static void encode1(String bmpFileName, String origFileName) throws IOException {
		File srcFile = new File(origFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(srcFile));

		int rleMarker = sdis.readUnsignedByte();		
		int imgEndPosition = sdis.readInt();
		
		int currentPosition = 1+4;
		byte[] data = new byte[imgEndPosition - currentPosition];
		sdis.readFully(data);
		
		byte[] pal = new byte[3*256];
		sdis.readFully(pal);
	
		sdis.close();
		
		int[] colors = pal2color(pal);

		BufferedImage image = BMPDecoder.read(new File(bmpFileName));
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();		

		for (int y=0; y<maxHeight; y++) {
			for (int x=0; x<maxWidth; x++) {
				int realColor = -1;
				int currentColor = image.getRGB(x, y);
				for (int j=0; j<256; j++) {
					if(currentColor == colors[j] ) {
						realColor = j;
					}
				}
				if (realColor == -1) {
					throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
				}
				baos.write(realColor);				
			}			
		}

		byte[] imageData = baos.toByteArray();
		imageData = rleEncode(imageData, rleMarker);
		
		baos = new ByteArrayOutputStream();		
		baos.write(rleMarker);

		int filesize = imageData.length+1+4;
		
		baos.write(filesize & 0xFF);
		baos.write((filesize & 0xFF00)>>8);
		baos.write((filesize & 0xFF0000)>>16);
		baos.write((filesize & 0xFF000000)>>24);

		baos.write(imageData);
		
		baos.write(pal);
		
		FileOutputStream fos = new FileOutputStream(new File(bmpFileName+".rle"));
		fos.write(baos.toByteArray());
		fos.close();	
	}

	private static void encode2(String bmpFileName, boolean isRaw) throws IOException {

		int rleMarker = 1;
		byte[] imageData = null;
		
		if (!isRaw) {

			int[] colors = new int[256];
			for (int i=0; i<colors.length; i++) {
				colors[i] = 0xFF000000 | (i * 0x10000 + i * 0x100 + i);			
			}

			BufferedImage image = BMPDecoder.read(new File(bmpFileName));

			ByteArrayOutputStream baos = new ByteArrayOutputStream();		

			for (int y=0; y<maxHeight; y++) {
				for (int x=0; x<maxWidth; x++) {
					int realColor = -1;
					int currentColor = image.getRGB(x, y);
					for (int j=0; j<256; j++) {
						if(currentColor == colors[j] ) {
							realColor = j;
						}
					}
					if (realColor == -1) {
						throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
					}
					baos.write(realColor);				
				}			
			}
			
			imageData = baos.toByteArray();
		} else {
			File rawFile = new File(bmpFileName);
			FileInputStream fis = new FileInputStream(rawFile);
			imageData = new byte[(int) rawFile.length()];
			fis.read(imageData);
			fis.close();
			rleMarker = 0;
		}

		
		
		
		imageData = rleEncode(imageData, rleMarker);
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();		
		baos.write(rleMarker);

		int filesize = imageData.length+1+4;
		
		baos.write(filesize & 0xFF);
		baos.write((filesize & 0xFF00)>>8);
		baos.write((filesize & 0xFF0000)>>16);
		baos.write((filesize & 0xFF000000)>>24);

		baos.write(imageData);
		
		FileOutputStream fos = new FileOutputStream(new File(bmpFileName+".rle"));
		fos.write(baos.toByteArray());
		fos.close();	
		
	}

	private static void encode3(String[] args) throws IOException {
		int[] colors = new int[256];
		for (int i=0; i<colors.length; i++) {
			colors[i] = 0xFF000000 | (i * 0x10000 + i * 0x100 + i);			
		}
		
		int rleMarker = 1;

		ByteArrayOutputStream result = new ByteArrayOutputStream();
		result.write(rleMarker);
		result.write(0);
		result.write(0);
		result.write(0);
		result.write(0);
		
		if (args.length > 1) {
			for (int i=1; i<args.length; i++) {
				BufferedImage image = BMPDecoder.read(new File(args[i]));				

				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				baos.write(0);

				int height = image.getHeight(); 
				int width = image.getWidth();

				for (int y=0; y<height; y++) {
					for (int x=0; x<width; x++) {
						int realColor = -1;
						int currentColor = image.getRGB(x, y);
						for (int j=0; j<256; j++) {
							if(currentColor == colors[j] ) {
								realColor = j;
							}
						}
						if (realColor == -1) {
							throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
						}
						baos.write(realColor);				
					}			
				}


				byte[] imageData = baos.toByteArray();
				
				imageData = rleEncode(imageData, rleMarker);
				
				result.write(width & 0xFF);
				result.write((width & 0xFF00)>>8);
				result.write(height & 0xFF);
				result.write(imageData);
			}
		}

		byte[] bResult = result.toByteArray();
		int filesize = bResult.length;
		
		bResult[1] = (byte) (filesize & 0xFF); 
		bResult[2] = (byte) ((filesize & 0xFF00)>>8); 
		bResult[3] = (byte) ((filesize & 0xFF0000)>>16); 
		bResult[4] = (byte) ((filesize & 0xFF000000)>>24); 
		
		FileOutputStream fos = new FileOutputStream(new File(args[1]+".rle"));
		fos.write(bResult);
		fos.close();	
	}

	private static void encode4(String bmpFileName, String origFileName) throws IOException {
		File srcFile = new File(origFileName);

		SwappedDataInputStream sdis = new SwappedDataInputStream(new FileInputStream(srcFile));

		sdis.skip(1);		
		int imgEndPosition = sdis.readInt();
		
		int currentPosition = 1+4;
		byte[] data = new byte[imgEndPosition - currentPosition];
		sdis.readFully(data);
		
		byte[] pal = new byte[3*256];
		sdis.readFully(pal);
	
		sdis.close();
		
		int[] colors = pal2color(pal);

		BufferedImage image = BMPDecoder.read(new File(bmpFileName));
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();		

		int height = image.getHeight(); 
		int width = image.getWidth();

		baos.write(width & 0xFF);
		baos.write((width & 0xFF00) >> 8);
		
		baos.write(height & 0xFF);
		baos.write((height & 0xFF00) >> 8);
		
		for (int y=0; y<height; y++) {
			for (int x=0; x<width; x++) {
				int realColor = -1;
				int currentColor = image.getRGB(x, y);
				for (int j=0; j<256; j++) {
					if((currentColor == colors[j]) && (realColor == -1)) {
						realColor = j;
					}
				}
				if (realColor == -1) {
					throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
				}
				baos.write(realColor);				
			}			
		}

		byte[] imageData = baos.toByteArray();

		FileOutputStream fos = new FileOutputStream(new File(bmpFileName+".rle"));
		fos.write(imageData);
		fos.close();	
	}

	private static void encode5(String frame1FileName, String frame2FileName, String origFileName) throws IOException {
		FileInputStream fis = new FileInputStream(new File(origFileName));
		byte[] oldFile = new byte[fis.available()];
		fis.read(oldFile);
		fis.close();
		
		BufferedImage image1 = BMPDecoder.read(new File(frame1FileName));
		BufferedImage image2 = BMPDecoder.read(new File(frame2FileName));
		
		int width1 = image1.getWidth();
		int width2 = image2.getWidth();
		int height1 = image1.getHeight();
		int height2 = image2.getHeight();

		int textPosition = 0x2D7D7;

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		baos.write(oldFile, 0, textPosition);
		
		byte[] pal = new byte[3*256];
		System.arraycopy(oldFile, oldFile.length - 3*256, pal, 0, pal.length);
		
		int[] colors = pal2color(pal);
		
		baos.write(width1 & 0xFF);
		baos.write((width1 & 0xFF00) >> 8);
		baos.write(height1 & 0xFF);
		baos.write((height1 & 0xFF00) >> 8);
		
		for (int y=0; y<height1; y++) {
			for (int x=0; x<width1; x++) {
				int realColor = -1;
				int currentColor = image1.getRGB(x, y);
				for (int j=0; j<256; j++) {
					if((currentColor == colors[j]) && (realColor == -1)) {
						realColor = j;
					}
				}
				if (realColor == -1) {
					throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
				}
				baos.write(realColor);				
			}			
		}

		baos.write(width2 & 0xFF);
		baos.write((width2 & 0xFF00) >> 8);
		baos.write(height2 & 0xFF);
		baos.write((height2 & 0xFF00) >> 8);
		
		for (int y=0; y<height2; y++) {
			for (int x=0; x<width2; x++) {
				int realColor = -1;
				int currentColor = image2.getRGB(x, y);
				for (int j=0; j<256; j++) {
					if((currentColor == colors[j]) && (realColor == -1)) {
						realColor = j;
					}
				}
				if (realColor == -1) {
					throw new IOException("Unknown color 0x"+Integer.toHexString(currentColor)+" in BMP at pos. (x,y): ("+x+","+y+")");
				}
				baos.write(realColor);				
			}			
		}
		
		baos.write(pal);
		
		byte[] result = baos.toByteArray();

		FileOutputStream fos = new FileOutputStream(new File(origFileName+".rle"));
		fos.write(result);
		fos.close();	
	}

	private static void encode6(String fileName) throws IOException {
		
		System.out.println("=== read configuration from \""+fileName+"\"");
		AnimationConfiguration configuration = new AnimationConfiguration(fileName);
		configuration.read();
		
		System.out.println("   directory with frames: "+configuration.getFramesDirectoryName());
		
		if (configuration.getEmptyFramesConfiguration().size() > 0) {
			Iterator<Integer> keyIterator = configuration.getEmptyFramesConfiguration().keySet().iterator();
			while (keyIterator.hasNext()) {
				Integer key = keyIterator.next();
				Integer value = configuration.getEmptyFramesConfiguration().get(key);
				System.out.println("   empty frames: place "+value+" empty frames after frame #"+key);
			}
		}
		
		System.out.println("=== find frame files in \""+configuration.getFramesDirectoryName()+"\"");
		Collection<File> frameFiles = configuration.findFrames();
		
		if (frameFiles.size() == 0) {
			throw new IOException("can't find BMP files in directory "+configuration.getFramesDirectoryName());
		} else {
			System.out.println("   found "+frameFiles.size()+" bmp files plus "+configuration.getEmptyFramesNumber()+" empty frames from configuration");
		}
		
		System.out.println("=== writing to new animation file");
		File animationFile = new File(configuration.getFramesDirectoryName()+".pzm");
		FileOutputStream animationStream = new FileOutputStream(animationFile);
		
		System.out.println("   animation name: "+animationFile.toString());
		
		EndianUtils.writeSwappedInteger(animationStream, frameFiles.size() + configuration.getEmptyFramesNumber());
		EndianUtils.writeSwappedShort(animationStream, (short)320);
		EndianUtils.writeSwappedShort(animationStream, (short)200);
		EndianUtils.writeSwappedInteger(animationStream, 0);
		EndianUtils.writeSwappedInteger(animationStream, 0);
		EndianUtils.writeSwappedInteger(animationStream, 0);
		
		System.out.println("   animation header saved");
		
		Iterator<File> frameIterator = frameFiles.iterator();
		byte[] oldPalette = new byte[256*3];
		byte[] oldBitmap = new byte[320*200];
		
		Arrays.fill(oldPalette, (byte)0);
		Arrays.fill(oldBitmap, (byte)0);
		
		while (frameIterator.hasNext()) {
			File oneFrame = frameIterator.next();
			System.out.println("=== frame "+oneFrame.getName());
			
			int currentFrameNumber = -1;

			String currentFrameName = FilenameUtils.getBaseName(oneFrame.getAbsolutePath());
			if (NumberUtils.isDigits(currentFrameName)) {
				currentFrameNumber = Integer.parseInt(currentFrameName);
			}

			BufferedImage image = ImageIO.read(oneFrame);
			
			if (image.getWidth() != 320) {
				throw new IOException("width of frame is not 320 pixels");
			}
			if (image.getHeight() != 200) {
				throw new IOException("height of frame is not 200 pixels");
			}
			
			byte[] palette = get6bitPalette(image);
			byte[] bitmap = getBitmap(image);
			
			boolean needPalette = !Arrays.equals(oldPalette, palette);
			
			if (needPalette) {
				byte[] packedFrame = rleEncodeFrame(bitmap, 320, 200);
				
				animationStream.write(0x80);
				EndianUtils.writeSwappedInteger(animationStream, 0);
				EndianUtils.writeSwappedInteger(animationStream, packedFrame.length);
				
				animationStream.write(palette);
				animationStream.write(packedFrame);
				
				System.out.println("   different palette - write full frame");
			} else {
				boolean equalFrames = Arrays.equals(oldBitmap, bitmap);
				
				if (equalFrames) {
					animationStream.write(0);
					EndianUtils.writeSwappedInteger(animationStream, 0xFFFFFFFF);
					EndianUtils.writeSwappedInteger(animationStream, 0);
					System.out.println("   frames are equal - write empty frame");
				} else {
					byte[] data = createSprite(oldBitmap, bitmap);

					animationStream.write(data);
				}
			}

			if (configuration.getEmptyFramesConfiguration().containsKey(currentFrameNumber)) {
				Integer emptyCount = configuration.getEmptyFramesConfiguration().get(currentFrameNumber);
				if (emptyCount != null) {
					System.out.println("   insert "+emptyCount+" empty frames after "+currentFrameNumber);
					
					for (int i=0; i<emptyCount.intValue(); i++) {
						animationStream.write(0);
						EndianUtils.writeSwappedInteger(animationStream, 0xFFFFFFFF);
						EndianUtils.writeSwappedInteger(animationStream, 0);
					}
				}
			}
			
			oldPalette = palette;
			oldBitmap = bitmap;
		}
		
		animationStream.close();
		
		RandomAccessFile raf = new RandomAccessFile(animationFile, "rw");
		raf.seek(8);
		raf.writeInt(EndianUtils.swapInteger((int)animationFile.length()));		
		raf.close();

		System.out.println("=== animation encoded successfully");

	}

	private static byte[] createSprite(byte[] oldBitmap, byte[] bitmap) throws IOException {
		
		int minX = 500;
		int maxX = -1;
		int minY = 300;
		int maxY = -1;
		
		for (int i=0; i<200; i++) {
			for (int j=0; j<320; j++) {
				if (oldBitmap[i*320 + j] != bitmap[i*320 + j]) {
					if (minX > j) {
						minX = j;
					}
					
					if (maxX < j) {
						maxX = j;
					}
					
					if (minY > i) {
						minY = i;
					}
					
					if (maxY < i) {
						maxY = i;
					}
				}
			}
		}
		
		int width = (maxX-minX)+1;
		int height = (maxY-minY)+1;
		int offset = minY * 320 + minX;
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream(bitmap.length + 4);
		
		for (int i=minY; i<=maxY; i++) {
			for (int j=minX; j<=maxX; j++) {
				if (oldBitmap[i*320 + j] != bitmap[i*320 + j]) {
					if (bitmap[i*320 + j] < 0) {
						baos.write(bitmap[i*320 + j] + 256);
					} else {
						baos.write(bitmap[i*320 + j]);
					}
				} else {
					baos.write(0);
				}
			}
		}
		byte[] source = baos.toByteArray();
		baos.close();
		
		byte[] packedSprite = rleEncodeFrame(source, width, height);

		baos = new ByteArrayOutputStream(1+4+4+packedSprite.length);
		baos.write(0);
		EndianUtils.writeSwappedInteger(baos, offset);
		EndianUtils.writeSwappedInteger(baos, packedSprite.length);		
		baos.write(packedSprite);
		byte[] result = baos.toByteArray();
		baos.close();
		
		System.out.println("   write sprite with size = "+width+"x"+height+", offset="+offset);
		
		return result;
	}

	private static byte[] rleEncodeFrame(byte[] bitmap, int width, int height) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream(bitmap.length + 4);
		EndianUtils.writeSwappedShort(baos, (short) width);
		EndianUtils.writeSwappedShort(baos, (short) height);
		baos.write(bitmap);
		byte[] source = baos.toByteArray();
		baos.close();

		int rleMarker = calculateColorUsage(source);
		
		byte[] packedBitmap = rleEncode(source, rleMarker);
		
		baos = new ByteArrayOutputStream(packedBitmap.length + 5);
		baos.write(rleMarker);
		EndianUtils.writeSwappedInteger(baos, packedBitmap.length + 5);
		baos.write(packedBitmap);
		byte[] result = baos.toByteArray();
		baos.close();
		
		return result;
	}

	private static int calculateColorUsage(byte[] bitmap) {
		
		int[] colorUsage = new int[256];
		Arrays.fill(colorUsage, 0);
		
		for (int i=0; i<bitmap.length; i++) {
			int color = bitmap[i];
			if (color < 0) {
				color += 256;
			}
			
			colorUsage[color]++;
		}
		
		int result = -1;
		int minUsage = 0x10000;
		
		for (int i=0; i<256; i++) {
			if (colorUsage[i] < minUsage) {
				result = i;
				minUsage = colorUsage[i];
			}
		}
		
		return result;
	}

	private static byte[] getBitmap(BufferedImage image) throws IOException {
		Raster raster = image.getData();
		DataBuffer dataBuffer = raster.getDataBuffer();
		if (dataBuffer.getDataType() != DataBuffer.TYPE_BYTE) {
			throw new IOException("frame doesn't have byte indexed bitmap");
		}
		DataBufferByte dataBufferByte = (DataBufferByte) dataBuffer;
		byte[] bitmap = dataBufferByte.getData();
		return bitmap;
	}

	private static byte[] get6bitPalette(BufferedImage image) throws IOException {

		ColorModel colorModel = image.getColorModel();
		if (!(colorModel instanceof IndexColorModel)) {
			throw new IOException("frame is not image with palette");
		}
		IndexColorModel indexColorModel = (IndexColorModel) colorModel;

		byte[] reds = new byte[indexColorModel.getMapSize()];
		byte[] greens = new byte[indexColorModel.getMapSize()];
		byte[] blues = new byte[indexColorModel.getMapSize()];
		
		indexColorModel.getReds(reds);
		indexColorModel.getGreens(greens);
		indexColorModel.getBlues(blues);
		
		ByteArrayInputStream redStream = new ByteArrayInputStream(reds);
		ByteArrayInputStream greenStream = new ByteArrayInputStream(greens);
		ByteArrayInputStream blueStream = new ByteArrayInputStream(blues);
		
		byte[] result = new byte[indexColorModel.getMapSize()*3];
		
		for (int i=0; i<indexColorModel.getMapSize(); i++) {
			result[i*3 + 0] = (byte) (redStream.read() >> 2);
			result[i*3 + 1] = (byte) (greenStream.read() >> 2);
			result[i*3 + 2] = (byte) (blueStream.read() >> 2);
		}
		
		return result;
	}

	private static int[] pal2color(byte[] pal) {
		int[] colors = new int[256];
		
		if (pal.length == 768) { 
			SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(pal));

			try {
				for (int i=0; i<256; i++) {
					int red = sdis.readUnsignedByte();
					int green = sdis.readUnsignedByte();
					int blue = sdis.readUnsignedByte();
			
					colors[i] = 0xFF000000 | (red * 0x40000 + green * 0x400 + blue*0x4);			
				}
		
				sdis.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		return colors;
		
	}
	
	private static byte[] pal6to8(byte[] srcPal) {
		byte[] result = new byte[srcPal.length];
		
		for (int i=0; i<srcPal.length; i++) {
			result[i] = (byte) (srcPal[i] << 2);
		}
		
		return result;
	}
	
	
	private static int rleDecode(byte[] data, ByteArrayOutputStream baos, int rleMarker, int currentPosition, int length) throws IOException {

		//System.out.println("rleDecode, currentPosition="+Integer.toHexString(currentPosition)+", length="+Integer.toHexString(length));
		
		int bytesProcessed = 0;
		
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(data));
		sdis.skip(currentPosition);

		int rleLength = 0;
		int rleColor = 0;
		int resultLength = 0;
		boolean rleFinished = false;
		boolean firstPixel = true;

		while (!rleFinished) {
			int currentByte = -1;
			try {
				currentByte = sdis.readUnsignedByte();
				bytesProcessed++;
			} catch (EOFException e) {
				rleFinished = true;
			}

			if (currentByte != -1) {
				if (currentByte == rleMarker) {
					try {
						rleLength = sdis.readUnsignedByte();
						rleColor = sdis.readUnsignedByte();
						bytesProcessed+=2;
					} catch (EOFException e) {
						e.printStackTrace();
						sdis.close();
						throw new IOException(e);
					}
				} else {
					rleLength = 1;
					rleColor = currentByte;
				}

				for (int i=0; i<rleLength; i++) {
					if (firstPixel) {
						firstPixel = false;
					} else {
						baos.write(rleColor);
						resultLength++;
					}
				}
			} else {
				rleFinished = true;
			}
			
			if (resultLength >= length) {
				rleFinished = true;
			}
		};		
		sdis.close();
		//System.out.println("resultLength="+Integer.toHexString(resultLength));
		return bytesProcessed;		
	}

	private static byte[] rleDecode(byte[] data, int rleMarker) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(data));
		
		int rleLength = 0;
		int rleColor = 0;
		boolean rleFinished = false;

		while (!rleFinished) {
			int currentByte = -1;
			try {
				currentByte = sdis.readUnsignedByte();
			} catch (EOFException e) {
				rleFinished = true;
			}

			if (currentByte != -1) {
				if (currentByte == rleMarker) {
					try {
						rleLength = sdis.readUnsignedByte();
						rleColor = sdis.readUnsignedByte();
					} catch (EOFException e) {
						e.printStackTrace();
						sdis.close();
						throw new IOException(e);
					}
				} else {
					rleLength = 1;
					rleColor = currentByte;
				}

				for (int i=0; i<rleLength; i++) {
					baos.write(rleColor);
				}
			} else {
				rleFinished = true;
			}
		};		
		sdis.close();
		return baos.toByteArray();		
	}

	private static ArrayList<OneFrame> rleDecodeSequence(byte[] data, int rleMarker) throws IOException {
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(data));
		ArrayList<OneFrame> result = new ArrayList<OneFrame>();

		int currentPosition = 0;
		
		int width = 0;
		int height = 0;
		do {
			width = sdis.readUnsignedShort();
			height = sdis.readUnsignedByte();				
			currentPosition += 3;
			//System.out.println("width="+Integer.toHexString(width)+", height="+Integer.toHexString(height));
		
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
		
			int bytesProcessed = rleDecode(data, baos, rleMarker, currentPosition, width*height);
			sdis.skip(bytesProcessed);
			currentPosition += bytesProcessed;

			//System.out.println(Integer.toHexString(bytesProcessed));
		
			OneFrame frame = new OneFrame();
			frame.setHeight(height);
			frame.setWidth(width);
			frame.setImage(baos.toByteArray());
			//System.out.println("image length = "+Integer.toHexString(frame.getImage().length));
		
			result.add(frame);			
		} while (sdis.available() > 0);
		
		sdis.close();

		return result;
	}

	private static byte[] rleEncode(byte[] imageData, int rleMarker) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(imageData));

		int rleLength = 0;
		int rleColor = -1;
		//int readed = 0;
		boolean rleFinished = false;

		while (!rleFinished) {
			int currentByte = -1;
			try {
				currentByte = sdis.readUnsignedByte();
				//readed++;
			} catch (EOFException e) {
				rleFinished = true;
			}

			if (currentByte != -1) {
				if (currentByte == rleColor && rleLength < 255) {
					rleLength++;
				} else {
					if (rleLength > 3) {						
						baos.write(rleMarker);
						baos.write(rleLength);
						baos.write(rleColor);						
					} else {
						if (rleColor == rleMarker) {
							baos.write(rleMarker);
							baos.write(rleLength);
							baos.write(rleColor);						
						} else {
							for (int i=0; i<rleLength; i++) {
								baos.write(rleColor);
							}
						}
					}		
					
					rleLength = 1;
					rleColor = currentByte;
				}
			} else {
				rleFinished = true;

				if (rleLength > 3) {
					baos.write(rleMarker);
					baos.write(rleLength);
					baos.write(rleColor);						
				} else {
					if (rleColor == rleMarker) {
						baos.write(rleMarker);
						baos.write(rleLength);
						baos.write(rleColor);
					} else {
						for (int i=0; i<rleLength; i++) {
							baos.write(rleColor);
						}
					}
				}		
				
			}
		};
		sdis.close();
		return baos.toByteArray();		
	}
}
