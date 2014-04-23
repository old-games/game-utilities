package lv;

import java.io.*;
import java.util.*;

public class LostVikingsUnpacker {

	private byte[] sourceData;

	private int getByte(byte[] b, int index) {

		int result = b[index];
		if (result < 0) result += 256;

		return result;
	}

	private int getWord(byte[] b, int index) {

		return getByte(b, index) + (getByte(b, index+1)<<8);

	}

	private int getInt(byte[] b, int index) {

		return getByte(b, index) + (getByte(b, index+1)<<8) + (getByte(b, index+2)<<16) + (getByte(b, index+3)<<24);

	}

	private String lpad(String s, char c, int width) {
		if (s.length() >= width) {
			return s;
		} else {
			StringBuffer sb = new StringBuffer(s);
			while (sb.length()<width) sb.insert(0, c);
			return sb.toString();
		}			

	}

//-------------------------------------------------

	private int getFileCount(byte[] b) {

		return getInt(b, 0) / 4;

	}

	private String fileInfo(int index) {
		String result = "";
	  try {
			result = "."+ResourceBundle.getBundle(this.getClass().getName()).getString(lpad(Integer.toHexString(index).toUpperCase(),'0',3));
		} catch (MissingResourceException e) {
			
		} catch (Exception e) {
			e.printStackTrace();
		}

		return result;
	}


	private byte[] decompress(byte[] source, int startPosition, int fileSize) {
				
		int origFileSize = getWord(source, startPosition)+1;

		byte[] resFile = new byte[origFileSize];

		byte[] buffer = new byte[0x1000];
		for (int i=0; i<buffer.length; i++) {
			buffer[i] = 0;
		}

		int bufferPos = 0;
		int sourcePos = startPosition+2; // after filesize
		int resPos = 0;

		int controlByte;
		int bitCheck;

		while (sourcePos < source.length) {
			bitCheck = 1;
			controlByte = getByte(source, sourcePos);
			sourcePos++;

			while (bitCheck < 256) {
				if ((controlByte & bitCheck) > 0) { // source[sourcePos] is not compressed

					buffer[bufferPos] = source[sourcePos];
					bufferPos++;
					if (bufferPos >= buffer.length)
						bufferPos -= buffer.length;

					resFile[resPos] = source[sourcePos];
					resPos++;

					if (resPos >= origFileSize) // end of file reached
						return resFile;

					sourcePos++;
				} else { // source[sourcePos] is a word-sized structure (4 bits for size and 12 bits for offset)

					int tempPos = getWord(source,sourcePos);
					int blockSize = ((tempPos & 0xF000) >> 12) + 3;
					tempPos = tempPos & 0x0FFF;

					sourcePos += 2;

					for (int i=0; i<blockSize; i++) {
						buffer[bufferPos] = buffer[tempPos];
						bufferPos++;
						if (bufferPos >= buffer.length)
							bufferPos -= buffer.length;
				
						resFile[resPos] = buffer[tempPos];
						resPos++;

						if (resPos >= origFileSize) // end of file reached
							return resFile;

						tempPos++;
						if (tempPos >= buffer.length)
							tempPos -= buffer.length;
					}
				}
				bitCheck = bitCheck << 1;
			}
		}
		return resFile;
	}


	private void writeFile(int index, byte[] b, int filePosition, int fileSize) throws FileNotFoundException, IOException {
		FileOutputStream resultFile = new FileOutputStream(lpad(Integer.toHexString(index),'0',3).toUpperCase()+fileInfo(index)+".bin");
		resultFile.write(b, filePosition, fileSize);
		resultFile.close();
	}


	private void processFile(byte[] b, int index) throws FileNotFoundException, IOException {

		int filePosition = getInt(b, index*4);

		int fileLength;

		if (index+1 >= getFileCount(b)) {
			fileLength = b.length - filePosition;
		} else {
			fileLength = getInt(b, (index+1)*4) - filePosition;
		}

		int realFileSize = getWord(b, filePosition);

		try {
			if (index == 0 || index == getFileCount(b)-1) { //not files
				writeFile(index, b, filePosition, fileLength);
				realFileSize = fileLength;
			} else if (realFileSize*4 == fileLength - 2) { // noncompressed file
//System.err.println(Integer.toHexString(index)+"=raw");
				writeFile(index, b, filePosition+2, fileLength-2);
				realFileSize = fileLength-2;
			} else { // compressed file
				realFileSize++;
				writeFile(index, decompress(b, filePosition, fileLength), 0, realFileSize);
			}
			System.out.println("File "+index+" at position:"+filePosition+" size in pack:"+fileLength+" size on disk:"+realFileSize);
		} catch (Exception e) {
			System.out.println("File "+index+" at position:"+filePosition+" size in pack:"+fileLength+" size on disk:"+realFileSize+" Error:");
			e.printStackTrace();
		}

	}

	public void unpack(Vector fileNumbers) throws FileNotFoundException, IOException {
		if (fileNumbers.size() > 0) {
			for (int i=0; i< fileNumbers.size(); i++) {
				int j = ((Integer)(fileNumbers.get(i))).intValue();
				processFile(sourceData, j);
			}
		} else {
			for (int i=0; i<getFileCount(sourceData); i++) {
				processFile(sourceData, i);
			}
		}
	}

	public LostVikingsUnpacker(String packName) throws FileNotFoundException, IOException {
		FileInputStream sourceFile = new FileInputStream(packName);

		if (sourceFile.available() > 0xFFFFFF) {
			throw new IOException("File "+packName+" is too large.");
		}

		sourceData = new byte[sourceFile.available()];
		sourceFile.read(sourceData);
		sourceFile.close();
	}

	public static void main(String[] args) throws Exception {

		System.out.println("LostVikingsUnpacker, v0.1, oFF_rus, 17 december 2008");
		System.out.println("Lost Vikings data.dat unpacker");
		System.out.println("Copyright (C) 2008 oFF_rus");
		System.out.println("E-mail: oFF_mail@mail.ru");
		System.out.println("");

		String dataDat = "./data.dat";
		Vector fileNumbers = new Vector();

		if (args.length > 1) {

			for (int i=0; i<args.length; i++) {
				if (args[i].equalsIgnoreCase("-f")) { // fileName
					if (args.length > i+1) {
						if (new File(args[i+1]).exists()) {
							dataDat = args[i+1];
						}
					}
				}
				if (args[i].equalsIgnoreCase("-n")) { // file to extract
					if (args.length > i+1) {
						fileNumbers.add(new Integer(Integer.parseInt(args[i+1], 16)));
					}
				}
			}

		}

		LostVikingsUnpacker lvu = new LostVikingsUnpacker(dataDat);
		lvu.unpack(fileNumbers);

	}
}