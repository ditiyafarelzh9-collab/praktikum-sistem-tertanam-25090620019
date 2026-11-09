library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_axi_lite_gpio is
end tb_axi_lite_gpio;

architecture sim of tb_axi_lite_gpio is
    constant CLK_PERIOD : time := 10 ns;
    signal aclk    : std_logic := '0';
    signal aresetn : std_logic := '0';
    signal awaddr  : std_logic_vector(3 downto 0)  := (others => '0');
    signal awvalid : std_logic := '0';
    signal awready : std_logic;
    signal wdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal wvalid  : std_logic := '0';
    signal wready  : std_logic;
    signal bresp   : std_logic_vector(1 downto 0);
    signal bvalid  : std_logic;
    signal bready  : std_logic := '0';
    signal araddr  : std_logic_vector(3 downto 0)  := (others => '0');
    signal arvalid : std_logic := '0';
    signal arready : std_logic;
    signal rdata   : std_logic_vector(31 downto 0);
    signal rresp   : std_logic_vector(1 downto 0);
    signal rvalid  : std_logic;
    signal rready  : std_logic := '0';
    signal gpio_out : std_logic_vector(15 downto 0);
    signal gpio_in  : std_logic_vector(15 downto 0) := (others => '0');
begin
    aclk <= not aclk after CLK_PERIOD / 2;

    dut : entity work.axi_lite_gpio_v1_0
        port map (
            S_AXI_ACLK    => aclk,
            S_AXI_ARESETN => aresetn,
            S_AXI_AWADDR  => awaddr,
            S_AXI_AWVALID => awvalid,
            S_AXI_AWREADY => awready,
            S_AXI_WDATA   => wdata,
            S_AXI_WVALID  => wvalid,
            S_AXI_WREADY  => wready,
            S_AXI_BRESP   => bresp,
            S_AXI_BVALID  => bvalid,
            S_AXI_BREADY  => bready,
            S_AXI_ARADDR  => araddr,
            S_AXI_ARVALID => arvalid,
            S_AXI_ARREADY => arready,
            S_AXI_RDATA   => rdata,
            S_AXI_RRESP   => rresp,
            S_AXI_RVALID  => rvalid,
            S_AXI_RREADY  => rready,
            gpio_out      => gpio_out,
            gpio_in       => gpio_in
        );

    stim : process
        variable rd : std_logic_vector(31 downto 0);
        procedure axi_write(addr : in std_logic_vector(3 downto 0);
                            data : in std_logic_vector(31 downto 0)) is
        begin
            wait until rising_edge(aclk);
            awaddr  <= addr;  awvalid <= '1';
            wdata   <= data;  wvalid  <= '1';
            wait until rising_edge(aclk) and awready = '1' and wready = '1';
            awvalid <= '0';  wvalid <= '0';
            bready  <= '1';
            wait until rising_edge(aclk) and bvalid = '1';
            bready  <= '0';
        end procedure;

        procedure axi_read(addr : in  std_logic_vector(3 downto 0);
                           data : out std_logic_vector(31 downto 0)) is
        begin
            wait until rising_edge(aclk);
            araddr  <= addr;  arvalid <= '1';
            wait until rising_edge(aclk) and arready = '1';
            arvalid <= '0';
            rready  <= '1';
            wait until rising_edge(aclk) and rvalid = '1';
            data    := rdata;
            rready  <= '0';
        end procedure;
    begin
        aresetn <= '0';
        wait for 5 * CLK_PERIOD;
        aresetn <= '1';
        wait for 2 * CLK_PERIOD;

        axi_write("0000", x"0000A5A5");
        wait for 2 * CLK_PERIOD;
        assert gpio_out = x"A5A5" report "TES 1 GAGAL" severity error;

        axi_read("0000", rd);
        assert rd = x"0000A5A5" report "TES 2 GAGAL" severity error;

        gpio_in <= x"1234";
        wait for 2 * CLK_PERIOD;
        axi_read("0100", rd);
        assert rd = x"00001234" report "TES 3 GAGAL" severity error;

        axi_write("0100", x"FFFFFFFF");
        axi_read("0100", rd);
        assert rd = x"00001234" report "TES 4 GAGAL" severity error;

        axi_write("1000", x"DEADBEEF");
        axi_write("1100", x"CAFEF00D");
        axi_read("1000", rd);
        assert rd = x"DEADBEEF" report "TES 5a GAGAL" severity error;
        axi_read("1100", rd);
        assert rd = x"CAFEF00D" report "TES 5b GAGAL" severity error;

        for i in 0 to 15 loop
            axi_write("0000", std_logic_vector(to_unsigned(2**i, 32)));
            wait for 3 * CLK_PERIOD;
        end loop;

        report "SIMULASI SELESAI" severity note;
        wait;
    end process;
end sim;
