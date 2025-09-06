library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Digital_lock is
end TB_Digital_lock;

architecture behavior of TB_Digital_lock is

    component Digital_lock
        Port (
            Clk         : in  STD_LOGIC;
            Rst         : in  STD_LOGIC;
            Keypad      : in  STD_LOGIC_VECTOR(9 downto 0);
            reset_pass  :in STD_LOGIC := '0';
            Change_Pass : in  STD_LOGIC;
            Lock        : out STD_LOGIC;
            Status      : out STD_LOGIC;
            Failure     : out STD_LOGIC
        );
    end component;

    signal Clk         : STD_LOGIC := '0';
    signal Rst         : STD_LOGIC := '0';
    signal Keypad      : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal Change_Pass : STD_LOGIC := '0';
    signal Lock        : STD_LOGIC;
    signal Status      : STD_LOGIC;
    signal Failure     : STD_LOGIC;

    constant clk_period : time := 10 ns;

    procedure Press_Key(signal kp: out STD_LOGIC_VECTOR(9 downto 0); key: integer) is
    begin
        kp <= (others => '0');
        kp(key) <= '1';
        wait for clk_period;
        kp <= (others => '0');
        wait for clk_period;
    end procedure;

    procedure Enter_Password(signal kp: out STD_LOGIC_VECTOR(9 downto 0); code: string) is
    begin
        for i in 1 to 4 loop
            Press_Key(kp, CHARACTER'POS(code(i)) - CHARACTER'POS('0'));
        end loop;
    end procedure;

begin

    uut: Digital_lock
        Port map (
            Clk => Clk,
            Rst => Rst,
            Keypad => Keypad,
            Change_Pass => Change_Pass,
            Lock => Lock,
            Status => Status,
            Failure => Failure
        );

    clk_process :process
    begin
        while now < 2000 ns loop
            Clk <= '0';
            wait for clk_period / 2;
            Clk <= '1';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
-- Reset system
Rst <= '1';
wait for 2 * clk_period;
Rst <= '0';
wait for 2 * clk_period;

Enter_Password(Keypad, "2345");
wait for 2 * clk_period;  -- WAIT here before entering the new password

Rst <= '1';
wait for 2 * clk_period;
Rst <= '0';
wait for 2 * clk_period;

-- Start change password mode first
Change_Pass <= '1';
wait for clk_period;

-- Enter new password "9876"
Enter_Password(Keypad, "9876");

-- End change password mode
Change_Pass <= '0';
wait for 3 * clk_period;  -- WAIT here before entering the new password


Rst <= '1';
wait for 2 * clk_period;
Rst <= '0';
wait for 2 * clk_period;


Enter_Password(Keypad, "9876");

wait for 5 * clk_period; 

Rst <= '1';
wait for 2 * clk_period;
Rst <= '0';
wait for 2 * clk_period;
Enter_Password(Keypad, "2345");
wait for 2 * clk_period;

Enter_Password(Keypad, "2345");
wait for 2 * clk_period;

Enter_Password(Keypad, "2345");

wait for 5 * clk_period; 


        wait;
    end process;
    


end behavior;