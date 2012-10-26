/**
 * @(#)Debris.java
 *
 *
 * @author 
 * @version 1.00 2010/2/16
 */


public class Debris {

	double xDeb,yDeb;
	int carrier;
	boolean carry;

    public Debris(int w, int h){
    	xDeb=200*Math.random()-100;
    	yDeb=200*Math.random()-100;
    }
    
   
    
    public double getX(){
    	return xDeb;
    }
    
    public double getY(){
    	return yDeb;
    }
    
    public void moveDebris(double x, double y){
    	xDeb=x;
    	yDeb=y;
    }
    
    public void setCarrier(int c){
    	carrier=c;
    }
    
    public int getCarrier(){
    	return carrier;
    }
    
    public void setCarry(boolean c){
    	carry=c;
    }
    
    public boolean getCarry(){
    	return carry;
    }
}