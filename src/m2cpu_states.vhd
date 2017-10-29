package m2cpu_states is
	type control_state is(
		LOAD_IR,
		INC_PC,
		DECODE,
		LOAD_REG,
		LOAD_REGi
	);
end package m2cpu_states;