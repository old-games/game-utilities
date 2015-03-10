/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.awt.Dimension;
import java.awt.image.BufferedImage;
import java.awt.image.DataBuffer;
import java.awt.image.DataBufferByte;
import java.awt.image.IndexColorModel;
import java.awt.image.Raster;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

/**
 *
 * @author john
 */
public class FlxImage {
    
    public LEBuffer buf;
    public int id;
    public int ofs;
    public int sz;
    public int w;
    public int h;
    public int count;
    public ArrayList<int[]> frames=new ArrayList<>();
    public HashMap<Integer,FlxFrame> frameObjects=new HashMap();

    private String size=null;
    
    public FlxImage(LEBuffer buf,int id,int ofs){
        this.buf=buf;
        this.id=id;
        this.ofs=ofs;
        this.sz=buf.length();
        w=buf.getShort();
        h=buf.getShort();
        count=buf.getShort();
        for (int i=0;i<count;i++){
            int[] f=new int[2];
            f[0]=buf.getInt() & 0x7FFFFFFF;
            f[1]=buf.getInt();
            frames.add(f);
        }
    }
    
    public String getSize(){
        if (null==size){
            size=String.format("%dx%d", w,h);
        }
        return size;
    }
    
    private FlxFrame getFrame(int id){
        if (id<0 || id>=count)
            return null;
        if (frameObjects.containsKey(id)){
            return frameObjects.get(id);
        }
        int[] osz=frames.get(id);
        if (osz[0]==0 || osz[1]==0){
            return null;
        }
        frameObjects.put(id, new FlxFrame(buf.subBuffer(osz[0], osz[1])));
        return frameObjects.get(id);
    }
    
    private Dimension wholeSize(){
        Dimension res=new Dimension(0, 0);
        for (int i=0;i<count;i++){
            FlxFrame frm=getFrame(i);
            if (null==frm)
                continue;
            if (res.width<frm.width)
                res.width=frm.width;
            res.height+=frm.height;
        }
        return res;
    }
    
    private byte[] makeSingle(Dimension sz){
        byte[] res=new byte[sz.width*sz.height];
        Arrays.fill(res,(byte)0);
        int pos=0;
        for (int i=0;i<count;i++){
            FlxFrame frm=getFrame(i);
            if (null==frm)
                continue;
            if (frm.width==0 || frm.height==0)
                continue;
            int src=0;
            for (int j=0;j<frm.height;j++){
                System.arraycopy(frm.bitmapData, src, res, pos, frm.width);
                pos+=sz.width;
                src+=frm.width;
            }
        }
        return res;
    }
    
    public BufferedImage render(int frame,boolean single,String palette){
        Dimension sz;
        byte[] data;
        if (single){
            sz=wholeSize();
            data=makeSingle(sz);
        }else{
            FlxFrame frm=getFrame(frame);
            if (null==frm){
                return null;
            }
            sz=frm.getSize();
            data=frm.bitmapData;
        }
        if(sz.width==0 || sz.height==0){
            return null;
        }
        Palettes.Palette pal=Palettes.get().palettes.get(palette);
        final BufferedImage img=new BufferedImage(sz.width,sz.height,BufferedImage.TYPE_BYTE_INDEXED,pal.model);
        final DataBuffer db=new DataBufferByte(data, sz.width*sz.height);
        final Raster r=Raster.createPackedRaster(db, sz.width, sz.height, 8, null);
        img.setData(r);
        return img;
    }
    
    
    private void updateFrame(int idx,FlxFrame frm,byte[] data) throws IOException{
        byte[] res=new Compressor(frm).compress(data);
        int[] f=frames.get(idx);
        if (f[1]!=res.length){
            sz+=res.length-f[1];
        }
        byte[] b=new byte[sz];
        int pos=6+count*8;
        System.arraycopy(buf.data, 0, b, 0, pos);
        for (int i=0;i<count;i++){
            f=frames.get(i);
            if (f[0]==0)
                continue;
            if (i!=idx){
                System.arraycopy(buf.data, f[0], b, pos, f[1]);
                f[0]=pos;
                pos+=f[1];
            }else{
                System.arraycopy(res, 0, b, pos, res.length);
                f[0]=pos;
                f[1]=res.length;
                pos+=res.length;
            }
            frames.set(i, f);
            int ppos=6+i*8;
            b[ppos++]=(byte)(f[0] & 0xFF);
            b[ppos++]=(byte)((f[0]>>8) & 0xFF);
            b[ppos++]=(byte)((f[0]>>16) & 0xFF);
            b[ppos++]=(byte)((f[0]>>24) & 0xFF);
            b[ppos++]=(byte)(f[1] & 0xFF);
            b[ppos++]=(byte)((f[1]>>8) & 0xFF);
            b[ppos++]=(byte)((f[1]>>16) & 0xFF);
            b[ppos++]=(byte)((f[1]>>24) & 0xFF);
        }
        buf=new LEBuffer(b);
        frameObjects.remove(idx);
    }
    
    private void setSingle(Dimension sz,byte[] data) throws Exception{
        if (data.length!=sz.width*sz.height)
            throw new Exception("Wrong bitmap buffer size");
        int pos=0;
        for (int i=0;i<count;i++){
            FlxFrame frm=getFrame(i);
            if (null==frm)
                continue;
            if (frm.width==0 || frm.height==0)
                continue;
            int src=0;
            byte[] res=new byte[frm.width*frm.height];
            for (int j=0;j<frm.height;j++){
                System.arraycopy(data, pos, res, src, frm.width);
                pos+=sz.width;
                src+=frm.width;
            }
            updateFrame(i,frm,res);
        }
    }
    

    
    public void importImage(int frame,boolean single,String palette,BufferedImage img) throws Exception{
        Dimension sz;
        FlxFrame frm=null;
        if (single){
            sz=wholeSize();
        }else{
            frm=getFrame(frame);
            if (null==frm)
                throw new Exception(String.format("Frame %d not found", frame));
            sz=frm.getSize();
        }
        if (sz.width!=img.getWidth() || sz.height!=img.getHeight())
            throw new Exception(String.format("Size mismatch %dx%d vs %dx%d", sz.width,sz.height,img.getWidth(),img.getHeight()));
        Palettes.Palette pal=Palettes.get().palettes.get(palette);
        if (!img.getColorModel().equals(pal.model)){
            throw new Exception("Wrong bmp format: expected 8bpp indexed");
        }
        IndexColorModel im=(IndexColorModel)img.getColorModel();
        if (pal.model.getMapSize()!=im.getMapSize())
            throw new Exception("Wrong palette");
        for (int i=0;i<256;i++){
            if (pal.model.getRGB(i)!=im.getRGB(i))
                throw new Exception("Wrong palette");
        }
        final DataBufferByte db=(DataBufferByte)img.getData().getDataBuffer();
        byte[] imgdata=db.getData();
        if (single){
            setSingle(sz,imgdata);
        }else{
            updateFrame(frame,frm,imgdata);
        }
        
    }

}
