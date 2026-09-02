module pe (
    input wire clk,
    input wire rst_n,       
    input wire en,           
    input wire clear_acc,  
    input wire [7:0] a,      
    input wire [7:0] b,      
    output reg [19:0] acc_out 
);

   
    wire [19:0] mult_result;
    wire rst = ~rst_n ; 
    assign mult_result = a * b;

   
    always @(posedge clk or posedge rst_n) begin
        if (rst) begin
            acc_out <= 20'd0;
        end
        else if (clear_acc) begin
            acc_out <= 20'd0;
        end
        else if (en) begin
            acc_out <= acc_out + mult_result;
        end
        else begin
            acc_out <= acc_out; 
        end
    end

endmodule
