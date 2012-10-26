package org.nlogo.extensions.multiview;

import org.nlogo.api.*;

import java.awt.*;
import java.awt.image.*;
import java.awt.PopupMenu;

import javax.imageio.ImageIO;
import javax.swing.*;

import org.nlogo.api.Context;
import org.nlogo.app.App;
import java.awt.image.BufferedImage;

import java.util.Iterator;
import org.nlogo.agent.*;
import java.awt.event.*;
import java.util.ArrayList;
import java.util.List;
import java.io.*;
import java.io.File;

/**
 * Copyright (C) [2010]  [JC Thiele]
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 
 * @author JC Thiele
 * @contact jthiele at gwdg.de
 * @version 0.1
 */

public class View extends JPanel implements org.nlogo.api.ExtensionObject, WindowListener, MouseListener  {

	// unique identifier of the instance
	private long viewcounter;
	// the main frame
	private JFrame f;
	private String name;
	// popup/context menu for right mouse click
	private JPopupMenu contextMenu = new JPopupMenu();
	// items of the popup menu
    JMenuItem inspectPatchMenuItem = new JMenuItem("inspect patch");
    JMenuItem exportMenuItem = new JMenuItem("Export View...");
    // color of patches
	private int[] imageData = null;
	// image visualizing the patches
	private Image image;
	private int imageXOffset;
	private int imageYOffset;
	private int numberXCells;
	private int numberYCells;
	private double pixelSize;
	private int imageWidth;
	private int imageHeight;
	private int cellsPerRow;
	private org.nlogo.api.World world;
	private org.nlogo.window.GUIWorkspace workspace;
	private int worldMinX;
	private int worldMinY;
	private int patchVarIndex;
	private boolean alreadyDisposed = false;
	private int[] inspectedPatch;
	// action listener for the popup menu
    private ActionListener actionListener = new ActionListener() {
    	public void actionPerformed(ActionEvent actionEvent) {
    		// if "inspect patch" is clicked:
    		if (actionEvent.getActionCommand().startsWith("inspect patch")) {
    			try {
    				org.nlogo.api.Agent patch = (org.nlogo.api.Agent)world.getPatchAt(inspectedPatch[0], inspectedPatch[1]);
    				workspace.inspectAgent(patch, 1);
    			} 
    			catch (Exception ex) {
    				//throw new org.nlogo.api.ExtensionException("Error in inspect patch: "+patchX+", "+patchY+". \n"+ex);
    			}
    		}
    		// if "Export View" is clicked:
    		if (actionEvent.getActionCommand().startsWith("Export View")) {
    			try {
    				//fc.setCurrentDirectory(new File(""));
    				PNGFilter pngFilter = new PNGFilter();
    				//Create a file chooser
    				final JFileChooser fc = new JFileChooser();
    				fc.setFileSelectionMode(JFileChooser.FILES_ONLY);
    				fc.setFileFilter(pngFilter);
    				fc.setSelectedFile(new File("multiviewExport.png"));    				
    				int returnVal = fc.showSaveDialog(f);
    				if (returnVal == JFileChooser.APPROVE_OPTION) {
    		            java.io.File file = fc.getSelectedFile();
    		            
    		            if(file.exists())
    		            {
    		            int replace = JOptionPane.showConfirmDialog(f, "Replace existing file?");
    		            if(replace == JOptionPane.YES_OPTION)
    		            {   
		    				BufferedImage bi = new BufferedImage(imageWidth, imageHeight, BufferedImage.TYPE_INT_RGB);
		    				Graphics2D g2d = bi.createGraphics();
		    				g2d.drawImage( image, imageXOffset, imageYOffset, imageWidth, imageHeight, null );
		    				ImageIO.write(bi, "png", file);
	    		        }
    		            }
    		            else {
		    				BufferedImage bi = new BufferedImage(imageWidth, imageHeight, BufferedImage.TYPE_INT_RGB);
		    				Graphics2D g2d = bi.createGraphics();
		    				g2d.drawImage( image, imageXOffset, imageYOffset, imageWidth, imageHeight, null );
		    				ImageIO.write(bi, "png", file);    		            	
    		            }
    				}
    			} 
    			catch (Exception ex) {
    				//System.out.println("Error in export view: \n"+ex);
    				//throw new org.nlogo.api.ExtensionException("Error in export view: \n"+ex);
    			}
    		}
    	}
    };
	
	public long getViewcounter() {
		return viewcounter;
	}
	
