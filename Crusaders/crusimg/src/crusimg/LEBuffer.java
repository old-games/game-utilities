/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

/**
 *
 * @author john
 */
public class LEBuffer {
    
    private byte[] data;
    private int _pos;
    
    public LEBuffer(byte[] data){
        this.data=data;
        _pos=0;
    }
    
    public LEBuffer subBuffer(int offset,int size){
        byte[] b=new byte[size];
        System.arraycopy(data, offset, b, 0, size);
        return new LEBuffer(b);
    }
    
    public int length(){
        return data.length;
    }
    
    public int pos(){
        return _pos;
    }
    
    public int seek(int pos){
        _pos=Math.max(Math.min(pos,data.length),0);
        return _pos;
    }
    
    public byte getByte(){
        return data[_pos++];
    }

    public int getIByte(){
        return (int)(data[_pos++] & 0xFF);
    }

    public short getShort(){
        int b1=data[_pos++];
        int b2=data[_pos++];
        return (short)((b1 & 0xFF) | ((b2 & 0xFF)<<8));
    }
    
    public int getInt(){
        int b1=data[_pos++];
        int b2=data[_pos++];
        int b3=data[_pos++];
        int b4=data[_pos++];
        return (b1 & 0xFF) | ((b2 & 0xFF) <<8) | ((b3 & 0xFF)<<16) | ((b4 & 0xFF) <<24);
    }
}
