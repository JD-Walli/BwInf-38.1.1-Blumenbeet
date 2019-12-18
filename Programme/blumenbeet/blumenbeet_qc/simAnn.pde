//Blumenkonfiguration zufällig befüllen
void randomizeFlowerConfig() {
  for (int i=0; i<flowerNum; i++) {
    for (int j=0; j<colorNum; j++) {
      flowerConfig[i][j]=int(random(2))==0?false:true;
    }
  }
}


//Blumenkasten nach Farben geordnet in Tabellenform ausgeben
void flowerConfigColorOutput() {
  for (int i=0; i<colorNum; i++) {
    print("color"+i+": ");
    for (int j=0; j<flowerNum; j++) {
      print((flowerConfig[j][i]?1:0)+"  ");
    }
    println();
  }
  println();
}


//Lösung des Optimierungsproblem mit simulated annealing 
void simulatedAnnealing() {
  float simAnn=costFunction(flowerConfig)-5;
  for (int durchlauf=0; durchlauf<2000000; durchlauf++) {
    int alteKosten = costFunction(flowerConfig);
    int x = int(random(flowerNum));
    int y = int(random(colorNum));
    flowerConfig[x][y]=!flowerConfig[x][y];
    int kosten = costFunction(flowerConfig);
    int kostenUnterschied=kosten-alteKosten;

    if ((kostenUnterschied>=0 && (random(1)>=exp(-kostenUnterschied/simAnn)))) {
      flowerConfig[x][y]=!flowerConfig[x][y];
    }

    simAnn*=0.99992;
  }
  println("\n");
  flowerConfigColorOutput();
  println("score: "+getScore());
  println("cost: "+costFunction(flowerConfig));
  println("temp: "+simAnn);
  println();
  checkSolution();
}


//Kostenfunktion für simulated annealing
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
