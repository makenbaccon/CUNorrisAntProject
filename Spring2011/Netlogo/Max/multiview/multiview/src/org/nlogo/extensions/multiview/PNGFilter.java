package org.nlogo.extensions.multiview;

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


/** Filter to work with JFileChooser to select png file type. **/
public class PNGFilter extends javax.swing.filechooser.FileFilter
{
	  public boolean accept (File f) {
	    return f.getName ().toLowerCase ().endsWith (".png")
	          || f.isDirectory ();
	  }	 
	  public String getDescription () {
	    return "Portable Network Graphics (*.png)";
	  }
}
