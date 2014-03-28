.SUFFIXES: .erl .beam .yrl
.erl.beam:
	erlc -W $<

MODS = example example_lid

all: ${MODES:%=%.beam} example example_drv.so

example: example.c erl_comm.c exp_driver.c
	gcc -o example example.c erl_comm.c exp_driver.c

example_drv.so: example_lid.c example.c
	gcc -o example_drv.so -fpic -shared example_lid.c example.c

clean:
	rm example example_drv.so *beam
