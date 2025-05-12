ORG 100H
.MODEL SMALL
.STACK 100H

.DATA 

     ; DATA SEGMENT 

     TIME_AUX DB 0

     BALL_X DW 0A0h            ; x position of ball
     BALL_Y DW 64h             ; y position of ball

     BALL_SIZE DW 04h          ; size of the ball  
     BALL_VELOCITY_X DW 05h    ; ball velocity on x axis
     BALL_VELOCITY_Y DW 02h    ; ball velocity on y axis

     WINDOW_WIDTH DW 140h      ; window height (320)
     WINDOW_HEIGHT DW 0C8h     ; window width (200)
     WINDOW_BOUNDS DW 06h      ; window bounds (6)

     BALL_ORIGINAL_X DW 0A0h   ; ball start position x axis
     BALL_ORIGINAL_Y DW 64h    ; ball start position y

     PADDLE_LEFT_X DW 0Ah      ; left paddle start position x axis
     PADDLE_LEFT_Y DW 0Ah      ; left paddle start position y axis
     PADDLE_LEFT_POINTS DW 0

     PADDLE_RIGHT_X DW 130h    ; right paddle start position x axis
     PADDLE_RIGHT_Y DW 0Ah     ; right paddle start position y axis
     PADDLE_RIGHT_POINTS DW 0

     PADDLE_WIDTH DW 05h       ; paddle width (05)
     PADDLE_HEIGHT DW 1Fh      ; paddle height (31)

     PADDLE_VELOCITY DW 05h    ; paddle velocity (05)

     GAME_ACTIVE DB 1          ; 1(game is active) / 0 (game ended)
     TEXT_GAME_OVER DB "GAME OVER $"
     TEXT_PLAYER DB "PLAYER $"
     PLAYER_ONE_WINNER DB 00h
     PLAYER_TWO_WINNER DB 00h
     TEXT_PLAYER_ONE DB "ONE WON THE GAME $"
     TEXT_PLAYER_TWO DB "TWO WON THE GAME $"


.CODE

     ; CODE SEGMENT

MAIN PROC

     MOV AX, @DATA
     MOV DS, AX
     
     CALL CLEAR_SCREEN

     CHECK_TIME:

          CMP GAME_ACTIVE, 00h
          JE SHOW_GAME_OVER_MENU

          MOV AH, 2Ch    ;get system time
          INT 21h        ;CH = hour, CL = minute, DH = second, DL = 1/100 seconds

          CMP DL, TIME_AUX

     JE CHECK_TIME

          MOV TIME_AUX, DL

          CALL CLEAR_SCREEN
          CALL MOVE_BALL
          CALL COLLISION
          CALL DRAWBALL
          CALL MOVE_PADDLES
          CALL DRAW_PADDLES
          CALL DRAW_UI

     JMP CHECK_TIME

     SHOW_GAME_OVER_MENU:
          CALL DRAW_GAME_OVER_MENU
          JMP CHECK_TIME

     RET
MAIN ENDP

DRAW_GAME_OVER_MENU PROC

     CALL CLEAR_SCREEN

     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 04h
     MOV DL, 0Dh
     INT 10h

     MOV AH, 09h
     LEA DX, TEXT_GAME_OVER
     INT 21h

     MOV AH, 02h
     MOV BH, 00h
     MOV DH, 08h
     MOV DL, 0Dh
     INT 10h

     MOV AH, 09h
     LEA DX, TEXT_PLAYER
     INT 21h

     CMP PLAYER_TWO_WINNER, 01h
     JE PLAYER_TWO_WON

     CMP PLAYER_ONE_WINNER, 01h
     JE PLAYER_ONE_WON

     MOV PLAYER_ONE_WINNER, 00h
     MOV PLAYER_TWO_WINNER, 00h

     

     PLAYER_ONE_WON:
          MOV AH, 09h
          LEA DX, TEXT_PLAYER_ONE
          INT 21h

          MOV AH, 00h
          INT 16h

          RET
     
     PLAYER_TWO_WON:
          MOV AH, 09h
          LEA DX, TEXT_PLAYER_TWO
          INT 21h

          MOV AH, 00h
          INT 16h

          RET

     RET     
DRAW_GAME_OVER_MENU ENDP

