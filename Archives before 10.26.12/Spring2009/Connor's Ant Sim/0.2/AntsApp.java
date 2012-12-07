import java.applet.*;
import java.awt.*;
import java.util.*;
import java.awt.event.*;

public class AntsApp extends Applet implements Runnable, KeyListener {

    int width, height;
    double posx, posy;
    double zoom;
    double zoomspeed;
    ArrayList<Ant> ants;
    ArrayList<Thing> otherstuff;
    static double movex, movey;
    double movespeed = 5;
    double antspeed = 1;
    final double nearSize = 30;

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

        movex = 0;
        movey = 0;

        posx = 500;
        posy = 500;
        zoom = 1;
        zoomspeed = 1;

        //Set up our blocks
        otherstuff = new ArrayList<Thing>(600);
        for(int i = 0; i < 600; i++) {
            otherstuff.add(new Block(500 + Math.random()*800 - 400, 500 + Math.random()*800 - 400));
        }

        //Set up double buffering
        offscreen = createImage(width, height);
        bufferGraphics = offscreen.getGraphics();

        //Set up our ants
        ants = new ArrayList<Ant>(1000);
        for(int i = 0; i < 1000; i++) {
            ants.add(new Ant(500, 500));
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
                for(int i = 0; i < ants.size(); i++) {
                    ants.get(i).move(antspeed);
                }

                antCollisions();
                antNearbys();

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
                //t.sleep(10);
            }
        }
        catch (InterruptedException e) { }
    }

    public void antCollisions() {
        Ant a;
        Thing b;

       //Go through every block 
        for(int i = 0; i < ants.size(); i++) {
            a = ants.get(i);
            //Sort out ones that satisfy x collision
            for(int j = 0; j < otherstuff.size(); j++) {
                b = otherstuff.get(j);
                if(Math.abs(a.getX() - b.getX()) < 4)
                    if(Math.abs(a.getY() - b.getY()) < 4)
                            a.collided(b);
                        
            }
        }
    }

    public void antNearbys() {
        Ant a;
        Thing b;
        ArrayList<Thing> near;

        //Go through random ants
        for(int i = 0; i < 80; i++) {
            a = ants.get((int) (Math.random()*ants.size()));
            near = new ArrayList<Thing>();
            //Sort out blocks within nearby cutoff
            for(int j = 0; j < otherstuff.size(); j++) {
                b = otherstuff.get(j);
                if(Math.abs(a.getX() - b.getX()) < nearSize)
                    if(Math.abs(a.getY() - b.getY()) < nearSize)
                         near.add(b);
               
                a.setNearby(near);
            }
        }
    } 

    public void paint( Graphics g ) {
        bufferGraphics.clearRect(0,0,width, height);
        bufferGraphics.setColor( Color.red );
        
        //Draw ants
        for(int i = 0; i < ants.size(); i++) {
            Ant a = ants.get(i);
            double x = a.getX();
            double y = a.getY();
            double c = a.getColor();
            bufferGraphics.setColor(new Color(255, (int) (c*255), (int)(c*255)));
            if(withinView(x, y))
                bufferGraphics.fillRect(world2viewX(x),world2viewY(y), (int) (zoom/10) + 1, (int) (zoom/10) + 1);
           
        }

        //Draw blocks
        bufferGraphics.setColor( Color.cyan );
        for(int i = 0; i < otherstuff.size(); i++) {
            Thing b = otherstuff.get(i);
            double x = b.getX();
            double y = b.getY();
            if(withinView(x, y))
                bufferGraphics.fillRect(world2viewX(x), world2viewY(y), (int) (4*zoom)+ 1, (int) (4*zoom) + 1);
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
    public void keyTyped( KeyEvent e ) {}
}
