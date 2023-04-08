#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health/score [2 marks]: Health points tracked on top right
# 2. Fail condition [1 mark]: When player loses all hearts
# 3. Win condition [1 mark]: When player reaches door
# 4. Moving objects [2 mark]: Moving blue enemy
# 5. Pick-up effects [2 marks]: 
#      - health pickup: increases player's health by 1
#      - key: necessary to complete the level
#      - green pickup: removes obstacle 
# 6. Double jump [1 mark]: the player can double jump
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes https://github.com/maplepolis/cscb58-final-project
#
# Any additional information that the TA needs to know:
# I made this project with the goal of creating clear and concise code.
# Hope it meets the expectations.
#####################################################################

.eqv BASE_ADDRESS 0x10008000
.eqv KEY_ADDRESS 0xffff0000
.eqv WHITE 0xffffff
.eqv ORANGE 0xff9400
.eqv RED 0xff0000
.eqv HEALTH_RED 0xff67b2
.eqv DOOR_YELLOW 0xfff900
.eqv KEY_YELLOW 0xeeff01
.eqv BLUE 0x005ef5
.eqv CYAN 0x00ffff
.eqv GREEN 0x01ff36
.eqv PURPLE 0x8300f3
.eqv BLACK 0x000000
.eqv GREY 0xcdceb9
.data
player: .space 4
enemy: .space 4
enemy_direction: .word -4 #-4 for left 4 for right
onPlatform:	.word 1
jumpAmount: .word 2
health: .word 3

.text
li $t0, BASE_ADDRESS # $t0 stores the base address for display

