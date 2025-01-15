`timescale 1ns / 1ps

module FSM_TB;

// Testbench signals
reg clock;
reg reset;
reg pedestrian_button;
reg high_traffic_sensor;
wire [1:0] LT1, LT2, LT3;

// Instantiate the traffic control module
FSM uut (
    .LT1(LT1),
    .LT2(LT2),
    .LT3(LT3),
    .pedestrian_button(pedestrian_button),
    .high_traffic_sensor(high_traffic_sensor),
    .clock(clock),
    .reset(reset)
);

// Clock generation
initial begin
    clock = 0;
    forever #2 clock = ~clock; // 10 ns clock period
end

// Test procedure
initial begin
    // Initialize inputs
    reset = 1;
    pedestrian_button = 0;
    high_traffic_sensor = 0;
    
    // Release reset after a short delay
    #8 reset = 0;
    
    // #20 high_traffic_sensor = 1;
    
    // Test Normal Operation Flow
    #760;  // Let the system run for a bit to observe initial state transitions

    // Test Pedestrian Button Press during S0
    pedestrian_button = 1; // Press button while in S0
    #30 pedestrian_button = 0; // Release button

    // Wait for the pedestrian sequence to complete
    #300;

    // Test High Traffic Sensor Activation in S4
    // #130 high_traffic_sensor = 1; // Activate high traffic sensor in S4
    // #20 high_traffic_sensor = 0; // Deactivate sensor

    // Wait for high traffic sequence to complete
    // #200;

    // Let the simulation run for a while to observe more transitions
    // #500;
    
    // Finish simulation
    $stop;
end

// Monitor signals to observe state changes
initial begin
    $monitor("Time: %0d | State - LT1: %b, LT2: %b, LT3: %b | Pedestrian: %b | High Traffic: %b",
             $time, LT1, LT2, LT3, pedestrian_button, high_traffic_sensor);
end

endmodule