String solution="0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 1 0 0 0 0";
int flowerNum=9;
int solutionInt[]=int(split(solution, " "));
int colorNum=solutionInt.length/flowerNum;
int[][] hamiltonMatrix;
boolean flowerConfig[][]=new boolean[flowerNum][colorNum];
int colorIDs[]={-1, -1, -1, -1, -1, -1, -1};  //siehe checkColorNum (newColorNums speichert an der Stelle der (alten) farbziffer die neue (z.b. rot -> 5 -> newColorNums[5])
int wishes[][];//speichert Wunchkombinationen (Farbe1 Farbe2 Belohnung)

void setup() {
  readFile();
  reassignColorIDs();

  String matrixString []=loadStrings("qubomatrix.txt");
  hamiltonMatrix=new int[matrixString.length][matrixString.length];
  for (int i=0; i<matrixString.length; i++) {
    String[] matrixReihe=new String[matrixString.length];
    matrixReihe=split(matrixString[i], " ");
    for (int j=0; j<matrixString.length; j++) {
      hamiltonMatrix[i][j]=int(matrixReihe[j]);
    }
  }

  //kombi ausgeben
  println("Wunschkombinationen nach vereinfachung:");
  for (int i=0; i<wishes.length; i++) {
    println(wishes[i][0]+" "+wishes[i][1]+" "+wishes[i][2]+" ");
  }
  
  randomizeFlowerConfig();
  //blumenkasten anzeigen
  for (int i=0; i<colorNum; i++) {
    print(i+": ");
    for (int j=0; j<flowerNum; j++) {
      print((flowerConfig[j][i]?1:0)+"  ");
    }
    println();
  }
  
  checkSolution();
  println("Punkte: "+getScore());
  flowerConfigGraphicalOutput(flowerConfig);
}


//Berechnung der aus der Aufgebenstellung resultierenden Punktzahl
int getScore() {
  int punkte=0;

  for (int x=0; x<flowerNum; x++) {
    for (int l=0; l<colorNum; l++) {
      for (int a=0; a<flowerNum; a++) {
        for (int m=0; m<colorNum; m++) {
          if ((x==0&&a==1||x==1&&a==0)||(x==0&&a==2||x==2&&a==0)||
            (x==1&&a==2||x==2&&a==1)||(x==1&&a==3||x==3&&a==1)||(x==1&&a==4||x==4&&a==1)||
            (x==2&&a==4||x==4&&a==2)||(x==2&&a==5||x==5&&a==2)||
            (x==3&&a==4||x==4&&a==3)||(x==3&&a==6||x==6&&a==3)||
            (x==4&&a==5||x==5&&a==4)||(x==4&&a==6||x==6&&a==4)||(x==4&&a==7||x==7&&a==4)||
            (x==5&&a==7||x==7&&a==5)||
            (x==6&&a==7||x==7&&a==6)||(x==6&&a==8||x==8&&a==6)||
            (x==7&&a==8||x==8&&a==7)) {

            if (flowerConfig[x][l]&&flowerConfig[a][m]) {
              for (int i=0; i<wishes.length; i++) {
                if (wishes[i][0]==l&&wishes[i][1]==m) {
                  punkte+=wishes[i][2];
                }
              }
            }
          }
        }
      }
    }
  }
  return punkte;
}


//Überprüfung der Richtigkeit der Lösung
void checkSolution() { 
  int anzahlDoppFarbe=0;
  int anzahlKeineFarbe=0;
  int anzahlFarbeNichtVerwendet=0;

  //zählt Farben pro Kästchen
  for (int x=0; x<flowerNum; x++) {
    int points=0;
    for (int y=0; y<colorNum; y++) {
      points+=flowerConfig[x][y]?1:0;
    }
    if (points==0) anzahlKeineFarbe++;
    else if (points>1)anzahlDoppFarbe++;
  }

  //zählt Kästchen pro Farbe
  for (int x=0; x<colorNum; x++) {
    int points=0;
    for (int y=0; y<flowerNum; y++) {
      points+=flowerConfig[y][x]?1:0;
    }
    if (points==0) anzahlFarbeNichtVerwendet++;
  }

  println(anzahlKeineFarbe +" x no color");
  println(anzahlDoppFarbe +" x 2+ colors");
  println(anzahlFarbeNichtVerwendet +" x color not used");
  println();
}


