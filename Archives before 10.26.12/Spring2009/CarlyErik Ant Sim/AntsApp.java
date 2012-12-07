import java.applet.*;
import java.awt.*;
import java.util.*;
import java.awt.event.*;

public class AntsApp extends Applet implements Runnable, KeyListener {

    int width, height,W,H,Rad;
    int nestFood,time;
    double posx, posy;
    double zoom;
    double zoomspeed;
    ArrayList<Ant> ants;
    Food[] eats;
    Debris[] junk;
    static double movex, movey;
    double movespeed = 5;
    double antspeed = 1;

    //Used for doublebuffering
    Graphics bufferGraphics;
    Image offscreen;

    //Used for threading
    Thread t = null;
    boolean threadSuspended;

    //Started when applet is created
    public void init() {
        System.out.println("App initiated");
        width = getSize().width;
        height = getSize().height;
        setBackground( Color.black );
        addKeyListener(this);
        
        nestFood=0;
        
        W=700;
        H=500;
        Rad=100;
        time=0;

        movex = 0;
        movey = 0;

        posx = 0;
        posy = 0;
        zoom = 1;
        zoomspeed = 1;

        //Set up double buffering
        offscreen = createImage(width, height);
        bufferGraphics = offscreen.getGraphics();

        //Set up our ants
        ants = new ArrayList<Ant>(20);
        for(int i = 0; i < 20; i++) {
            ants.add(new Ant());
        }
        
        //Set up Food source
        eats = new Food[10];
        for(int j = 0; j<eats.length; j++){
        	eats[j]=new Food(W,H);
        }
        
        //Spread debris
        junk = new Debris[10];
        for(int k = 0; k<junk.length; k++){
        	junk[k]=new Debris(W,H);
        }
    }

    public void destroy() {}

    //provides a transformation from the world position to view position
    public int world2viewX(double x) {
        return (int) ((x - posx) * zoom + (width * 0.5));
    }

    public int world2viewY(double y) {
        return (int) ((y - posy) * zoom + (height * 0.5));
    }

    public boolean withinView(double x, double y) {
        int xtrans = world2viewX(x);
        int ytrans = world2viewY(y);

        return (xtrans > 0 && xtrans < width && ytrans > 0 && ytrans < height);
    }

    //Executed when applet is created and whenever browser returns to applet
    public void start() { 
        if( t == null) {
            t = new Thread( this );
            threadSuspended = false;
            t.start();
        } else {
            if(threadSuspended) {
                threadSuspended = false;
                synchronized( this ) {
                    notify();
                }
            }
        }
    }

    public void stop() {
        threadSuspended = true;
    }

    // Executed within the thread that this applet created.
    public void run() {
        try {
            while(true) {
            	time++;
                for(int i = 0; i < ants.size(); i++) {
                    ants.get(i).walk(W,H);
                    ants.get(i).forage(eats[ants.get(i).getTarget()].getX(),eats[ants.get(i).getTarget()].getY());
                    foodTest(i);
                    nestTest(i);
                    proxTest(i);
                    debrisTest(i);
                    //followTest(i);
                }
                
                for(int j = 0; j < eats.length; j++){
                	if (eats[j].getFoodLeft()<=0)
                		eats[j].moveFood(W,H);
                }
                
                for(int k = 0; k < junk.length; k++){
                	
                }
                
                spawnAnt();
                //System.out.println(ants.get(1).getType());
                
				//System.out.println(nestFood + "," + ants.size());
				            
                posx += movex;
                posy += movey;
                zoom *= zoomspeed;	
                
                if( threadSuspended ) {
                    synchronized( this ) {
                        while( threadSuspended) {
                            wait();
                        }
                    }
                }
                repaint();
                t.sleep(5);
            }
        }
        catch (InterruptedException e) { }
    }

    public void paint( Graphics g ) {
        bufferGraphics.clearRect(0,0,width, height);
        
        bufferGraphics.setColor( Color.red );
        for(int i = 0; i < eats.length; i++){
        	Food e = eats[i];
        	double x = eats[i].getX();
        	double y = eats[i].getY();
            if(withinView(x, y))
                bufferGraphics.fillRect(world2viewX(x)-3,world2viewY(y)-3,6,6);
        }
        
        bufferGraphics.setColor( Color.blue );
        for(int j = 0; j < junk.length; j++){
        	Debris e = junk[j];
        	double x = ants.get(junk[j].getCarrier()).getX();
        	double y = ants.get(junk[j].getCarrier()).getY();
            if(withinView(x, y))
                bufferGraphics.fillRect(world2viewX(x)-3,world2viewY(y)-3,6,6);
        }

        for(int i = 0; i < ants.size(); i++) {
        	if(ants.get(i).getType()==1){
        		bufferGraphics.setColor( Color.white );
        	}else if(ants.get(i).getType()==2){
        		bufferGraphics.setColor( Color.red );
        	}else if(ants.get(i).getType()==3){
        		bufferGraphics.setColor( Color.blue );
        	}
        	
            Ant a = ants.get(i);
            double x = a.getX();
            double y = a.getY();
            if(withinView(x, y))
                bufferGraphics.fillRect(world2viewX(x),world2viewY(y), (int) (zoom/10) + 1, (int) (zoom/10) + 1);
           
        }

        g.drawImage(offscreen,0,0,this);
    }

