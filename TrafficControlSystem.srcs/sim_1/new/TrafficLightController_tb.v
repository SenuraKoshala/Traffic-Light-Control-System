`timescale 1ns / 1ps

module TrafficLightController_tb();

    reg clock;
    reg reset;
    reg pedestrian_button;
    reg high_traffic_sensor;
    wire [1:0] LT1;
    wire [1:0] LT2;
    wire [1:0] LT3;

    // Instantiate the TrafficLightController module
    TrafficLightController uut (
        .clock(clock),
        .reset(reset),
        .pedestrian_button(pedestrian_button),
        .high_traffic_sensor(high_traffic_sensor),
        .LT1(LT1),
        .LT2(LT2),
        .LT3(LT3)
    );


    initial begin
        clock = 0;
        forever #2 clock = ~clock; 
    end

    // Test scenario
    initial begin
        reset = 1;
        pedestrian_button = 0;
        high_traffic_sensor = 0;

    
        #10 reset = 0;

   
        #540;

        // Test pedestrian button activation
        #30 pedestrian_button = 1;
        #20 pedestrian_button = 0;

        // Wait to observe pedestrian crossing response
        #150;

        // Test high traffic sensor activation
        // #30 high_traffic_sensor = 1;
        // #20 high_traffic_sensor = 0;

        #150;

        // Reset the system and observe
        #20 reset = 1;
        #20 reset = 0;

        // End simulation
        #200 $finish;
    end

    // Monitor changes in outputs
    initial begin
        $monitor("Time=%0t | Reset=%b | Pedestrian Button=%b | High Traffic Sensor=%b | LT1=%b | LT2=%b | LT3=%b | State=%d",
                  $time, reset, pedestrian_button, high_traffic_sensor, LT1, LT2, LT3, uut.fsm_inst.current_state);
    end

endmodule
