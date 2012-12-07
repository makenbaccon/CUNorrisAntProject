import java.util.*;

public class Ant extends Thing {

    double direction;
    double color;
    boolean carrying;
    Carryable carryee;
    ArrayList<Thing> nearby;
    double biasX, biasY;
    double biasLevel;

    public Ant(double x, double y) {
        this.x = x;
        this.y = y;
        biasX = x;
        biasY = y;
        direction = Math.random()*Math.PI*2;
        carrying = false;
        carryee = null;
        color = 0.5;
        nearby = new ArrayList<Thing>();
        biasLevel = Math.PI/500;
    }

    public void move(double speed) {
        x += Math.cos(direction)*speed;
        y += Math.sin(direction)*speed;

        int biasTurn;
        if(leftOf(direction, Math.atan((y-biasY)/(x-biasX))))
            if(x > biasX)
                biasTurn = 1;
            else
                biasTurn = -1;
        else
            if(x > biasX)
                biasTurn = -1;
            else
                biasTurn = 1;

        direction = (direction + (biasLevel*biasTurn + (Math.random()*2 - 1)*Math.PI/10)*speed);
        direction = direction % (2*Math.PI);

        if(carrying) {
            carryee.carry(x, y);
        }

        if( carrying && nearby.size() > 4) {
           carrying = false;
           carryee.setCarry(false);
        }
    }

    public double getColor() {
        return color;
    }

    public void collided(Thing other) {
       if(!carrying && other instanceof Carryable && other != carryee) {
           if(false == ((Carryable) other).carried()) {
                carryee = (Carryable) other;
                ((Carryable) other).setCarry(true);
                carrying = true;
           }
       }
    }

    public void setNearby(ArrayList<Thing> nearby) {
        this.nearby = nearby;
    }

    public int countNearby(Thing check) {
        int num = 0;
        for(int i = 0; i < nearby.size(); i++)
            if(check.getClass() == nearby.get(i).getClass())
                num++;

        return num;
    }

    public boolean leftOf(double theta1, double theta2) {
        theta2 = theta2 % (2*Math.PI);
        theta1 = theta1 % (2*Math.PI);

        if(theta2 < Math.PI)
            if(theta1 > theta2 && theta1 < theta2 + Math.PI)
                return true;
            else
                return false;
        else
            if(theta1 < theta2 && theta1 > theta2 - Math.PI)
                return false;
            else
                return true;
    }

}
