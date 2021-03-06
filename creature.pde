//Creature class

class Creature {
  
  //Genetic Variables - maxspd, internalclockrate, radius, 
  
  private PVector pos;
  private int radius, sightrange, directionalrange;
  private int hunger, maxhunger;
  private int breedvalue, breedvaluemax;
  private float dir, spd, maxspd;
  private float internalclock, internalclockrate;

  //Class Constructor(s)
  //May delete overloading constructors if they are unused
  
  public Creature(PVector pos, int radius, int sightrange, float internalclockrate, int maxhunger, int breedvaluemax, float maxspd) {
    this.pos = pos;
    this.radius            = radius;
    this.sightrange        = sightrange;
    this.directionalrange  = directionalrange;
    this.internalclockrate = internalclockrate;
    this.maxhunger         = maxhunger;
    this.breedvaluemax     = breedvaluemax;
    this.maxspd            = maxspd;

    dir               = random(0, PI);
    directionalrange  = 90;
    spd               = 0.0;
    internalclock     = 0.0;
    maxspd            = random(12)+4;
    breedvalue        = 0;

    hunger            = maxhunger;
  }
  
  public Creature(int posx, int posy, int radius) {
    this.pos         = new PVector(posx, posy);
    this.radius      = radius;
    dir              = random(0, PI);
    spd              = 0.0;
    sightrange       = 500;
    directionalrange = 90;
    breedvaluemax    = int(random(50, 100));
    breedvalue       = 0;

    internalclock     = 0.0;
    internalclockrate = random(5)+1;
    maxspd            = random(12)+4;
    
    maxhunger         = 100;
    hunger            = maxhunger;
  }
  
  public Creature() {
    pos = new PVector(0, 0);
    radius           = 50;
    dir              = random(0, PI);
    spd              = 0.0;
    sightrange       = 500;
    directionalrange = 90;
    breedvaluemax    = int(random(50, 100));
    breedvalue       = 0;

    internalclock     = 0.0;
    internalclockrate = random(5)+1;
    maxspd            = random(12)+4;

    maxhunger         = 100;
    hunger            = maxhunger;
  }
  
  //Getters and Setters
  
  public float getposx() {
    return pos.x;
  }
  
  public float getposy() {
    return pos.y;
  }
  
  public PVector getpos() {
    return pos.copy();
  }
  
  public int getradius() {
    return radius;
  }
  
  public float getdir() {
    return dir;
  }
  
  public float getspd() {
    return spd;
  }

  public int getsightrange() {
    return sightrange;
  }

  public int getdirectionalrange() {
    return directionalrange;
  }

  public int getbreedvaluemax() {
    return breedvaluemax;
  }

  public int getbreedvalue() {
    return breedvalue;
  }

  public float getmaxspd() {
    return maxspd;
  }

  public float geticr() {
    return internalclockrate;
  }

  public int getmaxhunger() {
    return maxhunger;
  }
  
  public void setposx(int posx) {
    pos.x = posx;
  }
  
  public void setposy(int posy) {
    pos.y = posy;
  }
  
  public void setpos(PVector newpos) {
    pos = newpos;
  }
  
  public void setradius(int radius) {
    this.radius = radius;
  }
  
  public void setdir(float dir) {
    this.dir = dir;
  }
  
  public void setspd(float spd) {
    this.spd = spd;
  }

  public void setsightrange(int sr) {
    sightrange = sr;
  }

  public void setdirectionalrange(int dr) {
    directionalrange = dr;
  }

  public void setbreedvaluemax(int bvm) {
    breedvaluemax = bvm;
  }

  public void setbreedvalue(int bv) {
    breedvalue = bv;
  }

  public void setmaxspd(int mspd) {
    maxspd = mspd;
  }

  public void seticr(float icr) {
    internalclockrate = icr;
  }

  public void setmaxhunger(int mhunger) {
    maxhunger = mhunger;
  }
  
  //Class methods
  
  public void drawCreature() {
    //Draws creatures as circles
    int rate = 200 / maxhunger;
    fill((hunger * rate) + 55);
    circle(pos.x, pos.y, radius);
    //Toggles line drawn
    if (linetoggle) {
      strokeWeight((log(spd + exp(1)))*.75);
      stroke(255 - ((hunger * rate) + 55));
      line(pos.x, pos.y, pos.x + (cos(dir) * 8 * spd), pos.y + (sin(dir) * 8 * spd));
      strokeWeight(1);
    }
    //Toggles the sight range being drawn
    //MAY CAUSE SLOWDOWN WITH LARGE AMOUNTS OF CREATURES
    if (sighttoggle) {
      fill(0, 20);
      strokeWeight(0);
      circle (pos.x, pos.y, sightrange);
      strokeWeight(1);
    }
  }
  