//Blumenkonfiguration zufällig befüllen
void randomizeFlowerConfig() {
  for (int i=0; i<flowerNum; i++) {
    for (int j=0; j<colorNum; j++) {
      flowerConfig[i][j]=int(random(2))==0?false:true;
    }
  }
}


//Eingabedatei auslesen; wishes und colorNum initialisieren
void readFile() {
  String[] strings = loadStrings("input.txt");
  colorNum = int(strings[0]);
  wishes = new int[int(strings[1])][3];
  for (int i=0; i<int(strings[1]); i++) {
    String s[]= strings[i+2].split(" ");
    s[0].trim(); 
    s[1].trim(); 
    s[2].trim();
    wishes[i][0]=getColorID(s[0]);
    wishes[i][1]=getColorID(s[1]);
    wishes[i][2]=int(s[2]);
  }
}


//Ausgabe einer Blumenkonfiguration (Lösung) in graphischer Form auf der Konsole
void flowerConfigGraphicalOutput(boolean blumenkasten[][]) {
  int[] solution=new int[flowerNum];
  //Tabelle "eindimensional machen"
  for (int i=0; i<flowerNum; i++) {
    for (int j=0; j<colorNum; j++) {
      if (blumenkasten[i][j]) { 
        solution[i]=j; 
        break;
      }
    }
  }
  //solution farbnummern austauschen (neue durch alte)
  for (int i=0; i<flowerNum; i++) {
    for (int j=0; j<7; j++) {
      if (colorIDs[j]==solution[i]) { 
        solution[i]=j;
        break;
      }
    }
  }
  //Ausgabe in Rautenform
  println("     "+getColorName(solution[0]).substring(0, 3));
  println("  "+getColorName(solution[1]).substring(0, 3)+"  "+getColorName(solution[2]).substring(0, 3));
  println(getColorName(solution[3]).substring(0, 3)+"  "+getColorName(solution[4]).substring(0, 3)+"  "+getColorName(solution[5]).substring(0, 3));
  println("  "+getColorName(solution[6]).substring(0, 3)+"  "+getColorName(solution[7]).substring(0, 3));
  println("     "+getColorName(solution[8]).substring(0, 3));
  println();
  //ausgabe als reihe  
  for (int i=0; i<flowerNum; i++) {
    print(i+":"+getColorName(solution[i])+"  ");
  }
}


int costFunction(boolean[][]blumenkastenLocal) {
  int ergebnis=0;
  int[] vektor=new int[flowerNum*colorNum];
  int[] vektorerg=new int[flowerNum*colorNum];

  for (int i=0; i<flowerNum; i++) {
    for (int j=0; j<colorNum; j++) {
      vektor[i*colorNum+j]=blumenkastenLocal[i][j]==true? (1):(0);
    }
  }

  for (int i=0; i<flowerNum*colorNum; i++) {
    for (int j=0; j<flowerNum*colorNum; j++) {
      vektorerg[i]+=hamiltonMatrix[i][j]*vektor[j];
    }
  }

  for (int i=0; i<flowerNum*colorNum; i++) {
    ergebnis+=vektor[i]*vektorerg[i];
  }
  return ergebnis;
}

