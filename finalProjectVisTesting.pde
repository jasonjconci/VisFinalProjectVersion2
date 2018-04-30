/*
* drawMenu function - When button clicked set current state and launch ...
* drawState function - which draws detailed state shit based on global variable
* 
* Make escape go back to main menu
*
*/
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

GButton[] stateButtons = new GButton[50];
String[] nameOfStates = {"Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
"Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan",
"Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
"New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
"Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
"Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin",
"Wyoming"};


void handleButtonEvents (GButton button, GEvent event) {
   if((button.getText() == "Alabama") && (event == GEvent.CLICKED)){
       println("Fuck this");
   }
   else {
     println("Nothing");
   }
}

void setup(){
  fullScreen();
  smooth();
  background(#ffffff);
  surface.setResizable(true);
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
   
   //draw all buttons on screen
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
   GButton generalButton = new GButton(this, 700, 60, 100, 50, "General");
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

  
}


void draw(){
  //drawByState("California");
  
  // Commenting out this bit - I'm guessing, in the future, we'll have a MODE variable, and
  // depending on the value of this variable, we will draw to the screen a different visualization
  
  /*
  float X_UNIT =  ((width-20) / totalsList.size());
  float Y_UNIT =  ((height-20) / Collections.max(totalsList));
  float lastXCoordinate = 10;
  float lastYCoordinate = (height-10);
  float max = Collections.max(totalsList);
  int size = totalsList.size();  
  for(int i = 0; i < size; i++){
    float currX = X_UNIT * (1+i);
    float currY = Y_UNIT * (max - totalsList.get(i));
    
    line(lastXCoordinate, lastYCoordinate, currX, currY);
    
    lastXCoordinate = currX;
    lastYCoordinate = currY;
  }*/
 
}


void drawByState(String state){
  ArrayList<StateAtMonth> currState = byStateMap.get(state);
  int maxValState = Collections.max(currState, new StateComparator()).getTotal();
  double X_UNIT = ((width-20) / (currState.size()/15)) / 15;
  double Y_UNIT = (float) ((height-20) / (maxValState/4))/4;
  double[] lastX = new double[] {10,10,10,10};
  double[] lastY = new double[] {height-10,height-10,height-10,height-10};
  
  for(int i = 0; i < currState.size(); i++){
   StateAtMonth currMonth = currState.get(i);
   System.out.println(currMonth); 
   double xTotal = X_UNIT * (i+1);
   double yTotal = Y_UNIT * (maxValState -  currMonth.getTotal());
   double xHandgun = X_UNIT * (i+1);
   double yHandgun = Y_UNIT * (maxValState - currMonth.getHandgun());
   double xLonggun = X_UNIT * (i+1);
   double yLonggun = Y_UNIT * (maxValState - currMonth.getLonggun());
   double xOther = X_UNIT * (i+1);
   double yOther = Y_UNIT * (maxValState - currMonth.getOther());
   
   
   stroke(#000000);
   line((float) lastX[0], (float) lastY[0], (float) xTotal, (float) yTotal);
   stroke(#ff0000);
   line((float)lastX[1], (float)lastY[1], (float)xHandgun, (float)yHandgun);
   stroke(#0000ff);
   line((float)lastX[2], (float)lastY[2], (float)xLonggun,  (float)yLonggun);
   stroke(#00ff00);
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