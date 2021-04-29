CC = gcc
BUILD_DIR = .
SRC_DIR = ../src
CC_OPTS = -Wall -Werror -I$(SRC_DIR)

all: lexer parser codegen blaise-avr

check:

clean:

lexer.c: parser.h 
	flex -o $(BUILD_DIR)/lexer.c $(SRC_DIR)/lexer.l

lexer: lexer.c
	gcc $(CC_OPTS) -o $(BUILD_DIR)/lexer $(BUILD_DIR)/lexer.c

parser.h parser.c:
	bison -Wall -d -o $(BUILD_DIR)/parser.c $(SRC_DIR)/parser.y

parser: lexer.c parser.c
	gcc $(CC_OPTS) -o $(BUILD_DIR)/parser $(BUILD_DIR)/parser.c $(BUILD_DIR)/lexer.c

codegen: lexer.c parser.c
	gcc $(CC_OPTS) -o $(BUILD_DIR)/codegen $(SRC_DIR)/codegen.c $(BUILD_DIR)/parser.c

blaise-avr: codegen
	cp $(BUILD_DIR)/codegen $(BUILD_DIR)/blaise-avr
