package ru.old_games.nikita;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.input.SwappedDataInputStream;

import ru.old_games.lzw.LZW;

public class LibReader {

	/**
	 * NL is the signature of library files (possible abbreviation from "Nikita Library")
	 */
	private static final byte[] LIBRARY_SIGNATURE = {0x4E,0x4C};
	
	/**
	 * size in bytes of one FAT record in library
	 */
	private static final int LIBRARY_HEADER_RECORD_SIZE = 0x1A;
	
	/**
	 * defalt encoding for filenames in FAT
	 */
	private static final String DEFAULT_CHARSET = "IBM866";
	
	/**
	 * read files from NL library
	 * 
	 * @param source - full content of NL file
	 * @return - list of {@link FatEntry}
	 * @throws Exception in case the provided source bytes do not contain decodeable NL file
	 */
	public static List<FatEntry> read(byte[] source) throws Exception {

		int sourceSize = source.length;
		SwappedDataInputStream is = new SwappedDataInputStream(new ByteArrayInputStream(source));

		byte[] signature = new byte[2];
		is.read(signature);
		if (!Arrays.equals(LIBRARY_SIGNATURE, signature)) {
			is.close();
			throw new Exception("not a NikitaLibrary file (wrong signature - no NL at start of file)");
		}
		
		int fileCount = is.readUnsignedShort();
		if (fileCount == 0) {
			is.close();
			throw new Exception("not supported version of NikitaLibrary (no file count after signature)");
		}

		int headerSize = fileCount * LIBRARY_HEADER_RECORD_SIZE;
		byte[] header = new byte[headerSize];
		is.read(header);
		header = decodeHeader(header);
		
		byte[] body = new byte[sourceSize - signature.length - 2 - headerSize];
		is.read(body);
		body = decodeBody(body);

		is.close();

		List<FatEntry> result = prepareList(header, body);

		return result;
	}
	
	private static byte[] decodeHeader(byte[] header) {

		int dh = 0;
		int lastDecodedByte = 0x11;
		int cl = (header.length & 0xFF);

		ByteArrayOutputStream os = new ByteArrayOutputStream(header.length);
		ByteArrayInputStream is = new ByteArrayInputStream(header);

		while (is.available() > 0) {
			int oneByte = is.read();

			int bh = lastDecodedByte;
			oneByte = subtractUnsignedBytes(oneByte, dh);			
			bh = (bh ^ cl) & 0xFF;
			oneByte = subtractUnsignedBytes(oneByte, bh);
			lastDecodedByte = oneByte;
			dh = (dh + 0xF) & 0xFF;
			cl = subtractUnsignedBytes(cl, 1);

			os.write(oneByte);
		}
		
		byte[] result = os.toByteArray();
		
		try {
			os.close();
			is.close();
		} catch (IOException e) {
			// there's no chance this will happen with ByteArrayXXStream
			e.printStackTrace(System.out);
		}

		return result;
	}

	private static int subtractUnsignedBytes(int source, int value) {
		int result = source - value;
		if (result < 0) {
			result += 256;
		}

		return (result & 0xFF);
	}
	
	private static byte[] decodeBody(byte[] body) {
		ByteArrayOutputStream os = new ByteArrayOutputStream(body.length);
		ByteArrayInputStream is = new ByteArrayInputStream(body);

		while (is.available() > 0) {
			int oneByte = is.read();

			oneByte = (~oneByte) & 0xFF;

			os.write(oneByte);
		}

		byte[] result = os.toByteArray();

		try {
			os.close();
			is.close();
		} catch (IOException e) {
			// there's no chance this will happen with ByteArrayXXStream
			e.printStackTrace(System.out);
		}

		return result;
	}

	/**
	 * Extracts (and unpacks) files from decoded NL-file. It is possible to receive
	 * in last record data from the end of the file (not listed in FAT). Example: OSADA/introx.dat
	 * contains new-type NL-library appended to the old-type library.
	 * 
	 * @param header decoded FAT of NL-file
	 * @param body decoded body of NL-file (data still LZW-packed)
	 * @return collection of {@link FatEntry}, from this NL-file
	 */
	private static List<FatEntry> prepareList(byte[] header, byte[] body) {
		List<FatEntry> result = new ArrayList<FatEntry>();

		ByteArrayInputStream headerStream = new ByteArrayInputStream(header);

		int fileCount = header.length / LIBRARY_HEADER_RECORD_SIZE;
		int maxFilePosition = 0;
		
		try {
			for (int i=0; i<fileCount; i++) {
				byte[] rawName = new byte[12];
				headerStream.read(rawName);

				int nameLength = 0;
				while (nameLength < 12 && rawName[nameLength] != 0) {
					nameLength++;
				}
				String filename = new String(rawName, 0, nameLength, DEFAULT_CHARSET);

				byte[] unknown = new byte[6];
				headerStream.read(unknown);

				int offset = EndianUtils.readSwappedInteger(headerStream);
				int size = EndianUtils.readSwappedInteger(headerStream);

				FatEntry libEntry = new FatEntry();
				libEntry.setFilename(filename);
				libEntry.setUnknown(unknown);
				libEntry.setOffset(offset);
				libEntry.setSize(size);

				int bodyOffset = offset - header.length - 4;
				byte[] fileBody = Arrays.copyOfRange(body, bodyOffset, bodyOffset + size);
				fileBody = LZW.decompress(fileBody, 0, fileBody.length, 0, false);
				libEntry.setBody(fileBody);

				if (offset+size > maxFilePosition) {
					maxFilePosition = bodyOffset + size;
				}

				result.add(libEntry);
			}
			
			if (maxFilePosition < body.length) {
				FatEntry libEntry = new FatEntry();
				libEntry.setFilename("unknown.bin");
				libEntry.setUnknown(new byte[6]);
				libEntry.setOffset(maxFilePosition);
				libEntry.setSize(body.length - maxFilePosition);
				byte[] fileBody = Arrays.copyOfRange(body, maxFilePosition, body.length);
				fileBody = decodeBody(fileBody);
				libEntry.setBody(fileBody);				
				result.add(libEntry);
			}
		} catch (IOException e) {
			// there's no chance this will happen with ByteArrayXXStream
			e.printStackTrace(System.out);
		}

		return result;
	}


}
