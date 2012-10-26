package org.nlogo.extensions.multiview;

import org.nlogo.api.*;
import java.awt.event.ActionListener; 
import javax.swing.*;

import java.awt.*;
import java.awt.geom.*;
import java.util.HashMap;
import java.util.Collection;
import java.util.Iterator;

/**
 * Class to provide multiple Views/World Images.
 * Contains definitions of NetLogo primitives.
 * Copyright (C) [2010]  [JC Thiele]
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA 
 * @author JC Thiele
 * @contact jthiele at gwdg.de
 * @version 0.1
 */
public class MultiView extends DefaultClassManager {
	
	    public void load(PrimitiveManager primitiveManager) 
		{
	    	primitiveManager.addPrimitive( "newView" , new MakeView() ) ;
	        primitiveManager.addPrimitive( "repaint" , new Repaint() ) ;
	        primitiveManager.addPrimitive( "close" , new CloseView() ) ;
	        primitiveManager.addPrimitive( "rename" , new Rename() ) ;  
	    }

	    public void unload()
	    {
			try
			{
				clearAll();
			}
			catch( Exception e )
			{
				System.err.println( e.getMessage() ) ;
			}
	    }

	    
	    
	    
	    
	    // save all View instances to execute clearAll operation
		/**
		 * A counter giving the number of View created.
		 */
	    private static long viewcounter = 0;
		/**
		 * A HashMap holding the View instances created, accessible by their number (viewcounter).
		 * Needed to close all View Windows when executing clear-all in NetLogo.
		 */
	    private static HashMap<Long,View> viewMap = new HashMap<Long,View> ();

	    
		/**
		 * Class to set a new name/title to a specified View Window. 
		 */
		public static class Rename extends DefaultCommand
		{
			public Syntax getSyntax() {
				return Syntax.commandSyntax(new int[] {Syntax.TYPE_WILDCARD, Syntax.TYPE_STRING});
			}
			public String getAgentClassString()
			{
				return "OTPL" ;
			}    	
		    public void perform(Argument args[], Context context) throws ExtensionException, LogoException
		    { 
		    	try
		    	{
		    		Object view = args[0].get();
		    		if (!(view instanceof View)) {
						throw new org.nlogo.api.ExtensionException
						( "not a View object: " +
						  org.nlogo.api.Dump.logoObject( view ) ) ;		    			
		    		}
		    		((View) view).setName(args[1].getString());
		    	}
		    	catch (Exception ex)
				{
					throw new ExtensionException("Error in callRepaint: \n"+ex);
				}
		    }
		}

		/**
		 * Class to repaint/actualize a specified View Window. 
		 */
		public static class Repaint extends DefaultCommand
		{
			public Syntax getSyntax() {
				return Syntax.commandSyntax(new int[] {Syntax.TYPE_WILDCARD});
			}
			public String getAgentClassString()
			{
				return "OTPL" ;
			}    	
		    public void perform(Argument args[], Context context) throws ExtensionException, LogoException
		    { 
		    	try
		    	{
		    		Object view = args[0].get();
		    		if (!(view instanceof View)) {
						throw new org.nlogo.api.ExtensionException
						( "not a View object: " +
						  org.nlogo.api.Dump.logoObject( view ) ) ;		    			
		    		}
		    		((View) view).repaintPatches();
		    	}
		    	catch (Exception ex)
				{
					throw new ExtensionException("Error in callRepaint: \n"+ex);
				}
		    }
		}
		
		/**
		 * Class to close a specified View Window. 
		 */
		public static class CloseView extends DefaultCommand
		{
			public Syntax getSyntax() {
				return Syntax.commandSyntax(new int[] {Syntax.TYPE_WILDCARD});
			}
			public String getAgentClassString()
			{
				return "OTPL" ;
			}    	
		    public void perform(Argument args[], Context context) throws ExtensionException, LogoException
		    { 
		    	try
		    	{
		    		Object view = args[0].get();
		    		if (!(view instanceof View)) {
						throw new org.nlogo.api.ExtensionException
						( "not a View object: " +
						  org.nlogo.api.Dump.logoObject( view ) ) ;		    			
		    		}
		    		((View) view).closeWindow();
		    		viewMap.remove(((View) view).getViewcounter());
		    	}
		    	catch (Exception ex)
				{
					throw new ExtensionException("Error in callRepaint: \n"+ex);
				}
		    }
		}
		
		/**
		 * Class to create a new View Window. 
		 */
		public static class MakeView extends DefaultReporter
		{
			public Syntax getSyntax()
			{
				return Syntax.reporterSyntax
					( new int[] { Syntax.TYPE_STRING, Syntax.TYPE_STRING } ,
					  Syntax.TYPE_WILDCARD ) ;
			}
			
			public String getAgentClassString()
			{
				return "OTPL" ;
			}
			
			public Object report( Argument args[] , Context context)
				throws ExtensionException , LogoException
			{
		    	try
		    	{	 		
		    		View view = new View(viewcounter, args[0].getString());
		    		view.createView(context, args[1].getString());
		    		viewMap.put(viewcounter, view);
		    		viewcounter++;
		    		// org.nlogo.window.GUIWorkspace win = org.nlogo.app.App.app.frame.getWindows();
					return view;
		    	}
		    	catch (Exception ex)
				{
					throw new ExtensionException("Error in newView: \n"+ex);
				}
			}					      
		}
		
		/**
		 * Method to delete all View Windows when executing clear-all in NetLogo. 
		 */		
		public void clearAll()
		{
			Collection c = viewMap.values();
			Iterator itr = c.iterator();
			while(itr.hasNext())
			{
				View view = (View)itr.next(); 
				if (!view.isAlreadyDisposed()) {
					view.closeWindow();
				}
			}
			viewMap.clear();
    		viewcounter = 0;
		}


		
}
