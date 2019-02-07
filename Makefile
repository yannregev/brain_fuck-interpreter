objects = main.o bf.o read_file.o
.PHONY: clean

brainfuck: $(objects)
	$(CC) -o "$@" $^ -fPIC -fno-pie

build:
	mkdir build

build/%.o: %.s | build
	$(CC) -fPIC -fno-pie -c -o "$@" "$<"

clean:
	rm -rf brainfuck build
