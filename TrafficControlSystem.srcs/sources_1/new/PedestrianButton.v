`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2024 05:09:02 PM
// Design Name: 
// Module Name: PedestrianLatch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PedestrianButton (
    input clock,
    input reset,
    input B_IN, 
    input [3:0] FSM_STATE, 
    output reg pedestrian_request 
);

// Constants
parameter TIMEOUT = 30; // Time threshold in seconds
parameter S0 = 4'd0;    // S0 state code

// Internal signals
reg [5:0] timer;       // 6-bit timer to count up to 30
reg latched;           // Holds the button press

// Initialization
initial begin
    timer = 0;
    latched = 0;
    pedestrian_request = 0;
end

// Timer and Latching Logic
always @(posedge clock or posedge reset) begin
    if (reset) begin
        timer <= 0;
        latched <= 0;
        pedestrian_request <= 0;
    end
    else if (FSM_STATE == S0) begin
        // Start counting as soon as FSM enters S0
        if (timer < TIMEOUT) begin
            timer <= timer + 1;
        end

        // Latch the button press if it's pressed at any point during S0
        if (B_IN) begin
            latched <= 1;
        end

        // Check if 30 seconds have passed and button was pressed
        if (timer == TIMEOUT && latched) begin
            pedestrian_request <= 1; // Signal to FSM
            
            // Reset timer and latch for the next cycle
            timer <= 0;
            latched <= 0;
        end
    end
    else begin
        // Reset everything when not in S0
        timer <= 0;
        latched <= 0;
        pedestrian_request <= 0;
    end
end

endmodule

