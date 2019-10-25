int blumenN=9;//Anzahl der Blumen //<>//
int farben = 7;//anzahl der Farben (defaultwert)
boolean[][] blumenkasten; //2d array x=blume y=farbe
int[][] hamiltonMatrix = new int[blumenN*farben][blumenN*farben];
int newColorNums[]={100, 100, 100, 100, 100, 100, 100};  //siehe checkColorNum (newColorNums speichert an der Stelle der (alten) farbziffer die neue (z.b. rot -> 5 -> newColorNums[5])
int kombi[][];//speichert die vorgegebenen Wunchkombinationen in der Form farbe1 farbe2 belohnung. den Farben werden Werte zugewiesen

void setup() {
  readFile();
  checkColorNum();
  //kombi ausgeben
  println("Wunschkombinationen nach vereinfachung:");
  for (int i=0; i<kombi.length; i++) {
    println(kombi[i][0]+" "+kombi[i][1]+" "+kombi[i][2]+" ");
  }
  blumenkasten = new boolean[blumenN][farben];
  //blumenkasten zufällig befüllen
  for (int i=0; i<blumenN; i++) {
    for (int j=0; j<farben; j++) {
      blumenkasten[i][j]=int(random(2))==0?false:true;
    }
  }
  noLoop();
}



void draw() {
  hamiltonianBerechnen();
  println();
  //Hamiltonian-Matrix anzeigen
  for (int i=0; i<blumenN*farben; i++) {
    for (int j=0; j<blumenN*farben; j++) {
      if (hamiltonMatrix[i][j] >= 0)
        print(" ");
      print(hamiltonMatrix[i][j]);
    }
    println();
  }

  //blumenkasten anzeigen
  for (int i=0; i<farben; i++) {
    print(i+": ");
    for (int j=0; j<blumenN; j++) {
      print((blumenkasten[j][i]?1:0)+"  ");
    }
    println();
  }
  exportiereHamiltonianMatrix();
  simulatedAnnealing();
  grafischeAusgabe(blumenkasten);
}


//liest File und befüllt kombi und "farben"
void readFile() {
  String[] strings=loadStrings("test.txt");
  farben=int(strings[0]);
  kombi = new int[int(strings[1])][3];
  for (int i=0; i<int(strings[1]); i++) {
    String s[]= strings[i+2].split(" ");
    s[0].trim(); 
    s[1].trim(); 
    s[2].trim();
    kombi[i][0]=getColorNum(s[0]); // getColorNum() macht aus der in der Textdatei angegebenen farbbezeichnung eine Zahl
    kombi[i][1]=getColorNum(s[1]);
    kombi[i][2]=int(s[2]);
  }
  println("Wunschkombinationen vor vereinfachung:");
  for (int i=0; i<kombi.length; i++) {
    println(kombi[i][0]+" "+kombi[i][1]+" "+kombi[i][2]+" ");
  }
}


