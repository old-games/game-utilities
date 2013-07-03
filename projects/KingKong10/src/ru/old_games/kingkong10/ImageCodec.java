package ru.old_games.kingkong10;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import net.sf.image4j.codec.bmp.BMPDecoder;
import net.sf.image4j.codec.bmp.BMPEncoder;

import org.apache.commons.io.input.CountingInputStream;
import org.apache.commons.io.input.SwappedDataInputStream;

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

		CountingInputStream counter = new CountingInputStream(new FileInputStream(srcFile));
		SwappedDataInputStream sdis = new SwappedDataInputStream(counter);

		int frameCount = sdis.readInt();
		System.out.println("frames[4b]: "+frameCount);
		
		int width = sdis.readUnsignedShort();
		int height = sdis.readUnsignedShort();
		System.out.println("frame size[2b+2b]: "+width+"x"+height);
		
		int fileSize = sdis.readInt();
		System.out.println("internal file size[4b]: "+fileSize+", real file size:"+srcFile.length());
		
		int unknown1 = sdis.readInt();
		System.out.println("unknown1[4b] = "+unknown1);
		
		int unknown2 = sdis.readInt();
		System.out.println("unknown2[4b] = "+unknown2);
		
		int unknown3 = sdis.readUnsignedByte();
		System.out.println("unknown3[1b] = "+unknown3);

		int unknown4 = sdis.readInt();
		System.out.println("unknown4[4b] = "+unknown4);
		
		int unknown5 = sdis.readInt();
		System.out.println("unknown5[4b] = "+unknown5);
		
		byte[] pal = new byte[256*3];
		sdis.readFully(pal);
		int[] colors = pal2color(pal);
		System.out.println("pal read, size: 256*3");
		
		// first frame data
		int rleMarker = sdis.readUnsignedByte();
		System.out.println("rle marker[1b] = "+rleMarker);
		
		int fullFrameSize = sdis.readInt();
		System.out.println("fullFrameSize[4b] = "+fullFrameSize);
		
		int frameWidth = sdis.readUnsignedShort();
		int frameHeight = sdis.readUnsignedShort();		
		System.out.println("frame size[2b+2b]: "+frameWidth+"x"+frameHeight);
		
		byte[] data = new byte[fullFrameSize - 1 - 4 - 2 - 2];
		sdis.readFully(data);

		System.out.println("Position in file: 0x"+Integer.toHexString(counter.getCount()).toUpperCase());
		
		byte[] decodedImage = rleDecode(data, rleMarker);
		
		System.out.println("frame size should be: "+(frameWidth*frameHeight)+" but calculated: "+decodedImage.length);

		BufferedImage image = new BufferedImage(frameWidth, frameHeight, BufferedImage.TYPE_INT_RGB);

		SwappedDataInputStream sdis2 = new SwappedDataInputStream(new ByteArrayInputStream(decodedImage));
		for (int currentY = 0; currentY < frameHeight; currentY++) {
			for (int currentX = 0; currentX < frameWidth; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis2.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(srcFile.getAbsolutePath()+".0.bmp"));
		System.out.println("file "+srcFile.getAbsolutePath()+".0.bmp saved.");
		
		// second frame
		System.out.println("======= second frame");
		
		int unknown = sdis.readUnsignedByte();
		System.out.println("unknown1[1b]: "+unknown);

		unknown = sdis.readInt();
		System.out.println("unknown2[4b]: "+unknown);
		
		unknown = sdis.readInt();
		System.out.println("unknown3[4b]: "+unknown);

		unknown = sdis.readUnsignedByte();
		System.out.println("unknown4[1b]: "+unknown);
		
		unknown = sdis.readInt();
		System.out.println("unknown5[4b]: "+unknown);
		
		unknown = sdis.readInt();
		System.out.println("unknown6[4b]: "+unknown);
		
		unknown = sdis.readUnsignedByte();
		System.out.println("unknown7[1b]: "+unknown);
		
		int offsetX = sdis.readUnsignedByte();
		System.out.println("offset x[1b]: "+offsetX);
		
		int offsetY = sdis.readUnsignedByte();
		System.out.println("offset y[1b]: "+offsetY);
		
		unknown = sdis.readUnsignedShort();
		System.out.println("unknown8[2b]: "+unknown);
		
		unknown = sdis.readInt();
		System.out.println("unknown9[4b]: "+unknown);
		
		rleMarker = sdis.readUnsignedByte();
		System.out.println("rle marker[1b] = "+rleMarker);
		
		fullFrameSize = sdis.readInt();
		System.out.println("fullFrameSize[4b] = "+fullFrameSize);
		
		frameWidth = sdis.readUnsignedShort();
		frameHeight = sdis.readUnsignedByte();		
		System.out.println("frame size[2b+1b]: "+frameWidth+"x"+frameHeight);
		
		data = new byte[fullFrameSize - 1 - 4 - 2 - 1];
		sdis.readFully(data);
		
		System.out.println("Position in file: 0x"+Integer.toHexString(counter.getCount()).toUpperCase());
		
		decodedImage = rleDecode(data, rleMarker);
		
		System.out.println("frame size should be: "+(frameWidth*frameHeight)+" but calculated: "+decodedImage.length);

		image = new BufferedImage(frameWidth, frameHeight, BufferedImage.TYPE_INT_RGB);

		sdis2 = new SwappedDataInputStream(new ByteArrayInputStream(decodedImage));
		for (int currentY = 0; currentY < frameHeight; currentY++) {
			for (int currentX = 0; currentX < frameWidth; currentX++) {
				image.setRGB(currentX, currentY, colors[sdis2.readUnsignedByte()]);
			}			
		}
		
		BMPEncoder.write(image, new File(srcFile.getAbsolutePath()+".1.bmp"));
		System.out.println("file "+srcFile.getAbsolutePath()+".1.bmp saved.");

		
		sdis.close();
		
		
/*
		int rleMarker = sdis.readUnsignedByte();		
		
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
	*/		
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
						for (int i=0; i<rleLength; i++) {
							baos.write(rleColor);
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
					for (int i=0; i<rleLength; i++) {
						baos.write(rleColor);
					}
				}		
				
			}
		};
		sdis.close();
		return baos.toByteArray();		
	}
	
	

}
