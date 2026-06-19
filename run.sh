#!/bin/bash

EXE=sobel

# ~~~~ debug ~~~~

	make debug

	# ~~ photo ~~
	printf "\n\n| ~~~~~~~~~~ single photo : grayscale ~~~~~~~~~~ |\n"
	
	./$EXE #< >grayout.png

	#compare   gray.png   grayout.png   diff.png
	#EXIT_CODE=$?
	#if [ $EXIT_CODE -ne 0 ]; then
	#	eog diff.png
	#	exit
	#fi
	#rm diff.png

	#printf "\n\n"

	#printf "\n\n| ~~~~~~~~~~ single photo : sobel ~~~~~~~~~~ |\n"
	#./$EXE #< 
	#printf "\n\n"

	# ~~ video ~~
	#printf "\n\n| ~~~~~~~~~~ video : grayscale ~~~~~~~~~~ |\n"
	#./$EXE #< 
	#printf "\n\n"

	#printf "\n\n| ~~~~~~~~~~ video : sobel ~~~~~~~~~~ |\n"
	#./$EXE #< 
	#printf "\n\n"



# ~~~~ mem leaks ~~~~

	# ~~ photo ~~
	#printf "\n\n| ~~~~~~~~~~ valgrind: single photo ~~~~~~~~~~ |\n"
	#make debug
	#valgrind --leak-check=full --show-leak-kinds=all ./$EXE #< 
	#printf "\n\n"

	# ~~ video ~~
	

# ~~~~ frame counting ~~~~


