/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;

/**
 *
 * @author john
 */
public class Compressor {

    private static enum PMode{
        TRANSPARENT,
        SEQUENSE,
        SAME;
    };

    private class PackSt{
        PMode mode;
        int len;
        public PackSt(PackSt st){
            mode=st.mode;
            len=st.len;
        }
        public PackSt(PMode mode){
            this.mode=mode;
            len=1;
        }
    }
    
    
    byte[] line;
    
    byte[] nocompTry;
    int[] nocompOfs;
    byte[] current;
    int w;
    final int cmaxlen=0xFF>>1;

    FlxFrame frame;
    HashMap<Integer,Integer> compressed;
    
    public Compressor(FlxFrame frame){
        this.frame=frame;
        w=frame.width;
        line=new byte[w];
    }
    
    private ArrayList<PackSt> makeMap(boolean comp){
        ArrayList<PackSt> res=new ArrayList<>();
        int end=line.length;
        int pos=0;
        byte prev=line[pos++];
        PackSt curpack=new PackSt(prev==0xFF ? PMode.TRANSPARENT : PMode.SEQUENSE);
        int maxlen=comp ? cmaxlen : 0xFF;
        while(pos<end){
            byte cur=line[pos++];
            if (cur==0xFF){
                if (curpack.mode==PMode.TRANSPARENT){
                    curpack.len++;
                }else{
                    res.add(curpack);
                    curpack=new PackSt(PMode.TRANSPARENT);
                }
            }else if (cur==prev && comp){
                if (curpack.mode==PMode.SAME || curpack.len==1){
                    curpack.len++;
                    curpack.mode=PMode.SAME;
                }else{
                    curpack.len--;
                    res.add(curpack);
                    curpack=new PackSt(PMode.SAME);
                    curpack.len++;
                }
            }else{
                if (curpack.mode==PMode.SEQUENSE){
                    curpack.len++;
                }else{
                    res.add(curpack);
                    curpack=new PackSt(PMode.SEQUENSE);
                }
            }
            if ((curpack.len>maxlen && curpack.mode!=PMode.TRANSPARENT) || curpack.len>0xFF){
                PMode m=curpack.mode;
                curpack.len--;
                res.add(curpack);
                curpack=new PackSt(m==PMode.TRANSPARENT ? PMode.TRANSPARENT : PMode.SEQUENSE);
            }
            prev=cur;
        }
        res.add(curpack);
        return res;
    }


    private PackSt compressSameNext(PackSt cur,PackSt next){
        PackSt res=new PackSt(cur);
        if (next==null)
            return res;
        if (next.mode==PMode.SEQUENSE && cur.len<4){
            res.mode=PMode.SEQUENSE;
        }
        if (next.mode==PMode.SAME && cur.len+next.len<5){
            res.mode=PMode.SEQUENSE;
        }
        return res;
    }

    private PackSt compressSame(PackSt cur,PackSt last,PackSt next){
        if (last==null){
            return compressSameNext(cur,next);
        }
        if(last.mode!=PMode.SEQUENSE){
            return compressSameNext(cur,next);
        }
        PackSt res=new PackSt(cur);
        if (last.len+cur.len>cmaxlen)
            return res;
        if (next!=null && next.mode!=PMode.TRANSPARENT){
            if (next.mode==PMode.SEQUENSE && cur.len<6){
                last.len+=cur.len;
                return null;
            }
            if (next.mode==PMode.SAME && cur.len+next.len<6){
                last.len+=cur.len;
                return null;
            }
        }else{
            if (cur.len<4){
                last.len+=cur.len;
                return null;
            }
        }
        return res;
    }
    
    private ArrayList<PackSt> compressMap(ArrayList<PackSt> map){
        int i=0;
        ArrayList<PackSt> res=new ArrayList();
        PackSt cur=map.get(i);
        PackSt next;
        PackSt last=null;
        while(i<map.size()){
            next=(i<map.size()-1) ? map.get(i+1) : null;
            if (cur.mode==PMode.SAME){
                PackSt st=compressSame(cur,last,next);
                if (st!=null){
                    res.add(st);
                    last=st;
                }
            }else if (cur.mode==PMode.SEQUENSE){
                if (last!=null && last.mode==cur.mode && last.len+cur.len<cmaxlen){
                    last.len+=cur.len;
                }else{
                    last=new PackSt(cur);
                    res.add(last);
                }
            }else if (cur.mode==PMode.TRANSPARENT){
                res.add(cur);
                last=null;
            }
            cur=next;
            i++;
        }
        return res;
    }
    
