check : .PHONY
	idris --build js.ipkg

recheck: clean check

clean: .PHONY
	idris --clean js.ipkg

.PHONY:
