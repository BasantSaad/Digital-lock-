library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Digital_lock is
    Port (
        Clk         : in  STD_LOGIC;
        Rst         : in  STD_LOGIC;
        Keypad      : in  STD_LOGIC_VECTOR(9 downto 0);
        Change_Pass : in  STD_LOGIC;
        reset_pass  :in STD_LOGIC := '0';
        Lock        : out STD_LOGIC;
        Status      : out STD_LOGIC;
        Failure     : out STD_LOGIC
        
    );
end Digital_lock;

architecture Behavioral of Digital_lock is

    signal encoded        : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    signal entered_code   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal new_code       : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal digit_count    : integer range 0 to 4 := 0;
    signal stored_code    : STD_LOGIC_VECTOR(15 downto 0) := x"2345"; -- Initial password
    signal match          : STD_LOGIC := '0';
    signal enable         : STD_LOGIC := '0';
    signal fail_count     : integer range 0 to 4 := 0;
    signal system_fail    : STD_LOGIC := '0';
    signal reset_attempt  : STD_LOGIC := '0';
    signal change_mode    : STD_LOGIC := '0';
   

begin

    ----------------------------------------------------------------------
    -- Keypad Encoder
    ----------------------------------------------------------------------
    key_encoder: process(Keypad)
    begin
        case Keypad is
            when "0000000001" => encoded <= x"0";
            when "0000000010" => encoded <= x"1";
            when "0000000100" => encoded <= x"2";
            when "0000001000" => encoded <= x"3";
            when "0000010000" => encoded <= x"4";
            when "0000100000" => encoded <= x"5";
            when "0001000000" => encoded <= x"6";
            when "0010000000" => encoded <= x"7";
            when "0100000000" => encoded <= x"8";
            when "1000000000" => encoded <= x"9";
            when others       => encoded <= "1111";
        end case;
    end process;

    ----------------------------------------------------------------------
    -- Code Storage & Digit Counting
    ----------------------------------------------------------------------
    code_storage: process(Clk, Rst)
    begin
        if Rst = '1' then
            entered_code  <= (others => '0');
            new_code      <= (others => '0');
            digit_count   <= 0;
            enable        <= '0';
            reset_attempt <= '0';
            change_mode   <= '0';

        elsif rising_edge(Clk) then
            if system_fail = '0' then
                if reset_attempt = '1'or reset_pass='1' then
                    entered_code  <= (others => '0');
                    new_code      <= (others => '0');
                    digit_count   <= 0;
                    enable        <= '0';
                    reset_attempt <= '0';
                    

                 elsif digit_count < 4 then

                    if encoded /= "1111" then
                    
                        if change_mode = '1' or change_pass='1' then
                              change_mode <= '1';
                              new_code <= new_code(11 downto 0) & encoded;
                        else
                            entered_code <= entered_code(11 downto 0) & encoded;
                        end if;
                        
                        digit_count <= digit_count + 1;
                    end if;

                elsif digit_count = 4 then
                    enable <= '1';

                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Password Comparator & Fail Counter
    ----------------------------------------------------------------------
comparator: process(Clk, Rst)
begin
    if Rst = '1' then
        match         <= '0';
        fail_count    <= 0;
        system_fail   <= '0';

    elsif rising_edge(Clk) then
        if enable = '1' and system_fail = '0' then

            if change_mode = '1' then
                stored_code <= new_code;
                reset_attempt <= '1'; 

            elsif entered_code = stored_code then
                match <= '1';
                fail_count <= 0;
                reset_attempt <= '1'; 

            else
                match <= '0';
                if fail_count < 3 then
                    fail_count <= fail_count + 1;
                else
                    system_fail <= '1';
                end if;
                reset_attempt <= '1';  
            end if;

        else
            match <= '0';
        end if;
    end if;
end process;


    ----------------------------------------------------------------------
    -- Output Logic
    ----------------------------------------------------------------------
process(Clk, Rst)
begin
    if Rst = '1' then
        Lock <= '0';
        Status <= '0';
        Failure <= '0';


    elsif rising_edge(Clk) then
        if system_fail = '1' then
            Lock <= '0';
            Status <= '0';
            Failure <= '1';


        else
            Failure <= '0';

            if match = '1' then
                Lock <= '1';
                Status <= '1';
                reset_attempt <= '1';

            end if;

            

        end if;
    end if;
end process;


end Behavioral;