DRAW_PADDLES PROC

     MOV CX, PADDLE_LEFT_X         ; moving PADDLE_LEFT_X into CX because it draws the pixel on that point on the x axis.
     MOV DX, PADDLE_LEFT_Y         ; moving PADDLE_LEFT_Y into CX because it draws the pixel on that point on the y axis.

     DRAW_PADDLE_LEFT:

          MOV AH, 0Ch              ; pixel on the screen
          MOV AL, 0Fh              ; white color
          MOV BH, 00h              ; it is the page number (zero beacuse only one page here)
          INT 10h

          INC CX                   ; increments the CX having x axis point value
          MOV AX, CX               
          SUB AX, PADDLE_LEFT_X    ; subtracting the current x point with original point to see if it is greater than width
          CMP AX, PADDLE_WIDTH     ; and if it lesser than the width than draw another point on x axis till it reaches width
                                   ; and this label runs another time till it gets greater than width.
     JNG DRAW_PADDLE_LEFT  

          MOV CX, PADDLE_LEFT_X    ; updates the CX value with the original x axis value
          INC DX                   ; increments the y axis point value 
          MOV AX, DX               
          SUB AX, PADDLE_LEFT_Y    ; subtracting the current y point with original point to see if it is greater than height
          CMP AX, PADDLE_HEIGHT    ; and if it lesser than the height than draw another point on y axis till it reaches width
                                   ; and this label runs another time till it gets greater than height.
     JNG DRAW_PADDLE_LEFT

     MOV CX, PADDLE_RIGHT_X        ; same procedure which was used to draw the left paddle is used to draw the right paddle 
     MOV DX, PADDLE_RIGHT_Y        ; on different x and y coordinates.

     DRAW_PADDLE_RIGHT:

          MOV AH, 0Ch    ;pixel on the screen
          MOV AL, 0Fh    ;white color
          MOV BH, 00h    
          INT 10h

          INC CX
          MOV AX, CX
          SUB AX, PADDLE_RIGHT_X
          CMP AX, PADDLE_WIDTH

     JNG DRAW_PADDLE_RIGHT

          MOV CX, PADDLE_RIGHT_X
          INC DX
          MOV AX, DX
          SUB AX, PADDLE_RIGHT_Y
          CMP AX, PADDLE_HEIGHT

     JNG DRAW_PADDLE_RIGHT

     RET
DRAW_PADDLES ENDP

MOVE_PADDLES PROC

     CHECK_LEFT_PADDLE_MOVEMENT:

          MOV AH, 01h    ; check if key is pressed
          INT 16h        ; ZF = 0 if key is pressed /  ZF = 1 if no key pressed
          JZ NO_KEY_PRESSED

          MOV AH, 00h     ; check which key is pressed
          INT 16h         ; AL gets the ASCII of which key is pressed 

          CMP AL, 77h    ;'W'
          JE MOVE_LEFT_PADDLE_UP
          CMP AL, 57h    ;'w'
          JE MOVE_LEFT_PADDLE_UP

          CMP AL, 73h    ;'S'
          JE MOVE_LEFT_PADDLE_DOWN
          CMP AL, 53h    ;'s'
          JE MOVE_LEFT_PADDLE_DOWN

     JMP CHECK_RIGHT_PADDLE_MOVEMENT

     NO_KEY_PRESSED:
          JMP EXIT_MOVEMENT

     MOVE_LEFT_PADDLE_UP:
          MOV AX, PADDLE_VELOCITY
          SUB PADDLE_LEFT_Y, AX

          MOV AX, WINDOW_BOUNDS
          CMP PADDLE_LEFT_Y, AX
          JL FIX_PADDLE_LEFT_TOP
          JMP CHECK_RIGHT_PADDLE_MOVEMENT

          FIX_PADDLE_LEFT_TOP:
               MOV AX, WINDOW_BOUNDS
               MOV PADDLE_LEFT_Y, AX
               JMP CHECK_RIGHT_PADDLE_MOVEMENT

     MOVE_LEFT_PADDLE_DOWN:
          MOV AX, PADDLE_VELOCITY
          ADD PADDLE_LEFT_Y, AX

          MOV AX, WINDOW_HEIGHT
          SUB AX, WINDOW_BOUNDS
          SUB AX, PADDLE_HEIGHT
          CMP PADDLE_LEFT_Y, AX
          JG FIX_PADDLE_LEFT_BOTTOM
          JMP CHECK_RIGHT_PADDLE_MOVEMENT

          FIX_PADDLE_LEFT_BOTTOM:
               MOV PADDLE_LEFT_Y, AX
               JMP CHECK_RIGHT_PADDLE_MOVEMENT

     CHECK_RIGHT_PADDLE_MOVEMENT:
     
          CMP AL, 49h    ;'I'
          JE MOVE_RIGHT_PADDLE_UP
          CMP AL, 69h    ;'i'
          JE MOVE_RIGHT_PADDLE_UP

          CMP AL, 4Bh    ;'K'
          JE MOVE_RIGHT_PADDLE_DOWN
          CMP AL, 6Bh    ;'k'
          JE MOVE_RIGHT_PADDLE_DOWN

          JMP EXIT_MOVEMENT

          MOVE_RIGHT_PADDLE_UP:
               MOV AX, PADDLE_VELOCITY
               SUB PADDLE_RIGHT_Y, AX

               MOV AX, WINDOW_BOUNDS
               CMP PADDLE_RIGHT_Y, AX
               JL FIX_PADDLE_RIGHT_TOP
               JMP EXIT_MOVEMENT

               FIX_PADDLE_RIGHT_TOP:
                    MOV AX, WINDOW_BOUNDS
                    MOV PADDLE_RIGHT_Y, AX
                    JMP EXIT_MOVEMENT

          MOVE_RIGHT_PADDLE_DOWN:
               MOV AX, PADDLE_VELOCITY
               ADD PADDLE_RIGHT_Y, AX

               MOV AX, WINDOW_HEIGHT
               SUB AX, WINDOW_BOUNDS
               SUB AX, PADDLE_HEIGHT
               CMP PADDLE_RIGHT_Y, AX
               JG FIX_PADDLE_RIGHT_BOTTOM
               JMP EXIT_MOVEMENT

               FIX_PADDLE_RIGHT_BOTTOM:
                    MOV PADDLE_RIGHT_Y, AX
                    JMP EXIT_MOVEMENT

     EXIT_MOVEMENT:

     RET