//Generierung der problemspezifischen Hamilton-Matrix
//(Die Bestrafungs- bzw. Belohnungswerte müssen ggf. an die Problemgröße angepasst werden) 88q
void calculateHamiltonMatrix() {
  for (int l=0; l<colorNum; l++) {
    for (int x=0; x<flowerNum; x++) {
      for (int m=0; m<colorNum; m++) {
        for (int a=0; a<flowerNum; a++) {

          if (x==a && l!=m) { //nur eine Farbe pro Kästchen
            hamiltonMatrix[x*colorNum+l][a*colorNum+m] = 12;
          }

          if (x!=a && l==m) { //möglichst wenig gleiche Farben
            hamiltonMatrix[x*colorNum+l][a*colorNum+m] +=5;
          }

          if (x==a&&l==m) { //Grundbelohnung
            hamiltonMatrix[x*colorNum+l][a*colorNum+m] -= 4;
          }


          /*
          Farbwunschbelohnung:
           wenn Kästchen nebeneinanderliegen wird die gesamte kombi-Liste durchgegegangen und 
           jede kombi überprüft ob sie grade von m und l dargestellt wird und die belohnung 
           an der entsprechenden Stelle angetragen.
           Die Felder sind folgendermaßen nummeriert:
           0  2  5
           1  4  7
           3  6  8
           */

          if ((x==0&&a==1||x==1&&a==0)||(x==0&&a==2||x==2&&a==0)||
            (x==1&&a==2||x==2&&a==1)||(x==1&&a==3||x==3&&a==1)||(x==1&&a==4||x==4&&a==1)||
            (x==2&&a==4||x==4&&a==2)||(x==2&&a==5||x==5&&a==2)||
            (x==3&&a==4||x==4&&a==3)||(x==3&&a==6||x==6&&a==3)||
            (x==4&&a==5||x==5&&a==4)||(x==4&&a==6||x==6&&a==4)||(x==4&&a==7||x==7&&a==4)||
            (x==5&&a==7||x==7&&a==5)||
            (x==6&&a==7||x==7&&a==6)||(x==6&&a==8||x==8&&a==6)||
            (x==7&&a==8||x==8&&a==7)) { //checkt ob grade 2 nebeneinanderliegende Felder von x und a dargestellt werden (Sorry Paul, ist nicht die schönste Variante)

            for (int i=0; i<wishes.length; i++) {

              if (wishes[i][0]==m&&wishes[i][1]==l || wishes[i][0]==l&&wishes[i][1]==m) {
                hamiltonMatrix[x*colorNum+l][a*colorNum+m] -= 1.5*wishes[i][2];
              }
            }
          }
        }
      }
    }
  }
}


//Neuzuordnung der Farb-IDs nach Kürzung nicht verwendeter Farben
void reassignColorIDs() { 
  if (colorNum!=7) {
    int count=0;
    for (int i=0; i<wishes.length; i++) {
      if (colorIDs[wishes[i][0]]!=-1) {
        wishes[i][0]=colorIDs[wishes[i][0]];
      } else {
        colorIDs[wishes[i][0]]=count;
        wishes[i][0]=count;
        count++;
      }
      if (colorIDs[wishes[i][1]]!=-1) {
        wishes[i][1]=colorIDs[wishes[i][1]];
      } else {
        colorIDs[wishes[i][1]]=count;
        wishes[i][1]=count;
        count++;
      }
    }
    if (colorNum!=count) {
      colorNum=count;
      println("Mehr Wunschfarben als max. Farbanzahl. Farbanzahl ");
    }
    print("Farbzuordnung:  ");
    for (int i=0; i<colorIDs.length; i++) {
      if (colorIDs[i]!=-1)print(i+"->"+colorIDs[i]+"  ");
    }
  }
}


//macht aus der Zahl wieder den ursprünglichen Farbnamen
String getColorName(int s) {
  String colorName="";
  switch(s) {
  case 0:
    colorName="blau";
    break;
  case 1:
    colorName="gelb";
    break;
  case 2:
    colorName="gruen";
    break;
  case 3:
    colorName="orange";
    break;
  case 4:
    colorName="rosa";
    break;
  case 5:
    colorName="rot";
    break;
  case 6:
    colorName="tuerkis";
    break;
  }
  return colorName;
}


//Abruf der mit der eingegebenen Farbe verknüpften ID
int getColorID(String colour) {
  int colorNum=100;
  switch(colour) {
  case "blau":
    colorNum=0;
    break;
  case "gelb":
    colorNum=1;
    break;
  case "gruen":
    colorNum=2;
    break;
  case "orange":
    colorNum=3;
    break;
  case "rosa":
    colorNum=4;
    break;
  case "rot":
    colorNum=5;
    break;
  case "tuerkis":
    colorNum=6;
    break;
  }
  return colorNum;
}
