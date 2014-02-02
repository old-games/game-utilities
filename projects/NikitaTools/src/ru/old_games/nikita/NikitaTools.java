package ru.old_games.nikita;

import java.io.IOException;
import java.util.Arrays;

/**
 * Tools for Nikita Ltd.'s games
 * 
 * @author oFF_rus
 */
public class NikitaTools {
	
	/**
	 * Help info about options of the program 
	 */
	private static String[] HELP = {
		"-u <filePath> [<filePath>...] : decode and unpack library file",
	};
	
	/**
	 * Information about program and author 
	 */
	private static String[] BANNER = {
		"",
		"File tools for Nikia Ltd.'s games",
		"created by oFF_rus - off_mail@mail.ru for old-games.ru",
		"",
		"use -? to get help",
		""
	};

	/**
	 * Write text info to standard output stream
	 * 
	 * @param info - strings with information
	 * @param logger - logger, used to display info
	 */
	private static void showInformation(String[] info) {
		for (String oneTextLine: info) {
			System.out.println(oneTextLine);
		}
		System.out.println();
	}

	/**
	 * Main method of this application.
	 * 
	 * @param args - command-line arguments
	 * @throws IOException
	 */
	public static void main(String[] args) throws IOException {
		showInformation(BANNER);
		
		for (int i=0; i<args.length; i++) {
			if (args[i].equals("-?")) {
				showInformation(HELP);
			} else if (args[i].toLowerCase().equals("-u") && args.length > i+1) {
				String[] files = Arrays.copyOfRange(args, i+1, args.length);
				Unpacker.process(files);
			}
		}
	}


}
