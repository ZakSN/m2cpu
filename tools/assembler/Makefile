CXX=g++
CXXFLAGS=-Wall
OBJECTS=buffer.o main.o

.PHONY: clean all

all: $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) -o assembler

buffer.o: buffer.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c buffer.cpp

main.o: main.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c main.cpp

clean:
	rm $(OBJECTS)
	rm assembler
