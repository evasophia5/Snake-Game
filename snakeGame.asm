.data
	#Different variables
	frameBuffer:	.space	0x8000
	xVel:		.word	0
	yVel:		.word	0
	xPos:		.word	50
	yPos:		.word	27
	tail:		.word	7624
	appleX:		.word	32
	appleY:		.word	16
	snakeUp:	.word	0x0000ff00
	snakeDown:	.word	0x0100ff00
	snakeRight:	.word	0x0200ff00
	snakeLeft:	.word	0x0300ff00
	xCon:		.word	64
	yCon:		.word	4
	
.text
main:
	#BACKGROUND
	la 	$t0, frameBuffer#loads the address of the frame buffer
	li 	$t1, 8192	#512*256 pixels
	li 	$t2, 0x00d3d3d3	#load the gray color

loop:	
	sw 	$t2, 0($t0)
	addi 	$t0, $t0, 4	#go to the next pixel in the display
	addi 	$t1, $t1, -1   #decrement the pizels
	bnez 	$t1, loop	#use recursion to repeat function 
	
	#BORDER
	la 	$t0, frameBuffer#load buffer
	addi 	$t1, $zero, 64	#t1 = 64 which is the width
	li 	$t2, 0x00000000	#load black color
	
topOfBorder:
	sw 	$t2, 0($t0)	#color pixels black
	addi 	$t0, $t0, 4	#next pixel
	addi 	$t1, $t1, -1	#decrement pixel
	bnez 	$t1, topOfBorder#repeat until 0
	
	#bottom of wall
	la 	$t0, frameBuffer
	addi 	$t0, $t0, 7936	#put pixels near bottom left
	addi 	$t1, $zero, 64	#t1 = width = 512

bottomBorder:
	sw 	$t2, 0($t0)	#color black pixels
	addi 	$t0, $t0, 4	#next pixel
	addi 	$t1, $t1, -1	#decrement
	bnez 	$t1, bottomBorder#recursion until 0
	
	#left wall
	la 	$t0, frameBuffer
	addi 	$t1, $zero, 256	#t1 = columns = 256
	
borderLeft:
	sw 	$t2, 0($t0)
	addi 	$t0, $t0, 256	#next pixel
	addi 	$t1, $t1, -1	#decrement
	bnez 	$t1, borderLeft	#recursion
	
	#right section
	la 	$t0, frameBuffer
	addi 	$t0, $t0, 508	#put starting pizel is top right
	addi 	$t1, $zero, 512 # t1 = columns
	
borderRight:
	sw 	$t2, 0($t0)
	addi 	$t0, $t0, 256	#next pixel
	addi 	$t1, $t1, -1	#deceremnt
	bnez 	$t1, borderRight#recursion
	
	#draw beginning of snake
	la 	$t0, frameBuffer
	lw 	$s2, tail	#s2 = tail
	lw 	$s3, snakeUp	#s3 = direction of the snake
	
	add 	$t1, $s2, $t0	#t1 = start of the tail on the display
	sw 	$s3, 0($t1)	# add pixel where snake is ($t1)
	addi 	$t1, $t1, -256 
	sw 	$s3, 0($t1)	#draw pixel where snake is
	
	#draw the intial apple position
	jal	makeApple
	
	# t3 = input
	# s3 = direction of the snake
	
gameLoop:

	lw	$t3, 0xffff0004	#get input from keyboard
	
	#framerate, sleep for 66 ms, fram rate is 15 ish
	addi	$v0, $zero, 32 #sleep
	addi	$a0, $zero, 66	#66ms
	syscall
	
	beq 	$t3, 100, goRight#if "d" is pressed branch to goRight
	beq 	$t3, 97, goLeft	#if "a" is pressed branch to goLeft
	beq 	$t3, 119, goUp	#if "w" is pressed branch to goUp
	beq	$t3, 115, goDown#if "s" is pressed branch goDown
	beq	$t3, 0, goUp	#start the game going up
	
goUp:
	lw	$s3, snakeUp	#s3 = snake direction
	add	$a0, $s3, $zero	#put direction of snake into the argument
	jal	update
	#move the snake
	jal	moveSnakeHead
	
	j	stopMoving

goDown:
	lw	$s3, snakeDown	# s3 is the direction snake is going
	add	$a0, $s3, $zero	#add snake direction to the argument
	jal	update
	#move the snake
	jal	moveSnakeHead
	
	j	stopMoving
	
