// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Sat Nov 22 22:18:26 2025
// Host        : DESKTOP-38G0AHI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/Marcus/Documents/Vivado/ee410_XADC_Project/ee410_XADC_Project.gen/sources_1/ip/temp_lut_rom/temp_lut_rom_sim_netlist.v
// Design      : temp_lut_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "temp_lut_rom,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module temp_lut_rom
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
  temp_lut_rom_blk_mem_gen_v8_4_11 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 25792)
`pragma protect data_block
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
4QeA/AtBW9mKwGoZAVMTQSTOf/u+9ljC+e6nbg==
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