  public void update() {
    //Check hunger, if below 0 kill creature
    if (hunger < 0) {
      this.deathcall();
    }

    //Check if breeding partner is nearby
    //If so, check if they are able to breed
    for (Creature c : livecreatures) {
      if (PVector.dist(c.getpos(), pos) < sightrange / 2 && !isequalto(c)) {
        if (c.getbreedvalue() == c.getbreedvaluemax() && hunger > maxhunger / 2) {
          createchild(this, c);
          break;
        }
      }
    }

    //Consuming food
    ArrayList<Food> currentfood = (ArrayList)worldfood.clone();
    for (Food f : currentfood) {
      if (PVector.dist(f.getpos(), pos) < ((radius / 2) + (f.size / 2))) {
        hunger += f.size;
        f.removefood();
        spawnfood(1);
      }
    }

    //Updates internalclock and adds speed if over a certain threshold
    internalclock += internalclockrate;
    if (internalclock > 100 && spd == 0) {
      internalclock = 0;
      hunger -= maxspd / 3;
      //Find closest food
      PVector closestobjectpos = new PVector();
      float closestobjectdist = -1.0;
      for (Food f : worldfood) {
        if ((closestobjectdist == -1.0 || closestobjectdist > PVector.dist(f.getpos(), pos)) && PVector.dist(f.getpos(), pos) < sightrange / 2) {
          closestobjectpos = f.getpos();
          closestobjectdist = PVector.dist(f.getpos(), pos);
        }
      }
      
      //If food is out of range, find closest creature
      //NOT IN USE CURRENTLY

      // if (closestobjectpos.mag() == 0.0) {
      //   for (Creature c : livecreatures) {
      //     if ((closestobjectdist == -1.0 || closestobjectdist > PVector.dist(c.getpos(), pos)) && PVector.dist(c.getpos(), pos) < sightrange / 2) {
      //       if (!this.isequalto(c)) {
      //         closestobjectpos = c.getpos();
      //         closestobjectdist = PVector.dist(c.getpos(), pos);
      //       }
      //     }
      //   }
      // }

      //If object is out of range, use random direction
      if (closestobjectpos.mag() == 0.0) {
        dir = radians(random(degrees(dir) - directionalrange, degrees(dir) + directionalrange));
      } else {
        //If no random direction, use position of object to get direction
        dir = -atan2(pos.y - closestobjectpos.y, closestobjectpos.x - pos.x);
      }
      //Apply max spd to spd
      breedvalue++;
      if (breedvalue > breedvaluemax) {
        breedvalue = breedvaluemax;
      }
      spd += maxspd;
    }
    
    //Applies friction to speed and disallows speed from being below 0.0
    if (spd >= friction) {
      spd -= friction;
    }
    else {
      spd = 0.0;
    }
    
    //Caps hunger at maxhunger
    if (hunger > maxhunger) {
      hunger = maxhunger;
    }

    //Movement function
    this.move();
  }
  
  public void move() {
    //Moves creature depending on direction and speed
    if (spd != 0) {
      pos.x += int(cos(dir) * spd);
      pos.y += int(sin(dir) * spd);
    }

    if (pos.x < (windowsize[0] / 2) - ((borderlength - 25) / 2)) {
      pos.x += borderlength;
    } else if (pos.x > (windowsize[0] / 2) + ((borderlength + 25) / 2)) {
      pos.x -= borderlength;
    }
    if (pos.y < (windowsize[1] / 2) - ((borderlength - 25) / 2)) {
      pos.y += borderlength;
    } else if (pos.y > (windowsize[1] / 2) + ((borderlength + 25) / 2)) {
      pos.y -= borderlength;
    }
  }
  
  public boolean isequalto(Creature c) {
    //Checks if creature is equal to given creature
    if (this == c) {
      return true;
    }
    return false;
  }

  public void deathcall() {
    //Removes creature from livecreature arraylist
    livecreatures.remove(this);
  }
}

//Common creature methods

void spawncreatures(int numofspawns) {
  //Spawns creatures in area given by windowsize
  for (int a = 0;a < numofspawns;a++) {
    livecreatures.add(new Creature(int(random(borderlengthcreature) + (windowsize[0] / 2) - (borderlengthcreature / 2) - 25)
    , int(random(borderlengthcreature) + (windowsize[1] / 2) - (borderlengthcreature / 2) - 25), 50));
  }
}

void snapallcreatures() {
  //Clears all creatures from population
  livecreatures.clear();
}

void createchild(Creature c1, Creature c2) {
  //Creates child creature with random genes from given creatures (IN PROGRESS)
  Creature[] creatureparents = {c1, c2};

  c1.setbreedvalue(0);
  c2.setbreedvalue(0);

  int b_radius = creatureparents[int(random(1))].getradius();
  int b_sightrange = creatureparents[int(random(1))].getsightrange();
  float b_internalclockrate = creatureparents[int(random(1))].geticr();
  int b_maxhunger = creatureparents[int(random(1))].getmaxhunger();
  int b_breedvaluemax = creatureparents[int(random(1))].getbreedvaluemax();
  float b_maxspd = creatureparents[int(random(1))].getmaxspd();
  PVector b_pos = creatureparents[int(random(1))].getpos();

  livecreatures.add(new Creature(b_pos, b_radius, b_sightrange, 
    b_internalclockrate, b_maxhunger, b_breedvaluemax, b_maxspd));
}
