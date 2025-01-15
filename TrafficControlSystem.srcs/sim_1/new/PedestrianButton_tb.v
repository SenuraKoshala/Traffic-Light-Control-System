`timescale 1ns / 1ps

module PedestrianButton_tb();

// Inputs
reg clock;
reg reset;
reg B_IN;
reg [3:0] FSM_STATE;

// Outputs
wire pedestrian_request;

// Instantiate the PedestrianLatch module
PedestrianButton uut (
    .clock(clock),
    .reset(reset),
    .B_IN(B_IN),
    .FSM_STATE(FSM_STATE),
    .pedestrian_request(pedestrian_request)
);

// Clock generation (50 MHz)
initial begin
    clock = 0;
    forever #10 clock = ~clock; // 10ns period -> 50 MHz
end

// Test sequence
initial begin
    // Initialize Inputs
    reset = 1;
    B_IN = 0;
    FSM_STATE = 4'd0; // Initial state

    // Apply reset
    #20;
    reset = 0;

    // Test Case 1: No button press, FSM in S0
    FSM_STATE = 4'd0; // S0 state
    B_IN = 0;         // Button not pressed
    #310;             // Wait 31 clock cycles (31 * 10 ns)

    // Check pedestrian_request
    if (pedestrian_request == 1) 
        $display("Test Case 1 FAILED: pedestrian_request should not be set without button press.");
    else 
        $display("Test Case 1 PASSED.");

    // Test Case 2: Button press within S0, timeout reached
    FSM_STATE = 4'd0;
    B_IN = 1;         // Press button
    #10;
    B_IN = 0;         // Release button
    #300;             // Wait 30 more clock cycles (timeout)

    // Check pedestrian_request
    if (pedestrian_request == 1) 
        $display("Test Case 2 PASSED.");
    else 
        $display("Test Case 2 FAILED: pedestrian_request should be set after button press and timeout.");

    // Reset pedestrian_request and latch after timeout
    #20;
    FSM_STATE = 4'd1; // Change state
    #10;
    FSM_STATE = 4'd0; // Return to S0

    // Test Case 3: Button press multiple times before timeout
    B_IN = 1;
    #10;
    B_IN = 0;
    #100;
    B_IN = 1;
    #10;
    B_IN = 0;
    #200;

    if (pedestrian_request == 1) 
        $display("Test Case 3 PASSED.");
    else 
        $display("Test Case 3 FAILED: pedestrian_request should be set after multiple button presses and timeout.");

    // Test Case 4: Reset during S0
    reset = 1;
    #20;
    reset = 0;
    FSM_STATE = 4'd0;
    #300;

    if (pedestrian_request == 0) 
        $display("Test Case 4 PASSED.");
    else 
        $display("Test Case 4 FAILED: pedestrian_request should be reset after system reset.");

    // Finish simulation
    #20;
    $finish;
end

endmodule
