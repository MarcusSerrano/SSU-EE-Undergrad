// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Sat Nov 22 22:18:26 2025
// Host        : DESKTOP-38G0AHI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ temp_lut_rom_sim_netlist.v
// Design      : temp_lut_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "temp_lut_rom,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [11:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [7:0]douta;

  wire [11:0]addra;
  wire clka;
  wire [7:0]douta;
  wire ena;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [7:0]NLW_U0_doutb_UNCONNECTED;
  wire [11:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "12" *) 
  (* C_ADDRB_WIDTH = "12" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.326399 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "temp_lut_rom.mem" *) 
  (* C_INIT_FILE_NAME = "temp_lut_rom.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "4096" *) 
  (* C_READ_DEPTH_B = "4096" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "8" *) 
  (* C_READ_WIDTH_B = "8" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "4096" *) 
  (* C_WRITE_DEPTH_B = "4096" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "8" *) 
  (* C_WRITE_WIDTH_B = "8" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_11 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[7:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[11:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[11:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[7:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
gydSV72FvW4hnoyUt6yZFJHfJqjRQWPUfYIuDKP0fpjrPOkLRbJGBr4Z9msYTvoIHRlYtXJ2YMY0
d1TIQb+FK4gKsTRru9wr397OxuFBsTRf4e+ZjpYZEdsnqYWcgMSzhN4yhPvO06GyZO15y/LKBxa8
3OKwxVlOLYXhv+sxdXg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WHB6Zbfa5Qi47krP9T4L8UnPOlr881dWx7UcYaZfNGIQQM0gadcoXbhucIpRaUuyOKxv6yhKveRN
h0l+N9+KX6rbZ6+TRhP9JAMuPhlpI7T42QtRv5zx9+m3ct5S0NMszbFaK8zeTAYra5BGP7BHmtkr
MpKfLK5sFyaTE/A7ACtAace9MwFTHDZdl9uUs4aY6KJlm6GaypKduiqkNugukJp5vlFPX/ZapJqG
KMtMhI6grhcuYb1FJrwRZ4jW7hs9HxddSdGLzsZ0HsBcO/qaCPTst+ZA0YIQfd5ULlFmPqq39FfO
p1P+2hEH2n+LycbMj5cn4Dxfqv2R8eucM78R3w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
SmAzQA1VEuJXtJi5vXa2Jg7YvRqAJs6PX9HTZ1YqrJw4VfonBW3726gJ81BjlizpMkcf/Uk5sFIK
aPedVhEs4xCIZylz7gXYDshtytOA/pXUID2qV9nXr8qfI+FydSADUF3ScYDZmlkclFqlZrGq6DQ7
da3lJAzt2h/iR+cczrA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
iAph5JWb/chMQpLPX1UoLjQDxN5l2I8McM/k2xN5wRht7HXoE6F5yV8luDjn3zkI6vnfUYo7BaI1
mogRRx+R3XcwxvhHr+lngh4+/YLVex1TFncl+kiUMAsu3M/FjFSiqGMVMdKTNLDqr35DuZJVyuiF
lTwXob/KkbQDJiJjBEoxbt+968rKRKRyJGcqIjm4mqRBdqMcgo3HOJFG74SFsWAQrxvXfBhdLSG3
OfoLfls9XDojBjp7G83k0h82g1eeWgBfydm/OcX9o48Pst93NvI4ua8WShZL8MCvRWYqWZrrjrWi
cfUjXAF5SDACjq1/OU6arz/Idz6/a7AP/jmexw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BY49GZBxBT/gjZDPyaSWlti/sctckoR7jK6NuWdhnF9tiyNfVU7BqjjwxSnyMi0Uucv1BKHXC18h
8hQbFWnNtrq71ilURotXux7sssHlVJ2i1CsJWU18DOcBWxm2ai89uwvxDJh3TJkBJixB5KPvsDhL
lWOjTvZWPoR+Ixy+Tzo+U5Vx7z7SOakRwTrn3u7+c3vmCEBphE+HKeJExhBAoOEd0SXK5iwXaByW
D7Wb7zq6NNUmnCyaJ2BG9kGxLVsf+md7SlocuaFsYyaRZhwPyTucxIlz1tLYwcytKzx0ovoax3no
nYgzlzP/F0/PDWk9BqXgr/tuclc4EZYX0cf4ng==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qGnCvL35qO7cbUEKCL50yDv1UvezcqBz601zctKop1954QlcjemzZWZHg1zJ00nJaToNdH2S8AKX
n8hNJvbQ+x5HEGL5DoSU9m5qjXd8xxocnZ0yzuZX/dGCT8kDn3gWJR2Gz13pT+w2LQUno1fX+MsC
ehgwvjBBT6GeYjdxHi+aybQUP9AblSxX/z3vh857SGCPohEWvghOgORCHAe45YD+ZWnL62FLxMM2
c+Ozq/Au/Q4q1Yzlzcfv8Mnsvg7OqOeEamQHbuYOfdkJUuYqOwsskEWW348u7FXtsf8m7P3pZyyz
IWyTDAW4igGguMPLHfbtK/twZx8ScJQmOKzglg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hz+6K8+wh5/fukU4ZWNDXGsq6hreSVCSPP67nA6kUz9Vpjy4TtTnOrrl1BWY0ivEC7Ldyw8VI60A
VO/WPlt409LdAZdMZGsEZ1JuTZ0m9LPcgu9CPCyoMECctmd8LHE+otY6etTmYABB9syY61rk2hrv
RgbcyT/HCK9TzWxSm+XMqvx2nvagCLkMDPh/JZv51fj2zcKaBPnxsz8rnDipaeo0fEyVRC3Y1F/V
U3RmXojBjIumPHSJkQ537dENJEIA0Ra65u8EM/+ItUn1bcryLcIbKy1xGadrHmHdHRUoRcAodO2C
B48bNVeL0VnGg8P9ACIB04lMNzn5p6A1tPOb4Q==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
YDpb+UeT0rJ543Q8wCo2xSS3gpVAT+JoStgBlV5IMjJoUOWkiOPn691FGChmDi3BTq5NxC73KHHR
1galACCjeTGq6cv+0Zc2Ocm1oobdrnSPHp7TMDr5Zle8FX6WywJCiGdoWBODggZSlbOASIK/PVfY
cZM2z60M6RSvzsi3TnYHiKYHpju8THVoSgRd6r31GcbiSy9TjjARERXan0OVc79jGuAg90mmDEEq
91eqmn6NZ9yLI2fgBjFUZbtFCpmJ8WGxOL1h39niWnRK3ZXnk8jcpnZUlxLbYTPO0Z3vVr1zrvcn
RVQloU0OLqg7M95zSs7NtX5Vzvb6jGbMehWV+WMMyxWmxL2XOwsAwPSeX2dI2r77pioY7X6VzH7f
/JxMAnq9udra3WGPsUkD1G0CvPkCC3zdxjpVaflY37ztX9UONhKtzMQa8lJc1IL8GhXRY3R9Lg2c
HIeXSGkpNNuFDqKT6Khe/6Casq+SjFJq+IH9IUtz6RUZTkbFb0Xhgm2P

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q+63zFEYw/LeMgxa7g8g79GGvSyIKDKD8RvvC4DHDQuGObf6n9OGZX4e17v/E/+EDEwUhsWQHFDI
Lp/aH+6fNRmhu9BEWVjxq2WRrQSl4eQjfIaSOXu2dlYh3JjRJwiUp4LteVh8RFAf5t5sRQO4dRIK
x+h28yliSgibaWEAv5FaJQ1EFbNwmgedAaSYjgf2A3afBUcBh5Uy9VHbW/zRzdhhJdsVNBjZYcFy
CVLOcf1toCRp8J4U5FlnFMOzFegUbdXFQhq2VmIhPRxWjrfTk6iR4BcMEN9UMij/5IHRAeBdksyD
CqEKsyFxosbI5KVMRZ1Ln75Zipn0JdsGekHkxg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DPUa5DLPYRWvbPnX0U412yoWvvvHyuq43DrYmDJGTK0cR5U4U6th8icYgizC1/hUAEzt19kM/hVa
zZh7bXSWACYLpcfhPY8dRTVGDZVjpbkraw0ceBryLP7jc6Jt5JdNw88tZtZpprCB7nQ25lUL82Hf
WTwL1ZqgGIvtfHhxO0JF5L5ES5giedwQ6u5ffXG3UB6ELcpQD1NvpW5lAz4mfXyvVDCAPZN581TF
tlAy79iKbPKlJ2zFn1BS2cuRIHHe2JRxwPo+0n5VD5CXVgg+lCYxTnCxI8CdyFaTumbs4IfAKwVI
wSN/btbwDUhW9hAHWHIRo+BpdJ4qeGcTDPKtsA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mf5hcf6JE6yLm0jNCQnHMVmogjLlPz6re0FwG67yvOJ3FuEorru0emIeAKEwgOoxjUYNWvcM7QAH
/UEeB2EIdjLl6glPAUda0HjtaCU2rdncVdM8k6DSMBggc4yo18Qx5F+1TD/RoBgoo0jNkMdDy6wJ
JHjqlN+R01z3yYIMQ9f2z6ZaYncbBYEp4+YAb7g1D7CSMxP5cFRpQznRpYp0JwqJfT9CHzlKgdab
8B288NxeLM66iYodiTS+GSRGLGtDWXpz9yeiuiPe6kJxae2GJyHIMSfluO/0Slc3m24DQNdbojf8
jdc0G2UnrDe5mCUTfYiDmpOWTUJOdYo0FK0N2g==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 25824)
`pragma protect data_block
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
z0CK
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
