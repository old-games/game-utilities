/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.io.File;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 *
 * @author john
 */
public class Config {
    
    public class ImgInfo{
        public Integer id;
        public String palette="";
        public String name="";
        public ImgInfo(Integer id){
            this.id=id;
        }
    }
    
    public class FlxInfo{
        public String name;
        public Boolean single=false;
        public HashMap<Integer,ImgInfo> images=new HashMap<>();
        public FlxInfo(String name){
            this.name=name;
        }
        public ImgInfo getImg(int id){
            if (!images.containsKey(id)){
                images.put(id, new ImgInfo(id));
            }
            return images.get(id);
        }
    }
    
    private static Config _instance=null;
    
    public String path;
    public HashMap<String,FlxInfo> files=new HashMap<>();

    public static Config get() throws Exception{
        if (null==_instance){
                _instance=new Config();
        }
        return _instance;
    }

    private Config() throws URISyntaxException{
        File dir=new File(Config.class.getProtectionDomain().getCodeSource().getLocation().toURI().getPath());
        path=dir.getAbsolutePath();
        load();
    }
    
    
    public FlxInfo addFile(String fname){
        if (!files.containsKey(fname)){
            files.put(fname,new FlxInfo(fname));
        }
        return files.get(fname);
    }
    

    private void load(){
        try {
            File xml=new File(path,"config.xml");
            if (!xml.exists())
                return;
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder db=docFactory.newDocumentBuilder();
            Document doc=db.parse(xml);
            Node root=doc.getDocumentElement();
            if (!"flx".equals(root.getNodeName()))
                return;
            Node file=root.getFirstChild();
            for ( ; null!=file; file=file.getNextSibling()){
                if (file.getNodeType() != Node.ELEMENT_NODE || !"file".equals(file.getNodeName()))
                    continue;
                Element e=(Element)file;
                FlxInfo fi=addFile(e.getAttribute("path"));
                if (e.hasAttribute("single")){
                    fi.single=Boolean.parseBoolean(e.getAttribute("single"));
                }
                Node img=e.getFirstChild();
                for ( ; null!=img; img=img.getNextSibling()){
                    if (img.getNodeType() != Node.ELEMENT_NODE || !"img".equals(img.getNodeName()))
                        continue;
                    e=(Element)img;
                    ImgInfo info=new ImgInfo(Integer.parseInt(e.getAttribute("id")));
                    info.name=e.getAttribute("name");
                    info.palette=e.getAttribute("palette");
                    fi.images.put(info.id,info);
                }
            }
        } catch (Exception ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void save(){
        try {
            DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder db=docFactory.newDocumentBuilder();
            Document doc=db.newDocument();
            Element root = doc.createElement("flx");
            doc.appendChild(root);
            for (FlxInfo fi:files.values()){
                Element fnode=doc.createElement("file");
                fnode.setAttribute("path", fi.name);
                fnode.setAttribute("single", fi.single.toString());
                root.appendChild(fnode);
                for (ImgInfo img:fi.images.values()){
                    Element inode=doc.createElement("img");
                    inode.setAttribute("id", img.id.toString());
                    inode.setAttribute("name", img.name);
                    inode.setAttribute("palette", img.palette);
                    fnode.appendChild(inode);
                }
            }
            // write the content into xml file
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(new File(path,"config.xml"));
            transformer.transform(source, result);
        } catch (Exception ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
}
