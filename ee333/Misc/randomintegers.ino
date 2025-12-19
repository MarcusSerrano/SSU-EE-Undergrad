void setup() {
  Serial.begin(9600);
  randomSeed(analogRead(A0)); // seed with analog noise
  /*
  the random() function is a pseudo-random number generator (PRNG). 
  it always produces the same sequence of numbers unless you give it a different seed at the start with randomSeed().
  If you don’t call randomSeed(), the sequence will always repeat.
  If you call randomSeed() with a value that changes, you’ll get a different sequence each time the board resets.
  analogRead(A0) pin A0 is floating, gives us a number that is unpredictable, which makes a good seed.
  */
}

void loop() {
  int value = random(0, 101);   // random number 0–100
  Serial.println(value);        // print 
  delay(5000);                  // wait 5 seconds
}