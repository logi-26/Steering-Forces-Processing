
class Particle {
  
  // Particle location, velocity, and acceleration 
  PVector location, velocity, acceleration;
  float lifespan;
  float mass = 1;
  float size;
  int r,g,b;

  // Particle constructor
  Particle(PVector particleLocation, float particleSize, int red, int green, int blue) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-2,0));
    location = particleLocation.get();
    lifespan = 255.0;
    size = particleSize;
    r = red;
    g = green;
    b = blue;
  }
 
  // This function updates and displays the particle
  void run() {
    update();
    display();
  }

  // // This function Applies a force to a single particle in the system
  void applyForce(PVector force) {
    PVector f = force.get();
    f.div(mass);
    acceleration.add(f);
  }

  // This function updates the particle
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    lifespan -= 2.0;
  }

  // This function displays the particle
  void display() {
    stroke(r,g,b,lifespan);
    fill(r,g,b,lifespan);
    ellipse(location.x,location.y,size,size);
  }

  // This function is used to determine if the particle has died out
  boolean isDead() {
    if (lifespan < 0.0) return true;
    else return false;
  }

  // This function is used to determine if the particle has collided with the player ship
  boolean collideWithPlayer() {
    if (location.x >= mouseX-20 && location.x <= mouseX-20 + 40 && location.y >= 830 && location.y <= 830 + 30 && !isDead()) return true; 
    else return false;
  }

  // This function is used to determine if the particle has collided with an asteroid
  boolean collideWithAsteroid(Asteroid theAsteroid) {
    
    if (location.x >= theAsteroid.location.x && location.x <= theAsteroid.location.x + theAsteroid.size && 
    location.y >= theAsteroid.location.y && location.y <=theAsteroid.location.y + theAsteroid.size && !isDead()) return true; 
    else return false;
  }
}