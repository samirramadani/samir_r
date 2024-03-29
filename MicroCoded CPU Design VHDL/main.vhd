library IEEE;
library lpm;
use IEEE.std_logic_1164.all;
use lpm.lpm_components.all;
 
entity lab7 is
port (clk, reset: in std_logic;
uop: out std_logic_vector(18 downto 0);
    displayout1,displayout2,displayout3,
	 displayout4,displayout5,displayout6,
	 displayout7,displayout8: out std_logic_vector(6 downto 0));
end lab7;

architecture dataflow of lab7 is
signal A_MUX_SELECT, DR_MUX_SELECT, NOT_Z_MUX_SELECT, PC_COUNT_EN, PC_RESET, PC_DR, PC_TO_MAR, MMAR_TO_MAR, SP_TO_MAR, DR_TO_MMAR,A_TO_DR, ALU_ADD, ALU_AND, DR_TO_A, MMAR_TO_SP, SP_COUNT_DOWN, SP_COUNT_UP, Z_NOT,V_TO_Z, DR_TO_IR, MMAR_TO_DR, A_TO_R, Z_IN, Z_OUT, NOT_Z_OUT: std_logic_vector(0 downto 0);
	signal PC_OUT, MAR_IN, MAR_OUT, IR_OUT, DR_IN,
	DR_OUT, A_IN, A_OUT, R_OUT, SP_OUT,
	ALU_OUT, MMAR_OUT:std_logic_vector(7 downto 0);
	signal A_MUX_IN, DR_MUX_IN: std_logic_2D(1 downto 0, 7 downto 0);
	signal MAR_MUX_IN: std_logic_2D(3 downto 0, 7 downto 0);
	signal NOT_Z_MUX_IN: std_logic_2D(1 downto 0, 0 downto 0);
	signal MAR_MUX_select: std_logic_vector(1 downto 0);
	signal uROM: std_logic_vector(18 downto 0);
	signal opc: std_logic_vector(3 downto 0);
	signal clk2, clear: std_logic;

component sevensegdisplay is
	port(input: in std_logic_vector(3 downto 0);
		output: out std_logic_vector(6 downto 0));
end component;

component exp7_alu is
	port(a,b: in std_logic_vector(7 downto 0);
		op: in std_logic_vector(0 downto 0);
		result: out std_logic_vector(7 downto 0));
end component;


component exp7_useq is
	generic (uROM_width: integer;
		uROM_file: string);
	port (opcode: in std_logic_vector(3 downto 0);
		uop: out std_logic_vector(1 to (uROM_width-9));
		enable, clear: in std_logic;
		clock: in std_logic);
end component;

begin
Delay: lpm_counter
		GENERIC MAP(lpm_width=>25) 
		PORT MAP(clock=>clk, cout=>clk2);	
		
		--Display for A_register
display1a: sevensegdisplay port map(input=>A_OUT (3 downto 0), output=>displayout1);
display2a: sevensegdisplay port map(input=>A_OUT(7 downto 4), output=>displayout2);
		--Display for PC_count
display1pc: sevensegdisplay port map(input=>PC_OUT(3 downto 0), output=>displayout3);
display2pc: sevensegdisplay port map(input=>PC_OUT(7 downto 4), output=>displayout4);
		--Display for MAR_register
display1mar: sevensegdisplay port map(input=>MAR_OUT(3 downto 0), output=>displayout5);
display2mar: sevensegdisplay port map(input=>MAR_OUT(7 downto 4), output=>displayout6);
		--Display for DR_register
display1dr: sevensegdisplay port map(input=>DR_OUT(3 downto 0), output=>displayout7);
display2dr: sevensegdisplay port map(input=>DR_OUT(7 downto 4), output=>displayout8);
		
	opc<= DR_OUT(7 downto 4);			
	clear<= NOT reset;
	uop<= uROM;
	A_MUX_SELECT(0) <= (NOT DR_TO_A(0)) AND ALU_OUT(0);
	NOT_Z_MUX_SELECT(0) <= Z_NOT(0);		
	MAR_MUX_select(0) <= (NOT MMAR_TO_MAR(0)) AND PC_TO_MAR(0);
	MAR_MUX_select(1) <= SP_TO_MAR(0);
	DR_MUX_SELECT(0) <= (NOT MMAR_TO_DR(0)) AND A_TO_DR(0);	
			
	PC_COUNT_EN(0) <= uROM(18) AND clk2;
	PC_RESET(0) <= (uROM(17) AND clk2) AND reset;
	PC_DR(0) <= uROM(16) AND clk2;
	PC_TO_MAR(0) <= uROM(15) AND clk2;
	MMAR_TO_MAR(0) <= uROM(14) AND clk2;
	SP_TO_MAR(0) <= uROM(13) AND clk2;
	MMAR_TO_DR(0) <= uROM(12) AND clk2;
	A_TO_DR(0) <= uROM(11) AND clk2;
	ALU_ADD(0) <= uROM(10) AND clk2;
	ALU_AND(0) <= uROM(9) AND clk2;
	DR_TO_A(0) <= uROM(8) AND clk2;
	MMAR_TO_SP(0) <= uROM(7) AND clk2;
	SP_COUNT_DOWN(0) <= uROM(6) AND clk2;
	SP_COUNT_UP(0) <= uROM(5) AND clk2;
	Z_NOT(0) <= uROM(4) AND clk2;
	V_TO_Z(0) <= uROM(3) AND clk2;
	DR_TO_IR(0) <= uROM(2) AND clk2;
	DR_TO_MMAR(0) <= uROM(1) AND clk2;
	A_TO_R(0) <= uROM(0) AND clk2;
	
