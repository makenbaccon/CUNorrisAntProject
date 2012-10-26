public class Ant {

	int type, targetNum,prox,prox0;
	double xcoor,ycoor,bearing,targetx,targety;
	boolean success,carryFood;
	char direction;
	
	public Ant() {
		type=1;
		targetx=0;
		targety=0;
		bearing=2*Math.PI*Math.random();
		xcoor=5*Math.cos(bearing);
		ycoor=5*Math.sin(bearing);
		success=false;
		carryFood=false;
		direction='r';
		}
	
	public void walk(int w, int h) {
		if(direction=='r'){
			bearing+=1.2*Math.random()-.6;
			move(1);
		}else if(direction=='h'){
			bearing=Math.atan(ycoor/xcoor);
			if(xcoor>0)
				bearing+=Math.PI;
			move(1);
		}else if(direction=='t'){
			bearing=Math.atan((targety-ycoor)/(targetx-xcoor));
			if(xcoor<0)
				bearing+=Math.PI;
			move(1.1);
		}else if(direction=='d'){
			if(prox>prox0){
				bearing=1.2*Math.random()-.6;
			}
			move(1);
		}
		
		if(Math.abs(xcoor+Math.cos(bearing))>w){
			bearing-=Math.PI;
		}else if(Math.abs(ycoor+Math.sin(bearing))>h){
			bearing*=-1;
		}
	}
	
	public void move(double step){
		if(bearing>2*Math.PI) {
			bearing-=2*Math.PI;
		}else if(bearing<0){
			bearing+=2*Math.PI;
		}
		
		xcoor+=step*Math.cos(bearing);
		ycoor+=step*Math.sin(bearing);
	}
	
	public void findFood(double x, double y, int j) {
		targetx=x;
		targety=y;
		success=true;
		carryFood=true;
		direction='h';
		targetNum=j;
		type=2;
	}

	public void atNest() {
		if(success){
			direction='t';
			carryFood=false;
		}
	}
	
	public void forage(double x, double y) {
		if(success==true && carryFood==false && Math.abs(targetx-xcoor)<=2.5 && Math.abs(targety-ycoor)<=2.5 && 
			targetx!=x && targety!=y){
			success=false;
			direction= 'r';
			type=1;
		}
	}
	
	public void foundDebris(){
		type=3;
		direction='d';
	}
	
	public int getType() {
		return type;
	}
	public double getTargetX() {
		return targetx;
	}
	public double getTargetY() {
		return targety;
	}
	public double getX() {
		return xcoor;
	}
	public double getY() {
		return ycoor;
	}
	public double getBearing() {
		return bearing;
	}
	public boolean getSuccess() {
		return success;
	}
	public boolean getCarryFood() {
		return carryFood;
	}
	public int getTarget(){
		return targetNum;
	}
	public void setProx(int p){
		prox0=prox;
		prox=p;
	}
	public void setTarX(double x){
		targetx=x;
	}
	public void setTarY(double y){
		targety=y;
	}
	public void setDirection(char dir){
		direction=dir;
	}
    /*double x, y;
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
    }*/
}