	public boolean isAlreadyDisposed() {
		return alreadyDisposed;
	}

	public int getPatchVarIndex() {
		return patchVarIndex;
	}

	public void setPatchVarIndex(int patchVarIndex) {
		this.patchVarIndex = patchVarIndex;
	}
	
	public void checkForDisposion() {
		if (alreadyDisposed) {
			JOptionPane.showMessageDialog(null, "The View was already closed! Forgotten to delete the reference?", "Info", JOptionPane.OK_CANCEL_OPTION);
			org.nlogo.window.GUIWorkspace workspace = org.nlogo.app.App.app.workspace;
			// stop simulations
			workspace.halt();
		}
	}

	/*
	 *  Method to get the name/title of the Window
	 *  @ return String name/title of the Window
	 */
	public String getName() {

		return name;
	}

	/*
	 *  Method to change the name/title of the Window
	 *  @ param name the new name
	 */
	public void setName(String name) {
		checkForDisposion();
		this.name = name;
	}

	/*
	 *  Constructor
	 *  @ param id a unique long value to identify instance in HashMap of MultiView-Extension
	 *  @ param windowName a String with the title of the new View Window 
	 */
	public View(long id, String windowName) {
		viewcounter = id;
		name = windowName;
	}
	
	@Override
	protected void paintComponent( Graphics g )
	{
		if ( image != null )
		{	
			g.drawImage( image, imageXOffset, imageYOffset, imageWidth, imageHeight, this );
		}
	}
  
	/*
	 *  Method to close the View Window from command line
	 */
	public void closeWindow() {
		checkForDisposion();
		f.dispose();
		f = null;
	}
	
	/*
	 *  Method to fill image with new values from patches 
	 */
	public void repaintPatches()
	{
		checkForDisposion();
		imageData = new int[numberXCells*numberYCells];
		for(int x=0; x<numberXCells; x++) {
			for(int y=0; y<numberYCells; y++) {
				imageData[(numberYCells-1-y)*numberXCells+(x)] = (org.nlogo.api.Color.getColor(((Double)(world.fastGetPatchAt(worldMinX+x,worldMinY+y)).getVariable(patchVarIndex)).doubleValue())).getRGB();
			}
		}
		ImageProducer p = new MemoryImageSource( numberXCells, numberYCells, imageData, 0, cellsPerRow );
	    image = f.createImage( p );
	    this.repaint();
	}
  
	public void windowActivated(WindowEvent arg0) {	
	}

	public void windowClosed(WindowEvent arg0) {	
	}

	public void windowDeactivated(WindowEvent arg0) {
	}

	public void windowDeiconified(WindowEvent arg0) {	
	}

	public void windowIconified(WindowEvent arg0) {	
	}

	public void windowOpened(WindowEvent arg0) {	
	}
	
	/*
	 *  Method to handle Window closing via mouse click
	 *  @ param e closing event
	 */
	public void windowClosing(WindowEvent e) { 
	  int returnValue = javax.swing.JOptionPane.showConfirmDialog(f,
	            "Are you sure you want to close? \nIf yes, please remember that the reference to this view \nin your variable isn't active anymore!", "Confirmation",
	            javax.swing.JOptionPane.YES_NO_OPTION, javax.swing.JOptionPane.INFORMATION_MESSAGE);
	  if (returnValue==javax.swing.JOptionPane.NO_OPTION) 
	  {
		  return;  
	  } 
	  else 
	  {     
		  alreadyDisposed = true;
		  f.dispose();
	  }	
	}
	
