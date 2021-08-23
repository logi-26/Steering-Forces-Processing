import java.util.Iterator;

ParticleSystem ps;

class ParticleSystem {
  
  ArrayList<Particle> particles;
  PVector origin;
 
  // Particle system constructor
  ParticleSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<Particle>();
  }


  // This function adds a new particle to the particle array list
  void addParticle(float size, int red, int green, int blue) {
    particles.add(new Particle(origin, size, red, green, blue));
  }


  // This function applies a force to the particles
  void applyForce(PVector f) {
    
    // Loop through all particles applying the force
    for (Particle p: particles) p.applyForce(f);
  }
  
  
  // This function applies a repell force for the asteroids
  void applyRepeller(Asteroid theAsteroid) {

    // Calculating a force for each Particle based on a Repeller
    for (Particle p: particles) {
      PVector force = theAsteroid.repel(p);
      p.applyForce(force);
    }
  }
 
 
 // This function is used to determine if the particle has collided with the player ship
 boolean hitPlayer() {
   
   boolean playerHit = false;
   for (Particle p: particles) {
      if (p.collideWithPlayer()) playerHit = true;
   }
    
  if (playerHit) return true;
  else return false;
 }
 
 
 // This function is used to determine if the particle has collided with an asteroid
 boolean hitAsteroid(Asteroid theAsteroid) {
   
   boolean asteroidHit = false;
   for (Particle p: particles) {
      if (p.collideWithAsteroid(theAsteroid)) asteroidHit = true;
   }
    
  if (asteroidHit) return true;
  else return false;
 }
 
 
  // This function runs the particle system
  void run() {
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = (Particle) it.next();
      p.run();
      if (p.isDead()) it.remove();
    }
  }
}