MOVE_PADDLES ENDP   

MOVE_BALL PROC

     ; Moving ball on x axis and checking if it is colliding

     MOV AX, BALL_VELOCITY_X
     ADD BALL_X, AX           ; adding the velocity to the current x axis coordinate

     CMP BALL_X, 05h          ; x < 05
     JL GIVE_POINT_TO_PLAYER_TWO ; if ball goes on left side give point to player two and reset the ball

     MOV AX, WINDOW_WIDTH     ; x > window width
     SUB AX, BALL_SIZE
     SUB AX, 05h
     CMP BALL_X, AX
     JG GIVE_POINT_TO_PLAYER_ONE ; if ball goes on left side give point to player two and reset the ball


     ; Moving ball on y axis and checking if it is colliding or not

     MOV AX, BALL_VELOCITY_Y
     ADD BALL_Y, AX

     CMP BALL_Y, 05h     ;y < 05
     JL NEG_VELOCITY_Y

     MOV AX, WINDOW_HEIGHT    ; y > window height
     SUB AX, BALL_SIZE
     SUB AX, 05h
     CMP BALL_Y, AX
     JG NEG_VELOCITY_Y
     
     RET 

     GIVE_POINT_TO_PLAYER_ONE:
          INC PADDLE_LEFT_POINTS
          CALL RESET_BALL_POSITION

          CMP PADDLE_LEFT_POINTS, 05h
          MOV PLAYER_ONE_WINNER, 01h
          JGE GAME_OVER

          RET

     GIVE_POINT_TO_PLAYER_TWO:
          INC PADDLE_RIGHT_POINTS
          CALL RESET_BALL_POSITION

          CMP PADDLE_RIGHT_POINTS, 05h
          MOV PLAYER_TWO_WINNER, 01h
          JGE GAME_OVER

          RET

     GAME_OVER:
          MOV PADDLE_LEFT_POINTS, 00h
          MOV PADDLE_RIGHT_POINTS, 00h
          MOV GAME_ACTIVE, 00h
          RET

     NEG_VELOCITY_Y:
          NEG BALL_VELOCITY_Y
     RET 

MOVE_BALL ENDP

