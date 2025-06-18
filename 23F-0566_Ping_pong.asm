[org 0x100]            
jmp start;Jump to the start of the program to begin execution
; Player Names (initialized with empty spaces)
player_1: db '                  ', 0  ;Player 1's name (max 18 characters)
player_2: db '                  ', 0 ;Player 2's name (max 18 characters)
; Win and Tie messages
win: db 'won the game', 0  ;Message when Player 1 wins
Tie: db 'The match was a tie', 0  ;Message when the game ends in a tie
; Credits text
crText: db 'Made By Haseeb ur Rahman (23F-0566) and Areeba Majeed (23F-0651)', 0;Credits for the creators
; Game state information
state: dw 0  ;Current game state (e.g., running, paused, ended)
FieldWidth: dw 38 ;Field width, 38 characters wide (can be used for boundary calculations)
WidthProtection: dw 1 ;Width protection (for game boundaries or collision detection)
position_of_ball: dw 720 ;Current position of the ball on the field (pixel-based)
next_position: dw 0 ;Next position of the ball (for motion calculations)
motionofaball: dw 0;Ball's motion state (direction, speed, etc.)
paddle_1_pos: dw 22 ;Position of Player 1's paddle (row number or vertical position)
paddle_2_pos: dw 32   ;Position of Player 2's paddle (row number or vertical position)
; Player scores (initialized to zero)
playe_1_scr: dw 0  ;Player 1's score
playe_2_scr: dw 0 ;Player 2's score
;Input prompts for player names
inputgetting1: db 'Player 1 Enter your name:', 0;Prompt for Player 1's name input
inputgetting2: db 'Player 2 Enter your name:', 0 ; Prompt for Player 2's name input
; Ball color (the color code for the ball on the screen)
ballcolor: dw 0x1E01   ;Color for the ball (0x1E01 corresponds to a color combination in text mode)
; Score required to win the game
score_to_win: dw 6  ;Number of points required to win the game
clearDisplay:
    pusha ;Save all general-purpose registers (AX, BX, CX, DX, SI, DI, BP, SP)
    mov ax, 0xB800 ;Set AX to the video memory address for text mode (0xB800)
    mov es, ax ;Load ES register with the video memory address (0xB800)
    mov di, 0  ;Set DI to 0, starting position at the top-left corner of the screen
    mov cx, 2002 ;Set CX to 2000 (number of words to clear, as 80x25 screen = 2000 characters)
    mov ax, 0x1920 ;Set AX to 0x1920 (character space and background color; 0x19 is the color code, 0x20 is space)
    rep stosw ;Repeat storing AX to ES:DI for CX times, clearing the screen
    popa ;Restore all general-purpose registers (from the stack) after operation
    ret                  
delay:
    pusha ;Save all general-purpose registers (AX, BX, CX, DX, SI, DI, BP, SP)
    mov ax, 0x8600  ;Set AX to the delay function code (0x8600 for the BIOS delay)
    mov cx, 2 ;(ball delay) Set CX to 2, determining the duration of the delay (adjust as necessary)
    int 0x15    ;Call BIOS interrupt 0x15 to invoke the delay
    popa   ;Restore all general-purpose registers (from the stack) after operation
    ret                 
renderGameScreen:
    pusha;Save all general-purpose registers at once (AX, BX, CX, DX, SI, DI, BP, SP)
    call clearDisplay ;Clear the screen display
    mov ax, 0xB800 ;Set ES to the video memory segment for text mode (0xB800)
    mov es, ax
    mov di, 238 ;Set DI to the position for the top wall
    sub di, [FieldWidth] ;Adjust DI position by subtracting the field width
    mov ax, 242
    add ax, [FieldWidth] ;Calculate the ending position for the top and bottom wall
