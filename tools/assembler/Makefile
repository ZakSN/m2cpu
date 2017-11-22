CXX=g++
CXXFLAGS=-Wall -Wno-sign-compare
OBJECTS=buffer.o main.o cmd_line.o parser.o hex_formatter.o

.PHONY: clean all

all: $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) -o assembler

buffer.o: buffer.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c buffer.cpp

main.o: main.cpp buffer.h
	$(CXX) $(CXXFLAGS) -c main.cpp

cmd_line.o: cmd_line.cpp cmd_line.h
	$(CXX) $(CXXFLAGS) -c cmd_line.cpp

parser.o: parser.cpp parser.h
	$(CXX) $(CXXFLAGS) -c parser.cpp

hex_formatter.o: hex_formatter.cpp hex_formatter.h
	$(CXX) $(CXXFLAGS) -c hex_formatter.cpp

clean:
	rm $(OBJECTS)
	rm assembler
