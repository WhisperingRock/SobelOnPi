# Compiler
CC = g++

# Default Goal (Project) 
P = sobel

SRC = sobel.cpp

# Flags
CPPFLAGS = -Wall       # All warnings
CPPFLAGS+= -Wextra    # Extra warnings
#CPPFLAGS+= -Werror    # Treat all warnings as errors

LIBS = `pkg-config --cflags --libs opencv4`

all: $(P)

debug: CFLAGS+= -g
debug: clean all

$(P) : $(SRC)
	$(CC) $(SRC) -o $(P) $(LIBS) $(CPPFLAGS)

clean:
	rm -f *.o
