// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   VeilTools.java

package ru.old_games.veil;

import java.io.IOException;
import java.io.PrintStream;

// Referenced classes of package ru.old_games.veil:
//            ResourceConverter, TextConverter

public class VeilTools {

	public VeilTools() {
	}

	public static void main(String args[]) throws IOException {
		System.out.println("Veil of Darkness tools");
		System.out.println("created by oFF_rus (off_mail@mail.ru), bjfn for old-games.ru, 2010 - 2017");
		if (args.length < 2) {
			System.out.println("\nusage: java -jar VeilTools.jar /action file\n");
			System.out.println(
					"\naction /ER file [/D] - extract resources from lib (RES1, RESOURCE, ROOMS) file, D - save debug info");
			System.out.println("example: java -jar VeilTools.jar /ER RESOURCE /D");
			System.out.println("\naction /ET file - extract texts from TEXT file and words from A");
			System.out.println("example: java -jar VeilTools.jar /ET TEXT");
			System.out.println("\naction /EC file - extract texts from CODE.1 file");
			System.out.println("example: java -jar VeilTools.jar /EC CODE.1");
			System.out.println("\naction /EI file - extract INTERACT lib file");
			System.out.println("example: java -jar VeilTools.jar /EC CODE.1");
			System.out.println("\naction /UR file - update lib (RESOURCE) file");
			System.out.println("example: java -jar VeilTools.jar /UR RESOURCE");
			System.out.println("\naction /UT file - update TEXT and A files (also requires INTERACT file)");
			System.out.println("example: java -jar VeilTools.jar /UT TEXT");
			System.out.println("\naction /UC file - update CODE.1 file");
			System.out.println("example: java -jar VeilTools.jar /UC CODE.1");
		} else if (args[0].toUpperCase().equals("/ER")) {
			boolean needDebug = false;
			if (args.length > 2 && args[2].toUpperCase().equals("/D"))
				needDebug = true;
			ResourceConverter.extract(args[1], needDebug, false);
		} else if (args[0].toUpperCase().equals("/ET"))
			TextConverter.text2xls(args[1]);
		else if (args[0].toUpperCase().equals("/EC"))
			TextConverter.exe2xls(args[1]);
		else if (args[0].toUpperCase().equals("/EI"))
			ResourceConverter.extract(args[1], false, true);
		else if (args[0].toUpperCase().equals("/UR"))
			ResourceConverter.update(args[1]);
		else if (args[0].toUpperCase().equals("/UT"))
			TextConverter.xls2text(args[1]);
		else if (args[0].toUpperCase().equals("/UC"))
			TextConverter.xls2exe(args[1]);
		else {
			System.out.println("ERROR: Unsupported command: "+args[0]);
		}
	}
}
