// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
// Modifications by [Badr Mesbahi], [2025]

`include "../top_pkg.sv"

package tlul_pkg;

  // this can be either PPC or BINTREE
  // there is no functional difference, but timing and area behavior is different
  // between the two instances. PPC can result in smaller implementations when timing
  // is not critical, whereas BINTREE is favorable when timing pressure is high (but this
  // may also result in a larger implementation). on FPGA targets, BINTREE is favorable
  // both in terms of area and timing.
  parameter ArbiterImpl = "PPC";

  typedef enum logic [2:0] {
    PutFullData    = 3'h 0,
    PutPartialData = 3'h 1,
    Get            = 3'h 4
  } tl_a_op_e;

  typedef enum logic [2:0] {
    AccessAck     = 3'h 0,
    AccessAckData = 3'h 1
  } tl_d_op_e;

  parameter int H2DCmdMaxWidth  = 57;
  parameter int H2DCmdIntgWidth = 7;
  parameter int H2DCmdFullWidth = H2DCmdMaxWidth + H2DCmdIntgWidth;
  parameter int D2HRspMaxWidth  = 57;
  parameter int D2HRspIntgWidth = 7;
  parameter int D2HRspFullWidth = D2HRspMaxWidth + D2HRspIntgWidth;
  parameter int DataMaxWidth    = 32;
  parameter int DataIntgWidth   = 7;
  parameter int DataFullWidth   = DataMaxWidth + DataIntgWidth;
  parameter int RsvdWidth       = top_pkg::TL_AUW - H2DCmdIntgWidth - DataIntgWidth;

  // Data that is returned upon an a TL-UL error belonging to an instruction fetch.
  // Note that this data will be returned with the correct bus integrity value.
  parameter logic [top_pkg::TL_DW-1:0] DataWhenInstrError = '0;
  // Data that is returned upon an a TL-UL error not belonging to an instruction fetch.
  // Note that this data will be returned with the correct bus integrity value.
  parameter logic [top_pkg::TL_DW-1:0] DataWhenError      = {top_pkg::TL_DW{1'b1}};

  typedef struct packed {
    logic [RsvdWidth-1:0]       rsvd;
    logic [3:0]                 instr_type;
  } tl_a_user_t;

  parameter tl_a_user_t TL_A_USER_DEFAULT = '{
    rsvd: '0,
    instr_type: '0
  };

  typedef struct packed {
    logic                         a_valid;
    tl_a_op_e                     a_opcode;
    logic                  [2:0]  a_param;
    logic  [top_pkg::TL_SZW-1:0]  a_size;
    logic  [top_pkg::TL_AIW-1:0]  a_source;
    logic   [top_pkg::TL_AW-1:0]  a_address;
    logic  [top_pkg::TL_DBW-1:0]  a_mask;
    logic   [top_pkg::TL_DW-1:0]  a_data;
    tl_a_user_t                   a_user;

    logic                         d_ready;
  } tl_h2d_t;

  // The choice of all 1's as the blanked value is deliberate.
  // It is assumed that most security features of the design are opt-in instead
  // of opt-out.
  // Given the opt-in nature, if a 0 were to propagate, the feature would be turned
  // off.  Whereas if a 1 were to propagate, it would either stay on or be turned on.
  // There is however no perfect value for this purpose.
  localparam logic [top_pkg::TL_DW-1:0] BlankedAData = {top_pkg::TL_DW{1'b1}};

  localparam tl_h2d_t TL_H2D_DEFAULT = '{
    d_ready:  1'b1,
    a_opcode: tl_a_op_e'('0),
    a_user:   TL_A_USER_DEFAULT,
    a_data:   BlankedAData,
    default:  '0
  };

  typedef struct packed {
    logic [D2HRspIntgWidth-1:0]    rsp_intg;
    logic [DataIntgWidth-1:0]      data_intg;
  } tl_d_user_t;

  parameter tl_d_user_t TL_D_USER_DEFAULT = '{
    rsp_intg: {D2HRspIntgWidth{1'b1}},
    data_intg: {DataIntgWidth{1'b1}}
  };

  typedef struct packed {
    logic                         d_valid;
    tl_d_op_e                     d_opcode;
    logic                  [2:0]  d_param;
    logic  [top_pkg::TL_SZW-1:0]  d_size;   // Bouncing back a_size
    logic  [top_pkg::TL_AIW-1:0]  d_source;
    logic  [top_pkg::TL_DIW-1:0]  d_sink;
    logic   [top_pkg::TL_DW-1:0]  d_data;
    tl_d_user_t                   d_user;
    logic                         d_error;

    logic                         a_ready;

  } tl_d2h_t;

  typedef struct packed {
    tl_d_op_e                     opcode;
    logic  [top_pkg::TL_SZW-1:0]  size;
    // Temporarily removed because source changes throughout the fabric
    // and thus cannot be used for end-to-end checking.
    // A different PR will propose a work-around (a hoaky one) to see if
    // it gets the job done.
    //logic  [top_pkg::TL_AIW-1:0]  source;
    logic                         error;
  } tl_d2h_rsp_intg_t;

  localparam tl_d2h_t TL_D2H_DEFAULT = '{
    a_ready:  1'b1,
    d_opcode: tl_d_op_e'('0),
    d_user:   TL_D_USER_DEFAULT,
    default:  '0
  };

endpackage