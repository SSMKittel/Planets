final float PERIOD_MODIFIER = 2;
final float DISTANCE_MODIFIER = 100;

Planet[] planets;
int offsetX = 0;
int offsetY = 0;
float zoom = 1;
boolean pause = false;
boolean renderEpicycles = false;

final color SUN_C = color(255, 255, 0);
final color MERCURY_C = color(150, 75, 0);
final color VENUS_C = color(0, 255, 0);
final color EARTH_C = color(0, 0, 255);
final color MARS_C = color(255, 0, 0);
final color JUPITER_C = color(255, 165, 0);
final color SATURN_C = color(255, 253, 208);
final color URANUS_C = color(102, 153, 204);
final color NEPTUNE_C = color(0, 127, 255);

void setup() {
  size(1000, 1000, P3D); // P2D looks nicer but has some severe performance issues on this simulation
  smooth(4);
  
  float earthDist = 1 * DISTANCE_MODIFIER;
  float earthPeriod = 1 * PERIOD_MODIFIER;

  planets = new Planet[9];
  planets[0] = new Planet(0 * DISTANCE_MODIFIER, 0 * PERIOD_MODIFIER, 1, new Planet(earthDist, earthPeriod), 30, SUN_C);
  planets[1] = new Planet(0.39 * DISTANCE_MODIFIER, 0.240846 * PERIOD_MODIFIER, 25, new Planet(earthDist, earthPeriod), 60, MERCURY_C);
  planets[2] = new Planet(0.723 * DISTANCE_MODIFIER, 0.615 * PERIOD_MODIFIER, 60, new Planet(earthDist, earthPeriod), 90, VENUS_C);
  planets[3] = new Planet(earthDist, earthPeriod, 90, null, 1, EARTH_C);
  planets[4] = new Planet(1.524 * DISTANCE_MODIFIER, 1.881 * PERIOD_MODIFIER, 120, new Planet(earthDist, earthPeriod), 120, MARS_C);
  planets[5] = new Planet(5.203 * DISTANCE_MODIFIER, 11.86 * PERIOD_MODIFIER, 200, new Planet(earthDist, earthPeriod), 200, JUPITER_C);
  planets[6] = new Planet(9.539 * DISTANCE_MODIFIER, 29.46 * PERIOD_MODIFIER, 500, new Planet(earthDist, earthPeriod), 500, SATURN_C);
  planets[7] = new Planet(19.18 * DISTANCE_MODIFIER, 84.0 * PERIOD_MODIFIER, 1000, new Planet(earthDist, earthPeriod), 1000, URANUS_C);
  planets[8] = new Planet(30.06 * DISTANCE_MODIFIER, 164.8 * PERIOD_MODIFIER, 2000, new Planet(earthDist, earthPeriod), 2000, NEPTUNE_C);
}

void draw() { 
  background(0);
  translate (width / 2, height / 2);
  scale(zoom);
  translate (offsetX, offsetY);

  if (!pause)
  {
    for (int i = 0; i < planets.length; i++)
    {
      planets[i].next();
    }
  }

  if (renderEpicycles)
  {
    for (int i = 0; i < planets.length; i++)
    {
      planets[i].drawEpicycles();
    }
  }
  else
  {
    for (int i = 0; i < planets.length; i++)
    {
      planets[i].draw();
    }
  }
}

void mouseDragged()
{
  if (mouseButton == LEFT)
  {
    offsetX += (mouseX - pmouseX) * (1 / zoom);
    offsetY += (mouseY - pmouseY) * (1 / zoom);
  }
}

void mousePressed()
{
  if (mouseButton == RIGHT)
  {
    renderEpicycles = !renderEpicycles;
  }
  else if (mouseButton == CENTER)
  {
    offsetX = 0;
    offsetY = 0;
  }
}

void mouseWheel(MouseEvent e)
{
  int scroll = e.getCount();
  zoom = constrain(zoom - 0.1 * scroll, 0.1, 3);
}

void keyPressed()
{
  if (key == ' ')
  {
    pause = !pause;
  }
}

class Trail
{
  private final color colour;
  
  private float[] trailX;
  private float[] trailY;
  
  Trail(int length, color colour)
  {
    trailX = new float[length];
    trailY = new float[length];
    this.colour = colour;
  }
  
  void clear(float x, float y)
  {
    for (int i = 0; i < trailX.length; i++)
    {
      trailX[i] = x;
      trailY[i] = y;
    }
  }
  
  float peekX()
  {
    return trailX[0];
  }
  
  float peekY()
  {
    return trailY[0];    
  }

  void push(float x, float y)
  {
    if (peekX() == x && peekY() == y)
    {
      return;
    }
    for (int i = trailX.length - 1; i > 0; i--)
    {
      trailX[i] = trailX[i - 1];
      trailY[i] = trailY[i - 1];
    }
    trailX[0] = x;
    trailY[0] = y;
  }
  
  void draw()
  {
    strokeWeight(4);
    noFill();
    
    beginShape();
    for (int i = trailX.length - 1; i > 0; i--)
    {
      stroke(colour, map(trailX.length - i, 0, trailX.length, 0, 255));
      vertex(trailX[i], trailY[i]);
    }
    endShape();

    strokeWeight(16);
    stroke(colour, 255);
    point(peekX(), peekY());
  }
}

class Planet
{
  final float r;
  float angle = 0;
  final float angleChange;
  final Trail trail;
  final Planet centerPoint;
  final Trail trailEpicycles;
    
  Planet(float r, float orbitSeconds) {
    this(r, orbitSeconds, 1, null, 1, color(0, 0, 0));
  }
  
  Planet(float r, float orbitSeconds, int trailLength, Planet centerPoint, int trailEpicycleLength, color colour) {
    this.r = r;
    this.trail = new Trail(trailLength, colour);
    this.trail.clear(r, 0);
    if (orbitSeconds == 0)
    {
      this.angleChange = 0;
    }
    else
    {
      this.angleChange = 360 / (frameRate * orbitSeconds);
    }
    
    this.centerPoint = centerPoint;
    this.trailEpicycles = new Trail(trailEpicycleLength, colour);
    if (centerPoint != null)
    {
      this.trailEpicycles.clear(r - centerPoint.r, 0);
    }
  }
  
  void next()
  {
    float ox = r * cos(angle * PI / 180);
    float oy = r * sin(angle * PI / 180);
    ox = round(ox * 10) / 10;
    oy = round(oy * 10) / 10;
    
    trail.push(ox, oy);
    if (centerPoint != null)
    {
      centerPoint.next();
      trailEpicycles.push(ox - centerPoint.trail.peekX(), oy - centerPoint.trail.peekY());
    }
    
    angle += angleChange;
    if (angle >= 360)
    {
      angle -= 360;
    }
  }
  
  void draw()
  {
    trail.draw();
  }
  
  void drawEpicycles()
  {
    trailEpicycles.draw();
  }
}
