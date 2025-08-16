(REFRESH)  
    @8192 //the countdown number
    D=A
    @counter //16
    M=D // save for paint range


(LISTEN)
    @counter
    M=M-1
    D=M
    @REFRESH  //if counter <0, reset
    D;JLT
    @KBD  //25746
    D=M
    @BLACK //15
    D;JNE
    @WHITE //22
    0;JMP


(BLACK)
    @SCREEN //16384
    D=A
    @counter
    A=D+M
    M=-1
    @LISTEN
    0;JMP

(WHITE)
    @SCREEN
    D=A
    @counter
    A=D+M
    M=0
   @LISTEN
   0;JMP





//Loop1,whole process
//set Ram counter = 8192
//Loop2,listen, if KBD no input
//draw 16 black bit at @SCREEN 
//Screem + 1
//draw 8192 times
//Loop3, listen, if KBD has input, 
//draw 16 bit white at @SCREEN
//Screem + 1
//draw 8192 times
//Loop1 start
