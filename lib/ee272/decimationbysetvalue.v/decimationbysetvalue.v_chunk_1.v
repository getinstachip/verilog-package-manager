nter <= counter + 'd1;
            end
        end
    end
    
    assign data_o  = data_i;
    assign valid_o = (en_i & valid_i & (counter == 'd0));
  
    // No sim dump, can follow up with waveform through gtkwave or yosys

endmodule
