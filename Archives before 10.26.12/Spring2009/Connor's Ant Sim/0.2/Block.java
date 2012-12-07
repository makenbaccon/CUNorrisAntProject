public class Block extends Thing implements Carryable {

        boolean carried;

        public Block(double x, double y) {
                this.x = x;
                this.y = y;
                carried = false;
        }

        public void carry(double x, double y) {
            this.x = x;
            this.y = y;
        }

        public boolean carried() { return carried; }
        public void setCarry(boolean state) { carried = state; } 
}
