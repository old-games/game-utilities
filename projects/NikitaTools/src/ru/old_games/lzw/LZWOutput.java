package ru.old_games.lzw;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import org.apache.commons.io.EndianUtils;

public class LZWOutput {
	
	private ByteArrayOutputStream baos;
	private boolean[] types;
	
	private int currentPosition;
	private ByteArrayOutputStream tempBlock;
	
	private static boolean COMPRESSED = true;
	private static boolean UNCOMPRESSED = false;
	
	public int getCurrentSize() {
		return baos.size();
	}
	
	public LZWOutput() {		
		baos = new ByteArrayOutputStream();
		
		types = new boolean[8];
		for (int i=0; i<types.length; i++) {
			types[i] = UNCOMPRESSED;
		}
		
		tempBlock = new ByteArrayOutputStream();

		currentPosition = 0;
	}
	
	private void flushBuffer() throws IOException {
		int controlByte = 0;
		
		int one = 1;
		for (int i=0; i<currentPosition; i++) {
			if (types[i] == UNCOMPRESSED) {
				controlByte = controlByte | one;					
			}
			one = one << 1;
		}
		baos.write(controlByte);
		baos.write(tempBlock.toByteArray());
		tempBlock.reset();
	}
	
	public void writeUncompressedByte(int byteValue) throws IOException {
		tempBlock.write(byteValue);

		types[currentPosition] = UNCOMPRESSED;
		currentPosition++;
		
		if (currentPosition >= types.length) {
			flushBuffer();
			currentPosition = 0;
		}
	}
	
	public void writeCompressedBytesInfo(int pDictPosition, int blockSize) throws IOException {
		int dictPosition = pDictPosition;
		if (dictPosition < 0) {
			dictPosition += 0x1000;
		}
		
		int dictControl = 0;
		
		dictControl = dictControl | ((blockSize - 3) << 8); // number of bytes from this word: _A__
		dictControl = dictControl | (dictPosition & 0xFF) | ((dictPosition & 0xF00) << 4); // position of bytes from this word: B_BB

		EndianUtils.writeSwappedShort(tempBlock, (short) dictControl);

		types[currentPosition] = COMPRESSED;
		currentPosition++;
		
		if (currentPosition >= types.length) {
			flushBuffer();
			currentPosition = 0;
		}		
	}
	
	public byte[] getResult() throws IOException {
		if (currentPosition != 0) {
			flushBuffer();
		}
		
		baos.close();
		return baos.toByteArray();
	}

}