//Die Bestrafungs bzw belohnungswerte müssen ggf je nach Eingabe angepasst werden - je nachdem was das Problem ist 
//(Probleme werden bei checksolution() ausgegeben)
void hamiltonianBerechnen() {
  for (int l=0; l<farben; l++) {
    for (int x=0; x<blumenN; x++) {
      for (int m=0; m<farben; m++) {
        for (int a=0; a<blumenN; a++) {

          if (x==a && l!=m) { //nur eine Farbe pro Kästchen
            hamiltonMatrix[x*farben+l][a*farben+m] = 12;
          }

          if (x!=a && l==m) { //möglichst wenig gleiche Farben
            hamiltonMatrix[x*farben+l][a*farben+m] +=6;
          }

          if (x==a&&l==m) { //grundbelohnung
            hamiltonMatrix[x*farben+l][a*farben+m] -= 4;
          }


          /*
          Farbwunsch belohnung:
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

            for (int i=0; i<kombi.length; i++) {

              if (kombi[i][0]==m&&kombi[i][1]==l || kombi[i][0]==l&&kombi[i][1]==m) {
                hamiltonMatrix[x*farben+l][a*farben+m] -= 1.5*kombi[i][2];
              }
            }
          }
        }
      }
    }
  }
}


/*
Ziel: wenn weniger als 7 Farben erlaubt sind (z.B. 5) , die Farben aber durchnummeriert sind, wie wenn
 sieben erlaubt wären (z.B. 4 Farben mit Nummern 2, 7, 3, 2), sollen die (vorgegebenen) Farben die Nummern
 0,1,2,0 bekommen, damit sie von der Hamiltonfunktion gefressen werden können. Die übrige mögliche 1 Farbe 
 ist nicht festgelegt - diese kann man noch im nachhinein entscheiden.
 
 Lösungsweg: jede farbe die (als kombi) vorkommt wird durchgegangen - es wird über den kombis iteriert und bei jeder Farbe geschaut:
 wurde ihr schon ein neuer Wert zugeordnet? Ja: ändere die stelle in kombi auf die neu zugeordnete ziffer 
 -Nein: ordne der alten farbe eine neue ziffer zu und ändere die stelle in kombi auf die neu zugeordnete ziffer 
 
 newColorNums speichert an der Stelle der (alten) farbziffer die neue (z.b. rot -> 5 -> newColorNums[5])
 
 TODO:
 entscheidung treffen wenn mehr Farben als kombi genannt wurden als als Anzahl erlaubt sind.
 */

void checkColorNum() { 
  if (farben!=7) {
    int count=0;
    for (int i=0; i<kombi.length; i++) {
      if (newColorNums[kombi[i][0]]!=100) {
        kombi[i][0]=newColorNums[kombi[i][0]];
      } else {
        newColorNums[kombi[i][0]]=count;
        kombi[i][0]=count;
        count++;
      }
      if (newColorNums[kombi[i][1]]!=100) {
        kombi[i][1]=newColorNums[kombi[i][1]];
      } else {
        newColorNums[kombi[i][1]]=count;
        kombi[i][1]=count;
        count++;
      }
    }
    println("farbzuordnung: ");
    for (int i=0; i<newColorNums.length; i++) {
      print(i+" -> "+newColorNums[i]+"; ");
    }
    println();
  }
}


//checkt ob die Lösung richtig sein kann. Regeln: jedes Kästchen genau eine Farbe, jede Farbe mind. einmal verwendet
//Verstöße werden gezählt und geprintlt.
void checkSolution () { 
  int anzahlDoppFarbe=0;
  int anzahlKeineFarbe=0;
  int anzahlFarbeNichtVerwendet=0;

  //zählt Farben pro Kästchen
  for (int x=0; x<blumenN; x++) {
    int points=0;
    for (int y=0; y<farben; y++) {
      points+=blumenkasten[x][y]?1:0;
    }
    if (points==0) anzahlKeineFarbe++;
    else if (points>1)anzahlDoppFarbe++;
  }

  //zählt Kästchen pro Farbe
  for (int x=0; x<farben; x++) {
    int points=0;
    for (int y=0; y<blumenN; y++) {
      points+=blumenkasten[y][x]?1:0;
    }
    if (points==0) anzahlFarbeNichtVerwendet++;
  }

  println(anzahlKeineFarbe +" mal keine Farbe zugeordnet");
  println(anzahlDoppFarbe +" mal mehrere Farben zugeordnet");
  println(anzahlFarbeNichtVerwendet +" mal eine Farbe nicht verwendet");
}



int kostenfunktion(boolean[][]blumenkastenLocal) {
  int ergebnis=0;
  int[] vektor=new int[blumenN*farben];
  int[] vektorerg=new int[blumenN*farben];

  for (int i=0; i<blumenN; i++) {
    for (int j=0; j<farben; j++) {
      vektor[i*farben+j]=blumenkastenLocal[i][j]==true? (1):(0);
    }
  }


  for (int i=0; i<blumenN*farben; i++) {
    for (int j=0; j<blumenN*farben; j++) {
      vektorerg[i]+=hamiltonMatrix[i][j]*vektor[j];
    }
  }

  for (int i=0; i<blumenN*farben; i++) {
    ergebnis+=vektor[i]*vektorerg[i];
  }

  return ergebnis;
}



void simulatedAnnealing() {
  println("simAnn:");
  float simAnn=kostenfunktion(blumenkasten)-5;

  for (int durchlauf=0; durchlauf<100000; durchlauf++) {
    int alteKosten = kostenfunktion(blumenkasten);

    if (durchlauf%100==0) {
      print("#");
    }

    if (durchlauf%5000==0) {
      println();
      println(alteKosten);
    }

    int x = int(random(blumenN));
    int y = int(random(farben));
    blumenkasten[x][y]=!blumenkasten[x][y];
    int kosten = kostenfunktion(blumenkasten);
    int kostenUnterschied=kosten-alteKosten;

    if ((kostenUnterschied>=0 && (random(1)>=exp(-kostenUnterschied/simAnn)))) {
      blumenkasten[x][y]=!blumenkasten[x][y];
    }

    simAnn*=0.9999; //0.99999
  }
  println("\n");
  //blumenkasten anzeigen
  for (int i=0; i<farben; i++) {
    print(i+": ");
    for (int j=0; j<blumenN; j++) {
      print((blumenkasten[j][i]?1:0)+"  ");
    }
    println();
  }
  println("Punkte: "+getPunkte());
  println("simAnn: "+simAnn);
  println("Kosten: "+kostenfunktion(blumenkasten));
  checkSolution();
}


/*Die Aufgabe verlangt eine eigene Punkteberechnung, die unanbgängig von unseren Kosten bestimmt,
wie gut die Lösung ist. Die Punkte erhält man durch addieren der belohnungen, wenn eine Wunschkombination
erfüllt ist.
Dazu wieder alle Punkte durchgehen -> wenn zwei nebeneinanderliegen und beide (mit der entsprechenden Frabe) besetzt sind
wird überprüft, ob sie eine der Wunschkombinationen sind. Wenn ja, wird zu den Punkten die Belohnung addiert.
*/
int getPunkte() {
  int punkte=0;

  for (int x=0; x<blumenN; x++) {
    for (int l=0; l<farben; l++) {
      for (int a=0; a<blumenN; a++) {
        for (int m=0; m<farben; m++) {
          if ((x==0&&a==1||x==1&&a==0)||(x==0&&a==2||x==2&&a==0)||
            (x==1&&a==2||x==2&&a==1)||(x==1&&a==3||x==3&&a==1)||(x==1&&a==4||x==4&&a==1)||
            (x==2&&a==4||x==4&&a==2)||(x==2&&a==5||x==5&&a==2)||
            (x==3&&a==4||x==4&&a==3)||(x==3&&a==6||x==6&&a==3)||
            (x==4&&a==5||x==5&&a==4)||(x==4&&a==6||x==6&&a==4)||(x==4&&a==7||x==7&&a==4)||
            (x==5&&a==7||x==7&&a==5)||
            (x==6&&a==7||x==7&&a==6)||(x==6&&a==8||x==8&&a==6)||
            (x==7&&a==8||x==8&&a==7)) {

            if (blumenkasten[x][l]&&blumenkasten[a][m]) {
              for (int i=0; i<kombi.length; i++) {
                if (kombi[i][0]==l&&kombi[i][1]==m || kombi[i][0]==m&&kombi[i][1]==l) {
                  punkte+=kombi[i][2];
                }
              }
            }
          }
        }
      }
    }
  }
  return punkte/2; //nur die hälfte des bisher gezählten, weil jede Verindung doppelt ("von beiden Seiten")
  //gezählt wird. Alternativ bei der dritten if abfrage den "oder" teil weglassen.
}



void exportiereHamiltonianMatrix() {
  String [] export=new String[blumenN*farben];
  for (int x=0; x<blumenN*farben; x++) {
    export[x]="";
    for (int y=0; y<blumenN*farben; y++) {
      export[x]+=hamiltonMatrix[x][y]+" ";
    }
  }
  saveStrings("qubomatrixroesslesprung_" + blumenN +".txt", export);
}


//Ausgabe der Lösung in "Blumenkastenform" und "technisch". Dazu wird zuerst die Tabelle "eindimensionalisiert", dann
// werden die quasi vereinfachten farbnummern durch die alten ausgetauscht, dann mit getColorName() in Textform umgewandelt.
void grafischeAusgabe(boolean blumenkasten[][]) {
  int[] solution=new int[blumenN];
  //Tabelle "eindimensional machen"
  for (int i=0; i<blumenN; i++) {
    for (int j=0; j<farben; j++) {
      if (blumenkasten[i][j]) { 
        solution[i]=j; 
        break;
      }
    }
  }
  //solution farbnummern austauschen (alte durch neue)
  for (int i=0; i<blumenN; i++) {
    for (int j=0; j<7; j++) {
      if (newColorNums[j]==solution[i]) { 
        solution[i]=j;
        break;
      }
    }
  }
  //ausgabe in rautenform
  println("     "+getColorNameShort(solution[0]));
  println("  "+getColorNameShort(solution[1])+"  "+getColorNameShort(solution[2]));
  println(getColorNameShort(solution[3])+"  "+getColorNameShort(solution[4])+"  "+getColorNameShort(solution[5]));
  println("  "+getColorNameShort(solution[6])+"  "+getColorNameShort(solution[7]));
  println("     "+getColorNameShort(solution[8]));
  println();
  //ausgabe als reihe  
  for (int i=0; i<blumenN; i++) {
    print(i+": "+getColorName(solution[i])+"; ");
  }
}


//macht aus dem String, der in der Textdatei vorgegeben ist eine Zahl.
int getColorNum(String s) {
  int colorNum=100;
  switch(s) {
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

//macht aus der Zahl wieder den ursprünglichen Farbnamen als Kürzel, damit er besser in der Rautenform dargestellt werden kann
String getColorNameShort(int s) {
  String colorName="";
  switch(s) {
  case 0:
    colorName="bla";
    break;
  case 1:
    colorName="gel";
    break;
  case 2:
    colorName="gru";
    break;
  case 3:
    colorName="ora";
    break;
  case 4:
    colorName="ros";
    break;
  case 5:
    colorName="rot";
    break;
  case 6:
    colorName="tue";
    break;
  }
  return colorName;
}