COLLISION PROC
     ; Checking if the ball is colliding with the right paddle
     ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
     ; BALL_X + BALL_SIZE > PADDLE_RIGHT_X && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH && BALL_Y
     ; + BALL_SIZE > PADDLE_RIGHT_Y && BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT

     CHECK_COLLISION_WITH_RIGHT_PADDLE:

     MOV AX, BALL_X
     ADD AX, BALL_SIZE
     CMP AX, PADDLE_RIGHT_X
     JNG CHECK_COLLISION_WITH_LEFT_PADDLE

     MOV AX, BALL_X
     MOV BX, PADDLE_RIGHT_X
     ADD BX, PADDLE_WIDTH
     CMP AX, BX
     JG CHECK_COLLISION_WITH_LEFT_PADDLE

     MOV AX, BALL_Y
     ADD AX, BALL_SIZE
     CMP AX, PADDLE_RIGHT_Y
     JNG CHECK_COLLISION_WITH_LEFT_PADDLE

     MOV AX, BALL_Y
     MOV BX, PADDLE_RIGHT_Y
     ADD BX, PADDLE_HEIGHT
     CMP AX, BX
     JG CHECK_COLLISION_WITH_LEFT_PADDLE

     NEG BALL_VELOCITY_X
     RET

     ; Checking if the ball is colliding with the left paddle
     ; maxx1 > minx2 && minx1 < maxx2 && maxy1 > miny2 && miny1 < maxy2
     ; BALL_X + BALL_SIZE > PADDLE_LEFT_X && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH && BALL_Y
     ; + BALL_SIZE > PADDLE_LEFT_Y && BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT

     CHECK_COLLISION_WITH_LEFT_PADDLE:

     MOV AX, BALL_X
     ADD AX, BALL_SIZE
     CMP AX, PADDLE_LEFT_X
     JNG EXIT_COLLISION_CHECK

     MOV AX, BALL_X
     MOV BX, PADDLE_LEFT_X
     ADD BX, PADDLE_WIDTH
     CMP AX, BX
     JG EXIT_COLLISION_CHECK

     MOV AX, BALL_Y
     ADD AX, BALL_SIZE
     CMP AX, PADDLE_LEFT_Y
     JNG EXIT_COLLISION_CHECK

     MOV AX, BALL_Y
     MOV BX, PADDLE_LEFT_Y
     ADD BX, PADDLE_HEIGHT
     CMP AX, BX
     JG EXIT_COLLISION_CHECK

     NEG BALL_VELOCITY_X

     EXIT_COLLISION_CHECK:
     RET 
     
COLLISION ENDP

RESET_BALL_POSITION PROC

     MOV AX, BALL_ORIGINAL_X
     MOV BALL_X, AX

     MOV AX, BALL_ORIGINAL_Y
     MOV BALL_Y, AX

     NEG BALL_VELOCITY_X
     NEG BALL_VELOCITY_Y

     RET
RESET_BALL_POSITION ENDP

DRAWBALL PROC

     MOV CX, BALL_X
     MOV DX, BALL_Y

     DRAW_BALL:

          MOV AH, 0Ch    ;pixel on the screen
          MOV AL, 0Fh    ;white color
          MOV BH, 00h    
          INT 10h

          INC CX
          MOV AX, CX
          SUB AX, BALL_X
          CMP AX, BALL_SIZE

     JNG DRAW_BALL

          MOV CX, BALL_X
          INC DX
          MOV AX, DX
          SUB AX, BALL_Y
          CMP AX, BALL_SIZE

     JNG DRAW_BALL

     RET
DRAWBALL ENDP

CLEAR_SCREEN PROC 

     MOV AH, 00h
     MOV AL, 13h    ;setting the video mode
     INT 10h

     MOV AH, 0Bh    ;setting the background color
     MOV BH, 00h    
     MOV BL, 00h    ;black color
     INT 10h

     RET

CLEAR_SCREEN ENDP

DRAW_UI PROC

     ; Drawing the points of left player (player one)

     MOV AH, 02h         ; setting cursor position
     MOV BH, 00h         ; page no
     MOV DH, 03h         ; row
     MOV DL, 06h         ; column
     INT 10h 

     MOV AH, 02h
     MOV DX, PADDLE_LEFT_POINTS
     ADD DX, 48
     INT 21h  

     ; Drawing the points of right player (player two)

     MOV AH, 02h         ; setting cursor position
     MOV BH, 00h         ; page no
     MOV DH, 03h         ; row
     MOV DL, 20h         ; column
     INT 10h 

     MOV AH, 02h
     MOV DX, PADDLE_RIGHT_POINTS
     ADD DX, 48
     INT 21h  


     RET
DRAW_UI ENDP

END MAIN
