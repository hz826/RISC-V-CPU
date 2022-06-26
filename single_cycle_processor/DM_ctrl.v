`include "ctrl_encode_def.v"

module DM_ctrl(
    output reg [31:0] dm_Data_out,
    input      [31:0] raw_Data_out,
    input      [31:0] dm_Data_in,
    output reg [31:0] real_Data_in,

    input             mem_w,
    input      [2:0]  DMType,
    input      [1:0]  pos,
    output reg [3:0]  wea
);

    reg [3:0]  wea_tmp;
    reg [31:0] dtmp;

    always @(*) begin
        if (mem_w) begin
            case (DMType)
                `dm_word: begin
                    wea_tmp <= 4'b1111;
                end
                
                `dm_halfword: begin
                    wea_tmp <= 4'b0011;
                end

                `dm_byte: begin
                    wea_tmp <= 4'b0001;
                end

                default wea_tmp <= 4'b0000;
            endcase
        end
        else begin  
            wea_tmp <= 4'b0000;
        end
    end

    always @(*) begin
        wea <= wea_tmp;
        dm_Data_out <= raw_Data_out;
        dtmp <= dm_Data_in;
        /*
        case (pos)
            2'b00 : begin
                wea <= {wea_tmp[3:0]};
                dm_Data_out <= {raw_Data_out[31:0]};
                dtmp <= {dm_Data_in[31:0]};
            end

            2'b01 : begin
                wea <= {wea_tmp[2:0],1'b0};
                dm_Data_out <= {raw_Data_out[23:0],8'b0};
                dtmp <= {8'b0,dm_Data_in[31:8]};
            end

            2'b10 : begin
                wea <= {wea_tmp[1:0],2'b0};
                dm_Data_out <= {raw_Data_out[15:0],16'b0};
                dtmp <= {16'b0,dm_Data_in[31:16]};
            end

            2'b11 : begin
                wea <= {wea_tmp[0:0],3'b0};
                dm_Data_out <= {raw_Data_out[7:0],24'b0};
                dtmp <= {24'b0,dm_Data_in[31:24]};
            end
        endcase
        */
    end

    always @(*) begin
        case (DMType)
            `dm_word: begin
                real_Data_in <= dtmp;
            end
            
            `dm_halfword: begin
                real_Data_in <= {{16{dtmp[15]}}, dtmp[15:0]};
            end

            `dm_byte: begin
                real_Data_in <= {{24{dtmp[7]}}, dtmp[7:0]};
            end

            `dm_halfword_unsigned: begin
                real_Data_in <= {16'b0, dtmp[15:0]};
            end

            `dm_byte_unsigned: begin
                real_Data_in <= {24'b0, dtmp[7:0]};
            end
            default real_Data_in <= 32'b0;
        endcase
    end
endmodule