goLeft:
	lw	$s3, snakeLeft	#s3 = direction snake is going
	add	$a0, $s3, $zero	#add the directin to the argument
	jal	update
	#move the snake
	jal	moveSnakeHead
	
	j	stopMoving
	
goRight:
	lw	$s3, snakeRight	#s3 = direction of snake
	add	$a0, $s3, $zero#direction goes into the argument
	jal	update
	#move the snake
	jal	moveSnakeHead
	
	j	stopMoving
	
stopMoving:
	j gameLoop	#go back to the beginning of the loop
	
update:
	addiu	$sp, $sp, -24	#set room for 24 bytes in stack
	sw 	$fp, 0($sp)	#store frame pointer
	sw 	$ra, 4($sp)	#store return address
	addiu	$fp, $sp, 20	#setup the update frame pointer
	
	#DRAW HEAD
	
	lw	$t0, xPos	#t0 is the x position of snake
	lw	$t1, yPos	#t1 is the y position of snake
	lw	$t2, xCon	#t2 = 64
	mult	$t1, $t2	#y position x 64
	mflo	$t3		#t3 = yPOs x 64
	add	$t3, $t3, $t0	#t3 = yPOS x 64 x xPOS
	lw	$t2, yCon	#t2 = 4
	mult	$t3, $t2	
	mflo	$t0
	
	la	$t1, frameBuffer
	add	$t0, $t1, $t0
	lw 	$t4, 0($t0)	#save velocity of pixel in t4
	sw	$a0, 0($t0)	#store direction and color
	
	#set velocity
	lw 	$t2, snakeUp		#snakeUp = 0x0000ff00
	beq	$a0, $t2, velocityUp	#if head and color is up then branch to Velocity up
	
	lw	$t2, snakeDown		#snakeUp = 0x0100ff00
	beq	$a0, $t2, velocityDown#if head direction is down then branch to vel down
	
	lw	$t2, snakeLeft		#snakeUp = 0x0200ff00
	beq	$a0, $t2, velocityLeft#if head and color is left then branch to vel go left
	
	lw	$t2, snakeRight		#snakeRight = 0x0300ff00
	beq	$a0, $t2, velocityRight
	
velocityUp:
	addi	$t5, $zero, 0		#set x vel to 0
	addi	$t6, $zero, -1		#set y vel to -1
	
	sw	$t5, xVel
	sw	$t6, yVel
	j stopVelocity
	
velocityDown:
	addi	$t5, $zero, 0		#set x vel to zero
	addi	$t6, $zero, 1		#set y vel to 1
	sw	$t5, xVel		#update xVel
	sw	$t6, yVel		#update yVel
	j stopVelocity
	
velocityLeft:
	addi	$t5, $zero, -1		#set x vel to -1
	addi	$t6, $zero, 0		#set y vel to zero
	sw	$t5, xVel		#update xVel
	sw	$t6, yVel		#update yVel
	j stopVelocity

velocityRight:
	addi	$t5, $zero, 1		#set x vel to 1
	addi	$t6, $zero, 0		#set y vel to zero
	sw	$t5, xVel		#update xVel
	sw	$t6, yVel		#update yVel
	j stopVelocity
	
stopVelocity:
	#check head position
	li	$t2, 0x00ff0000		#load color red
	bne	$t2, $t4, notApple	#if there is not an apple in front branch to notApple
	#if we did run into an apple
	jal	newApple
	jal	makeApple
	j	stopSnake
	
notApple:
	li	$t2, 0x00d3d3d3		#load gray color
	beq	$t2, $t4, advance
	
	addi	$v0, $zero, 10		#exit program
	syscall
	
advance:
	#remove a tail pixel
	lw	$t0, tail		#t0 = tail
	la	$t1, frameBuffer
	add	$t2, $t0, $t1		#t2 = tail location
	li	$t3, 0x00d3d3d3
	lw	$t4, 0($t2)		#t4 = tail and color
	sw	$t3, 0($t2)		#replace tail with background
	
	lw	$t5, snakeUp		#snakeUp = 0x0000ff00
	beq	$t5, $t4, setTailUp	#if tail and color is up then branch to set tail up
	
	lw	$t5, snakeDown
	beq	$t5, $t4, setTailDown
	
	lw	$t5, snakeLeft
	beq	$t5, $t4, setTailLeft
	
	lw	$t5, snakeRight
	beq	$t5, $t4, setTailRight
	