--PC_count
PC: lpm_counter
	GENERIC MAP(lpm_width=>8)
PORT MAP(cnt_en=>PC_COUNT_EN(0), data=>DR_OUT, q=>PC_OUT, clock=>clk,
sload=>(PC_DR(0) AND (NOT (IR_OUT(7) AND NOT IR_OUT(6) AND NOT IR_OUT(5) AND IR_OUT(4)) OR Z_OUT(0))),
			sclr=>(clear OR PC_RESET(0)));
--SP_counter	
SP: lpm_counter
	GENERIC MAP(lpm_width=>8)
PORT MAP(updown=>SP_COUNT_UP(0),cnt_en=>(SP_COUNT_UP(0) OR SP_COUNT_DOWN(0)),data=>MMAR_OUT, q=>SP_OUT, clock=>clk,sload=>(MMAR_TO_SP(0)),sclr=>clear);
--Z_MUX signals
NOT_Z_MUX_IN(0, 0) <= Z_OUT(0);
NOT_Z_MUX_IN(1, 0) <= NOT Z_OUT(0);
--Z_mux
NOTZMUX: lpm_mux
	GENERIC MAP(lpm_width=>1,lpm_size=>2,lpm_widths=>1)
PORT MAP(result=>NOT_Z_OUT,data=>NOT_Z_MUX_IN,sel=>NOT_Z_MUX_SELECT);
--Z_register
Z_register: lpm_ff
	GENERIC MAP(lpm_width=>1)
PORT MAP(data=>Z_IN,q=>Z_OUT,clock=>clk,enable=>(Z_NOT(0) OR V_TO_Z(0)),sclr=>clear);
--IR_register
IR_register: lpm_ff	
	GENERIC MAP(lpm_width=>8)
PORT MAP(data=>DR_OUT,q=>IR_OUT,clock=>clk,enable=>(DR_TO_IR(0)),sclr=>clear);
		--R_register
R_register: lpm_ff	
	GENERIC MAP(lpm_width=>8)
PORT MAP(data=>A_OUT,q=>R_OUT,clock=>clk,enable=>(A_TO_R(0)),sclr=>clear);
--RAM																							--RAM FILE
RAM: lpm_ram_dq	
	GENERIC MAP(lpm_width=>8, lpm_widthad=>8,lpm_file=>"exp7_ram01_05.mif")
PORT MAP(data=>DR_OUT,address=>MAR_OUT,q=>MMAR_OUT, inclock=>clk,outclock=>clk,we=>DR_TO_MMAR(0));
--MAR_MUX signals
MUX_MAR: for i in 0 to 7 generate
	MAR_MUX_IN(0,i) <= MMAR_OUT(i);
	MAR_MUX_IN(1,i) <= PC_OUT(i);
	MAR_MUX_IN(2,i) <= SP_OUT(i);
	MAR_MUX_IN(3,i) <= SP_OUT(i);
	end generate;
--MAR_MUX
MAR_MUX: lpm_mux
	GENERIC MAP(lpm_width=>8,lpm_size=>4,lpm_widths=>2)
	PORT MAP(result=>MAR_IN,data=>MAR_MUX_IN,sel=>MAR_MUX_select);
--MAR_register
MAR_register: lpm_ff	
	GENERIC MAP(lpm_width=>8)
PORT MAP(data=>MAR_IN,q=>MAR_OUT,clock=>clk,enable=>(PC_TO_MAR(0) OR MMAR_TO_MAR(0) OR SP_TO_MAR(0)),sclr=>clear);
		--DR_MUX signals
	MUX_DR: for i in 0 to 7 generate
		DR_MUX_IN(0,i) <= MMAR_OUT(i);
		DR_MUX_IN(1,i) <= A_OUT(i);
	end generate;
--DR_MUX
DR_MUX: lpm_mux	
	GENERIC MAP(lpm_width=>8,lpm_size=>2,lpm_widths=>1)
	PORT MAP(result=>DR_IN,data=>DR_MUX_IN,sel=>DR_MUX_SELECT);
--DR_register
DR_register: lpm_ff
	GENERIC MAP(lpm_width=>8)
PORT MAP(data=>DR_IN,q=>DR_OUT,clock=>clk,enable=>(MMAR_TO_DR(0) OR A_TO_DR(0)),sclr=>clear);
--A_MUX signals
MUX_A: for i in 0 to 7 generate
		A_MUX_IN(0,i) <= DR_OUT(i);
		A_MUX_IN(1,i) <= ALU_OUT(i);
	end generate;
--A_MUX
A_MUX: lpm_mux	
	GENERIC MAP(lpm_width=>8,lpm_size=>2,lpm_widths=>1)
	PORT MAP(result=>A_IN,data=>A_MUX_IN,sel=>A_MUX_SELECT);

--A_register
A_register: lpm_ff	
	GENERIC MAP(lpm_width=>8)
PORT MAP(data=>A_IN,q=>A_OUT,clock=>clk,enable=>(ALU_ADD(0) OR ALU_AND(0) OR DR_TO_A(0)),sclr=>clear);
--uSeq component	
useq: exp7_useq 
	GENERIC MAP(uROM_width=>28, uROM_file=>"urom_lab7.mif")
PORT MAP(opcode=>opc, uop=>uROM, enable=>(clk2 AND NOT PC_RESET(0)), clear=>clear, clock=>clk);
		--ALU_component
	ALU: exp7_alu 
		PORT MAP(a=>A_OUT, b=>R_OUT, op=>ALU_AND, result=>ALU_OUT);
end dataflow;
