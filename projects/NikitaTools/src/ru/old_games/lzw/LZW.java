package ru.old_games.lzw;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.util.LinkedList;

import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.input.SwappedDataInputStream;

public class LZW {
	
	private static boolean needLog = false;
	
	public static byte[] decompress(byte[] dat, int offset, int size, int filler, boolean containsUncompressedSize) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(dat, offset, size));

		int uncompressedSize = 0;
		if (containsUncompressedSize) {
			uncompressedSize = sdis.readInt();
		} else {
			uncompressedSize = Integer.MAX_VALUE;
		}
		
		LZWDictionary dict = new LZWDictionary(filler);
		
		int bitSelector = 0;
		int controlByte = 0;
		
		int readBytesCount = 0;
		
		try {
			do {
				if ((bitSelector & 0xFF) == 0) {
					// start new cycle (8 or less commands)
					bitSelector = 0x01;
					// read control byte from stream
					controlByte = sdis.readUnsignedByte();
					if (controlByte < 0) {
						sdis.close();
						return baos.toByteArray();
					}
				}
				
				if ((controlByte & bitSelector) == 0) {
					// read from dictionary
					int wordSize = 0;
					int wordPosition = 0;					
					int compressionInfo = 0;
					
					try {
						compressionInfo = sdis.readUnsignedShort();
					} catch (EOFException e) {
						sdis.close();
						return baos.toByteArray();
					}

					wordSize = ((compressionInfo & 0xF00) >> 8) + 3; // number of bytes from this word: _A__
					wordPosition = (compressionInfo & 0xFF) + ((compressionInfo & 0xF000) >> 4); // position of bytes from this word: B_BB
					
					if (needLog) System.out.println("read compressed bytes from dict pos: 0x"+Integer.toHexString(wordPosition)+" with size: "+wordSize);

					for (int i=0; i<wordSize; i++) {
						int oneByte = dict.read(wordPosition+i);
						dict.write(oneByte);						
						baos.write(oneByte);

						if (needLog) System.out.println("read byte #"+Integer.toHexString(readBytesCount)+" value = 0x"+Integer.toHexString(oneByte));
						if (needLog) readBytesCount++;
					}
				} else {
					// read byte from stream
					int oneByte = sdis.read();
					if (oneByte < 0) {
						sdis.close();
						return baos.toByteArray();
					}
					dict.write(oneByte);
					baos.write(oneByte);

					if (needLog) System.out.println("read uncompresseed byte #"+Integer.toHexString(readBytesCount)+" value = 0x"+Integer.toHexString(oneByte));
					if (needLog) readBytesCount++;
				}
				
				bitSelector = bitSelector << 1;
			} while (baos.size() < uncompressedSize);
		} finally {
			if (containsUncompressedSize && (baos.size() != uncompressedSize)) {
				System.out.println("LZW decompression ERROR! header file size = "+uncompressedSize+", real file size = "+baos.size());
			}
		}
		
		sdis.close();
		return baos.toByteArray();
	}

	public static byte[] compressFake(byte[] dat, int offset, int size, boolean writeUncompressedSize) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(dat, offset, size));
		
		boolean finish = false;
		int position = 0;
		
		if (writeUncompressedSize) {
			EndianUtils.writeSwappedInteger(baos, size);
		}
		
		baos.write(255);
		
		do {
			int oneByte = sdis.read();
			
			if (oneByte < 0) {
				finish = true;
			} else {
				baos.write(oneByte);
				position ++;

				if ((position % 8 == 0) && sdis.available() > 0) {
					baos.write(255);
				}
			}
			
		} while (!finish);
		
		sdis.close();
		return baos.toByteArray();		
	}
	

  	public static byte[] compress(byte[] dat, int offset, int size, int filler, boolean writeUncompressedSize) throws IOException {

		ByteArrayInputStream src = new ByteArrayInputStream(dat, offset, size);
		int readBytesCount = 0;

		LZWDictionary dict = new LZWDictionary(filler);
		LZWOutput lzw = new LZWOutput();
		
		LinkedList<Integer> currentWord = new LinkedList<Integer>();
		
		boolean skipRead = false;
		
		boolean wordFound = false;
		boolean wordPartFound = false;
		boolean wordBytesAreEqual = false;
		boolean wordBytesAreEqualExeptTheLast = false;
		
		int wordPosition = -1;
		int wordPartPosition = -1;
		
		boolean finish = false;
		do {
			int oneByte = -2;				
			if (!skipRead) {
				oneByte = src.read();
				if (needLog) System.out.println("read byte #"+Integer.toHexString(readBytesCount)+" value = 0x"+Integer.toHexString(oneByte));
				if (needLog) readBytesCount++;
			}			
			
			if (oneByte == -1) {
				finish = true;
				
				if (wordFound) {
					lzw.writeCompressedBytesInfo(wordPosition, currentWord.size());
					
					int bytesToRemove = currentWord.size(); 
					for (int i=0; i<bytesToRemove; i++) {
						int oldByte = currentWord.poll().intValue();
						dict.write(oldByte);
					}					
				} else if (wordBytesAreEqual) {
					int dictPosition = dict.getDictPosition();
					int lastByteInDicionary = dict.read(dictPosition-1);
					
					if ((currentWord.get(0).intValue() == lastByteInDicionary) && (currentWord.size() > 2)) {
						lzw.writeCompressedBytesInfo(dictPosition-1, currentWord.size());
						
						for (int i=0; i<currentWord.size(); i++) {
							dict.write(lastByteInDicionary);
						}						
					} else if ((currentWord.get(0).intValue() != lastByteInDicionary) && (currentWord.size() > 3)) {
						int firstByte = currentWord.poll().intValue();
						lzw.writeUncompressedByte(firstByte);
						dict.write(firstByte);
						
						lzw.writeCompressedBytesInfo(dictPosition, currentWord.size());
						
						for (int i=0; i<currentWord.size(); i++) {
							dict.write(lastByteInDicionary);
						}
					} else {
						int bytesToRemove = currentWord.size(); 
						for (int i=0; i<bytesToRemove; i++) {
							int oldByte = currentWord.poll().intValue();
							lzw.writeUncompressedByte(oldByte);
							dict.write(oldByte);
						}
					}					
				} else {
					int bytesToRemove = currentWord.size(); 
					for (int i=0; i<bytesToRemove; i++) {
						int oldByte = currentWord.poll().intValue();
						lzw.writeUncompressedByte(oldByte);
						dict.write(oldByte);
					}					
				}
				
			} else {
				if (!skipRead) {
					currentWord.add(new Integer(oneByte));
				} else {
					if (needLog) System.out.println("skip read");
					skipRead = false;
				}
				
				if (currentWord.size() > 2) {
					// search for means to compress current word
					int[] currentWordBytes = new int[currentWord.size()];
					for (int i=0; i<currentWord.size(); i++) {
						currentWordBytes[i] = currentWord.get(i).intValue();						
					}

					int dictPosition = dict.getDictPosition();
					int lastByteInDicionary = dict.read(dictPosition-1);					
					
					// check for equality of bytes (RLE-sort compression)
					wordBytesAreEqual = true;
					wordBytesAreEqualExeptTheLast = false;
					
					for (int i=0; i<currentWordBytes.length-1; i++) {
						if (currentWordBytes[i] != currentWordBytes[i+1]) {
							if (wordBytesAreEqual && 
									(i == currentWordBytes.length-2) && 
									((currentWordBytes.length > 3) && (currentWordBytes[0] == lastByteInDicionary) || (currentWordBytes.length > 4))
								) {
								wordBytesAreEqualExeptTheLast = true;
							}
							wordBytesAreEqual = false;
						}
					}
					
					// check for presence of word in dictionary
					wordPartFound = wordFound;
					wordPartPosition = wordPosition; 
					
					wordPosition = dict.search(currentWordBytes);
					if (wordPosition >= 0) {
						wordFound = true;
						wordPartFound = false;
					} else {
						wordFound = false;
					}
					
					if (needLog) System.out.println("currentWord size: "+currentWord.size());
					if (needLog) System.out.println("wordFound: "+wordFound);
					if (needLog) System.out.println("wordPartFound: "+wordPartFound);
					if (needLog) System.out.println("wordBytesAreEqualExceptTheLast: "+wordBytesAreEqualExeptTheLast);
					if (needLog) System.out.println("wordBytesAreEqual: "+wordBytesAreEqual);
					if (needLog) System.out.println("dictPosition: "+dictPosition);
					if (needLog) System.out.println("wordPosition: "+wordPosition);
					if (needLog) System.out.println("wordPartPosition: "+wordPartPosition);
					if (needLog) System.out.println("lzwSize(+4): "+lzw.getCurrentSize()+4);
			
					if (wordBytesAreEqual && (currentWord.size() == 18) && (lastByteInDicionary == currentWord.get(0).intValue())) {
						if (needLog) System.out.println("do 1.");

						lzw.writeCompressedBytesInfo(dictPosition-1, currentWord.size());							
						
						for (int i=0; i<currentWord.size(); i++) {
							dict.write(lastByteInDicionary);
						}
						
						currentWord.clear();
						
						wordFound = false;
						wordPartFound = false;
						wordBytesAreEqual = false;
						wordBytesAreEqualExeptTheLast = false;
						
						wordPosition = -1;
						wordPartPosition = -1;						
					} else if (wordBytesAreEqual && (currentWord.size() == 19) && (lastByteInDicionary != currentWord.get(0).intValue())) {
						if (needLog) System.out.println("do 2.");

						int firstByte = currentWord.poll().intValue();
						lzw.writeUncompressedByte(firstByte);
						dict.write(firstByte);
						
						lzw.writeCompressedBytesInfo(dictPosition, currentWord.size());
						
						for (int i=0; i<currentWord.size(); i++) {
							dict.write(firstByte);
						}
						
						currentWord.clear();

						wordFound = false;
						wordPartFound = false;
						wordBytesAreEqual = false;
						wordBytesAreEqualExeptTheLast = false;
						
						wordPosition = -1;
						wordPartPosition = -1;						
					} else if (wordFound && (currentWord.size() == 18)) {
						lzw.writeCompressedBytesInfo(wordPosition, currentWord.size());
						if (needLog) System.out.println("do 3.");
						
						int bytesToRemove = currentWord.size(); 
						for (int i=0; i<bytesToRemove; i++) {
							int oldByte = currentWord.poll().intValue();
							dict.write(oldByte);
						}

						wordFound = false;
						wordPartFound = false;
						wordBytesAreEqual = false;
						wordBytesAreEqualExeptTheLast = false;
						
						wordPosition = -1;
						wordPartPosition = -1;						
					} else if (wordBytesAreEqualExeptTheLast && !wordFound) {
						if (needLog) System.out.println("do 4.");

						int firstByte = currentWord.get(0).intValue();
						if (firstByte != lastByteInDicionary) {
							firstByte = currentWord.poll().intValue();
							lzw.writeUncompressedByte(firstByte);
							dict.write(firstByte);
							dictPosition = dict.getDictPosition();
						}

						lzw.writeCompressedBytesInfo(dictPosition-1, currentWord.size()-1);
						
						int bytesToRemove = currentWord.size()-1; 
						for (int i=0; i<bytesToRemove; i++) {
							int oldByte = currentWord.poll().intValue();
							dict.write(oldByte);
						}

						wordFound = false;
						wordPartFound = false;
						wordBytesAreEqual = false;
						wordBytesAreEqualExeptTheLast = false;
						
						wordPosition = -1;
						wordPartPosition = -1;
					} else if (wordPartFound && !wordBytesAreEqual) {
						if (needLog) System.out.println("do 5.");

						lzw.writeCompressedBytesInfo(wordPartPosition, currentWord.size()-1);
						
						int bytesToRemove = currentWord.size()-1; 
						for (int i=0; i<bytesToRemove; i++) {
							int oldByte = currentWord.poll().intValue();
							dict.write(oldByte);
						}
						
						wordFound = false;
						wordPartFound = false;
						wordBytesAreEqual = false;
						wordBytesAreEqualExeptTheLast = false;
						
						wordPosition = -1;
						wordPartPosition = -1;						
					} else if (!wordFound && !wordPartFound && !wordBytesAreEqual && !wordBytesAreEqualExeptTheLast) {
						if (needLog) System.out.println("do 6.");

						int uncompressedByte = currentWord.poll().intValue();
						lzw.writeUncompressedByte(uncompressedByte);
						dict.write(uncompressedByte);
						
						if (currentWord.size() > 2) {
							skipRead = true;
						}
					}
				}
			}
		} while (!finish);
		
		ByteArrayOutputStream result = new ByteArrayOutputStream();
		if (writeUncompressedSize) {
			EndianUtils.writeSwappedInteger(result, size);
		}
		result.write(lzw.getResult());		
		
		return result.toByteArray();		
	}

}