main:

	#stores intial player position
	initialize:
	
		#clears board
		li $a0, BLACK
		addi $a1, $t0, 0
		li $a2, 4096
		jal draw_line
		
		#stores intial player position
		addi $t2, $t0, 12560
		sw $t2, player
		
		#draw player
		li $t1, WHITE
		sw $t1, 0($t2)
		sw $t1, -256($t2)
		sw $t1, -512($t2)
		
		#stores intial enemy position
		addi $t3, $t0, 9860
		sw $t3, enemy
		
		#draw enemy
		li $t1, BLUE
		sw $t1, 0($t3)
		sw $t1, -256($t3)
		sw $t1, -512($t3)
		
		#draw platforms from left to right
		li $a0, ORANGE
		addi $a1, $t0, 12808
		li $a2, 5
		jal draw_line
		
		addi $a1, $t0, 12076
		li $a2, 5
		jal draw_line
		
		addi $a1, $t0, 11080
		li $a2, 2
		jal draw_line
		
		addi $a1, $t0, 10080
		li $a2, 12
		jal draw_line
		
		addi $a1, $t0, 8820
		li $a2, 4
		jal draw_line
		
		addi $a1, $t0, 9112
		li $a2, 7
		jal draw_line
		
		addi $a1, $t0, 8124
		li $a2, 6
		jal draw_line
		
		addi $a1, $t0, 7132
		li $a2, 9
		jal draw_line
		
		#draw lava
		li $a0, RED
		addi $a1, $t0, 15872
		li $a2, 128
		jal draw_line
		
		#draw door
		li $t1, DOOR_YELLOW
		sw $t1, 6128($t0)
		sw $t1, 6132($t0)
		sw $t1, 6136($t0)
		sw $t1, 6140($t0)
		sw $t1, 6384($t0)
		sw $t1, 6640($t0)
		sw $t1, 6896($t0)
		sw $t1, 6396($t0)
		sw $t1, 6652($t0)
		sw $t1, 6908($t0)
		sw $t1, 6648($t0)
		
		#draw key_slot
		li $a0, CYAN
		addi $a1, $t0, 1496
		li $a2, 10
		jal draw_line
		
		addi $a1, $t0, 216
		li $a2, 5
		jal draw_vertical_line
		
		li $a0, GREY
		addi $a1, $t0, 484
		li $a2, 5
		jal draw_line
		
		addi $a1, $t0, 484
		li $a2, 3
		jal draw_vertical_line
		
		
		#draw key
		li $a0, KEY_YELLOW
		addi $a1, $t0, 6776
		li $a2, 3
		jal draw_line
		sw $t1 7032($t0)
		
		#draw health_number
		jal update_health
		
		#draw obstacle
		li $a0, PURPLE
		addi $a1, $t0, 5084
		li $a2, 8
		jal draw_vertical_line
		
	
	#loops continuously until win or fail
	cont_loop:
		jal check_key_press # checks whether there is a key press and moves player/switch screen as appropriate
		key_checked:
			jal check_on_platform
			jal check_on_lava
			lw $t4, onPlatform
			beq $t4, 0, gravity
		gravity_checked:
			jal move_enemy # moves enemy and determines if enemy hits player
			#jal pickup_health # if player picks up health then health +1
			#jal check_door # checks if player reached the door and wins
		
		li $v0, 32
		li $a0, 50
		syscall
		j cont_loop
			
	draw_player:
		sw $a0, 0($t2)
		sw $a0, -256($t2)
		sw $a0, -512($t2)
		jr $ra
	
	check_key_press:
		li $t9, KEY_ADDRESS
		lw $t8, 0($t9)
		beq $t8, 1, key_pressed
		j key_checked
	
	key_pressed:
		lw $t4, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
		beq $t4, 0x61, pressed_a # ASCII code of 'a' is 0x61 or 97 in decimal
		beq $t4 0x64 pressed_d
		beq $t4 0x77 pressed_w
		j key_checked
		
	pressed_a:
		
		#checks if it is possible to move left
		lw $t5, -4($t2)
		bne $t5, BLACK, key_checked
		lw $t5, -260($t2)
		bne $t5, BLACK, key_checked
		lw $t5, -516($t2)
		bne $t5, BLACK, key_checked
		
		#redraws player and moves left
		li $a0, BLACK
		jal draw_player
		subi $t2, $t2, 4
		li $a0, WHITE
		jal draw_player
		j key_checked
		
	
	pressed_w:
		lw $t6, jumpAmount
		blez  $t6, key_checked
		subi $t6, $t6, 1
		
		li $t7, 0
		going_up:
			beq $t7, 12, going_up_end
			li $a0, BLACK
			jal draw_player
			subi $t2, $t2, 256
			li $a0, WHITE
			jal draw_player
			addi $t7, $t7, 1
			j going_up
		
		going_up_end:
			sw $t6, jumpAmount
			j key_checked
	
	pressed_d:
		#checks if it is possible to move right
		lw $t5, 4($t2)
		bne $t5, BLACK, key_checked
		lw $t5, -252($t2)
		bne $t5, BLACK, key_checked
		lw $t5, -508($t2)
		bne $t5, BLACK, key_checked
		
		#redraws player and moves right
		li $a0, BLACK
		jal draw_player
		addi $t2, $t2, 4
		li $a0, WHITE
		jal draw_player
		j key_checked
	
	pressed_p:
		j initialize
	
	check_on_platform:
		lw $t5, 256($t2)
		beq $t5, ORANGE, on_platform
		
		not_on_platform:
		li $t4, 0
		sw $t4, onPlatform
		jr $ra
		
		on_platform:
		li $t4, 1
		sw $t4, onPlatform
		li $t6, 2
		sw $t6, jumpAmount
		jr $ra
		
	check_on_lava:
		lw $t5, 256($t2)
		beq $t5, RED, on_lava
		
		not_on_lava:
			jr $ra
		
		on_lava:
			lw $t6, health
			subi $t6, $t6, 1
			sw $t6, health
			j initialize
		
	
	gravity:
		li $a0, BLACK
		jal draw_player
		addi $t2, $t2, 256
		li $a0, WHITE
		jal draw_player
    	
    	j gravity_checked
    	
    draw_enemy:
		sw $a0, 0($t3)
		sw $a0, -256($t3)
		sw $a0, -512($t3)
		jr $ra
	#moves enemy and checks if it hits the player. If the player is hit, then game over
	move_enemy:
		addi $sp, $sp, -4    # decrement stack pointer by 4 bytes
		sw $ra, 0($sp)     # store $ra on the stack
		
		lw $t4, enemy_direction
		lw $t5, 252($t3)
		bne $t5, ORANGE, enemy_move_right
		lw $t5, 260($t3)
		bne $t5, ORANGE, enemy_move_left
		j movement
		
		enemy_move_right:
			li $t4, 4
			sw $t4, enemy_direction
			j movement
			
		enemy_move_left:
			li $t4, -4
			sw $t4, enemy_direction
			j movement
			
		movement:
			li $a0, BLACK
			jal draw_enemy
			add $t3, $t3, $t4
			li $a0, BLUE
			jal draw_enemy
		
		end_move_enemy:
			lw $ra, 0($sp)     # load $ra from the stack
			addi $sp, $sp, 4     # increment stack pointer by 4 bytes
			jr $ra

	
	#if player reaches a health pickup then increase health by one
	pickup_health:
	
	check_door:
	
	#clears screen and draws winning screen
	win:
		#j clear_display
	
	#tells player they've lost
	lose:
		#TODO: display "Game Over"
		j end
	
	draw_line:
		li $s0, 0
		draw_line_loop:
	    	bge $s0, $a2, end_line_loop	
	    	sw $a0, ($a1)
	    	add $a1, $a1, 4
   	 		addi $s0, $s0, 1	# increment loop counter by 1
   		 	j draw_line_loop		# jump back to the beginning of the loop
		end_line_loop:
			jr $ra
			
	draw_vertical_line:
		li $s0, 0
		draw_vertical_line_loop:
	    	bge $s0, $a2, end_vertical_line_loop	
	    	sw $a0, ($a1)
	    	add $a1, $a1, 256
   	 		addi $s0, $s0, 1	# increment loop counter by 1
   		 	j draw_vertical_line_loop		# jump back to the beginning of the loop
		end_vertical_line_loop:
			jr $ra
	
	update_health:
		addi $sp, $sp, -4    # decrement stack pointer by 4 bytes
		sw $ra, 0($sp)     # store $ra on the stack
		
		li $a0, BLACK
		addi $a1, $t0, 520
		li $a2, 5
		jal draw_vertical_line
		addi $a1, $t0, 524
		li $a2, 5
		jal draw_vertical_line
		addi $a1, $t0, 528
		li $a2, 5
		jal draw_vertical_line
			
		
		lw $t6, health
		li $a0, HEALTH_RED
		beq $t6, 0, health_0
		beq $t6, 1, health_1
		beq $t6, 2, health_2
		beq $t6, 3, health_3
		beq $t6, 4, health_4
		
		health_0:
			addi $a1, $t0, 520
			li $a2, 5
			jal draw_vertical_line
			addi $a1, $t0, 528
			li $a2, 5
			jal draw_vertical_line
			sw $a0, 524($t0)
			sw $a0, 1548($t0)
			j lose
		
		health_1:
			addi $a1, $t0, 520
			li $a2, 5
			jal draw_vertical_line
			j end_update_health
		
		health_2:
			addi $a1, $t0, 520
			li $a2, 3
			jal draw_line
			addi $a1, $t0, 1032
			li $a2, 3
			jal draw_line
			addi $a1, $t0, 1544
			li $a2, 3
			jal draw_line
			sw $a0, 784($t0)
			sw $a0, 1288($t0)
			j end_update_health
		
		health_3:
			addi $a1, $t0, 520
			li $a2, 3
			jal draw_line
			addi $a1, $t0, 1032
			li $a2, 3
			jal draw_line
			addi $a1, $t0, 1544
			li $a2, 3
			jal draw_line
			addi $a1, $t0, 528
			li $a2, 5
			jal draw_vertical_line
			j end_update_health
		
		health_4:
			addi $a1, $t0, 520
			li $a2, 3
			jal draw_vertical_line
			addi $a1, $t0, 528
			li $a2, 5
			jal draw_vertical_line
			sw $t1, 784($t0)
			j end_update_health
		
		end_update_health:
			lw $ra, 0($sp)     # load $ra from the stack
			addi $sp, $sp, 4     # increment stack pointer by 4 bytes
			jr $ra

end:
	li $v0, 10 # terminate the program gracefully
	syscall
