.data
	#Different variables
	frameBuffer:	.space	0x8000
	xVelo:		.word	0
	yVelo:		.word	0
	xPos:		.word	50
	yPos:		.word	27
	tail:		.word	7624
	xApple:		.word	32
	yApple:		.word	16
	upSnake:	.word	0x0000ff00
	downSnake:	.word	0x0100ff00
	rightSnake:	.word	0x0200ff00
	leftSnake:	.word	0x0300ff00
	xCon:		.word	64
	yCon:		.word	4
	
.text
main:
	#BACKGROUND
	la $t0, frameBuffer #loads the address of the frame buffer
	li $t1, 8192	     #512*256 pixels
	li $t2, 0x00d3d3d3  #load the gray color

loop:	
	sw $t2, 0($t0)
	addi $t0, $t0, 4    #go to the next pixel in the display
	addi $t1, $t1, -1   #decrement the pizels
	bnez $t1, loop	     #use recursion to repeat function 
	
	#BORDER
	la $t0, frameBuffer #load buffer
	addi $t1, $zero, 64 #t1 = 64 which is the width
	li $t2, 0x00000000 #load black color
	
topOfBorder:
	sw $t2, 0($t0)	    #color pixels black
	addi $t0, $t0, 4   #next pixel
	addi $t1, $t1, -1  #decrement pixel
	bnez $t1, topOfBorder #repeat until 0
	
	#bottom of wall
	la $t0, frameBuffer
	addi $t0, $t0, 7936 #put pixels near bottom left
	addi $t1, $zero, 64 #t1 = width = 512

bottomBorder:
	sw $t2, 0($t0) #color black pixels
	addi $t0, $t0, 4 #next pixel
	addi $t1, $t1, -1 #decrement
	bnez $t1, bottomBorder #recursion until 0
	
	#left wall
	la $t0, frameBuffer
	addi $t1, $zero, 256 #t1 = columns = 256
	
borderLeft:
	sw $t2, 0($t0)
	addi $t0, $t0, 256 #next pixel
	addi $t1, $t1, -1 #decrement
	bnez $t1, borderLeft #recursion
	
	#right section
	la $t0, frameBuffer
	addi $t0, $t0, 508 #put starting pizel is top right
	addi $t1, $zero, 512 # t1 = columns
	
borderRight:
	sw $t2, 0($t0)
	addi $t0, $t0, 256 #next pixel
	addi $t1, $t1, -1 #deceremnt
	bnez $t1, borderRight #recursion
	
	
	
	
	
	
	
	
	