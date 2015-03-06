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
import java.awt.image.Raster;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

/**
 *
 * @author john
 */
public class FlxImage {
    
    private LEBuffer buf;
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
}