TopBottomWalls:
    mov word [es:di], 0x1ECD;Set the character and attribute for the top wall
    add di, 3520 ;Move to the bottom row of the screen
    mov word [es:di], 0x1ECD ;Set the bottom wall character and attribute
    sub di, 3520 ;Move back to the top row
    add di, 2 ;Move to the next position
    cmp di, ax  ;Check if the current position reaches the end
    jnz TopBottomWalls ;If not, repeat for the next column
    mov word [es:3920], 0x1EBA;Set the attribute for the top-left corner
    mov di, 398  ;Set DI to the starting position for the left wall
    sub di, [FieldWidth] ;Adjust DI position by subtracting the field width
    mov ax, [FieldWidth]
    shl ax, 1 ;Shift left by 1 to multiply by 2 (for two-byte characters)
    add ax, 2;Add 2 for the initial space between paddles
LeftRightWalls:
    mov word [es:di], 20h ;Set the space for the left wall
    add di, ax ;Move to the next column on the right wall
    mov word [es:di], 20h  ;Set the space for the right wall
    sub di, ax  ;Move back to the left wall
    add di, 160;Move to the next row
    cmp di, 3600 ;Check if we reached the bottom of the screen
    jl LeftRightWalls ;If not, repeat for the next row
    mov di, [position_of_ball];Set DI to the current position of the ball
    mov ax, [ballcolor];Load the ball color
    mov word [es:di], ax ;Display the ball at its current position
    mov di, 966  ;Set DI for the paddle 1 position
    mov ax, 0x1E20  ;Set the color attribute for paddle 1
    mov di, [paddle_1_pos] ;Load paddle 1 position
    mov word [es:di], 0x02DB;Set the paddle 1 character
    mov word [es:di + 160], 0x02DB ;Display paddle 1 on the next line
    mov word [es:di - 160], 0x02DB ;Display paddle 1 on the previous line

    mov di, [paddle_2_pos];Set DI for the paddle 2 position
    mov word [es:di], 0x03DB ;Set the paddle 2 character
    mov word [es:di + 160], 0x03DB ;Display paddle 2 on the next line
    mov word [es:di - 160], 0x03DB ;Display paddle 2 on the previous line

    mov di, 10  ;Set DI for player text
    mov si, crText ;Set SI to the string for credits text
    cld  ;Clear the direction flag for string operations
    mov ax, 0x1E00 ;Set the color attribute for the credits
printingplayer1:
    lodsb  ;Load a byte from SI (player 1 name)
    stosw ;Store the byte into ES:DI (video memory)
    cmp al, 0  ;Check if it's the end of the string
    jne printingplayer1 ;If not, repeat for the next character
    mov di, 3844 ;Set DI to the starting position for player 1
    mov si, player_1 ;Load the player 1 name into SI
printingplayer2:
    lodsb   ;Load a byte from SI (player 1 name)
    stosw ;Store the byte into ES:DI (video memory)
    cmp al, 0  ;Check if it's the end of the string
    jne printingplayer2 ;If not, repeat for the next character
    mov si, player_2  ;Load player 2 name into SI
printingplayer3:
    lodsb   ;Load a byte from SI (player 2 name)
    cmp al, 0  ;Check if it's the end of the string
    jnz printingplayer3 ;If not, repeat for the next character
    sub si, player_2  ;Adjust SI pointer for player 2 name
    shl si, 1 ;Multiply by 2 for character size (2 bytes)
    mov di, 3984 ;Set DI for position to start printing player 2 name
    sub di, si ;Adjust DI to the correct position
    mov si, player_2 ;Load player 2 name again for printing
printingplayer4:
    lodsb ;Load a byte from SI (player 2 name)
    stosw    ;Store the byte into ES:DI (video memory)
    cmp al, 0 ;Check if it's the end of the string
    jnz printingplayer4 ;If not, repeat for the next character
    mov ax, [playe_1_scr];Load player 1's score
    mov bx, 10 ;Set the base for division
    mov di, 3910  ;Set DI to position for displaying player 1's score
printingplayer5:
    mov dx, 0  ;Clear DX for division
    div bx  ;Divide AX by BX to get the next digit
    add dx, 30h ;Convert the digit to ASCII
    mov dh, 0x1E  ;Set the color attribute for the score
    mov word [es:di], dx  ;Store the score in video memory
    sub di, 2 ;Move back to the previous position
    cmp ax, 0  ;Check if there are more digits
    jnz printingplayer5   ;If so, continue
    mov ax, [playe_2_scr]  ;Load player 2's score
    mov di, 3928  ;Set DI to position for displaying player 2's score
