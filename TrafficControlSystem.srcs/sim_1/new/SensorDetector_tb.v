`timescale 1ns / 1ps

module SensorDetector_tb();

// Inputs
reg clock;
reg reset;
reg S_IN;
reg [3:0] FSM_STATE;

// Outputs
wire sensor_request;

// Instantiate the SensorDetector module
SensorDetector uut (
    .clock(clock),
    .reset(reset),
    .S_IN(S_IN),
    .FSM_STATE(FSM_STATE),
    .sensor_request(sensor_request)
);

// Clock generation (50 MHz)
initial begin
    clock = 0;
    forever #5 clock = ~clock; // 10ns period -> 50 MHz
end

// Test sequence
initial begin
    reset = 1;
    S_IN = 0;
    FSM_STATE = 4'd0;

    // Apply reset
    #20;
    reset = 0;

    // Test Case 1: No sensor activation, FSM in S0
    FSM_STATE = 4'd0; 
    S_IN = 0;        
    #310;             

    // Check sensor_request
    if (sensor_request == 1) 
        $display("Test Case 1 FAILED: sensor_request should not be set without sensor activation.");
    else 
        $display("Test Case 1 PASSED.");

    // Test Case 2: Sensor activation within S4, timeout reached
    FSM_STATE = 4'd4; 
    S_IN = 1;         
    #10;
    S_IN = 0;         
    #300;             // Wait 30 more clock cycles (timeout)

    // Check sensor_request
    if (sensor_request == 1) 
        $display("Test Case 2 PASSED.");
    else 
        $display("Test Case 2 FAILED: sensor_request should be set after sensor activation and timeout.");

    // Reset sensor_request and latch after timeout
    #20;
    FSM_STATE = 4'd1; 
    #10;
    FSM_STATE = 4'd4; 

    // Test Case 3: Multiple sensor activations before timeout
    S_IN = 1;
    #10;
    S_IN = 0;
    #100;
    S_IN = 1;
    #10;
    S_IN = 0;
    #200;

    if (sensor_request == 1) 
        $display("Test Case 3 PASSED.");
    else 
        $display("Test Case 3 FAILED: sensor_request should be set after multiple sensor activations and timeout.");

    // Test Case 4: Reset during S4
    reset = 1;
    #20;
    reset = 0;
    FSM_STATE = 4'd4;
    #300;

    if (sensor_request == 0) 
        $display("Test Case 4 PASSED.");
    else 
        $display("Test Case 4 FAILED: sensor_request should be reset after system reset.");

    // Finish simulation
    #20;
    $finish;
end

endmodule