    public void update(Graphics g) {
        paint(g);
    }

    public void keyPressed( KeyEvent e ) {
        //Movement and zooming
        if( e.getKeyCode() == e.VK_LEFT ) 
            movex = -movespeed/zoom;
        if( e.getKeyCode() == e.VK_RIGHT ) 
            movex = movespeed/zoom;
        if( e.getKeyCode() == e.VK_DOWN )
            movey = movespeed/zoom;
        if( e.getKeyCode() == e.VK_UP )
            movey = -movespeed/zoom;
        if( e.getKeyCode() == e.VK_Q )
            zoomspeed = 1.01;
        if( e.getKeyCode() == e.VK_A )
            zoomspeed = 0.99;

    }

    public void keyReleased( KeyEvent e ) { 
        if( e.getKeyCode() == e.VK_LEFT )
            movex = 0;
        if( e.getKeyCode() == e.VK_RIGHT)
            movex = 0;
        if( e.getKeyCode() == e.VK_DOWN)
            movey = 0;
        if( e.getKeyCode() == e.VK_UP)
            movey = 0;
        if( e.getKeyCode() == e.VK_Q )
            zoomspeed = 1;
        if( e.getKeyCode() == e.VK_A )
            zoomspeed = 1;
    }
    
    public void keyTyped( KeyEvent e ) {
    }
    
    public void foodTest(int i) {
    	for(int j = 0; j < eats.length; j++) {
    		if(ants.get(i).getType()==1){
    			if(Math.abs(eats[j].getX()-ants.get(i).getX())<=2.5) {
					if(Math.abs(eats[j].getY()-ants.get(i).getY())<=2.5) {
							ants.get(i).findFood(eats[j].getX(),eats[j].getY(),j);
							eats[j].decFood();
					}
				}
			}
    	}
    }  
    	
    public void debrisTest(int i) {
    	for(int k = 0; k < junk.length; k++) {
    		if(junk[k].getX()*junk[k].getX()+junk[k].getY()*junk[k].getY()<100000 && junk[k].getCarry()!=true){	
    			if(ants.get(i).getType()==1 || ants.get(i).getType()==2){
    				if(Math.abs(junk[k].getX()-ants.get(i).getX())<=2.5) {
						if(Math.abs(junk[k].getY()-ants.get(i).getY())<=2.5) {
							junk[k].setCarrier(i);
							junk[k].setCarry(true);
							//junk[k].moveDebris(ants.get(i).getX(),ants.get(i).getY());
							ants.get(i).foundDebris();
						}	
					}
				}
    		}
    	}
    }
    
    public void nestTest(int i) {
   		if(Math.abs(ants.get(i).getX())<=5){
   			if(Math.abs(ants.get(i).getY())<=5){
   				if(ants.get(i).getCarryFood())
  					nestFood+=5;
  				ants.get(i).atNest();
   			}
   		}
    }
    
    public void spawnAnt() {
    	if((nestFood-ants.size())/5>=1){
    		ants.add(new Ant());
    		nestFood-=5;
    	}
    }
    
    public void proxTest(int i){
    	int pro = 0;
    	for(int j = (i+1); j < ants.size(); j++){
    		if(Math.abs(ants.get(i).getX()-ants.get(j).getX())<=5){
    			if(Math.abs(ants.get(i).getY()-ants.get(j).getY())<=5){
    				pro++;
    			}
    		}
    	}
    	ants.get(i).setProx(pro);
    }
    
    /*public void followTest(int i){
    	double nearx=ants.get(1).getX();
    	double neary=ants.get(1).getY();
    	int nearnum=1;
    	
    	if(ants.get(i).getSuccess()!=true){
    		for(int j = 1; j < ants.size(); j++){
    			if(ants.get(j).getSuccess()){
    				if((Math.abs(ants.get(i).getX()-ants.get(j).getX())+Math.abs(ants.get(i).getY()-ants.get(j).getY()))<
    					(Math.abs(ants.get(i).getX()-nearx)+Math.abs(ants.get(i).getY()-neary))){
    						nearx=ants.get(j).getX();
    						neary=ants.get(j).getY();
    				}
    			}
    		}
    	}
    	if((nearx*nearx+neary*neary)<100){
    		ants.get(i).setTarX(nearx);
    		ants.get(i).setTarY(neary);
    		ants.get(i).setDirection('t');
    	}
    }*/
}