printingplayer6:
    mov dx, 0 ;Clear DX for division
    div bx  ;Divide AX by BX to get the next digit
    add dx, 30h  ;Convert the digit to ASCII
    mov dh, 0x1E   ;Set the color attribute for the score
    mov word [es:di], dx ;Store the score in video memory
    sub di, 2 ;Move back to the previous position
    cmp ax, 0   ;Check if there are more digits
    jnz printingplayer6  ;If so, continue
    popa                       
    ret                      
takinginput:
    push bp  ;Save the base pointer (BP) to preserve the caller's frame
    mov bp, sp  ;Set BP to SP (Stack Pointer) to create a new stack frame
    push ax                  
    push bx                  
    push cx                    
    push dx                    
    push si                  
    push di                     
    push sp                   
    mov ax, 0xB800  ;Set AX to the video memory segment address (0xB800)
    mov es, ax ;Set ES (Extra Segment) to video memory
    mov si, [bp + 4] ;Load the space for the name (first argument passed to the function) into SI
    mov di, [bp + 6]   ;Load the DI location (second argument passed to the function) into DI
    mov bx, 0  ;Initialize BX to 0, used for character position in the input
input:
    mov ax, 0   ;Clear AX register
    int 0x16;BIOS interrupt for keyboard input (reads a character)
    cmp ax, 0x1C0D  ;Compare the result with the Enter key (0x1C0D)
    jz endInput  ;If Enter key was pressed, jump to endInput
    cmp ax, 0x1E08  ;Compare the result with the Backspace key (0x1E08)
    jnz si1  ;If not backspace, jump to si1 to handle regular character input
    cmp bx, 0  ;Check if BX is zero, indicating there's nothing to delete
    jz si2 ;If BX is zero, jump to si2 (skip backspace handling)
    dec bx  ;Decrease BX to move the cursor position to the left
    sub di, 2   ;Move DI left by 2 (for one character space)
    mov byte [si + bx], 0x20 ;Insert a space at the current BX position in the name string
    mov word [es:di], 0x1E20;Write a space character (0x20) at the video memory location
    jmp si2 ;Jump to si2 to continue processing other keys
si1:
    mov byte [si + bx], al  ;Store the pressed key (AL) at the current position in the name string
    mov ah, 0x1E ;Set the color attribute for the character (green text on black background)
    mov word [es:di], ax ;Write the character at the current DI location in video memory
    add di, 2  ;Move the DI pointer right by 2 (for the next character)
    inc bx ;Increment BX to move to the next character position in the name string
si2:
    cmp bx, 15 ;Compare BX to 15 (maximum name length)
    jnz input;If BX is less than 15, continue reading input

endInput:
    mov byte [si + bx], 0 ;Null-terminate the name string
    pop sp                   
    pop di                        
    pop si                        
    pop dx                        
    pop cx                        
    pop bx                        
    pop ax                        
    pop bp                       
    ret 2 
skipChecks:
    call clearDisplay ;Clear the display before starting
    mov ax, 0xB800;Set AX to video memory segment (0xB800)
    mov es, ax;Set ES to video memory segment (0xB800)
    mov di, 160 ;Set DI to starting position on the screen
    mov ax, 0x1E20  ;Set AX to color attribute (green text)
    mov si, inputgetting1 ;Load the input string for player 1
playerno1:
    lodsb ;Load the next byte (character) from SI into AL
    stosw    ;Store the word (AL, AH) to ES:DI (video memory)
    cmp al, 0 ;Check if the character is null (end of string)
    jnz playerno1 ;If not null, continue storing characters for player 1
    push di ;Save DI before pushing player 1 details
    mov ax, player_1 ;Set AX to player 1's identifier
    push ax  ;Save player 1's identifier
    call takinginput ;Call the input function for player 1
    mov ax, 0x1E20;Set AX to color attribute (green text)
    mov di, 320 ;Set DI to starting position for player 2's input
    mov si, inputgetting2 ;Load the input string for player 2
