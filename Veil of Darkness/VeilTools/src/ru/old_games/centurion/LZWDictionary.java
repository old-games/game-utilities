package ru.old_games.centurion;

public class LZWDictionary {

	private final int DICT_SIZE = 0x1000;
	private final int DICT_START = 0xFEE;
	private final int MAX_DICT_POS = DICT_SIZE - 1;

	private int[] dict = new int[DICT_SIZE];
	private int dictPosition = DICT_START;
	private int processedBytesCount = 0;

	public LZWDictionary(int filler) {
		for (int i=0; i<DICT_SIZE; i++) {
			dict[i] = filler;
		}
	}

	public void write(int oneByte) {
		dict[dictPosition] = oneByte;
		dictPosition++;
		dictPosition = dictPosition & MAX_DICT_POS;
		
		processedBytesCount++;
	}

	public int read(int i) {
		int pos = i;
		if (pos < 0) {
			pos += DICT_SIZE;
		}

		return dict[i & MAX_DICT_POS];
	}

	public int search(int[] currentWordBytes) {
		int result = -1;
		
		int searchLength = Math.min(DICT_SIZE, processedBytesCount) - currentWordBytes.length;
		
		for (int i=0; i<searchLength; i++) {
			int startPosition = dictPosition - i - currentWordBytes.length;
			if (startPosition < 0) {
				startPosition += DICT_SIZE;
			}

			boolean possiblyFound = true;
			for (int j=0; j<currentWordBytes.length; j++) {
				if (dict[(startPosition + j) & 0xFFF] != currentWordBytes[j]) {
					possiblyFound = false;
				}
			}
			
			if (possiblyFound) {
				result = startPosition;
				return result;
			}
		}
		
		return result;
	}

	public int getDictPosition() {
		return dictPosition;
	}

}
