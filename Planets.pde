final float PERIOD_MODIFIER = 2;
final float DISTANCE_MODIFIER = 100;
final int TRAIL_LENGTH = 120;

Planet[] planets;
float zoom = 1;
boolean renderEpicycles = false;

void setup() {
  size(1000, 1000);

  planets = new Planet[9];
  planets[3] = new Planet(1 * DISTANCE_MODIFIER, 1 * PERIOD_MODIFIER, null, 0, 0, 255);
  planets[0] = new Planet(0 * DISTANCE_MODIFIER, 0 * PERIOD_MODIFIER, planets[3], 255, 255, 0);
  planets[1] = new Planet(0.39 * DISTANCE_MODIFIER, 0.240846 * PERIOD_MODIFIER, planets[3], 150, 75, 0);
  planets[2] = new Planet(0.723 * DISTANCE_MODIFIER, 0.615 * PERIOD_MODIFIER, planets[3], 0, 255, 0);
  planets[4] = new Planet(1.524 * DISTANCE_MODIFIER, 1.881 * PERIOD_MODIFIER, planets[3], 255, 0, 0);
  planets[5] = new Planet(5.203 * DISTANCE_MODIFIER, 11.86 * PERIOD_MODIFIER, planets[3], 255, 165, 0);
  planets[6] = new Planet(9.539 * DISTANCE_MODIFIER, 29.46 * PERIOD_MODIFIER, planets[3], 255, 253, 208);
  planets[7] = new Planet(19.18 * DISTANCE_MODIFIER, 84.01 * PERIOD_MODIFIER, planets[3], 102, 153, 204);
  planets[8] = new Planet(30.06 * DISTANCE_MODIFIER, 164.8 * PERIOD_MODIFIER, planets[3], 0, 127, 255);
}

void draw() { 
  background(0);
  translate (width / 2, height / 2);
  scale(zoom);

  for (int i = 0; i < planets.length; i++)
  {
    planets[i].next();
    planets[i].draw();
  }
}

void mousePressed()
{
  renderEpicycles = !renderEpicycles;
}

void mouseWheel(MouseEvent e)
{
  int scroll = e.getCount();
  zoom = constrain(zoom - 0.1 * scroll, 0.1, 3);
}

class Trail
{
  final int red;
  final int green;
  final int blue;
  
  float[] trailX = new float[TRAIL_LENGTH];
  float[] trailY = new float[TRAIL_LENGTH];
  
  Trail(int r, int g, int b)
  {
    red = r;
    green = g;
    blue = b;
  }
  
  void clear(float x, float y)
  {
    for (int i = 0; i < TRAIL_LENGTH; i++)
    {
      trailX[i] = x;
      trailY[i] = y;
    }
  }

  void push(float x, float y)
  {
    if (trailX[0] == x && trailY[0] == y)
    {
      return;
    }
    for (int i = TRAIL_LENGTH - 1; i > 0; i--)
    {
      trailX[i] = trailX[i - 1];
      trailY[i] = trailY[i - 1];
    }
    trailX[0] = x;
    trailY[0] = y;
  }
  
  void draw()
  {
    strokeWeight(2);

    for (int i = TRAIL_LENGTH - 2; i > 0; i--)
    {
      stroke(red, green, blue, map(TRAIL_LENGTH - i, 0, TRAIL_LENGTH, 0, 255));
      line(trailX[i], trailY[i], trailX[i + 1], trailY[i + 1]);
    }
    
    strokeWeight(8);
    stroke(red, green, blue, 255);
    point(trailX[0], trailY[0]);
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
  
  Planet(float r, float orbitSeconds, Planet centerPoint, int red, int green, int blue)
  {
    this.r = r;
    this.trail = new Trail(red, green, blue);
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
    this.trailEpicycles = new Trail(red, green, blue);
    if (centerPoint != null)
    {
      this.trailEpicycles.clear(r - centerPoint.r, 0);
    }
  }
  
  void next()
  {
    float ox = r * cos(angle * PI / 180);
    float oy = r * sin(angle * PI / 180);
    ox = round(ox * 100) / 100;
    oy = round(oy * 100) / 100;
    
    trail.push(ox, oy);
    if (centerPoint != null)
    {
      trailEpicycles.push(ox - centerPoint.trail.trailX[0], oy - centerPoint.trail.trailY[0]);
    }
    
    angle += angleChange;
    if (angle >= 360)
    {
      angle -= 360;
    }
  }
  
  void draw()
  {
    if (renderEpicycles)
    {
      trailEpicycles.draw();
    }
    else
    {
      trail.draw();
    }
  }
}