playerno2:
    lodsb ;Load the next byte (character) from SI into AL
    stosw   ;Store the word (AL, AH) to ES:DI (video memory)
    cmp al, 0  ;Check if the character is null (end of string)
    jnz playerno2    ;If not null, continue storing characters for player 2
    push di ;Save DI before pushing player 2 details
    mov ax, player_2  ;Set AX to player 2's identifier
    push ax ;Save player 2's identifier
    call takinginput ;Call the input function for player 2
    mov ax, [FieldWidth] ;Load the field width
    shl ax, 1 ;Double the field width (for adjustment)
    mov [FieldWidth], ax ;Store the new field width
    mov word[position_of_ball], 2000 ;Set the initial position of the ball
    mov word[next_position], 2000 ;Set the next position of the ball
    mov word[motionofaball], -158;Set the initial motion of the ball (angle)
    mov word[state], 0xFFFF ;Set the initial game state (active)
    mov word[paddle_2_pos], 558;Set the initial position of player 2's paddle
	push dx
    mov dx, [FieldWidth] ;Load the field width again
    sub word[paddle_2_pos], dx ;Adjust player 2's paddle position
	pop dx
    mov word[paddle_1_pos], 560 ;Set the initial position of player 1's paddle
    add word[paddle_1_pos], ax ;Adjust player 1's paddle position
lewp:
    mov ax, 0x0100 ;Wait for keyboard input (BIOS interrupt)
    int 0x16 ;Wait for key press
    jz updateBall ;If no key pressed, update the ball position
    jmp checkInputs  ;If key is pressed, check inputs
updateBall:
    cmp word[state], 0  ;Check if the game state is 0 (active)
    jne continue ;If game is not active, continue
    mov ax, 0 ;Get a new keyboard input (BIOS interrupt)
    int 0x16    ;Wait for key press
    cmp ah, 0x39  ;Check if the key pressed is '9' (toggle state)
    jne lewp  ;If not '9', loop back and wait for input
    call toggleState  ;Call toggleState to pause/unpause the game
continue:
    call delay ;Call delay function to slow down the game loop
    call renderGameScreen ;Render the game screen after updating
    push ax ;Save the AX register before starting ball movement
    push bx    ;Save the BX register
    push dx ;Save the DX register
startIteration:
    mov ax, [motionofaball] ;Get the ball's motion value (direction)
    add [next_position], ax  ;Update the next position of the ball
    mov ax, [motionofaball] ;Get the motion value again

checkSides:
    mov ax, 0xB800 ;Set AX to video memory segment (0xB800)
    mov es, ax ;Set ES to video memory segment (0xB800)
    mov di, [next_position] ;Get the ball's next position
    cmp word[es:di], 20h;Check if the position is a space (empty)
    jne checkWalls  ;If not, check for wall collisions
    cmp word[motionofaball], -158;Check if the ball is moving left
    jne sk1  ;If not, jump to sk1
    call incplayer_1  ;If moving left, increment player 1's score
sk1:
    cmp word[motionofaball], 162 ;Check if the ball is moving right
    jnz sk2 ;If not, jump to sk2
    call incplayer_1  ;If moving right, increment player 1's score
sk2:
    cmp word[motionofaball], 158 ;Check if the ball is moving up
    jnz sk3     ;If not, jump to sk3
    call incplayer_2 ;If moving up, increment player 2's score
sk3:
    cmp word[motionofaball], -162 ;Check if the ball is moving down
    jnz sk4    ;If not, jump to sk4
    call incplayer_2  ;If moving down, increment player 2's score
sk4:
    mov word[position_of_ball], 2000 ;Reset ball position to center
    mov word[next_position], 2000 ;Reset next position to center
    mov ax, [motionofaball] ;Get the ball's motion value
    not ax    ;Invert the direction
    add ax, 1   ;Adjust the direction
    mov word[motionofaball], ax  ;Store the new direction