setTailUp:
	addi	$t0, $t0, -256		#tail is tail - 256
	sw	$t0, tail		#add tail to memory
	j 	stopSnake
	
setTailDown:
	addi	$t0, $t0, 256		#tail is tail + 256
	sw	$t0, tail		#store in memory
	j	stopSnake

setTailLeft:
	addi	$t0, $t0, -4		#tail is tail - 4
	sw	$t0, tail		#store in memory
	j	stopSnake
	
setTailRight:
	addi	$t0, $t0, 4		#tail is tail + 4
	sw	$t0, tail		#store tail in memory
	j	stopSnake
	
stopSnake:
	lw	$ra, 4($sp)		#load return address of the caller
	lw	$fp, 0($sp)		#restore caller frame pointer
	addiu	$sp, $sp, 24		#restore caller stack pointer
	jr	$ra			#exit function
	
moveSnakeHead:
	addiu	$sp, $sp, -24		#make space for 24 bytes in stack
	sw	$fp, 0($sp)		#store caller frame pointer
	sw	$ra, 4($sp)		#store caller address
	addiu	$fp, $sp, 20		#setup update frame pointer
	
	lw	$t3, xVel		#load xVel
	lw	$t4, yVel		#load yVel
	lw	$t5, xPos		#load xPos 
	lw	$t6, yPos		#load yPos
	add	$t5, $t5, $t3		#update x pos
	add	$t6, $t6, $t4		#updare y pos
	sw	$t5, xPos		#store the new xpos into memory
	sw	$t6, yPos		#store the new yPos into memory
	
	lw	$ra, 4($sp)		#load return address of caller
	lw	$fp, 0($sp)		#restore caller frame pointer
	addiu	$sp, $sp, 24		#return the caller stack pointer
	jr	$ra			#exit function
	
makeApple:
	addiu	$sp, $sp, -24		#make room to 24 bytes in stack
	sw	$fp, 0($sp)		#store caller frame pointer
	sw	$ra, 4($sp)		#store the return address
	addiu	$fp, $sp, 20		#update the frame pointer
	
	lw	$t0, appleX		#t0 = the xpos of apple
	lw	$t1, appleY		#t1 = yPos of the apple
	lw	$t2, xCon		#t2 = 64
	mult	$t1, $t2		#appley x 64
	mflo	$t3
	add	$t3, $t3, $t0		#t3 = appley x 64 + applex
	lw	$t2, yCon		#t2 = 4
	mult	$t3, $t2
	mflo	$t0
	
	la	$t1, frameBuffer
	add	$t0, $t1, $t0
	li	$t4, 0x00ff0000
	sw	$t4, 0($t0)		#store the direction and color in the bitmap display
	
	lw	$ra, 4($sp)		#load caller return address
	lw	$fp, 0($sp)		#restore the callers frame pointer
	addiu	$sp, $sp, 24		#restore the caller stack pointer
	jr	$ra			#exit function
	
newApple:
	addiu	$sp, $sp, -24
	sw	$fp, 0($sp)		#store caller frame pointer
	sw	$ra, 4($sp)		#store the caller return address
	addiu	$fp, $sp, 20		#update the frame pointer
	
random:
	addi	$v0, $zero, 42		#random int
	addi	$a1, $zero, 63		#make 63 the upper bound
	syscall
	add	$t1, $zero, $a0		#random x coordiante
	
	addi	$v0, $zero, 42		#random int
	addi	$a1, $zero, 31		#make 31 the upper bound
	syscall
	add	$t2, $zero, $a0		#random y coordinate
	
	lw	$t3, xCon		#t3 = 64
	mult	$t2, $t3	
	mflo	$t4
	add	$t4, $t4, $t1
	lw	$t3, yCon		#t3  = 4
	mult	$t3, $t4
	mflo	$t4
	
	la	$t0, frameBuffer
	add	$t0, $t4, $t0
	lw	$t5, 0($t0)
	
	li	$t6, 0x00d3d3d3
	beq	$t5, $t6, okayForApple	#if the square is good for an apple, then branch
	
	j random
	
okayForApple:
	sw	$t1, appleX
	sw	$t2, appleY
	
	lw	$ra, 4($sp)	#load return address of the caller
	lw	$fp, 0($sp)	#restore the frame pointer
	addiu	$sp, $sp, 24
	jr	$ra
