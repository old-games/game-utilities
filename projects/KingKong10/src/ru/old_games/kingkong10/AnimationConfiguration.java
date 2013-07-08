package ru.old_games.kingkong10;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Collection;
import java.util.Collections;
import java.util.Map;
import java.util.TreeMap;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.math.NumberUtils;

public class AnimationConfiguration {
	
	private String framesDirectoryName;
	private int emptyFramesNumber;
	private Map<Integer, Integer> emptyFramesConfiguration;
	
	private String configFileName;

	/**
	 * Simple constructor.
	 * 
	 * @param fileName - name of configuration file
	 */
	public AnimationConfiguration(String fileName) {
		configFileName = fileName;
		emptyFramesConfiguration = new TreeMap<Integer, Integer>();
		emptyFramesNumber = 0;
	}

	/**
	 * Read information from configuration file
	 * 
	 * @throws IOException
	 */
	public void read() throws IOException {
		
		File configFile = new File(configFileName);		
		BufferedReader configReader = new BufferedReader(new InputStreamReader(new FileInputStream(configFile)));
		
		framesDirectoryName = configReader.readLine();
		
		String tempString = "";
		while (tempString != null) {
			tempString = configReader.readLine();
			if (tempString != null && NumberUtils.isDigits(tempString)) {
				String secondString = configReader.readLine();
				if (secondString != null && NumberUtils.isDigits(secondString)) {

					// two integers, first is frame number, second is skip count (number of empty frames)
					int frameNumber = Integer.parseInt(tempString);
					int emptyFrameSequenceLength = Integer.parseInt(secondString);
					
					emptyFramesConfiguration.put(frameNumber, emptyFrameSequenceLength);
					emptyFramesNumber += emptyFrameSequenceLength;
				}
			}
		}
		
		configReader.close();
	}

	/**
	 * Find frame files in {@link #framesDirectoryName}. Frame files should have .BMP extension and number as filenames.
	 * 
	 * @return collection of bmp files
	 * @throws IOException
	 */
	public Collection<File> findFrames() throws IOException {
		Collection<File> result = Collections.emptyList();

		File workDir = new File(framesDirectoryName);
		if (workDir.isDirectory()) {
			FileFilter filter = new ExtensionFileFilter("bmp");
			File[] files = workDir.listFiles(filter);

			TreeMap<Integer, File> sortedFrameFiles = new TreeMap<Integer, File>();
			for (int i=0; i<files.length; i++) {
				String frameName = FilenameUtils.getBaseName(files[i].getPath());
				if (NumberUtils.isDigits(frameName)) {
					int frameNumber = Integer.parseInt(frameName);
					sortedFrameFiles.put(frameNumber, files[i]);						
				}
			}
			result = sortedFrameFiles.values();
		} else {
			throw new IOException("directory \""+workDir.getAbsolutePath()+"\" doesn't exist");
		}
		
		return result;
	}

	public String getFramesDirectoryName() {
		return framesDirectoryName;
	}

	public int getEmptyFramesNumber() {
		return emptyFramesNumber;
	}

	public Map<Integer, Integer> getEmptyFramesConfiguration() {
		return emptyFramesConfiguration;
	}
}
