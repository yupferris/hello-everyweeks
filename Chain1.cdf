/* Quartus II 64-Bit Version 15.0.2 Build 153 07/15/2015 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(10M50DAF484ES) Path("C:/msys64/home/ferris/dev/fpga/projects/hello-everyweeks/output_files/") File("hello-everyweeks.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(VTAP10) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
