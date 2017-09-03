// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   TextConverter.java

package ru.old_games.veil;

import java.io.*;
import java.nio.file.*;
import java.util.*;
import org.apache.commons.io.EndianUtils;
import org.apache.commons.io.input.SwappedDataInputStream;
import org.apache.poi.hssf.usermodel.*;

// Referenced classes of package ru.old_games.veil:
//            LibFile

public class TextConverter
{

    public TextConverter()
    {
    }
    
    public static void text2xls(String fileName)
        throws IOException
    {
        resources2xls(fileName, 4, 218);
		Path par = Paths.get(fileName).getParent();
		String aname = (null!=par ? par + File.pathSeparator : "") + "A";
        resources2xls(aname, 2, 0);
    }

    private static void resources2xls(String fileName, int fatRecordSize, int xorValue)
        throws IOException
    {
        File file = new File(fileName);
        byte rawData[] = new byte[(int)file.length()];
        FileInputStream fis = new FileInputStream(file);
        fis.read(rawData);
        fis.close();
        LibFile libFile = new LibFile(rawData, fatRecordSize, false);
        List rawMessages = libFile.getResources();
        byte xlsFile[] = convert2xls(rawMessages, "Veil of Darkness", xorValue, null);
        FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(fileName))).append(".xls").toString());
        fos.write(xlsFile);
        fos.close();
    }

    public static void exe2xls(String srcFileName)
        throws IOException
    {
        byte dseg[] = new byte[65535];
        int dsegLength = 0;
        FileInputStream fis = new FileInputStream(srcFileName);
        fis.skip(0x11390L);
        dsegLength = fis.read(dseg);
        fis.close();
        List messages = new ArrayList();
        SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(dseg, 0, dsegLength));
        sdis.skip(2824L);
        for(int i = 0; i < 25; i++)
        {
            int messageStart = sdis.readUnsignedShort();
            addString(dseg, dsegLength, messages, messageStart);
        }

        sdis.close();
        byte excel[] = convert2xls(messages, "Intro", 0, null);
        messages.clear();
        sdis = new SwappedDataInputStream(new ByteArrayInputStream(dseg, 0, dsegLength));
        sdis.skip(6266L);
        for(int i = 0; i < 21; i++)
        {
            int filledLinksCount = sdis.readUnsignedShort();
            if(filledLinksCount != 65535)
            {
                for(int j = 0; j < 5; j++)
                {
                    int messageStart = sdis.readUnsignedShort();
                    addString(dseg, dsegLength, messages, messageStart);
                }

            }
        }

        excel = convert2xls(messages, "Authors", 0, excel);
        FileOutputStream fos = new FileOutputStream(new File((new StringBuilder(String.valueOf(srcFileName))).append(".xls").toString()));
        fos.write(excel);
        fos.close();
    }

    public static void xls2text(String fileName)
        throws IOException
    {
		Path par = Paths.get(fileName).getParent();
		String aname = (null!=par ? par + File.pathSeparator : "") + "A";
		Map<Integer, Integer> newOrder = new HashMap<Integer, Integer>();
        xls2messages(aname, 2, 0, true, newOrder);
        xls2messages(fileName, 4, 218, false, newOrder);
    }
    
    private static List<Object> reorderMessages(List<Object> messages, Map<Integer, Integer> reorderMap) {
		//build reverse map
    		HashMap<Integer,Integer> rev = new HashMap<Integer, Integer>();
		//first index(0) at msg.last - 1
    		int zero = messages.size()-2;
    		for(Map.Entry<Integer, Integer> entry : reorderMap.entrySet()) {
    			rev.put(zero - entry.getValue(), zero - entry.getKey());
    		}
    		List<Object> ret = new ArrayList<Object>();
    		for (int i=0; i<messages.size(); ++i) {
			ret.add( messages.get(rev.containsKey(i) ? rev.get(i) : i) );
    		}
    		return ret;
    }

    private static void xls2messages(String fileName, int fatRecordSize, int xorValue, boolean isWordList, Map<Integer,Integer> reorderMap)
        throws IOException
    {
        File xlsFile = new File((new StringBuilder(String.valueOf(fileName))).append(".xls").toString());
        byte excel[] = new byte[(int)xlsFile.length()];
        FileInputStream fis = new FileInputStream(xlsFile);
        fis.read(excel);
        fis.close();
        List messages = convert2messages(excel, "Veil of Darkness", xorValue, isWordList);        
        if(isWordList)
        {
            String parentPath = xlsFile.getParent();
            File interactFile;
            if(parentPath != null)
                interactFile = new File((new StringBuilder(String.valueOf(parentPath))).append(File.pathSeparator).append("INTERACT").toString());
            else
                interactFile = new File("INTERACT");
            byte interact[] = new byte[(int)interactFile.length()];
            fis = new FileInputStream(interactFile);
            fis.read(interact);
            fis.close();
            LibFile libFile = new LibFile(interact, 4, true);
            List rawInteract = libFile.getResources();
            reorderMap.putAll(prepareWords(messages, rawInteract));
            byte newLibFile[] = libFile.composeLibFile();
            FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(interactFile.getCanonicalPath()))).append(".new").toString());
            fos.write(newLibFile);
            fos.close();
        }else {
        		messages = reorderMessages(messages, reorderMap);
        }
        LibFile libFile = new LibFile(fatRecordSize);
        libFile.setResources(messages);
        byte newLibFile[] = libFile.composeLibFile();
        FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(fileName))).append(".new").toString());
        fos.write(newLibFile);
        fos.close();
    }

    private static Map<Integer, Integer> prepareWords(List messages, List rawInteract)
    {
        class _cls1StringComparator
            implements Comparator
        {

            public int compare(String o1, String o2)
            {
                return o1.compareToIgnoreCase(o2);
            }

            public int compare(Object obj, Object obj1)
            {
                return compare((String)obj, (String)obj1);
            }

            _cls1StringComparator()
            {
            }
        }

        _cls1StringComparator comparator = new _cls1StringComparator();
        TreeMap sortedMessages = new TreeMap(comparator);
        List originalOrderedStrings = new ArrayList();
        for(int i = 0; i < messages.size(); i++)
        {
            byte oneMessage[] = (byte[])messages.get(i);
            int realLength = 0;
            for(int j = 0; j < oneMessage.length; j++)
            {
                if(oneMessage[j] != 0)
                    continue;
                realLength = j;
                break;
            }

            String oneString;
            try
            {
                oneString = new String(oneMessage, 0, realLength, "CP866");
            }
            catch(UnsupportedEncodingException e)
            {
                oneString = new String(oneMessage, 0, realLength);
                e.printStackTrace();
            }
            originalOrderedStrings.add(oneString);
            sortedMessages.put(oneString, Integer.valueOf(i));
        }

        List source = new ArrayList(messages);
        Map<Integer, Integer> newOrder = new HashMap<Integer, Integer>();
        Collection oldPositions = sortedMessages.values();
        Iterator iterator = oldPositions.iterator();
        for(int position = 0; iterator.hasNext(); position++)
        {
            Integer oldPosition = (Integer)iterator.next();
            messages.set(position, (byte[])source.get(oldPosition.intValue()));
            newOrder.put(oldPosition, Integer.valueOf(position));
        }

        for(int i = 0; i < rawInteract.size(); i++)
        {
            byte oneResource[] = (byte[])rawInteract.get(i);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            try
            {
                SwappedDataInputStream sdis = new SwappedDataInputStream(new ByteArrayInputStream(oneResource));
                for(int j = 0; j < 20; j++)
                {
                    int value = sdis.read();
                    baos.write(value);
                }

                int size = sdis.readUnsignedShort();
                EndianUtils.writeSwappedShort(baos, (short)size);
                int readCount = 0;
                int command = 0;
                do
                {
                    command = sdis.readUnsignedShort();
                    EndianUtils.writeSwappedShort(baos, (short)command);
                    readCount += 2;
                    if(command == 65534)
                        do
                        {
                            command = sdis.readUnsignedShort();
                            EndianUtils.writeSwappedShort(baos, (short)command);
                            readCount += 2;
                            switch(command)
                            {
                            case 6: // '\006'
                            case 8: // '\b'
                            {
                                int data = 0;
                                do
                                {
                                    data = sdis.readUnsignedShort();
                                    if(data != 65532 && command == 6)
                                    {
                                        String key = (String)originalOrderedStrings.get(data);
                                        Integer oldPosition = (Integer)sortedMessages.get(key);
                                        Integer newPosition = (Integer)newOrder.get(oldPosition);
                                        data = newPosition.intValue();
                                    }
                                    EndianUtils.writeSwappedShort(baos, (short)data);
                                    readCount += 2;
                                } while(data != 65532);
                                command = data;
                                break;
                            }

                            case 12: // '\f'
                            case 17: // '\021'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                readCount += 2;
                                break;
                            }

                            case 9: // '\t'
                            case 10: // '\n'
                            case 11: // '\013'
                            case 14: // '\016'
                            case 15: // '\017'
                            case 16: // '\020'
                            case 18: // '\022'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                int data2 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data2);
                                readCount += 4;
                                break;
                            }

                            default:
                            {
                                System.err.println((new StringBuilder("unknow command in FFFE block of file ")).append(Integer.toHexString(i)).append(" : ").append(Integer.toHexString(command)).append(", position: ").append(Integer.toHexString((readCount - 2) + 20 + 2)).toString());
                                break;
                            }

                            case 4: // '\004'
                            case 5: // '\005'
                            case 7: // '\007'
                            case 13: // '\r'
                            case 19: // '\023'
                            case 65532: 
                                break;
                            }
                        } while(command != 65532);
                    else
                    if(command == 65533)
                        do
                        {
                            command = sdis.readUnsignedShort();
                            EndianUtils.writeSwappedShort(baos, (short)command);
                            readCount += 2;
                            switch(command)
                            {
                            case 21: // '\025'
                            {
                                int data = sdis.readUnsignedShort();
                                if(data < originalOrderedStrings.size())
                                {
                                    String key = (String)originalOrderedStrings.get(data);
                                    Integer oldPosition = (Integer)sortedMessages.get(key);
                                    Integer newPosition = (Integer)newOrder.get(oldPosition);
                                    data = newPosition.intValue();
                                } else
                                {
                                    System.err.println((new StringBuilder("error? data = ")).append(Integer.toHexString(data)).toString());
                                }
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                readCount += 2;
                                break;
                            }

                            case 20: // '\024'
                            case 22: // '\026'
                            case 25: // '\031'
                            case 26: // '\032'
                            case 30: // '\036'
                            case 31: // '\037'
                            case 33: // '!'
                            case 34: // '"'
                            case 40: // '('
                            case 42: // '*'
                            case 44: // ','
                            case 45: // '-'
                            case 46: // '.'
                            case 54: // '6'
                            case 55: // '7'
                            case 56: // '8'
                            case 58: // ':'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                readCount += 2;
                                break;
                            }

                            case 24: // '\030'
                            case 41: // ')'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                int data2 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data2);
                                readCount += 4;
                                break;
                            }

                            case 43: // '+'
                            {
                                int data = 0;
                                do
                                {
                                    data = sdis.readUnsignedShort();
                                    EndianUtils.writeSwappedShort(baos, (short)data);
                                    readCount += 2;
                                } while(data != 65531);
                                break;
                            }

                            case 57: // '9'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                int data2 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data2);
                                int data3 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data3);
                                readCount += 6;
                                break;
                            }

                            case 59: // ';'
                            {
                                int data = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data);
                                int data2 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data2);
                                int data3 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data3);
                                int data4 = sdis.readUnsignedShort();
                                EndianUtils.writeSwappedShort(baos, (short)data4);
                                readCount += 8;
                                break;
                            }

                            default:
                            {
                                System.err.println((new StringBuilder("unknow command in FFFD block of file ")).append(Integer.toHexString(i)).append(" : ").append(Integer.toHexString(command)).append(", position: ").append(Integer.toHexString((readCount - 2) + 20 + 2)).toString());
                                break;
                            }

                            case 23: // '\027'
                            case 27: // '\033'
                            case 28: // '\034'
                            case 29: // '\035'
                            case 32: // ' '
                            case 35: // '#'
                            case 36: // '$'
                            case 37: // '%'
                            case 38: // '&'
                            case 39: // '\''
                            case 47: // '/'
                            case 48: // '0'
                            case 49: // '1'
                            case 50: // '2'
                            case 51: // '3'
                            case 52: // '4'
                            case 53: // '5'
                            case 65532: 
                                break;
                            }
                        } while(command != 65532);
                } while(command != 65535);
                if(readCount != size)
                    System.err.println((new StringBuilder("Error parsing interact codes readCount = ")).append(readCount).append(", size = ").append(size).toString());
                sdis.close();
            }
            catch(IOException e)
            {
                e.printStackTrace();
            }
            rawInteract.set(i, baos.toByteArray());
        }
        return newOrder;

    }

    public static void xls2exe(String fileName)
        throws IOException
    {
        File srcFile = new File(fileName);
        byte src[] = new byte[(int)srcFile.length()];
        FileInputStream fis = new FileInputStream(srcFile);
        fis.read(src);
        fis.close();
        File xlsFile = new File((new StringBuilder(String.valueOf(fileName))).append(".xls").toString());
        byte excel[] = new byte[(int)xlsFile.length()];
        fis = new FileInputStream(xlsFile);
        fis.read(excel);
        fis.close();
        List messages = convert2messages(excel, "Intro", 0, false);
        int messagesSize = calculateMessagesSize(messages);
        if(messagesSize > 1585 && messages.size() == 25)
        {
            System.err.println("Can't update intro text - new text is too large");
        } else
        {
            ByteArrayOutputStream links = new ByteArrayOutputStream();
            ByteArrayOutputStream data = new ByteArrayOutputStream();
            int offset = 4378;
            for(Iterator iterator = messages.iterator(); iterator.hasNext();)
            {
                byte oneMessage[] = (byte[])iterator.next();
                if(oneMessage.length > 1)
                {
                    EndianUtils.writeSwappedShort(links, (short)offset);
                    data.write(oneMessage);
                    offset += oneMessage.length;
                } else
                {
                    links.write(0);
                    links.write(0);
                }
            }

            byte linkArray[] = links.toByteArray();
            byte dataArray[] = data.toByteArray();
            for(int i = 0; i < linkArray.length; i++)
                src[(int)(0x11e98L + (long)i)] = linkArray[i];

            for(int i = 0; i < dataArray.length; i++)
                src[(int)(0x124aaL + (long)i)] = dataArray[i];

        }
        messages = convert2messages(excel, "Authors", 0, false);
        messagesSize = calculateMessagesSize(messages);
        if(messagesSize > 739 && messages.size() == 105)
        {
            System.err.println("Can't update intro text - new text is too large");
        } else
        {
            ByteArrayOutputStream links = new ByteArrayOutputStream();
            ByteArrayOutputStream data = new ByteArrayOutputStream();
            int offset = 6518;
            int count = 1;
            int filledCount = 0;
            ByteArrayOutputStream linksTemp = new ByteArrayOutputStream();
            for(Iterator iterator1 = messages.iterator(); iterator1.hasNext();)
            {
                byte oneMessage[] = (byte[])iterator1.next();
                if(oneMessage.length > 1)
                {
                    EndianUtils.writeSwappedShort(linksTemp, (short)offset);
                    data.write(oneMessage);
                    offset += oneMessage.length;
                    filledCount++;
                } else
                {
                    linksTemp.write(0);
                    linksTemp.write(0);
                }
                if(++count > 5)
                {
                    EndianUtils.writeSwappedShort(links, (short)filledCount);
                    links.write(linksTemp.toByteArray());
                    linksTemp.reset();
                    filledCount = 0;
                    count = 1;
                }
            }

            linksTemp.close();
            byte linkArray[] = links.toByteArray();
            byte dataArray[] = data.toByteArray();
            for(int i = 0; i < linkArray.length; i++)
                src[(int)(0x12c0aL + (long)i)] = linkArray[i];

            for(int i = 0; i < dataArray.length; i++)
                src[(int)(0x12d06L + (long)i)] = dataArray[i];

        }
        FileOutputStream fos = new FileOutputStream((new StringBuilder(String.valueOf(fileName))).append(".new").toString());
        fos.write(src);
        fos.close();
    }

    private static int calculateMessagesSize(List messages)
    {
        int result = 0;
        for(Iterator iterator = messages.iterator(); iterator.hasNext();)
        {
            byte oneMessage[] = (byte[])iterator.next();
            if(oneMessage.length > 1)
                result += oneMessage.length;
        }

        return result;
    }

    private static void addString(byte dseg[], int dsegLength, List messages, int messageStart)
    {
        if(messageStart != 0)
        {
            int messageEnd;
            for(messageEnd = messageStart; dseg[messageEnd] != 0; messageEnd++);
            if(messageEnd == messageStart)
                messages.add(new byte[0]);
            else
            if(dseg[messageEnd] == 0)
            {
                byte oneMessage[] = Arrays.copyOfRange(dseg, messageStart, messageEnd);
                messages.add(oneMessage);
            } else
            if(messageEnd == dsegLength - 1)
                messages.add(new byte[0]);
        } else
        {
            messages.add(new byte[0]);
        }
    }

    private static byte[] convert2xls(List messages, String sheetName, int xorKey, byte excel[])
        throws IOException
    {
        HSSFWorkbook wb = null;
        if(excel == null)
        {
            wb = new HSSFWorkbook();
        } else
        {
            ByteArrayInputStream bais = new ByteArrayInputStream(excel);
            wb = new HSSFWorkbook(bais);
            bais.close();
        }
        HSSFSheet sheet = wb.createSheet(sheetName);
        HSSFCellStyle style = wb.createCellStyle();
        style.setWrapText(true);
        for(int i = 0; i < messages.size(); i++)
        {
            byte resource[] = (byte[])messages.get(i);
            byte realBytes[] = (byte[])null;
            realBytes = new byte[resource.length];
            int realLength = realBytes.length;
            String oneMessage = "";
            if(resource.length > 0)
            {
                for(int j = 0; j < resource.length; j++)
                {
                    if(resource[j] != 0)
                    {
                        realBytes[j] = (byte)(resource[j] ^ xorKey);
                        continue;
                    }
                    realLength = j;
                    break;
                }

                oneMessage = new String(realBytes, 0, realLength, "CP866");
            } else
            {
                oneMessage = "";
            }
            HSSFRow row = sheet.createRow(sheet.getLastRowNum() + 1);
            HSSFCell cell = row.createCell(0);
            cell.setCellValue(new HSSFRichTextString(oneMessage));
            cell.setCellStyle(style);
            cell = row.createCell(1);
            cell.setCellValue(new HSSFRichTextString(oneMessage));
            cell.setCellStyle(style);
        }

        sheet.setColumnWidth(0, 15360);
        sheet.setColumnWidth(1, 15360);
        HSSFRow row = sheet.createRow(sheet.getLastRowNum() + 1);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue(new HSSFRichTextString("===="));
        cell = row.createCell(1);
        cell.setCellValue(new HSSFRichTextString("===="));
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        wb.write(baos);
        baos.close();
        return baos.toByteArray();
    }

    private static List convert2messages(byte excel[], String sheetName, int xorKey, boolean isWordList)
        throws IOException
    {
        List messages = new ArrayList();
        ByteArrayInputStream bais = new ByteArrayInputStream(excel);
        HSSFWorkbook wb = new HSSFWorkbook(bais);
        bais.close();
        HSSFSheet sheet = wb.getSheet(sheetName);
        if(sheet != null)
        {
            for(int i = sheet.getFirstRowNum(); i < sheet.getLastRowNum(); i++)
            {
                HSSFRow row = sheet.getRow(i);
                if(row == null)
                    continue;
                HSSFCell cell = row.getCell(1);
                String value = cell.getRichStringCellValue().toString();
                if(isWordList)
                    value = value.toLowerCase();
                if(value.equals("===="))
                    break;
                byte srcBytes[] = value.getBytes("CP866");
                byte resource[] = new byte[srcBytes.length + 1];
                for(int j = 0; j < srcBytes.length; j++)
                    resource[j] = (byte)(srcBytes[j] ^ xorKey);

                resource[resource.length - 1] = 0;
                messages.add(resource);
            }

        }
        return messages;
    }

    private static final long EXE_DSEG_OFFSET = 0x11390L;
    private static final long EXE_FIRST_BLOCK_OFFSET = 2824L;
    private static final long EXE_SECOND_BLOCK_OFFSET = 6266L;
    private static final int EXE_FIRST_BLOCK_SIZE = 25;
    private static final int EXE_SECOND_BLOCK_SIZE = 105;
    private static final int EXE_FIRST_BLOCK_MAX_SIZE = 1585;
    private static final int EXE_FIRST_BLOCK_MESSAGE_OFFSET = 4378;
    private static final int EXE_SECOND_BLOCK_MAX_SIZE = 739;
    private static final int EXE_SECOND_BLOCK_MESSAGE_OFFSET = 6518;
    private static final String DEFAULT_ENCODING = "CP866";
    private static final int XOR_KEY = 218;
    private static final String DEFAULT_SHEET_NAME = "Veil of Darkness";
}
