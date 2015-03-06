/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author john
 */
public class FlxFile {
    
    public File file;
    private RandomAccessFile fs;
    byte[] header=new byte[0x80];
    int count;
    public ArrayList<int[]> offsets=new ArrayList();
    public HashMap<Integer,FlxImage> images=new HashMap();
    
    public int readShort() throws IOException{
        return (int) (fs.read() | (fs.read()<<8));
    }

    public int readInt() throws IOException{
        return (int) (fs.read() | (fs.read()<<8) | (fs.read()<<16) | (fs.read()<<24));
    }

    
    public FlxFile(String path) throws Exception{
        file=new File(path);
        if (!file.exists()){
            throw new Exception("File not found "+path);
        }
        load();
    }
    
    public final void load() throws Exception{
        if (file.length()<0x80)
            throw new Exception("Wrong file format.");
        fs=new RandomAccessFile(file,"r");
        fs.read(header);
        for (int i=0;i<0x52;i++){
            if (header[i]!=0x1A)
                throw new Exception("Wrong file format.");
        }
        fs.seek(0x54);
        count=readShort();
        if (count==0)
            throw new Exception("Wrong file format.");
        fs.seek(0x80);
        for (int i=0;i<count;++i){
            int[] ofs=new int[2];
            ofs[0]=readInt();
            ofs[1]=readInt();
            offsets.add(ofs);
        }
        for (int i=0;i<count;++i){
            int[] ofs=offsets.get(i);
            if (ofs[0]!=0 && ofs[1]!=0){
                byte[] buf=new byte[ofs[1]];
                fs.seek(ofs[0]);
                fs.read(buf);
                FlxImage img=new FlxImage(new LEBuffer(buf),i,ofs[0]);
                images.put(img.id,img);
            }

        }
    }
}
