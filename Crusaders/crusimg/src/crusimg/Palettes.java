/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.awt.image.IndexColorModel;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.util.LinkedHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author john
 */
public class Palettes {
    
    public class Palette{
        public int type; 
        public String name;
        IndexColorModel model;
        public Palette(String name,int type){
            this.type=type;
            this.name=name;
            byte[] gray=new byte[256];
            for (int i=0;i<256;i++){
                gray[i]=(byte)(i&0xFF);
            }
            model=new IndexColorModel(8,256,gray,gray,gray);
        }
        public Palette(File f){
            type=0;
            name=f.getName();
            try {
                FileInputStream fs;
                fs = new FileInputStream(f);
                byte[] map=new byte[3*256];
                fs.read(map);
                fs.close();
                for (int i=0;i<map.length;i++){ 
                    map[i]=(byte)((map[i]<<2)+(map[i]>>4));
                }
                model=new IndexColorModel(8,256,map,0,false);
            } catch (Exception ex) {
                Logger.getLogger(Palettes.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
    
    private static Palette grayscalePalette;
    private static Palettes _instance=null;
    private String path=null;
    public LinkedHashMap<String,Palette> palettes=new LinkedHashMap<>();
    
    public static Palettes get(){
        if (null==_instance){
            _instance=new Palettes();
        }
        return _instance;
    }
    
    private Palettes(){
        grayscalePalette=new Palette("-=grayscale=-",1);
    }
    
    public void setPath(String path){
        if (path.equals(this.path))
            return;
        palettes.clear();
        this.path=path;
        File dir=new File(path);
        FileFilter ff=new FileFilter() {
            @Override
            public boolean accept(File pathname) {
                if (!pathname.exists() || !pathname.isFile())
                    return false;
                if (!pathname.getName().toLowerCase().endsWith(".pal"))
                    return false;
                return pathname.length()==256*3;
            }
        };
        for (File f: dir.listFiles(ff) ){
            if (f.getName().toLowerCase().equals("gamepal.pal")){
                palettes.put(f.getName(), new Palette(f));
            }
        }
        for (File f: dir.listFiles(ff) ){
            if (!f.getName().toLowerCase().equals("gamepal.pal")){
                palettes.put(f.getName(), new Palette(f));
            }
        }
        palettes. put(grayscalePalette.name, grayscalePalette);
    }
    
}
