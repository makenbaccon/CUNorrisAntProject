public class Ant {

    double x, y;
    double direction;

    public Ant(double x, double y) {
        this.x = x;
        this.y = y;
        direction = Math.PI/2;
    }

    public double getX() { return x; }
    public double getY() { return y; }

    public void move(double speed) {
        x += Math.cos(direction)*speed;
        y += Math.sin(direction)*speed;
        direction = (direction + (Math.random()*2 - 1)*Math.PI/20)*speed % (2*Math.PI);
    }
}
