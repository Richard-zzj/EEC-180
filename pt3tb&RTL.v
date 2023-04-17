/* 	- Your adder must have the ports a, b, s, cout
 	- Replace addn below with your generic adder module name
		This is called a text macro it can be used to change the name
		of instances, and many other things at compile time
*/
`define YOUR_DUT_NAME addn
/*
	- Set the name of your size parameter in your generic adder
*/
`define SIZE_PARAM_NAME N
/* 
	- The TB will simulate all adders of size 0-NUM_TINSTS
 	- In modelsim the adder of size i will be located in tb_addn/genblk[i]/uut
*/
`define NUM_TINSTS 15
/*
	- Number of random test vectors
	- TB will also check all 0's and all 1's for a and b
*/
`define NUM_TESTS 100

/*############# DON'T MODIFY BELOW CODE! #############*/

module tb_addn();

	// Number of test instances
	parameter NUM_TINSTS = `NUM_TINSTS;

	// Number of random tests
	parameter NUM_TESTS = `NUM_TESTS;

	// Inputs 
	//	Shared among all test instances
	reg [NUM_TINSTS-1:0] 
		a, b;

	// Outputs
	//	2xN matrix to hold all computed sums
	wire [NUM_TINSTS-1:0]
		s [NUM_TINSTS-1:0];
	// 1xN vector to hold all computed couts
	wire [NUM_TINSTS-1:0]
		cout;

	// Utilities for easier checking
	wire [NUM_TINSTS-1:0] 
		checks;
	reg [NUM_TINSTS-1:0] 
		error_flags;

	// Iterators and genvars
	integer j;
	genvar i;

	// Instantiate adders of all input sizes
	//	from 1 to NUM_TINSTS
	generate
		for(i = 1; i <= NUM_TINSTS; i = i + 1) begin
			// Generate all sized instances up to NUM_TINSTS
			`YOUR_DUT_NAME
			#(.`SIZE_PARAM_NAME(i))
			uut 
			(	
				// Each DUT takes only the input bits it needs
				//	all outputs are saved from all instances
				.a(a[i-1:0]), 
			  	.b(b[i-1:0]),
				.sum(s[i-1][i-1:0]),
				.carry(cout[i-1])
			);
			// Generate a 1-d vector of check bits
			assign checks[i-1]
				// Each DUT check only looks at the DUT's input bits 
				= {cout[i-1], s[i-1][i-1:0]} 
					=== ( a[i-1:0] + b[i-1:0] );
		end
	endgenerate

	// Task to make sure checks passed
	task check_insts ();
		begin
			for(j = 0; j<NUM_TINSTS; j = j + 1) begin
				if(checks[j] != 1'b1) begin
					$display("@ time %0t: Error on %d-bit adder!",
							 	$time, j+1);
					error_flags[j] = 1'b1;
				end 
			end
		end
	endtask

	// Test sequence: special cases, random stimulus, print summary
	initial begin
		error_flags = {NUM_TINSTS{1'b0}};
		// Test special case a='b000..., b='b000...
		a = {NUM_TINSTS{1'b0}}; 
		b = {NUM_TINSTS{1'b0}};
		#5;
		check_insts();
		// Test special case a='b111..., b='b111...
		a = {NUM_TINSTS{1'b1}};
		b = {NUM_TINSTS{1'b1}};
		#5;
		check_insts();
		// Run random test on all instances of the adder
		repeat(NUM_TESTS) begin
			// Unsigned random in the range of max DUT
			a = $urandom_range(0,(2**NUM_TINSTS)-1); 
			b = $urandom_range(0,(2**NUM_TINSTS)-1);
			#5;
			check_insts();
		end
		// Always put some time at the end of your stimulus so the
		//	waveforms are legible!
		#5;
		// If any error flags were thrown report failure
		for(j = 0; j<NUM_TINSTS; j = j + 1) begin
			if(error_flags[j] != 1'b0)
				$display("Error(s) detected for %0d-bit adder!", j+1);
		end
		// If no error flags were thrown report success
		if(&error_flags == 1'b0)
			$display("Success all adders of size 0 to %0d passed! :)", NUM_TINSTS);
		$stop;
	end

endmodule : tb_addn

//-----------------RTL--------------------
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
