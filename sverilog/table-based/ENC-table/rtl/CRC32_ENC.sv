// Copyright (c) 2024 Sungkyunkwan University
// All rights reserved
// Author: Yujin Lim <dbwls1229@g.skku.edu>


module CRC32_ENC
#(
    parameter   DATA_WIDTH              = 512,
    parameter   CRC_WIDTH               = 32
)
(
    input   wire                        clk,
    input   wire                        rst_n,

    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,

    output  logic                       valid_o,
    output  logic   [DATA_WIDTH-1:0]    data_o,
    output  logic   [CRC_WIDTH-1:0]     checksum_o
);

    logic           [CRC_WIDTH-1:0]     checksum,       checksum_n;

    localparam [DATA_WIDTH-1:0] CRC_COEFF_TABLE[CRC_WIDTH-1:0] = '{
        512'h1055_3F85_5589_D635_0FB4_6FD5_6857_8848_ED70_C739_591B_C3C0_1FFF_580D_701C_3CAB_55FC_3D59_C417_7F45_746E_544C_5DA6_CB3E_7C30_9F06_46F5_576F_78E6_40F6_8DFD_FEFF,
        512'h30FF_408F_FE9A_7A5F_10DC_B07F_B8F8_98D9_3791_494B_EB2C_4440_2001_E817_9024_45FD_FE04_47EA_4C39_81CF_9CB2_FCD4_E6EB_5D42_8451_A10A_CB1F_F9B1_892A_C11B_9606_0301,
        512'h61FE_811F_FD34_F4BE_21B9_60FF_71F1_31B2_6F22_9297_D658_8880_4003_D02F_2048_8BFB_FC08_8FD4_9873_039F_3965_F9A9_CDD6_BA85_08A3_4215_963F_F363_1255_8237_2C0C_0602,
        512'hD3A8_3DBA_AFE0_3F49_4CC6_AE2B_8BB5_EB2C_3335_E216_F5AA_D2C0_9FF8_F853_308D_2B5C_ADED_22F0_F4F1_787B_06A5_A71F_C60B_BE34_6D76_1B2D_6A8A_B1A9_5C4D_4498_D5E5_F2FB,
        512'hA750_7B75_5FC0_7E92_998D_5C57_176B_D658_666B_C42D_EB55_A581_3FF1_F0A6_611A_56B9_5BDA_45E1_E9E2_F0F6_0D4B_4E3F_8C17_7C68_DAEC_365A_D515_6352_B89A_8931_ABCB_E5F6,
        512'h5EF5_C96F_EA09_2B10_3CAE_D77B_4680_24F8_21A7_4F62_8FB0_88C2_601C_B941_B228_91D9_E248_B69A_17D2_9EA9_6EF8_C833_4588_33EF_C9E8_F3B3_ECDF_91CA_09D3_5295_DA6A_3513,
        512'hBDEB_92DF_D412_5620_795D_AEF6_8D00_49F0_434E_9EC5_1F61_1184_C039_7283_6451_23B3_C491_6D34_2FA5_3D52_DDF1_9066_8B10_67DF_93D1_E767_D9BF_2394_13A6_A52B_B4D4_6A26,
        512'h6B82_1A3A_FDAD_7A75_FD0F_3238_7257_1BA8_6BED_FAB3_67D9_E0C9_9F8D_BD0B_B8BE_7BCC_DCDE_E731_9B5D_05E0_CF8D_7481_4B86_0481_5B93_51C9_F58B_1047_5FAB_0AA1_E455_2AB3,
        512'hC751_0BF0_AED3_22DE_F5AA_0BA5_8CF9_BF18_3AAB_325F_96A8_0253_20E4_221A_0160_CB32_EC41_F33A_F2AD_7484_EB74_BD4E_CAAA_C23C_CB16_3C95_ADE3_77E1_C7B0_55B5_4557_AB99,
        512'h8EA2_17E1_5DA6_45BD_EB54_174B_19F3_7E30_7556_64BF_2D50_04A6_41C8_4434_02C1_9665_D883_E675_E55A_E909_D6E9_7A9D_9555_8479_962C_792B_5BC6_EFC3_8F60_AB6A_8AAF_5732,
        512'h1D44_2FC2_BB4C_8B7B_D6A8_2E96_33E6_FC60_EAAC_C97E_5AA0_094C_8390_8868_0583_2CCB_B107_CCEB_CAB5_D213_ADD2_F53B_2AAB_08F3_2C58_F256_B78D_DF87_1EC1_56D5_155E_AE64,
        512'h3A88_5F85_7699_16F7_AD50_5D2C_67CD_F8C1_D559_92FC_B540_1299_0721_10D0_0B06_5997_620F_99D7_956B_A427_5BA5_EA76_5556_11E6_58B1_E4AD_6F1B_BF0E_3D82_ADAA_2ABD_5CC8,
        512'h7510_BF0A_ED32_2DEF_5AA0_BA58_CF9B_F183_AAB3_25F9_6A80_2532_0E42_21A0_160C_B32E_C41F_33AF_2AD7_484E_B74B_D4EC_AAAC_23CC_B163_C95A_DE37_7E1C_7B05_5B54_557A_B990,
        512'hEA21_7E15_DA64_5BDE_B541_74B1_9F37_E307_5566_4BF2_D500_4A64_1C84_4340_2C19_665D_883E_675E_55AE_909D_6E97_A9D9_5558_4799_62C7_92B5_BC6E_FC38_F60A_B6A8_AAF5_7320,
        512'hC417_C3AE_E141_6188_6536_86B6_5638_4E46_47BC_50DC_F31B_5708_26F7_DE8D_282E_F010_4580_F3E5_6F4A_5E7F_A941_07FE_F716_440C_B9BF_BA6D_3E28_AF1E_94F3_2DA7_D817_18BF,
        512'h882F_875D_C282_C310_CA6D_0D6C_AC70_9C8C_8F78_A1B9_E636_AE10_4DEF_BD1A_505D_E020_8B01_E7CA_DE94_BCFF_5282_0FFD_EE2C_8819_737F_74DA_7C51_5E3D_29E6_5B4F_B02E_317E,
        512'h000A_313E_D08C_5014_9B6E_750C_30B6_B151_F381_844A_9576_9FE0_8420_2239_D0A7_FCEA_43FF_F2CC_793E_06BB_D16A_4BB7_81FF_DB0C_9ACE_76B2_BE57_EB15_2B2A_F669_EDA1_9C03,
        512'h0014_627D_A118_A029_36DC_EA18_616D_62A3_E703_0895_2AED_3FC1_0840_4473_A14F_F9D4_87FF_E598_F27C_0D77_A2D4_976F_03FF_B619_359C_ED65_7CAF_D62A_5655_ECD3_DB43_3806,
        512'h0028_C4FB_4231_4052_6DB9_D430_C2DA_C547_CE06_112A_55DA_7F82_1080_88E7_429F_F3A9_0FFF_CB31_E4F8_1AEF_45A9_2EDE_07FF_6C32_6B39_DACA_F95F_AC54_ACAB_D9A7_B686_700C,
        512'h0051_89F6_8462_80A4_DB73_A861_85B5_8A8F_9C0C_2254_ABB4_FF04_2101_11CE_853F_E752_1FFF_9663_C9F0_35DE_8B52_5DBC_0FFE_D864_D673_B595_F2BF_58A9_5957_B34F_6D0C_E018,
        512'h00A3_13ED_08C5_0149_B6E7_50C3_0B6B_151F_3818_44A9_5769_FE08_4202_239D_0A7F_CEA4_3FFF_2CC7_93E0_6BBD_16A4_BB78_1FFD_B0C9_ACE7_6B2B_E57E_B152_B2AF_669E_DA19_C030,
        512'h0146_27DA_118A_0293_6DCE_A186_16D6_2A3E_7030_8952_AED3_FC10_8404_473A_14FF_9D48_7FFE_598F_27C0_D77A_2D49_76F0_3FFB_6193_59CE_D657_CAFD_62A5_655E_CD3D_B433_8060,
        512'h12D9_7031_769D_D313_D429_2CD9_45FB_DC34_0D11_D59C_04BC_3BE1_17F7_D679_59E3_063B_AA00_8E47_8B96_D1B1_2EFC_B9AC_2250_0818_CFAD_33A9_D30F_9225_B25B_DA8D_E59A_FE3F,
        512'h25B2_E062_ED3B_A627_A852_59B2_8BF7_B868_1A23_AB38_0978_77C2_2FEF_ACF2_B3C6_0C77_5401_1C8F_172D_A362_5DF9_7358_44A0_1031_9F5A_6753_A61F_244B_64B7_B51B_CB35_FC7E,
        512'h5B30_FF40_8FFE_9A7A_5F10_DCB0_7FB8_F898_D937_9149_4BEB_2C44_4020_01E8_1790_2445_FDFE_0447_EA4C_3981_CF9C_B2FC_D4E6_EB5D_4284_51A1_0ACB_1FF9_B189_2AC1_1B96_0603,
        512'hB661_FE81_1FFD_34F4_BE21_B960_FF71_F131_B26F_2292_97D6_5888_8040_03D0_2F20_488B_FBFC_088F_D498_7303_9F39_65F9_A9CD_D6BA_8508_A342_1596_3FF3_6312_5582_372C_0C06,
        512'h6CC3_FD02_3FFA_69E9_7C43_72C1_FEE3_E263_64DE_4525_2FAC_B111_0080_07A0_5E40_9117_F7F8_111F_A930_E607_3E72_CBF3_539B_AD75_0A11_4684_2B2C_7FE6_C624_AB04_6E58_180C,
        512'hD987_FA04_7FF4_D3D2_F886_E583_FDC7_C4C6_C9BC_8A4A_5F59_6222_0100_0F40_BC81_222F_EFF0_223F_5261_CC0E_7CE5_97E6_A737_5AEA_1422_8D08_5658_FFCD_8C49_5608_DCB0_3018,
        512'hB30F_F408_FFE9_A7A5_F10D_CB07_FB8F_898D_9379_1494_BEB2_C444_0200_1E81_7902_445F_DFE0_447E_A4C3_981C_F9CB_2FCD_4E6E_B5D4_2845_1A10_ACB1_FF9B_1892_AC11_B960_6030,
        512'h661F_E811_FFD3_4F4B_E21B_960F_F71F_131B_26F2_2929_7D65_8888_0400_3D02_F204_88BF_BFC0_88FD_4987_3039_F396_5F9A_9CDD_6BA8_508A_3421_5963_FF36_3125_5823_72C0_C060,
        512'hCC3F_D023_FFA6_9E97_C437_2C1F_EE3E_2636_4DE4_5252_FACB_1110_0800_7A05_E409_117F_7F81_11FA_930E_6073_E72C_BF35_39BA_D750_A114_6842_B2C7_FE6C_624A_B046_E581_80C0,
        512'h882A_9FC2_AAC4_EB1A_87DA_37EA_B42B_C424_76B8_639C_AC8D_E1E0_0FFF_AC06_B80E_1E55_AAFE_1EAC_E20B_BFA2_BA37_2A26_2ED3_659F_3E18_4F83_237A_ABB7_BC73_207B_46FE_FF7F};

    always_comb begin
        checksum_n                      = {$bits(checksum_o){1'b0}};

        // Calculate over 32-bits of CRC checksum.
        for (int i = 0; i < CRC_WIDTH; i++) begin
            checksum_n[i]                   = ^(data_i & CRC_COEFF_TABLE[i]);
        end
    end 

    always_ff @(posedge clk)
        if (!rst_n) begin
            valid_o                         <= 1'b0;
            checksum                        <= {$bits(checksum_o){1'bx}};
        end
        else begin
            valid_o                         <= valid_i;
            checksum                        <= checksum_n;
        end

    assign  data_o                      = data_i;
    assign  checksum_o                  = checksum;

endmodule