checkWalls:
    cmp word[next_position], 318 ;Check if the ball is touching the upper wall
    jge checkLowWall ;If yes, check the lower wall
    jmp UpperWall ;Otherwise, check the upper wall

checkLowWall:
    cmp word[next_position], 3680 ;Check if the ball is touching the lower wall
    jle checkPlayers  ;If yes, check for players
    jmp LowerWall  ;Otherwise, go to check lower wall

checkPlayers:
    mov ax, 0xB800   ;Set AX to video memory segment (0xB800)
    mov es, ax   ;Set ES to video memory segment (0xB800)
    mov di, [next_position] ;Get the ball's next position
    cmp word[es:di], 0x02DB;Check for right player 1 wall
    jne R1    ;If no, check for other conditions
    call RightWall ;If yes, call RightWall function to handle wall collision
    jmp nextIteration  ;Go to next iteration
R1:
    cmp word[es:di+2], 0x02DB ;Check for next right player 1 wall
    jne checkLeftPlr ;If no, check left player wall
    call RightWall ;If yes, call RightWall function
    jmp nextIteration  ;Go to next iteration

checkLeftPlr:
    mov ax, 0xB800  ;Set AX to video memory segment (0xB800)
    mov es, ax ;Set ES to video memory segment (0xB800)
    mov di, [next_position] ;Get the ball's next position
    cmp word[es:di], 0x03DB;Check for left player 2 wall
    jne L1 ;If no, check other conditions
    call LeftWall;If yes, call LeftWall function to handle left wall collision
    jmp nextIteration  ;Go to next iteration
L1:
    cmp word[es:di-2], 0x03DB  ;Check for the previous left player wall
    jne nextIteration  ;If no, continue
    call LeftWall ;If yes, call LeftWall function to handle left wall collision
nextIteration:
    mov ax, [motionofaball]  ;Get the ball's motion value (direction)
    add word[position_of_ball], ax ;Update ball's current position
    mov ax, [position_of_ball] ;Get the updated position
    mov [next_position], ax;Store the new position
    pop dx                     
    pop bx                      
    pop ax                   
    mov ax, [score_to_win]  ;Load score to win value
    cmp ax, [playe_1_scr];Check if player 1 reached the winning score
    je endd    ;If yes, end the game
    cmp ax, [playe_2_scr] ;Check if player 2 reached the winning score
    je endd  ;If yes, end the game
    jmp lewp   ;Loop back to the start
checkInputs:
    mov ax, 0  ;Get input from keyboard
    int 0x16 ;Wait for key press
    cmp ah, 0   ;Check if key press is valid
    jz endIteration  ;If no key press, end iteration
    cmp ah, 0x48 ;Check for 'up' key press for player 1
    jne i0 ;If not, continue to the next check
    call player_1up  ;If yes, call player_1up function
i0:
    cmp ah, 0x50 ;Check for 'down' key press for player 1
    jne i1 ;If not, continue to the next check
    call player_1down ;If yes, call player_1down function
i1:
    cmp ah, 0x11 ;Check for 'up' key press for player 2
    jne i2  ;If not, continue to the next check
    call player_2up ;If yes, call player_2up function
i2:
    cmp ah, 0x1F ;Check for 'down' key press for player 2
    jne i3   ;If not, continue to the next check
    call player_2down ;If yes, call player_2down function
i3:
    cmp ah, 0x39  ;Check for '9' key press to toggle game state
    jne i4   ;If not, continue to the next check
    call toggleState   ;If yes, call toggleState function
i4:
    cmp ah, 0x01 ;Check for 'escape' key press to end the game
    je endd ;If yes, end the game
endIteration:
    call renderGameScreen;Render the game screen
    jmp lewp  ;Loop back to the start of the game loop

endd:
    mov ax, 0xB800  ;Set AX to video memory segment (0xB800)
    mov es, ax ;Set ES to video memory segment (0xB800)
    mov di, 2140  ;Set DI to display the results
    mov ax, 0x1E00  ;Set AX to color attribute (green text)
    mov bx, [playe_1_scr]  ;Load player 1's score
    mov dx, [playe_2_scr];Load player 2's score
    cmp dx, bx ;Compare both scores
    je wintie ;If scores are equal, display a tie
    cmp bx, dx  ;Compare the scores
    jl player2win ;If player 2 wins, display player 2's name
    mov si, player_1 ;Set SI to player 1's name
    jmp displayingwinners ;Jump to displaying the winner
