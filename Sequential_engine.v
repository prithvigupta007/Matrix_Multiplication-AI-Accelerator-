`timescale 1ns / 1ps

module matmul_seq #(
    parameter N  = 4,
    parameter DW = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire start,

    output reg done,

    input  wire [N*N*DW-1:0] A_flat,
    input  wire [N*N*DW-1:0] B_flat,

    output reg [N*N*20-1:0] C_flat
);

  
    // Loop counters
    // i -> row of C
    // j -> column of C
    // k -> multiplication index

    reg [$clog2(N)-1:0] i, j, k;

   
    // FSM states
 
    localparam IDLE    = 3'd0,
               INIT    = 3'd1,
               LOAD    = 3'd2,
               COMPUTE = 3'd3,
               STORE   = 3'd4,
               NEXT    = 3'd5,
               DONE    = 3'd6;

    reg [2:0] state;

   
    // PE control

    reg en;
    reg clear_acc;

    wire [19:0] acc;

   
    // Select required A and B elements
    // A[i][k]
    // B[k][j]
   
    wire [DW-1:0] a_data;
    wire [DW-1:0] b_data;

    assign a_data = A_flat[(i*N + k)*DW +: DW];
    assign b_data = B_flat[(k*N + j)*DW +: DW];

  
    // PE
   
    pe #(DW) pe_inst (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .clear_acc(clear_acc),
        .a(a_data),
        .b(b_data),
        .acc_out(acc)
    );

 
    // FSM
    wire rst = ~rst_n ; 
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            state     <= IDLE;
            done      <= 1'b0;
            en        <= 1'b0;
            clear_acc <= 1'b0;

            i <= 0;
            j <= 0;
            k <= 0;

            C_flat <= 0;
        end

        else begin

            case (state)

              
                // Wait for start
                
                IDLE: begin
                    done <= 1'b0;

                    if (start)
                        state <= INIT;
                end

              
                // Initialize matrix multiplication
             
                INIT: begin
                    i <= 0;
                    j <= 0;
                    k <= 0;

                    clear_acc <= 1'b1;
                    en        <= 1'b0;

                    state <= LOAD;
                end

          
                // Present A[i][k] and B[k][j]
                // to the PE
              
                LOAD: begin
                    clear_acc <= 1'b0;
                    en        <= 1'b1;

                    state <= COMPUTE;
                end

            
                // PE performs:
                
                // acc = acc + A[i][k] * B[k][j]
               
                COMPUTE: begin

                    en <= 1'b0;

                    if (k < N-1) begin
                        k <= k + 1;
                        state <= LOAD;
                    end

                    else begin
                        state <= STORE;
                    end

                end

                // ----------------------------------------
                // Store calculated C[i][j]
                // ----------------------------------------
                STORE: begin

                    C_flat[(i*N + j)*20 +: 20] <= acc;

                    state <= NEXT;

                end

              
                // Move to next C element
            
                NEXT: begin

                    k         <= 0;
                    clear_acc <= 1'b1;

                    if (j < N-1) begin

                        j <= j + 1;
                        state <= LOAD;

                    end

                    else if (i < N-1) begin

                        i <= i + 1;
                        j <= 0;
                        state <= LOAD;

                    end

                    else begin

                        state <= DONE;

                    end

                end

            
                // Entire multiplication finished
              
                DONE: begin

                    done  <= 1'b1;
                    state <= IDLE;

                end

            endcase
        end
    end

endmodule
