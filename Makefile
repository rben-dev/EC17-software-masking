.PHONY: clean

CC = gcc
CFLAGS = -Wall -Wextra -O0 -MMD -MP -g
LDFLAGS = 
OBJ = main.o $(patsubst %.S, %.o, test/test_1_fieldmult.S)
PLATFORM_TEST = ./hom_ec17

ifeq ($(PLATFORM),cortexm4)
CC = arm-none-eabi-gcc
CFLAGS = -Wall -Wextra -O0 -MMD -MP -g -mcpu=cortex-m4 -mthumb
LDFLAGS = --specs=rdimon.specs -lrdimon -T linker.ld
OBJ = main.o startup.o $(patsubst %.S, %.o, test/test_1_fieldmult.S)
PLATFORM_TEST = qemu-system-arm -machine mps2-an386 -cpu cortex-m4 -semihosting -nographic -kernel ./hom_ec17
endif
ifeq ($(PLATFORM),cortexa)
CC = arm-linux-gnueabi-gcc
CFLAGS = -Wall -Wextra -O0 -MMD -MP -g -march=armv7-a
LDFLAGS = -static
OBJ = main.o $(patsubst %.S, %.o, test/test_1_fieldmult.S)
PLATFORM_TEST = ./hom_ec17
endif

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

hom_ec17: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJ) -o $@

platform_test:
	$(PLATFORM_TEST)

exec_CI:
	docker build -t ec17_tester -f CI/Dockerfile .
	docker run --rm ec17_tester

# clean
clean:
	rm -rf *.o src/*.o test/*.o *.d src/*.d test/*.d
	rm -rf hom_ec17
