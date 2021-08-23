
class Asteroid {

  // Asteroid location, velocity, and acceleration 
  PVector location, velocity, acceleration;
  float mass;                                          // Mass is tied to size
  float size;                                          // Size of the asteroid
  int maxHealth;                                       // Asteroid maximum health
  int health;                                          // Asteroid current health
  float repelStrength = 100;                           // Asteroid repel force
  float maxForce;                                      // Maximum steering force
  float maxSpeed;                                      // Maximum speed
  float r;

  // Asteroid constructor
  Asteroid(PVector asteroidLocation, float asteroidMass, int asteroidHealth, float asteroidMaxForce, float asteroidMaxSpeed) {
    location = asteroidLocation;
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    mass = asteroidMass;
    size = mass*16;
    maxHealth = asteroidHealth;
    health = maxHealth;
    maxForce = asteroidMaxForce;
    maxSpeed = asteroidMaxSpeed;
    r = 3.0;
  }


  // This function applies a force to the asteroid
  void applyForce(PVector force) {
    PVector newForce = PVector.div(force, mass);        // Divide by mass
    acceleration.add(newForce);                         // Accumulate all forces in acceleration
  }


  // This function Updates the asteroid
  void update() {
    velocity.add(acceleration);                        // Velocity changes according to acceleration
    velocity.limit(maxSpeed);                          // Limit the maximum speed
    location.add(velocity);                            // Location changes by velocity
    acceleration.mult(0);                              // Acceleration must be cleared each frame
  }
  
  
  // Implementing Reynolds' flow field following algorithm
  void follow(FlowField flow) {
    
    // What is the vector at that spot in the flow field?
    PVector desired = flow.lookup(location);
    
    // Scale it up by maxspeed
    desired.mult(maxSpeed);
    
    // Steering is desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);  // Limit to maximum steering force
    applyForce(steer);
  }
  
  
  // Wraparound
  void checkBorders() {
    if (location.x < -r) location.x = width+r;
    if (location.x > width+r) location.x = -r;
  }
  
  
  // This function draws the asteroid
  void display() {
    stroke(255);
    strokeWeight(2);
    fill(255, 200);
    ellipse(location.x, location.y, size, size);
  }
  

  // This function applies a repeller force between the asteroid and any particles
  PVector repel(Particle theParticle) {
    PVector dir = PVector.sub(location,theParticle.location);
    float d = dir.mag();
    dir.normalize();
    d = constrain(d,5,100);
    float force = -1 * repelStrength / (d * d);
    dir.mult(force);
    return dir;
  }
  

  // This function checks if the asteroid has reached the bottom of the screen
  boolean outOfBounds(boolean gameOver) {
    if (location.y >= 840) gameOver = true;          // If the asteroid has reached the bottom of the screen the boolean is set true
    return gameOver;                                 // Returns the boolean
  }
}