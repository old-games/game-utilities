/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.awt.Graphics;
import java.awt.image.BufferedImage;
import javax.swing.JPanel;

/**
 *
 * @author john
 */
public class ImagePanel extends JPanel{
    
    private BufferedImage img=null;
    
    public void setImage(BufferedImage img){
        this.img=img;
        if (null!=img){
            this.setSize(img.getWidth(), img.getHeight());
        }else{
            this.setSize(0,0);
        }
        this.setPreferredSize(getSize());
    }
    
    public BufferedImage getImg(){
        return img;
    }
    
    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if(null!=img){
            g.drawImage(img, 0, 0, null); // see javadoc for more info on the parameters            
        }
    }
    
}
