module top
(
	input wire clk,
	input wire dir,
	inout wire req,
	output wire fin,
	inout wire [7:0] data
);

localparam RENDER_COUNT = 4;

reg req_last;

reg [7:0] waddr;
reg [7:0] raddr;

wire [7:0] command;

ram command_buffer(.wclk(clk), .rclk(clk), .waddr(waddr), .raddr(raddr), .data_in(data), .write_en(dir && req), .data_out(command));

wire [7:0] iters[RENDER_COUNT];

wire [7:0] x[RENDER_COUNT];
wire [7:0] y[RENDER_COUNT];

wire [RENDER_COUNT-1:0] renderer_done;
reg [RENDER_COUNT-1:0] renderer_done_r;

wire coords_fin;
reg coords_inc;

reg coords_inc_last;
reg [5:0] coords_fin_last;

genvar ri;
generate
	for (ri = 0; ri < RENDER_COUNT; ri = ri + 1) begin
		renderer r(.clk(clk), .rst(dir), .start(!dir && !coords_fin && !renderer_done[ri] && !renderer_done_r[ri]), .x(x[ri]), .y(y[ri]), .cx(15'h1000), .cy(15'h2000), .zoom(3'd6), .done(renderer_done[ri]), .iters(iters[ri])); 
	end
endgenerate

coords #(.POS_COUNT(RENDER_COUNT)) coords_inst(.clk(clk), .rst(dir), .inc(coords_inc), .x(x), .y(y), .finished(coords_fin));

wire fb_clk;
reg [16:0] fb_addr;
wire fb_we;

wire [15:0] fb_data_out;
reg [15:0] fb_data_out_last;

reg fb_half_out;

spram_big fb
(
	.clk(fb_clk),
	.we
	({
		{ fb_we, fb_we, fb_we, fb_we },
		{ fb_we, fb_we, fb_we, fb_we },
		{ fb_we, fb_we, fb_we, fb_we },
		{ fb_we, fb_we, fb_we, fb_we }
	}),
	.addr(fb_addr[15:0]),
	.data_in
	({
		{ 8'd128, iters[0] + 8'd16 },
		{ 8'd128, iters[1] + 8'd16 },
		{ 8'd128, iters[2] + 8'd16 },
		{ 8'd128, iters[3] + 8'd16 }
	}),
	.data_out(fb_data_out)
);

always_ff @(posedge clk) begin
	req_last <= req;
	coords_fin_last[5:1] <= coords_fin_last[4:0];
	coords_fin_last[0] <= coords_fin && !dir;
	coords_inc_last <= coords_inc && !dir;
	
	if (dir) begin
		renderer_done_r <= '0;
	end else begin
		integer i;
		for (i = 0; i < RENDER_COUNT; i = i + 1) begin
			if (renderer_done[i]) begin
				renderer_done_r[i] <= 1;
			end
		end
	
		if (renderer_done_r == '1) begin
			renderer_done_r <= '0;
			coords_inc <= 1;
		end else begin
			coords_inc <= 0;
		end
	end
	
	if (dir) begin
		raddr <= 0;
		fb_addr <= 0;
		fb_half_out <= 0;
		
		if (req && req_last) begin
			waddr <= waddr + 1;
		end else begin
			waddr <= 0;
		end
	end else if (coords_fin) begin
		if (!coords_fin_last[0] || !coords_fin_last[1]) begin
			fb_addr <= 0;
			fb_half_out <= 0;
		end else begin
			fb_half_out <= !fb_half_out;
			if (fb_half_out) begin
				fb_data_out_last <= fb_data_out;
				fb_addr <= fb_addr + 1;
			end
		end
	end else if (coords_inc_last) begin
		fb_addr <= fb_addr + RENDER_COUNT;
	end
end

assign fb_clk = clk;
assign fb_we = coords_inc && !coords_fin;
assign fin = !dir && coords_fin_last[5] && fb_addr >= 65536;

assign req = dir ? 'Z : coords_fin_last[5];
assign data = dir ? 'Z : (fb_half_out ? fb_data_out_last[15:8] : fb_data_out_last[7:0]);

endmodule