player2win:
    mov si, player_2  ;Set SI to player 2's name
displayingwinners:
    lodsb  ;Load the next byte (character) from player 1's name
    stosw    ;Store the character to screen memory
    cmp al, 0    ;Check if it's the null terminator
    jne displayingwinners ;If not, continue storing characters
    mov si, win  ;Set SI to "win" string
w4:
    lodsb ;Load the next byte from "win" string
    stosw  ;Store it to screen memory
    cmp al, 0 ;Check if it's the null terminator
    jnz w4  ;If not, continue storing characters
    jmp stop      ;Jump to stop
wintie:
    mov di, 2144 ;Set DI to display result at screen position
    mov si, Tie ;Set SI to "Tie" string
w5:
    lodsb ;Load the next byte from "Tie"
    stosw  ;Store it to screen memory
    cmp al, 0   ;Check if it's the null terminator
    jnz w5  ;If not, continue storing characters
stop:
    mov ax, 0x4C00  ;Exit program interrupt
    int 0x21  ;Terminate program
incplayer_1:
    inc word[playe_1_scr] ;Increment player 1's score
    ret

incplayer_2:
    inc word[playe_2_scr]            ; Increment player 2's score
    ret

player_1up:
    cmp word[paddle_1_pos], 640;Check if player 1's paddle is at top limit
    jle player_1u ;If no, move paddle up
    sub word[paddle_1_pos], 160 ;If yes, move paddle up
player_1u:
    ret
player_1down:
    cmp word[paddle_1_pos], 3360 ;Check if player 1's paddle is at bottom limit
    jge player_1d  ;If yes, move paddle down
    add word[paddle_1_pos], 160 ;If no, move paddle down
player_1d:
    ret
player_2up:
    cmp word[paddle_2_pos], 640 ;Check if player 2's paddle is at top limit
    jle player_2u  ;If no, move paddle up
    sub word[paddle_2_pos], 160 ;If yes, move paddle up
player_2u:
    ret
player_2down:
    cmp word[paddle_2_pos], 3360;Check if player 2's paddle is at bottom limit
    jge player_2d ;If yes, move paddle down
    add word[paddle_2_pos], 160;If no, move paddle down
player_2d:
    ret
UpperWall:
    add word[motionofaball], 320 ;Ball hits upper wall, move down
    jmp nextIteration ;Go to next iteration
LowerWall:
    add word[motionofaball], -320;Ball hits lower wall, move up
    jmp nextIteration ;Go to next iteration
RightWall:
    add word[motionofaball], -4 ;Ball hits right wall, move left
    ret

LeftWall:
    add word[motionofaball], 4 ;Ball hits left wall, move right
    ret
toggleState:
    not word[state] ;Toggle game state (pause/unpause)
    ret
start:
    cmp word[WidthProtection], 1 ;Compare the value at 'WidthProtection' with 1
    jne skipChecks ;If 'WidthProtection' is not 1, jump to skipChecks (bypass the following checks)
    cmp word[FieldWidth], 15 ;Compare the value at 'FieldWidth' with 15
    jge sc1 ;If 'FieldWidth' is greater than or equal to 15, jump to sc1 (skip the exit check)
    mov ax, 0x4C00  ;If 'FieldWidth' is less than 15, prepare to exit by setting AX to 0x4C00
    int 0x21 ;Call interrupt 0x21 to terminate the program (exit with return code 0)
sc1:
    cmp word[FieldWidth], 38 ;Compare the value at 'FieldWidth' with 38
    jle skipChecks  ;If 'FieldWidth' is less than or equal to 38, jump to skipChecks (bypass the exit check)
    mov ax, 0x4C00 ;If 'FieldWidth' is greater than 38, prepare to exit by setting AX to 0x4C00
    int 0x21