//generic ripple carry adder
//Use singel-adder as a module and use the module K times
//date: 0413
module singel_adder (
    input a, b, cin,
    output sum, cout
);
    assign sum = a^b^cin;
    assign cout = (a&b)|(a&cin)|(b&cin);
endmodule

module full_adder #(
    K = 8
) (
    input [K-1:0] a,
    input [K-1:0] b,
    output [K-1:0] sum,
    output overflow
);

    wire [K:0] cin; //extra cin[K] to avoid exceed boundary
    wire [K-1:0] cout;

    genvar i;

    assign cin[0] = 0;
    for (i=0; i<=K-1; i=i+1) begin
        singel_adder sgl_adder (
            .a(a[i]),
            .b(b[i]),
            .cin(cin[i]),
            .sum(sum[i]),
            .cout(cout[i])
        )
        assign cin[i+1] = cout[i]; //here need an extra cin[K]
    end
    assign overflow = cout[K-1];
    
endmodule


/*
module full_add(
  input [7:0] a,
  input [7:0] b,
  output [7:0] sum,
  output overflow);
  
  wire [7:0] cin;
  wire [7:0] cout;

  genvar i;

  assign cin[0] = 0;
  for (i=0; i<=7; i=i+1) begin
      assign {cout[i], sum[i]} = a[i] + b[i] + cin[i];   
      assign cin[i+1] = cout[i]; 
    end
  assign overflow = cout[7];
endmodule
*/