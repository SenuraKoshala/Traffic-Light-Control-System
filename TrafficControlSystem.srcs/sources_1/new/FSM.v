`timescale 1ns / 1ps


`define TRUE      1'b1
`define FALSE     1'b0

// Define Lights
`define RED       2'd0
`define YELLOW    2'd1
`define GREEN     2'd2

// Define States
`define S0       4'd0  // LT1: Green, LT2: Red, LT3: Red
`define S1       4'd1  // LT1: Yellow, LT2: Red, LT3: Red
`define S2       4'd2  // LT1: Red, LT2: Red, LT3: Green
`define S3       4'd3  // LT1: Red, LT2: Green, LT3: Red
`define S4       4'd4  // LT1: Red, LT2: Green, LT3: Red
`define S5       4'd5  // LT1: Red, LT2: Yellow, LT3: Red
`define S6       4'd6  // Return to S0

// Pedestrian Cross Mode
`define S1_PRIME 4'd7  // LT1: Yellow, LT2: Red, LT3: Red (Pedestrian)
`define S2_PRIME 4'd8  // LT1: Red, LT2: Red, LT3: Green (Pedestrian)

// High Traffic Mode
`define S5_PRIME 4'd9  // LT1: Red, LT2: Yellow, LT3: Red
`define S6_PRIME 4'd10 // LT1: Green, LT2: Red, LT3: Red
`define S7_PRIME 4'd11 // LT1: Yellow, LT2: Red, LT3: Red

module FSM (
    output reg [3:0] current_state,
    output reg [1:0] LT1, LT2, LT3,
    input pedestrian_button,
    input high_traffic_sensor,
    input clock,
    input reset
);

// State variables
reg [3:0] state;
reg [3:0] next_state;

// Timing constants
integer timer;
reg reset_timer;

// Initialize the state
initial begin
    state = `S0;
    next_state = `S0;
    LT1 = `GREEN;
    LT2 = `RED;
    LT3 = `RED;
    current_state = `S0;
    timer = 0;
end

// State transitions on clock edge
always @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= `S0;
        timer <= 0;
    end 
    else begin
        state <= next_state;
        if (reset_timer) 
            timer <= 0;
        else 
            timer <= timer + 1;
    end
end

// Define state behavior and transitions
always @* begin
    current_state = state;
    next_state = state;
    reset_timer = 0;
    
    case (state)
        `S0: begin
            LT1 = `GREEN; LT2 = `RED; LT3 = `RED;
            if (pedestrian_button && timer == 30) begin
                next_state = `S1_PRIME;
                reset_timer = 1;
            end
            else if (timer == 30) begin
                next_state = `S1;
                reset_timer = 1;
            end
        end
        
        `S1: begin
            LT1 = `GREEN; LT2 = `RED; LT3 = `RED;
            if (timer == 20) begin
                next_state = `S2;
                reset_timer = 1;
            end
        end

        `S2: begin     
            LT1 = `YELLOW; LT2 = `RED; LT3 = `RED;
            if (timer == 10) begin
                next_state = `S3;
                reset_timer = 1;
            end
        end

        `S3: begin
            LT1 = `RED; LT2 = `RED; LT3 = `GREEN;
            if (timer == 15) begin
                next_state = `S4;
                reset_timer = 1;
            end
        end

        `S4: begin
            LT1 = `RED; LT2 = `GREEN; LT3 = `RED;
            if (high_traffic_sensor && timer == 30) begin
                next_state = `S5_PRIME;
                reset_timer = 1;
            end
            else if (timer == 30 ) begin
                next_state = `S5;
                reset_timer = 1;
            end
        end
        `S5: begin
            LT1 = `RED; LT2 = `GREEN; LT3 = `RED;
            if (timer == 20) begin
                next_state = `S6;
                reset_timer = 1;
            end
        end
        `S6: begin
            LT1 = `RED; LT2 = `YELLOW; LT3 = `RED;
            if (timer == 10) begin
                next_state = `S0;
                reset_timer = 1;
            end
            
        end

        // Pedestrian Mode
        `S1_PRIME: begin
            LT1 = `YELLOW; LT2 = `RED; LT3 = `RED;
            if (timer == 10) begin
                next_state = `S2_PRIME;
                reset_timer = 1;
            end
        end

        `S2_PRIME: begin
            LT1 = `RED; LT2 = `RED; LT3 = `GREEN;
            if (timer == 15) begin
                next_state = `S1;
                reset_timer = 1;
            end
        end

        // High Traffic Mode
        `S5_PRIME: begin
            LT1 = `RED; LT2 = `YELLOW; LT3 = `RED;
            if (timer == 10) begin
                next_state = `S6_PRIME;
                reset_timer = 1;
            end
        end

        `S6_PRIME: begin
            LT1 = `GREEN; LT2 = `RED; LT3 = `RED;
            if (timer == 20) begin
                next_state = `S7_PRIME;
                reset_timer = 1;
            end
        end

        `S7_PRIME: begin
            LT1 = `YELLOW; LT2 = `RED; LT3 = `RED;
            if (timer == 10) begin
                next_state = `S5;
                reset_timer = 1;
            end
        end

        default: begin
                next_state = `S0;
                reset_timer = 1;
            end
    endcase
end

endmodule