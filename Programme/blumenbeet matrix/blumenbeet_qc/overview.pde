/*
setup: Initialisierung und Hamiton-Matrix-Generierung
draw: simulated annealing 

hamiltonMatrix:
 - readFile()
 - reassignColorIDs()
 - calculateHamiltonMatrix()
 - exportHamiltonMatrix()
 - getColorID()

simAnn:
 - randomizeFlowerConfig()
 - flowerConfigColorOutput()
 - simulatedAnnealing()
 - costFunction()
 - getScore()
 - checkSolution()
 - flowerConfigGraphicalOutput()
 - getColorName()
 - exportGraph()
*/







/*Die Aufgabe verlangt eine eigene Punkteberechnung, die unanbgängig von unseren Kosten bestimmt,
 wie gut die Lösung ist. Die Punkte erhält man durch addieren der belohnungen, wenn eine Wunschkombination
 erfüllt ist.
 Dazu wieder alle Punkte durchgehen -> wenn zwei nebeneinanderliegen und beide (mit der entsprechenden Frabe) besetzt sind
 wird überprüft, ob sie eine der Wunschkombinationen sind. Wenn ja, wird zu den Punkten die Belohnung addiert.
 */
 
 /*
Ziel: wenn weniger als 7 Farben erlaubt sind (z.B. 5) , die Farben aber durchnummeriert sind, wie wenn
 sieben erlaubt wären (z.B. 4 Farben mit Nummern 2, 7, 3, 2), sollen die (vorgegebenen) Farben die Nummern
 0,1,2,0 bekommen, damit sie von der Hamiltonfunktion gefressen werden können. Die übrige mögliche 1 Farbe 
 ist nicht festgelegt - diese kann man noch im nachhinein entscheiden.
 
 Lösungsweg: jede farbe die (in wishes) vorkommt wird durchgegangen - es wird über wishes iteriert und bei jeder Farbe geschaut:
 wurde ihr schon ein neuer Wert zugeordnet? Ja: ändere die stelle in wishes auf die neu zugeordnete ziffer 
 -Nein: ordne der alten farbe eine neue ziffer zu und ändere die stelle in wishes auf die neu zugeordnete ziffer 
 
 newColorIDs speichert an der Stelle der (alten) farbziffer die neue (z.b. rot -> 5 -> newColorNums[5])
 
 TODO:
 Entscheidung treffen wenn mehr Farben als kombi genannt wurden als als Anzahl erlaubt sind.
 */
