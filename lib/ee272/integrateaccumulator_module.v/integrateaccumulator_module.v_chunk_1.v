id_i);

    // Simulation Only Waveform Dump (.vcd export)
    `ifdef COCOTB_SIM
    `ifndef SCANNED
    `define SCANNED
    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars (0, integrator);
        #1;
    end
    `endif
    `endif

endmodule
