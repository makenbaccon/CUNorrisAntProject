/**
 * @(#)Food.java
 *
 *
 * @author 
 * @version 1.00 2010/2/11
 */


public class Food {
	
	int foodLeft;
	double x,y;

    public Food(int w, int h){
    	x=2*w*Math.random()-w;
    	y=2*h*Math.random()-h;
    	foodLeft=100;
    }
    
    public void moveFood(int w, int h){
    	x=2*w*Math.random()-w;
    	y=2*h*Math.random()-h;
    	foodLeft=100;
    }
    
    public void decFood(){
    	foodLeft-=5;
    }
    
    public double getX(){
    	return x;
    }
    
    public double getY(){
    	return y;
    }
    
    public int getFoodLeft(){
    	return foodLeft;
    }
  
}