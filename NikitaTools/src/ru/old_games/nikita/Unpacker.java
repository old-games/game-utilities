package ru.old_games.nikita;

import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;

public class Unpacker {


	/**
	 * unpack NL files. For every library it's content will be unpacked to "originalLibName.files" directory
	 * 
	 * @param files - command line arguments, paths of the files to unpack
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws EOFException
	 */
	static void process(String[] files) throws FileNotFoundException, IOException, EOFException {
		
		for (String oneFile : files) {
			System.out.print("Processing library file \""+oneFile+"\":");

			File file = new File(oneFile);
			if (file.exists() && file.isFile()) {
				try {
					FileInputStream fis = new FileInputStream(file);
					byte[] fileBody = new byte[(int) file.length()];
					fis.read(fileBody);
					fis.close();
					
					List<FatEntry> libFiles = LibReader.read(fileBody);
					System.out.println(" found "+libFiles.size() + " files");

					saveFiles(libFiles, file);
					
				} catch (Exception e) {
					System.out.println(" error!");
					e.printStackTrace(System.out);
					System.out.println();
				}
			} else {
				System.out.println(" error, "+(file.exists()?"path is a directory, need file.":"file does'n exist."));
				System.out.println();
			}
		}
	}




	/**
	 * Save unpacked library files to "originalLibName.files" directory
	 * 
	 * @param libFiles - list of decrypted files from some library
	 * @param sourceFile - original NL file
	 * @throws IOException
	 */
	private static void saveFiles(List<FatEntry> libFiles, File sourceFile) throws IOException {

		File newFile = new File(sourceFile.getAbsolutePath() + ".files");
		newFile.mkdir();

		for (FatEntry oneFile : libFiles) {
			System.out.println("Extract "+oneFile.getFilename()+", packed size="+oneFile.getSize()+", unpacked size="+oneFile.getBody().length);
			String newFileName = newFile.getAbsolutePath() + File.separator + oneFile.getFilename();
			FileOutputStream fos = new FileOutputStream(newFileName);
			fos.write(oneFile.getBody());
			fos.close();
		}
		
		System.out.println("all files unpacked to \""+newFile.getAbsolutePath()+"\"");
		System.out.println();
	}


}