	/*
	 *  Method to create a new View Window
	 *  @ param context the current instance of org.nlogo.api.Context
	 *  @ param patchVar the name of the patch variable to be used for coloring
	 */
	public void createView(Context context, String patchVar) {
		world = context.getAgent().world();
		workspace = org.nlogo.app.App.app.workspace;
		org.nlogo.api.AgentSet turtles = (org.nlogo.api.AgentSet) world.turtles();
		Iterator<org.nlogo.api.Agent> iterator = turtles.agents().iterator();
		while( iterator. hasNext() ){
			org.nlogo.api.Agent agent = iterator.next();
			org.nlogo.agent.Agent agent2 = (org.nlogo.agent.Agent) agent;
			int whoIndex = agent2.world().indexOfVariable(agent2, "who".toUpperCase());
			int xcorIndex = agent2.world().indexOfVariable(agent2, "xcor".toUpperCase());
			int ycorIndex = agent2.world().indexOfVariable(agent2, "ycor".toUpperCase());
			int shapeIndex = agent2.world().indexOfVariable(agent2, "shape".toUpperCase());
		}
		org.nlogo.api.RendererInterface rend = App.app.workspace.newRenderer();
		pixelSize = world.patchSize();
	
		int worldMaxX = world.maxPxcor();
		worldMinX = world.minPxcor();
		int worldMaxY = world.maxPycor();
		worldMinY = world.minPycor();
		
		numberXCells = worldMaxX - worldMinX + 1;
		numberYCells = worldMaxY - worldMinY + 1;
		
		imageWidth = (int) (numberXCells * pixelSize + 0.5);
		imageHeight = (int) (numberYCells * pixelSize + 0.5);
		
		org.nlogo.agent.Agent patch0 = (org.nlogo.agent.Agent)world.getPatch(0);
		patchVarIndex = patch0.world().indexOfVariable(patch0, patchVar.toUpperCase());
		
		imageData = new int[numberXCells*numberYCells];
		for(int x=0; x<numberXCells; x++) {
			for(int y=0; y<numberYCells; y++) {
				imageData[(numberYCells-1-y)*numberXCells+(x)] = (org.nlogo.api.Color.getColor(((Double)(world.fastGetPatchAt(worldMinX+x,worldMinY+y)).getVariable(patchVarIndex)).doubleValue())).getRGB();
			}
		}
				
		cellsPerRow = numberXCells;
		
		String windowName = name + "  -  Multiview by Jan C. Thiele";
		f = new JFrame( windowName );
	    exportMenuItem.addActionListener(actionListener);
	    contextMenu.add(exportMenuItem);
	    contextMenu.addSeparator();
	    inspectPatchMenuItem.addActionListener(actionListener);
	    contextMenu.add(inspectPatchMenuItem);
	    f.addWindowListener(this);
		f.addMouseListener(this);
        f.setDefaultCloseOperation( JFrame.DO_NOTHING_ON_CLOSE); //EXIT_ON_CLOSE );
	    ImageProducer p = new MemoryImageSource( numberXCells, numberYCells, imageData, 0, cellsPerRow );
	    image = f.createImage( p );
	    //f.add( new test1() );
	    f.add( this );	    
	    f.setSize( imageWidth + imageXOffset+6, imageHeight + imageYOffset+32);
	    f.setResizable(false);
	    f.setLocation((int)viewcounter*20, (int)viewcounter*20);
	    f.setVisible( true );
	}
	  

	
	public String dump(boolean arg0, boolean arg1, boolean arg2) {
		checkForDisposion();
		return name;
	}

	public String getExtensionName() {
		checkForDisposion();
		return "MultiView";
	}

	public String getNLTypeName() {
		checkForDisposion();
		return "";
	}

	public boolean recursivelyEqual(Object arg0) {
		checkForDisposion();
		if (arg0 instanceof View) {
			if ((((View)arg0).getName() == name) && ((View)arg0).getPatchVarIndex() == patchVarIndex) {
				return true;
			}
			else {
				return false;
			}			
		}
		else {
			return false;
		}
	}

	public void mouseClicked(MouseEvent arg0) {
	}

	public void mouseEntered(MouseEvent arg0) {	
	}

	public void mouseExited(MouseEvent arg0) {
	}

  
	public void mousePressed(MouseEvent arg0) {
		// on right mouse click
		if ((arg0.getModifiers() & InputEvent.BUTTON3_MASK) != 0)
		{	    
			showIfPopupTrigger(arg0);
		}
	}

	public void mouseReleased(MouseEvent arg0) {
		showIfPopupTrigger(arg0);
	}
	
    private void showIfPopupTrigger(MouseEvent mouseEvent) {
        if (mouseEvent.isPopupTrigger()) {
			int patchX = (int)((mouseEvent.getX() - 3) / pixelSize) + worldMinX;
			int patchY = (int)((numberYCells * pixelSize - mouseEvent.getY() + 30) / pixelSize) + worldMinY;
			inspectPatchMenuItem.setLabel("inspect patch "+patchX+" "+patchY);
			inspectedPatch = new int[2];
			inspectedPatch[0] = patchX;
			inspectedPatch[1] = patchY;

          contextMenu.show(mouseEvent.getComponent(),
			  mouseEvent.getX(),
			  mouseEvent.getY());
        }
    }
        
}