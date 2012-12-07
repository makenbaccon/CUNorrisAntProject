package org.nlogo.extensions.multiview;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JMenuItem;
import javax.swing.JPopupMenu;
import javax.swing.event.PopupMenuEvent;
import javax.swing.event.PopupMenuListener;
import javax.swing.JPanel;

/**
 * Copyright (C) [2010]  [JC Thiele]
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 
 * @author JC Thiele
 * @contact jthiele at gwdg.de
 * @version 0.1
 */

public class ContextMenu { //extends JPanel{
	  public JPopupMenu popup;

	  public ContextMenu() {

		    popup = new JPopupMenu();
		    JMenuItem ticks = new JMenuItem("inspect patch");
		    ticks.addActionListener(new ActionListener() {
		      public void actionPerformed(ActionEvent event) {
		        System.out.println("clicked on inspect patch..");
		      }
		    });
		    popup.add(ticks);
		    popup.addPopupMenuListener(new PopupPrintListener());
		    //addMouseListener(new MousePopupListener());
		  }
	  

	// Inner class to check whether mouse events are the popup trigger
	class MousePopupListener extends MouseAdapter {
	  public void mousePressed(MouseEvent e) {
	    checkPopup(e);
	  }
	
	  public void mouseClicked(MouseEvent e) {
	    checkPopup(e);
	  }
	
	  public void mouseReleased(MouseEvent e) {
	    checkPopup(e);
	  }
	
	  private void checkPopup(MouseEvent e) {
	    if (e.isPopupTrigger()) {
	      //popup.show(ContextMenu.this, e.getX(), e.getY());
	    }
	  }
	}

	  // Inner class to print information in response to popup events
	  class PopupPrintListener implements PopupMenuListener {
	    public void popupMenuWillBecomeVisible(PopupMenuEvent e) {
	    }

	    public void popupMenuWillBecomeInvisible(PopupMenuEvent e) {
	      System.out.println("The value is now " );
	    }

	    public void popupMenuCanceled(PopupMenuEvent e) {
	      System.out.println("Popup menu is hidden!");
	    }
	  }
}
