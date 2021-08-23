
class Seeker {
  
  // Seeker location, velocity, and acceleration 
  PVector location, velocity, acceleration;
  float mass;                                        // Seeker mass
  float size;                                        // Seeker size
  float maxForce;                                    // Maximum steering force
  float maxSpeed;                                    // Maximum speed
 
  // Seeker constructor
  Seeker(PVector seekerLocation) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-10,-8));
    location = seekerLocation.get();
    size = 14;
    maxSpeed = 10;
    maxForce = 0.1;
    mass = 1;
  }
 
 
 // This function Applies a force to the seeker
  void applyForce(PVector force) {
    PVector f = force.get();
    f.div(mass);
    acceleration.add(f);
  }
 
 
 // This function updates the seeker
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
  }


  // This function displays the seeker
  void display() {
    stroke(231,250,14);
    fill(231,250,14);
    ellipse(location.x,location.y,size,size);
  }
 
 
 // This function is used to determine if the seeker object has hit an asteroid
 boolean hitAsteroid(ArrayList<Asteroid> asteroidArray, ArrayList<ParticleSystem> asteroidParticleSystemArray) {

   boolean asteroidHit = false;
   
   // Loops through the asteroid array
   for(int i = 0; i < asteroidArray.size(); i++) {
      Asteroid theAsteroid = (Asteroid)asteroidArray.get(i); 
      
      // Calculates the distance between the seeker and the asteroid
      float distance = dist(location.x, location.y, theAsteroid.location.x, theAsteroid.location.y);
        
      // If the distance is less than 30 (the seeker has hit the asteroid)
      if (distance < 30) {
        
        // Set the asteroid hit boolean value
        asteroidHit = true; 

        // Create a new particle system
        ps = new ParticleSystem(theAsteroid.location);
        float particleSize = theAsteroid.mass * 3;                                                           // The asteroid particles size is relative to the size of the asteroid
        int red = 255;                                                                                       // Asteroid particles are red
        int green = 0;
        int blue = 0;
        for(int j = 0; j < 10; j++) ps.addParticle(particleSize, red, green, blue);                          // This adds 10 red particles with the size relative to the asteroid that spawns them
      
        PVector gravity = new PVector(0,1);                                                                  // This sets the gravitational force
        ps.applyForce(gravity);                                                                              // This applies the gravitational force to the particle
        asteroidParticleSystemArray.add(ps);                                                                 // This adds the new particle system to the particle system array         
        
        theAsteroid = null;                                                                                  // This sets the asteroid to null
        asteroidArray.remove(i);                                                                             // This removes the asteroid from the asteroid array list
      }
    }
   
  return asteroidHit;                                                                                        // Returns the asteroid hit boolean value
 }
 
 
  // A method that calculates a steering force towards a target
  void seek(PVector target) {
    PVector desired = PVector.sub(target,location);                                                          // A vector pointing from the location to the target
    
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxSpeed);
    
    // Steering = Desired minus velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxForce);                                                                                  // Limit to maximum steering force
    
    applyForce(steer);
  }
}