    private byte[] compressLine(boolean comp) throws IOException{
        ArrayList<PackSt> map=makeMap(comp);
        if (comp){
            map=compressMap(map);
            int sz=0;
            for (int i=0;i<map.size();i++){
                sz+=map.get(i).len;
            }
            if (sz>w){
                System.out.print("\n");
            }
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        DataOutputStream buf = new DataOutputStream(out);
        
        int pos=0;
        Iterator<PackSt> it=map.iterator();
        while(it.hasNext()){
            PackSt st=it.next();
            if (st.mode==PMode.TRANSPARENT){
                buf.writeByte((byte)st.len);
                pos+=st.len;
                if (!it.hasNext())
                    break;
                st=it.next();
            }else{
                buf.writeByte(0);
            }
            
            if (st.mode==PMode.TRANSPARENT){
                buf.writeByte(0);
                continue;
            }
            
            int len=st.len;
            if (comp){
                int type=(len<<1) | (st.mode==PMode.SAME ? 1 : 0);
                buf.writeByte((byte)type);
            }else{
                buf.writeByte((byte)len);
            }
            
            for (int i=0;i<len;i++){
                if (i==0 || st.mode==PMode.SEQUENSE){
                    buf.writeByte(line[pos]);
                }
                pos++;
            }
        }

        byte[] res=out.toByteArray();
        buf.close();
        out.close();
        return res;
    }
    
    private int packBytes(byte[] data){
        int spos=0;
        while(spos<current.length){
            if (current[spos]!=data[0]){
                spos++;
                continue;
            }
            int idx=spos;
            boolean found=true;
            for (int i=0;i<data.length;i++){
                if (idx>=current.length)
                    break;
                if (current[idx]!=data[i]){
                    found=false;
                    break;
                }
                idx++;
            }
            if (found)
                break;
            spos++;
        }
        if(spos+data.length>current.length){
            byte[] res=new byte[spos+data.length];
            System.arraycopy(current, 0, res, 0, current.length);
            System.arraycopy(data, 0, res, spos, data.length);
            current=res;
        }
        return spos;
    }
    
    private int placeLine(byte[] data,int ofs,boolean comp) throws IOException{
        System.arraycopy(data, ofs, line, 0, w);
        int hash=Arrays.hashCode(line);
        if (compressed.containsKey(hash))
            return compressed.get(hash);
        if (comp && ofs==w*2){
            System.out.print("");
        }
        int res=packBytes(compressLine(comp));
        compressed.put(hash, res);
        return res;
    }
    
    private int[] compressInternal(byte[] data,boolean comp) throws IOException{
        current=new byte[0];
        compressed=new HashMap();
        int[] ofs=new int[frame.height];
        for (int i=0;i<frame.height;i++){
            ofs[i]=placeLine(data,i*w,comp);
        }
        return ofs;
    }

    private void packInt(byte[] data,int ofs,int val){
        data[ofs++]=(byte)(val & 0xFF);
        data[ofs++]=(byte)((val>> 8) & 0xFF);
        data[ofs++]=(byte)((val>> 16) & 0xFF);
        data[ofs++]=(byte)((val>> 24) & 0xFF);
    }
    

    public byte[] compress(byte[] data) throws IOException{
        nocompOfs=compressInternal(data,false);
        nocompTry=current;
        int[] ofs=compressInternal(data,true);
        int comp=1;
        if (nocompTry.length<current.length){
            current=nocompTry;
            ofs=nocompOfs;
            comp=0;
        }
        byte[] res=new byte[current.length+4*5+frame.height*4];
        packInt(res,0,comp);
        packInt(res,4,w);
        packInt(res,8,frame.height);
        packInt(res,12,frame.x);
        packInt(res,16,frame.y);
        int pos=20;
        for (int i=0;i<frame.height;i++){
            int o=ofs[i];
            o=(frame.height-i)*4+o;
            packInt(res,pos,o);
            pos+=4;
        }
        System.arraycopy(current, 0, res, pos, current.length);
        return res;
    }
    
}
