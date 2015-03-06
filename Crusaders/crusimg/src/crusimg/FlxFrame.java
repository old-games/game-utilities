/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.awt.Dimension;

/**
 *
 * @author john
 */
public final class FlxFrame {
    
    public byte[] bitmapData;
    public int width;
    public int height;

    
    public FlxFrame(LEBuffer buf){
        int comp=buf.getInt();
        width=buf.getInt();
        height=buf.getInt();
        int wo=buf.getInt();
        int ho=buf.getInt();
        bitmapData=new byte[width*height];
        unpack(buf,comp);
    }
    
    public Dimension getSize(){
        return new Dimension(width,height);
    }
    
    public void unpack(LEBuffer buf,int comp){
        int[] ofs=new int[height];
        for (int i = 0; i < height; i++)
        {
            ofs[i]=buf.getInt()-(height-i)*4;
        }
        int ipos=buf.pos();
        int i,j,k;
        int type,dlen;
        byte val=0;
        for (i=0;i<height;i++){
            int out=i*width;
            buf.seek(ipos+ofs[i]);
            int xpos = 0;
            do{
                dlen=buf.getIByte();
                for (j=0;j<dlen;j++){
                    bitmapData[out++]=(byte)0xFF;
                    xpos++;
                }
                if (xpos>=width) break;
                type=0;
                dlen=buf.getIByte();
                if (comp!=0){
                    type=dlen&1;
                    dlen>>=1;
                }
                for (j=0;j<dlen;j++){
                    if (j==0 || type==0){
                        val=buf.getByte();
                    }
                    bitmapData[out++]=val;
                    xpos++;
                }
            }while(xpos<width);
        }
    }
    
}
