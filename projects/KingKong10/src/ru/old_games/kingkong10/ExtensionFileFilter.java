package ru.old_games.kingkong10;

import java.io.File;
import java.io.FileFilter;

import org.apache.commons.io.FilenameUtils;

public class ExtensionFileFilter implements FileFilter {

	private String ext;
	
	public ExtensionFileFilter(String extension) {
		ext = extension.toLowerCase();
	}

	@Override
	public boolean accept(File file) {
		if (FilenameUtils.getExtension(file.getPath()).toLowerCase().equals(ext)) {
			return true;
		} else {
			return false;
		}
	}


}
