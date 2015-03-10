/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author john
 */
public class FlxFile {
    
    public File file;
    public boolean changed=false;
    byte[] header=new byte[0x80];
    int count;
    public ArrayList<int[]> offsets=new ArrayList();
    public HashMap<Integer,FlxImage> images=new HashMap();
    
    public int readShort(RandomAccessFile fs) throws IOException{
        return (int) (fs.read() | (fs.read()<<8));
    }

    public int readInt(RandomAccessFile fs) throws IOException{
        return (int) (fs.read() | (fs.read()<<8) | (fs.read()<<16) | (fs.read()<<24));
    }

    
    public void writeInt(FileOutputStream fs,int val) throws IOException{
        byte b[]=new byte[4];
        b[0]=(byte)(val & 0xFF);
        b[1]=(byte)((val >> 8) & 0xFF);
        b[2]=(byte)((val >> 16) & 0xFF);
        b[3]=(byte)((val >> 24) & 0xFF);
        fs.write(b);
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
        RandomAccessFile fs=new RandomAccessFile(file,"r");
        fs.read(header);
        for (int i=0;i<0x52;i++){
            if (header[i]!=0x1A)
                throw new Exception("Wrong file format.");
        }
        fs.seek(0x54);
        count=readShort(fs);
        if (count==0)
            throw new Exception("Wrong file format.");
        fs.seek(0x80);
        for (int i=0;i<count;++i){
            int[] ofs=new int[2];
            ofs[0]=readInt(fs);
            ofs[1]=readInt(fs);
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
        fs.close();
    }
    
    
    private void backup() throws Exception{
        Integer i=0;
        File f=new File(file.getParentFile(),file.getName()+".backup0");
        while (f.exists()){
            i++;
            f=new File(file.getParentFile(),file.getName()+".backup"+i.toString());
        }
        FileChannel fin=null;
        FileChannel fout=null;
        try {
            fin = new FileInputStream(file).getChannel();
            FileChannel foud = new FileOutputStream(f).getChannel();
            foud.transferFrom(fin, 0, fin.size());
        }finally {
            if(fin != null)
                fin.close();
            if (fout!=null)
                fout.close();
        }
    }
    
    public void save() throws Exception{
        backup();
        changed=false;
        FileOutputStream fs=new FileOutputStream(file);
        fs.write(header);
        int fofs=0;
        for (int i=0;i<count;i++){
            if (images.containsKey(i)){
                fofs=offsets.get(i)[0];
                break;
            }
        }
        int ofs=fofs;
        for (int i=0;i<count;i++){
            if (images.containsKey(i)){
                writeInt(fs,ofs);
                int sz=images.get(i).sz;
                writeInt(fs,sz);
                ofs+=sz;
            }else{
                writeInt(fs, offsets.get(i)[0]);
                writeInt(fs, offsets.get(i)[1]);
            }
        }
        for (int i=0;i<count;i++){
            if (!images.containsKey(i))
                continue;
            fs.write(images.get(i).buf.data);
        }
        fs.close();
    }
}
