import java.util.Deque;
import java.util.ArrayDeque;

Lsystem l, l2, l3;

void setup() {
  size(1024, 1024);

  l=new Lsystem("X", 25, width/2, height*19/20, width*0.5*0.9);
  l.setMagnification(0.5);
  l.setAngle(-90);
  l.addRule('X', "F-[[X]+X]+F[+FX]-X");
  l.addRule('F', "FF");
  noLoop();
}

void mousePressed() {
  if (mouseButton==LEFT) {
    if (keyEvent!=null&&keyEvent.isShiftDown())
      g=createGraphics(width, height);
    redraw();
  } else {
    String name="output";
    for (int i=0;; i++) {
      String path=dataPath("");
      path=path.substring(0, max(path.lastIndexOf("/"), path.lastIndexOf("\\")));
      java.io.File f=new java.io.File(path+"/"+name+"("+i+").png");
      if (!f.exists()) {
        name+="("+i+").png";
        break;
      }
    }
    save(name);
  }
}

void draw() {
  strokeWeight(0);
  stroke(#00ff00);
  noFill();
  if (!(keyEvent!=null&&keyEvent.isShiftDown())) {
    background(0);
  } else {
    stroke(0);
  }

  int t=millis();
  l.draw();
  l.update();
  println("step "+frameCount+", take "+(millis()-t)+" millsec.");
}


public class PData {
  float x, y, d;
  public PData(float x, float y, float d) {
    this.x=x;
    this.y=y;
    this.d=d;
  }
}

public class Lsystem {
  String axiom, reglex;
  HashMap<Character, String>rule;
  float angleP, angleM, angle;
  float x, y, l, mag;
  Integer c;
  Deque<PData> stack;

  public Lsystem(String axiom, float angle, float x, float y, float l) {
    this(axiom, angle, angle, x, y, l);
  }
  public Lsystem(String axiom, float angleP, float angleM, float x, float y, float l) {
    this.axiom=axiom;
    this.angleP=angleP;
    this.angleM=angleM;
    this.x=x;
    this.y=y;
    this.l=l;
    this.mag=1;
    reglex="\\+-|-\\+";
    if (360%angleP==0)reglex+="|\\+{"+int(abs(360/angleP))+"}+";
    if (360%angleM==0)reglex+="|-{"+int(abs(360/angleM))+"}+";
    this.rule=new HashMap<Character, String>();
    this.stack=new ArrayDeque<PData>();
  }

  public void setAngle(float angle) {
    this.angle=angle;
  }
  public void setMagnification(float mag) {
    this.mag=mag;
  }
  public void setColor(int c) {
    this.c=c;
  }
  public void addRule(char c, String t) {
    rule.put(c, t);
  }

  public void update() {
    StringBuffer sb=new StringBuffer();
    for (char c : axiom.toCharArray ())
      sb.append(rule.containsKey(c)?rule.get(c):c);
    axiom=sb.toString().replaceAll(reglex, "");
  }

  public void draw() {
    float x=this.x, y=this.y, d=angle, l=this.l*pow(mag, frameCount-1);

    if (c!=null)stroke(c);
    beginShape();
    vertex(x, y);
    for (char c : axiom.toCharArray ())
      switch(c) {
      case 'G':
        x+=cos(radians(d))*l;
        y+=sin(radians(d))*l;
        endShape();
        beginShape();
        break;
      case 'A':
      case 'B':
      case 'F':
        x+=cos(radians(d))*l;
        y+=sin(radians(d))*l;
        vertex(x, y);
        break;
      case '+':
        d+=angleP;
        break;
      case '-':
        d-=angleM;
        break;
      case '|':
        d+=180;
        break;
      case '[':
        stack.push(new PData(x, y, d));
        break;
      case ']':
        PData p=stack.pop();
        x=p.x;
        y=p.y;
        d=p.d;
        endShape();
        beginShape();
        vertex(x, y);
        break;
      }
    endShape();
    l*=mag;
  }

  public String toString() {
    return axiom;
  }
}

