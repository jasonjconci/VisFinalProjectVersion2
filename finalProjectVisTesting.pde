import java.util.*;
import java.lang.*;
import g4p_controls.*;

Table originalTable;
Table totalsTable;

ArrayList<Float> totalsList;
ArrayList<Float> handgunList;
ArrayList<Float> longgunList;
ArrayList<Float> otherList;
Map<String, ArrayList<StateAtMonth>> byStateMap;
ArrayList<String> stateList;

int MID_SCREEN;
GButton[] stateButtons = new GButton[50];
GButton generalButton, backToMain;

int stateView;
String currentState;

PFont f;

String[] nameOfStates = {"Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
"Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
"Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
"New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
"Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
"Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin",
"Wyoming"};

String[] years = {"1998", "1999", "2000", "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017"};

void handleButtonEvents (GButton button, GEvent event) {
   if(event == GEvent.CLICKED){
     if((button.getText() != "Line Chart") && (button.getText() != "Stacked Bar Chart") && (button.getText() != "Back To Menu")) {
       currentState = button.getText();
       for(int i = 0; i < 50; i++) {
          stateButtons[i].dispose();
          stateButtons[i] = null;
       }
       //generalButton.dispose();
       //generalButton = null;
       clear();
       background(255, 255, 255);
       backToMain = new GButton(this, (width / 2), 100, 100, 50, "Back To Menu");
       stateView = 1;
    }
  
    if(button.getText() == "Back To Menu") {
      backToMain.dispose();
      backToMain = null;
      drawButtons();
      stateView = 0;
    }
  }
}

void drawButtons() {
   for (int i = 0; i < 10; i = i + 1) {
     stateButtons[i] = new GButton(this, 50, 60 + (i*(height/11)), 100, 50, nameOfStates[i]);
   }
   for (int i = 0; i < 10; i = i + 1) {
     stateButtons[i+10] = new GButton(this, 180, 60 + (i*(height/11)), 100, 50, nameOfStates[i+10]);
   }
   for (int i = 0; i < 10; i = i + 1) {
     stateButtons[i+20] = new GButton(this, 310, 60 + (i*(height/11)), 100, 50, nameOfStates[i+20]);
   }
   for (int i = 0; i < 10; i = i + 1) {
     stateButtons[i+30] = new GButton(this, 440, 60 + (i*(height/11)), 100, 50, nameOfStates[i+30]);
   }
   for (int i = 0; i < 10; i = i + 1) {
     stateButtons[i+40] = new GButton(this, 570, 60 + (i*(height/11)), 100, 50, nameOfStates[i+40]);
   }
   //generalButton = new GButton(this, 700, 60, 100, 50, "General");
}

