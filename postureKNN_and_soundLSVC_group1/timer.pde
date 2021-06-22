void timerbegin(){
  println("restarting");
  timer = millis()*10e-3;
}


//void resettimer() {
//timer = 0;
//time_elapsed = 0;
//}

void setclosing() {
  time_elapsed = (millis()*10e-3) - timer;
  println("closing = " + closing);
  println(time_elapsed);
  if(time_elapsed>=duration)
  {
  closing=false;
  println("closing is false yes = " + closing);
  //resettimer();
  }
}
