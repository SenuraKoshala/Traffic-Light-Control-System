`timescale 1ns / 1ps

module TrafficLightController(
    input clock,
    input reset,
    input pedestrian_button,
    input high_traffic_sensor,
    output [1:0] LT1, // Traffic light 1 (e.g., main road)
    output [1:0] LT2, // Traffic light 2 (secondary road)
    output [1:0] LT3  // Traffic light 3 (e.g., pedestrian crossing)
);

    // Internal signals
    wire [3:0] current_state;
    wire pedestrian_request;
    wire sensor_request;

    // Instantiate FSM module
    FSM fsm_inst (
        .current_state(current_state),
        .LT1(LT1),
        .LT2(LT2),
        .LT3(LT3),
        .pedestrian_button(pedestrian_request),
        .high_traffic_sensor(sensor_request),
        .clock(clock),
        .reset(reset)
    );

    // Instantiate PedestrianButton module
    PedestrianButton pedestrian_button_inst (
        .clock(clock),
        .reset(reset),
        .B_IN(pedestrian_button),
        .FSM_STATE(current_state),
        .pedestrian_request(pedestrian_request)
    );

    // Instantiate SensorDetector module
    SensorDetector sensor_detector_inst (
        .clock(clock),
        .reset(reset),
        .S_IN(high_traffic_sensor),
        .FSM_STATE(current_state),
        .sensor_request(sensor_request)
    );

endmodule
