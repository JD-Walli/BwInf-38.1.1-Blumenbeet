int flowerNum = 9; //Anzahl der Blumen  //<>//
int colorNum = 0; //Anzahl der Farben (Standardwert)
boolean[][] flowerConfig; //x=blumenkasten y=farbe
int[][] hamiltonMatrix = new int[flowerNum*colorNum][flowerNum*colorNum]; //Matrix zur Ausführung auf Qc
int colorIDs[] = {-1, -1, -1, -1, -1, -1, -1}; //88q
int wishes[][]; //speichert Wunchkombinationen (Farbe1 Farbe2 Belohnung) 
ArrayList<String> simAnnGraph = new ArrayList<String>();


void setup() {
  readFile();
  reassignColorIDs();
  hamiltonMatrix = new int[flowerNum*colorNum][flowerNum*colorNum];
  calculateHamiltonMatrix();
  exportHamiltonMatrix();
  noLoop();
}


void draw() { 
  flowerConfig = new boolean[flowerNum][colorNum];
  randomizeFlowerConfig();
  simulatedAnnealing();
  flowerConfigGraphicalOutput(flowerConfig);
  exportGraph(simAnnGraph);
}
