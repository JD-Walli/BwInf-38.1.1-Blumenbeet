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
    println(wishes[i][0] +" | "+wishes[i][1]);
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
      //colorNum=count; //je nachdem ob wunschpriorität oder farbanzahlpriorität
      println("Mehr Wunschfarben als max. Farbanzahl. Farbanzahl ");
    }
    print("Farbzuordnung:  ");
    for (int i=0; i<colorIDs.length; i++) {
      if(colorIDs[i]!=-1)print(i+"->"+colorIDs[i]+"  ");
    }
  }
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
            hamiltonMatrix[x*colorNum+l][a*colorNum+m] +=6;
          }

          if (x==a&&l==m) { //Grundbelohnung
            hamiltonMatrix[x*colorNum+l][a*colorNum+m] -= 4;
          }


          /*
          Farbwunschbelohnung:
           wenn Kästchen nebeneinanderliegen wird die gesamte kombi-Liste durchgegeangen und 
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


//Export der generierten Hamilton-Matrix
void exportHamiltonMatrix() {
  String [] export=new String[flowerNum*colorNum];
  for (int x=0; x<flowerNum*colorNum; x++) {
    export[x]="";
    for (int y=0; y<flowerNum*colorNum; y++) {
      export[x]+=hamiltonMatrix[x][y]+" ";
    }
  }
  saveStrings("blumenbeetQcMatrix.txt", export);
}



//Abruf der mit der eingegebenen Farbe verknüpften ID
int getColorID(String colour) {
  int colorID=100;
  switch(colour) {
  case "blau":
    colorID=0;
    break;
  case "gelb":
    colorID=1;
    break;
  case "gruen":
    colorID=2;
    break;
  case "orange":
    colorID=3;
    break;
  case "rosa":
    colorID=4;
    break;
  case "rot":
    colorID=5;
    break;
  case "tuerkis":
    colorID=6;
    break;
  }
  return colorID;
}

void printHamiltonMatrix(int[][]hamiltonMatrix){
   //Hamiltonian-Matrix ausgeben
  for (int i=0; i<hamiltonMatrix.length; i++) {
    for (int j=0; j<hamiltonMatrix.length; j++) {
      if (hamiltonMatrix[i][j] >= 0)
        print(" ");
      print(hamiltonMatrix[i][j]);
    }
    println();
  } 
}