void setup(){
  fullScreen();
  smooth();
  background(#ffffff);
  surface.setResizable(true);
  
  MID_SCREEN = height / 2;
  stateView = 0;
  
  originalTable = loadTable("nics-firearm-background-checks.csv", "header");
  totalsTable = loadTable("nics_firearm_background_checks_total_by_month.csv", "header");
  
  // These four ArrayLists are the monthly total, across all states of our table for handgun, longgun,
  // other, and the total of all permits given for a given month in the U.S.
  totalsList = new ArrayList<Float>();
  handgunList = new ArrayList<Float>();
  longgunList = new ArrayList<Float>();
  otherList = new ArrayList<Float>();
  
  // Adding values for our total-by-month table
  for(TableRow row: totalsTable.rows()){
   float total = (float) ((row.getInt("totals")/1000));
   float handgun = (float) (row.getInt("handgun")/1000);
   float longgun = (float) (row.getInt("long_gun")/1000);
   float other = (float) (row.getInt("other")/1000);
   
   totalsList.add(0,total);
   handgunList.add(0,handgun);
   longgunList.add(0,longgun);
   otherList.add(0,other);
   
   f = createFont("Arial", 16, true);
  }
 
 byStateMap = new HashMap<String, ArrayList<StateAtMonth>>();
 stateList = new ArrayList<String>();
  
  for(TableRow row: originalTable.rows()){
    // First, we get the name of the state we're working with
    String stateName = row.getString("state");
    // Next, if it isnt in our list of state names, we add it
    if(stateList.indexOf(stateName) == -1) stateList.add(stateName);
    
    // Then, we get the ArrayList of our current state
    ArrayList<StateAtMonth> currList = byStateMap.get(stateName);
    StateAtMonth curr = new StateAtMonth(row.getInt("totals"), 
      row.getInt("handgun"), row.getInt("long_gun"), row.getInt("other"));
    // If the ArrayList has been initialized, we add our current entry to the front
    if(currList != null){
      currList.add(0,curr);
    } 
    // Otherwise, we make a new ArrayList, add our current state to it, and put it in the HashMap
    else {
      ArrayList<StateAtMonth> newList = new ArrayList<StateAtMonth>();
      newList.add(0,curr);
      byStateMap.put(stateName, newList);
    }
  }
  drawButtons();
}


void draw(){
  textFont(f, 28);
  if(stateView == 1) {
    clear();
    background(255, 255, 255);
    drawStateView(currentState);
  }
  else {
    clear();
    background(255, 255, 255);
  }
}

void drawStateView(String state) {
  clear();
  background(255, 255, 255);
  
  drawStateBarChart(state);
  drawByState(state);
}

void drawStateBarChart(String state) {
  rectMode(CORNER);
  ArrayList<StateAtMonth> currState = byStateMap.get(state);
  int maxValState = Collections.max(currState, new StateComparator()).getTotal();
  double bar_width = ((width - 20) / (currState.size()/15))/15;
  float scale = ((MID_SCREEN-20)/((float)maxValState/4)/4);

  for(int i = 0; i < currState.size(); i++) {
    StateAtMonth currMonth = currState.get(i);  
    float yHandgun = scale * currMonth.getHandgun();
    float yLonggun = scale * currMonth.getLonggun();
    float yOther = scale * currMonth.getOther();
    float yTotal = scale * currMonth.getTotal();
    
    // draw total lines
    //stroke(#000000);
    //line(10 + ((float)bar_width * i), MID_SCREEN - 20 - (float)yTotal, 10 + (float)bar_width + ((float)bar_width * i), MID_SCREEN - 20 - (float)yTotal);
    
    strokeWeight(1);
    stroke(#ffffff);
    // longgun
    fill(#0000ff);
    rect(10 + ((float)bar_width * i), (MID_SCREEN - 20 - yLonggun), (float)bar_width, yLonggun);
    
    // handgun
    fill(#ff0000);
    rect(10 + ((float)bar_width * i), (MID_SCREEN - 20 - yLonggun - yHandgun), (float)bar_width, yHandgun);
    
    fill(#00ff00);
    rect(10 + ((float)bar_width * i), (MID_SCREEN - 20 - yLonggun - yHandgun - yOther), (float)bar_width, yOther);
    }
    
    // draw year lines
    stroke(#000000);
    for(int i = (10 + (2 * (int) bar_width)); i < width; i += (bar_width * 12)) {
      line(i, 0, i, height);
    }
    
    fill(#000000);
    text(years[1], (10 + (4 * (int)bar_width)), 50);
    text(years[2], (10 + (16* (int)bar_width)), 50);
    text(years[3], (10 + (28 * (int)bar_width)), 50);
    text(years[4], (10 + (40 * (int)bar_width)), 50);
    text(years[5], (10 + (52 * (int)bar_width)), 50);
    text(years[6], (10 + (64 * (int)bar_width)), 50);
    text(years[7], (10 + (76 * (int)bar_width)), 50);
    text(years[8], (10 + (88 * (int)bar_width)), 50);
    text(years[9], (10 + (100 * (int)bar_width)), 50);
    text(years[10], (10 + (112 * (int)bar_width)), 50);
    text(years[11], (10 + (124 * (int)bar_width)), 50);
    text(years[12], (10 + (136 * (int)bar_width)), 50);
    text(years[13], (10 + (148 * (int)bar_width)), 50);
    text(years[14], (10 + (160 * (int)bar_width)), 50);
    text(years[15], (10 + (172 * (int)bar_width)), 50);
    text(years[16], (10 + (184 * (int)bar_width)), 50);
    text(years[17], (10 + (196 * (int)bar_width)), 50);
    text(years[18], (10 + (208 * (int)bar_width)), 50);
    text(years[19], (10 + (220 * (int)bar_width)), 50);
}

void drawByState(String state){
  ArrayList<StateAtMonth> currState = byStateMap.get(state);
  int maxValState = Collections.max(currState, new StateComparator()).getTotal();
  double X_UNIT = ((width-20) / (currState.size()/15)) / 15;
  double Y_UNIT = (float) ((MID_SCREEN+10) / (maxValState/4))/4;
  double[] lastX = new double[] {10,10,10,10};
  double[] lastY = new double[] {MID_SCREEN+10,MID_SCREEN+10,MID_SCREEN+10,MID_SCREEN+10};
  
  for(int i = 0; i < currState.size(); i++){
   StateAtMonth currMonth = currState.get(i);
   double xTotal = X_UNIT * (i+1);
   double yTotal = Y_UNIT * (maxValState +  currMonth.getTotal());
   double xHandgun = X_UNIT * (i+1);
   double yHandgun = Y_UNIT * (maxValState + currMonth.getHandgun());
   double xLonggun = X_UNIT * (i+1);
   double yLonggun = Y_UNIT * (maxValState + currMonth.getLonggun());
   double xOther = X_UNIT * (i+1);
   double yOther = Y_UNIT * (maxValState + currMonth.getOther());
   
   strokeWeight(3);
   stroke(#000000);
   line((float) lastX[0], (float) lastY[0], (float) xTotal, (float) yTotal);
   stroke(#ff0000);
   line((float)lastX[1], (float)lastY[1], (float)xHandgun, (float)yHandgun);
   stroke(#0000ff);
   line((float)lastX[2], (float)lastY[2], (float)xLonggun,  (float)yLonggun);
   stroke(#009900);
   line((float)lastX[3], (float)lastY[3],(float) xOther,(float) yOther);
   
   lastX = new double[] {xTotal, xHandgun, xLonggun, xOther};
   lastY = new double[] {yTotal, yHandgun, yLonggun, yOther};
  }
  
  
}




// Generalized Point class - meant to be a sort of foundation for all points
// used in a dot-line chart. 
class Point{
  float xCoord, yCoord;
  int numberToShow;
  int month;
  int year;
  
  Point(float xCoord, float yCoord, int numberToShow, int month, int year){
    this.xCoord = xCoord;
    this.yCoord = yCoord;
    this.numberToShow = numberToShow;
    this.month = month;
    this.year = year;
  }
}

// Meant to be a concise way of storing all of the data for a state at a given month.
// Really, just a glorified struct
class StateAtMonth{
 int total, handgun, longgun, other;
 
 StateAtMonth(int total, int handgun, int longgun, int other){
  this.total = total/2000;
  this.handgun = handgun/2000;
  this.longgun = longgun/2000;
  this.other = other/2000;
 }
 int getTotal(){
  return this.total; 
 }
 int getHandgun(){
  return this.handgun; 
 }
 int getLonggun(){
  return this.longgun; 
 }
 int getOther(){
  return other; 
 }
 
 @Override
 public String toString(){
   return this.total + " " + this.handgun + " " + this.longgun + " " + this.other;
 }
 
}

class StateComparator implements Comparator {
  public int compare(Object o1, Object o2){
   StateAtMonth s1 = (StateAtMonth) o1;
   StateAtMonth s2 = (StateAtMonth) o2;
   
   return (s1.getTotal() > s2.getTotal()) ? 1:-1;
  }
}