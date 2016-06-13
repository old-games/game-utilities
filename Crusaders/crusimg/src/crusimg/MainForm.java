/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package crusimg;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.net.URISyntaxException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author john
 */
public class MainForm extends javax.swing.JFrame {

    private FlxFile file = null;
    private Config conf = null;
    private int prevrow = -1;
    private boolean skipdraw = true;
    private ImagePanel imgPanel;
    private File myPath = null;

    /**
     * Creates new form MainForm
     */
    public MainForm() throws Exception {
        initComponents();
        conf = Config.get();
        for (String e : Config.get().files.keySet()) {
            fileCombo.insertItemAt(e, 1);
        }
        final MainForm frm = this;
        table.getSelectionModel().addListSelectionListener(new ListSelectionListener() {
            @Override
            public void valueChanged(ListSelectionEvent e) {
                frm.selectionChanged();
            }
        });
        imgPanel = new ImagePanel();
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent ev) {
                frm.windowClosing();
            }
        });
        try {
            File fl = new File(MainForm.class.getProtectionDomain().getCodeSource().getLocation().toURI().getPath());
            myPath = fl.getParentFile();
        } catch (URISyntaxException ex) {
        }
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        fileCombo = new javax.swing.JComboBox();
        jLabel2 = new javax.swing.JLabel();
        jSplitPane1 = new javax.swing.JSplitPane();
        jPanel1 = new javax.swing.JPanel();
        jScrollPane3 = new javax.swing.JScrollPane();
        table = new javax.swing.JTable();
        jPanel2 = new javax.swing.JPanel();
        palCombo = new javax.swing.JComboBox();
        singleCheck = new javax.swing.JCheckBox();
        scroll = new javax.swing.JScrollPane();
        frameCombo = new javax.swing.JComboBox();
        jButton1 = new javax.swing.JButton();
        jButton2 = new javax.swing.JButton();
        saveBtn = new javax.swing.JButton();

        setDefaultCloseOperation(javax.swing.WindowConstants.EXIT_ON_CLOSE);
        setTitle("CrusImg v0.1");
        setLocation(new java.awt.Point(0, 0));

        fileCombo.setModel(new javax.swing.DefaultComboBoxModel(new String[] { " ", "<open...>" }));
        fileCombo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                fileComboActionPerformed(evt);
            }
        });

        jLabel2.setText("File");

        jSplitPane1.setDividerLocation(300);

        table.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {

            },
            new String [] {
                "id", "name", "size", "frames"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.String.class
            };
            boolean[] canEdit = new boolean [] {
                false, true, false, false
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        table.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_ALL_COLUMNS);
        table.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
        table.getTableHeader().setReorderingAllowed(false);
        table.addPropertyChangeListener(new java.beans.PropertyChangeListener() {
            public void propertyChange(java.beans.PropertyChangeEvent evt) {
                tablePropertyChange(evt);
            }
        });
        jScrollPane3.setViewportView(table);

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 286, Short.MAX_VALUE)
                .addContainerGap())
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(jScrollPane3, javax.swing.GroupLayout.DEFAULT_SIZE, 484, Short.MAX_VALUE)
                .addContainerGap())
        );

        jSplitPane1.setLeftComponent(jPanel1);

        palCombo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                palComboActionPerformed(evt);
            }
        });

        singleCheck.setText("single");
        singleCheck.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                singleCheckActionPerformed(evt);
            }
        });

        scroll.setViewportBorder(javax.swing.BorderFactory.createEmptyBorder(1, 1, 1, 1));
        scroll.setAutoscrolls(true);

        frameCombo.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                frameComboActionPerformed(evt);
            }
        });

        jButton1.setText("export");
        jButton1.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton1ActionPerformed(evt);
            }
        });

        jButton2.setText("import");
        jButton2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jButton2ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addComponent(frameCombo, javax.swing.GroupLayout.PREFERRED_SIZE, 65, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(singleCheck)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(palCombo, javax.swing.GroupLayout.PREFERRED_SIZE, 151, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jButton1)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jButton2)
                .addContainerGap(18, Short.MAX_VALUE))
            .addComponent(scroll)
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(palCombo, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(singleCheck)
                    .addComponent(frameCombo, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jButton1)
                    .addComponent(jButton2))
                .addGap(11, 11, 11)
                .addComponent(scroll, javax.swing.GroupLayout.DEFAULT_SIZE, 450, Short.MAX_VALUE))
        );

        jSplitPane1.setRightComponent(jPanel2);

        saveBtn.setText("save");
        saveBtn.setEnabled(false);
        saveBtn.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                saveBtnActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(layout.createSequentialGroup()
                        .addContainerGap()
                        .addComponent(jSplitPane1, javax.swing.GroupLayout.PREFERRED_SIZE, 0, Short.MAX_VALUE))
                    .addGroup(layout.createSequentialGroup()
                        .addComponent(jLabel2)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(fileCombo, 0, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                        .addComponent(saveBtn)))
                .addContainerGap())
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(layout.createSequentialGroup()
                .addContainerGap()
                .addGroup(layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(fileCombo, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jLabel2)
                    .addComponent(saveBtn))
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jSplitPane1)
                .addContainerGap())
        );

        setSize(new java.awt.Dimension(822, 569));
        setLocationRelativeTo(null);
    }// </editor-fold>//GEN-END:initComponents

    public void windowClosing() {
        if (!askForSave()) {
            return;
        }
        conf.save();
        System.exit(0);
    }

    private Config.FlxInfo currentConfig(boolean create) {
        if (null == file) {
            return null;
        }
        String idx = file.file.getAbsolutePath();
        if (!conf.files.containsKey(idx) && create) {
            return conf.addFile(idx);
        }
        if (!conf.files.containsKey(idx)) {
            return null;
        }
        return conf.files.get(idx);
    }

    private void updateTable() {
        prevrow = -1;
        DefaultTableModel mod = (DefaultTableModel) table.getModel();
        mod.setRowCount(0);
        if (null == file) {
            return;
        }
        Config.FlxInfo info = currentConfig(true);
        for (FlxImage img : file.images.values()) {
            Object[] obj = new Object[4];
            obj[0] = String.format("%d", img.id);
            obj[1] = info.images.containsKey(img.id) ? info.images.get(img.id).name : "";
            obj[2] = img.getSize();
            obj[3] = String.format("%d", img.count);
            mod.addRow(obj);
        }
    }

    private void setPath(String path) {
        try {
            skipdraw = true;
            saveBtn.setEnabled(false);
            file = new FlxFile(path);
            Palettes.get().setPath(file.file.getParent());
            palCombo.removeAllItems();
            for (String s : Palettes.get().palettes.keySet()) {
                palCombo.addItem(s);
            }
            Config.FlxInfo info = currentConfig(true);
            singleCheck.setSelected(info.single);
            frameCombo.setEnabled(!singleCheck.isSelected());
            fileCombo.removeAllItems();
            for (String s : conf.files.keySet()) {
                fileCombo.addItem(s);
                if (s.equals(path)) {
                    fileCombo.setSelectedIndex(fileCombo.getItemCount() - 1);
                }
            }
            fileCombo.addItem("<open...>");
        } catch (Exception e) {
            file = null;
            JOptionPane.showMessageDialog(this, e.getClass().getName() + "\n" + e.getMessage());
        }
        updateTable();
    }

    public FlxImage currentImage() {
        if (file == null) {
            return null;
        }
        int row = table.getSelectedRow();
        if (row < 0) {
            return null;
        }
        int id = Integer.parseInt((String) table.getValueAt(row, 0));
        return file.images.get(id);
    }

    public Config.ImgInfo currentImageConfig() {
        Config.FlxInfo info = currentConfig(false);
        if (null == info) {
            return null;
        }
        FlxImage img = currentImage();
        if (null == img) {
            return null;
        }
        if (info.images.containsKey(img.id)) {
            return info.images.get(img.id);
        }
        return null;
    }

    public void redraw() {
        if (skipdraw) {
            return;
        }
        try {
            FlxImage img = currentImage();
            BufferedImage bmp = img.render(frameCombo.getSelectedIndex(), singleCheck.isSelected(), (String) palCombo.getSelectedItem());
            imgPanel.setImage(bmp);
            scroll.setViewportView(imgPanel);
        } catch (Exception ex) {
            Logger.getLogger(MainForm.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void selectionChanged() {
        int row = table.getSelectedRow();
        if (row == prevrow) {
            return;
        }
        skipdraw = true;
        frameCombo.removeAllItems();
        if (row == -1) {
            return;
        }
        prevrow = row;
        FlxImage img = currentImage();
        if (null == img) {
            return;
        }
        for (int i = 0; i < img.count; i++) {
            frameCombo.addItem(String.format("%d", i));
            if (i == 0) {
                frameCombo.setSelectedIndex(0);
            }
        }
        Config.ImgInfo info = currentImageConfig();
        if (null != info && Palettes.get().palettes.containsKey(info != null ? info.palette : "")) {
            palCombo.setSelectedItem(info.palette);
        } else {
            palCombo.setSelectedIndex(0);
        }
        skipdraw = false;
        redraw();
    }

    private boolean askForSave() {
        if (file == null) {
            return true;
        }
        if (!file.changed) {
            return true;
        }
        int res = JOptionPane.showConfirmDialog(this, "File changed. Save?", "Save file", JOptionPane.YES_NO_CANCEL_OPTION);
        if (res == JOptionPane.CANCEL_OPTION) {
            return false;
        }
        if (res == JOptionPane.YES_OPTION) {
            try {
                file.save();
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, e.getClass().getName() + "\n" + e.getMessage());
                return false;
            }
        }
        saveBtn.setEnabled(file.changed);
        return true;
    }

    private void fileComboActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_fileComboActionPerformed
        if (!askForSave()) {
            return;
        }
        if (fileCombo.getSelectedItem().equals(" ")) {
            return;
        }
        if (fileCombo.getSelectedItem().equals("<open...>")) {
            final JFileChooser fc = new JFileChooser();
            FileFilter ff = new FileNameExtensionFilter("Flx files(*.flx)", "flx");
            if (null != myPath) {
                fc.setCurrentDirectory(myPath);
            }
            fc.addChoosableFileFilter(ff);
            fc.setFileFilter(ff);
            if (fc.showOpenDialog(this) == JFileChooser.APPROVE_OPTION) {
                setPath(fc.getSelectedFile().getAbsolutePath());
            }
        } else {
            setPath((String) fileCombo.getSelectedItem());
        }
    }//GEN-LAST:event_fileComboActionPerformed

    private void singleCheckActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_singleCheckActionPerformed
        Config.FlxInfo info = currentConfig(false);
        if (null == info) {
            return;
        }
        info.single = singleCheck.isSelected();
        frameCombo.setEnabled(!singleCheck.isSelected());
        redraw();
    }//GEN-LAST:event_singleCheckActionPerformed

    private void tablePropertyChange(java.beans.PropertyChangeEvent evt) {//GEN-FIRST:event_tablePropertyChange
        int row = table.getSelectedRow();
        if (row < 0) {
            return;
        }
        Config.FlxInfo info = currentConfig(false);
        if (null == info) {
            return;
        }
        String pname = (String) table.getValueAt(row, 1);
        int id = Integer.parseInt((String) table.getValueAt(row, 0));
        if (!info.images.containsKey(id)) {
            if (pname.length() == 0) {
                return;
            }
            info.getImg(id).name = pname;
            return;
        }
        if (!pname.equals(info.images.get(id).name)) {
            info.getImg(id).name = pname;
        }
    }//GEN-LAST:event_tablePropertyChange

    private void frameComboActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_frameComboActionPerformed
        redraw();
    }//GEN-LAST:event_frameComboActionPerformed

    private void palComboActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_palComboActionPerformed
        FlxImage img = currentImage();
        if (null == img) {
            return;
        }
        Config.ImgInfo info = currentImageConfig();
        if (null == info && palCombo.getSelectedIndex() != 0) {
            info = currentConfig(true).getImg(img.id);
        }
        if (null != info) {
            info.palette = (String) palCombo.getSelectedItem();
        }
        redraw();
    }//GEN-LAST:event_palComboActionPerformed

    private void jButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton1ActionPerformed
        final JFileChooser fc = new JFileChooser();
        FileFilter ff = new FileNameExtensionFilter("Bitmap files(*.bmp)", "bmp");
        fc.addChoosableFileFilter(ff);
        fc.setFileFilter(ff);
        if (null != myPath) {
            fc.setCurrentDirectory(myPath);
        }
        if (fc.showSaveDialog(this) == JFileChooser.APPROVE_OPTION) {
            File f = fc.getSelectedFile();
            if (!f.getName().endsWith(".bmp")) {
                f = new File(f.getParentFile(), f.getName() + ".bmp");
            }
            try {
                ImagePanel ip = (ImagePanel) scroll.getViewport().getView();
                ImageIO.write(ip.getImg(), "bmp", f);
            } catch (Exception e) {
                JOptionPane.showMessageDialog(this, e.getClass().getName() + "\n" + e.getMessage());
            }
        }
    }//GEN-LAST:event_jButton1ActionPerformed

    private void jButton2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton2ActionPerformed
        try {
            FlxImage img = currentImage();
            if (null == img) {
                throw new Exception("Image not selected");
            }
            final JFileChooser fc = new JFileChooser();
            FileFilter ff = new FileNameExtensionFilter("Bitmap files(*.bmp)", "bmp");
            fc.addChoosableFileFilter(ff);
            fc.setFileFilter(ff);
            if (null != myPath) {
                fc.setCurrentDirectory(myPath);
            }
            if (fc.showOpenDialog(this) != JFileChooser.APPROVE_OPTION) {
                return;
            }
            BufferedImage image = ImageIO.read(fc.getSelectedFile());
            img.importImage(frameCombo.getSelectedIndex(), singleCheck.isSelected(), (String) palCombo.getSelectedItem(), image);
            redraw();
            file.changed = true;
            saveBtn.setEnabled(file.changed);
        } catch (Exception e) {
            Logger.getLogger(MainForm.class.getName()).log(Level.SEVERE, null, e);
            JOptionPane.showMessageDialog(this, e.getClass().getName() + "\n" + e.getMessage());
        }
    }//GEN-LAST:event_jButton2ActionPerformed

    private void saveBtnActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_saveBtnActionPerformed
        if (null == file) {
            return;
        }
        try {
            file.save();
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, e.getClass().getName() + "\n" + e.getMessage());
        }
        saveBtn.setEnabled(file.changed);
    }//GEN-LAST:event_saveBtnActionPerformed

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JComboBox fileCombo;
    private javax.swing.JComboBox frameCombo;
    private javax.swing.JButton jButton1;
    private javax.swing.JButton jButton2;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JSplitPane jSplitPane1;
    private javax.swing.JComboBox palCombo;
    private javax.swing.JButton saveBtn;
    private javax.swing.JScrollPane scroll;
    private javax.swing.JCheckBox singleCheck;
    private javax.swing.JTable table;
    // End of variables declaration//GEN-END:variables
}
