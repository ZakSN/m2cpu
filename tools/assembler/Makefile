CXX=g++
CXXFLAGS=-Wall
OBJECTS=buffer.o main.o cmd_line.o

.PHONY: clean all

all: $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) -o assembler

buffer.o: buffer.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c buffer.cpp

main.o: main.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c main.cpp

cmd_line.o: cmd_line.cpp cmd_line.h
	$(CXX) $(CXXFLAGS) -c cmd_line.cpp

clean:
	rm $(OBJECTS)
	rm assembler
