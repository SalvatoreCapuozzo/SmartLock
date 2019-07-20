#include <SoftwareSerial.h>

SoftwareSerial ble(2, 3); // RX, TX
int chiave = 5;
char c;
String stringa;
String code;

void setup() {
  // Open serial port
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  digitalWrite(7, HIGH);
  Serial.begin(9600);
   Serial.println("Start");;
  // begin bluetooth serial port communication
  ble.begin(9600);
}

// Now for the loop

void loop() {

  if(ble.available()) {
    stringa = "";
    do {
      if (ble.available()) {
        c = ble.read();
        stringa += c;
      }
    } while (ble.available());
    Serial.print("Sending Bluetooth Message... ");
    Serial.println(stringa);
    
    if (stringa.equals("ciao"))
      ble.println("Ciao Salvatore");
    else if (stringa.equals("apri") || stringa.equals("apri ")) {
      int op = random(10, 200/chiave);
      Serial.println(op);
      ble.println(op);
      
      while (!ble.available());
        code = "";
        delay(5);
      do {
        if (ble.available()) {
          c = ble.read();
          code += c;
        }
      } while (ble.available());
      // LED_BUILTIN
      if (code.toInt() == op*chiave) {
        digitalWrite(6, HIGH);
        digitalWrite(7, LOW);
      } 
      else
        Serial.println(code);
    }
    else if (stringa.equals("chiudi")) {
      digitalWrite(6, LOW);
      digitalWrite(7, HIGH);
    } 
    else if (stringa.charAt(0) == ('3')) {
      Serial.println(stringa);
    }
    else {
      ble.print("Messaggio inviato: ");
      ble.println(stringa);
    }
  }
  else
    ble.write("In attesa... \n");
    //char c = ble.read();
    
  delay(500);
  
}
  
  
  
 
  
