module adler32(
    input clock,
    input rst_n,
    input size_valid,
    input [31:0] size,
    input data_start,
    input [7:0] data,
    output checksum_valid,
    output [31:0] checksum
);
    wire last;    //This will go high when the output can be valid
    reg sumValid;

    //Find way to clear accumlator
    adler32_acc acc1(
        .clk( clock ),
        .rst_n( rst_n ),
        .data ( data ),
        .checksum( checksum ),
        .checksum_valid( checksum_valid ),
        .data_start( data_start )
    );
    
    size_count cnt1(
        .rst_n( rst_n ),
        .clock ( clock ),
        .size_valid( size_valid ),
        .data_start( data_start ),
        .size ( size ),
        .last ( last )    
    );

  always @( posedge clock )begin
      sumValid <= last;
  end

  assign checksum_valid = sumValid;
endmodule

//This is my implementation of adler accuumulator. Data will be junk until valid is high
module adler32_acc(
    input clk,
    input rst_n,
    input [7:0] data,
    input checksum_valid,
    input data_start,
    output [31:0] checksum
);
    reg [16:0] A;
    reg [16:0] B;

    always @( posedge clk )begin
      if( !rst_n || checksum_valid || data_start ) begin
        A <= 16'h0001;
        B <= 16'h0000;
      end
      else begin
          A = A + data;
          if(A >= 16'hFFF1)
            A = A - 16'hFFF1;
          else begin
           A = A;
	end
          B = B + A;
          if(B >= 16'hFFF1)
             B = B - 16'hFFF1;
            else 
              B = B;
    end
  end
assign checksum = {B[15:0],A[15:0]};
endmodule



//This module does the actual counting down from x value
module size_count(
    input rst_n,
    input clock,
    input size_valid,
    input data_start,
    input [31:0] size,
    output  last
);

wire [31:0] v_size;
wire  valid;
reg [31:0] vr_size;
reg once;
wire done;

size_set U1(
    .rst_n( rst_n ),
    .clock( clock ),
    .size_valid( size_valid ),
    .size( size ),
    .v_size( v_size )
);

valid_set U2(
    .rst_n( rst_n ),
    .clock( clock ),
    .data_start( data_start ),
    .done ( done ),
    .valid( valid )
);

always @( posedge clock )begin
      if( !rst_n )begin
        once <= 0;
	vr_size <=0;
	end
      else begin
        if( valid )begin
          if(once==0)begin
            vr_size <= v_size-1;
            once <= 1;	
          end
          if( vr_size >= 1)
          vr_size <= vr_size - 1;
        end
        else begin
          vr_size <= vr_size;
	 once <= 0;
	end
      end
end

assign last = ( vr_size  ==  1 );
assign done = last;
endmodule


//This module sets the size of the value
module size_set(
    input rst_n,
    input clock,
    input size_valid,
    input [31:0] size,
    output reg [31:0] v_size
);

always @( posedge clock )begin
    if( !rst_n )
      v_size <= 0;
    else begin
      if( size_valid )
        v_size <= size;
      else
        v_size <= v_size;
    end
end
endmodule

//This is my implementation of project 2
module valid_set(
    input rst_n,
    input clock,
    input data_start,
    input done,
    output reg valid
);

always @( posedge clock )begin
    if( !rst_n )
      valid <= 0;
    else begin
      if( data_start )
        valid <= 1;
      else begin
      if( done )
	valid <=0;
      else
	valid <= valid;
	end
    end
end
endmodule
