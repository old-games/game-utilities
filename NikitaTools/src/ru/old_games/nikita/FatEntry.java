package ru.old_games.nikita;

public class FatEntry {
	
	/**
	 * filename (DOS format 8+3)
	 */
	private String filename;
	/**
	 * unknown 6 bytes in FAT (it's possible that one of them contains the "compressed" flag)
	 */
	private byte[] unknown;
	/**
	 * absolute offset of file in NL-file
	 */
	private int offset;
	/**
	 * size of packed file
	 */
	private int size;
	/**
	 * body of file
	 */
	private byte[] body;
	
	public String getFilename() {
		return filename;
	}
	public void setFilename(String filename) {
		this.filename = filename;
	}
	public byte[] getUnknown() {
		return unknown;
	}
	public void setUnknown(byte[] unknown) {
		this.unknown = unknown;
	}
	public int getOffset() {
		return offset;
	}
	public void setOffset(int offset) {
		this.offset = offset;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}
	public byte[] getBody() {
		return body;
	}
	public void setBody(byte[] body) {
		this.body = body;
	}

}
