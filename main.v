import gg
import gx
import time
import os

const (
	canvas_size  = 700
	tick_rate_ms = 100
	margin = 20
	scale = canvas_size - 2*margin
)


struct RangeStruct{
	mut:
	min_x f32 = 500
	max_x f32 = -500
	min_y f32 = 500
	max_y f32 = -500
	dif_x f32
	dif_y f32
}

fn convert(rg RangeStruct,node Node,is_y bool) int{
	mut rt := 5 // return value
	mut dif := 0.000 // will store range difference used by scaling
	// scale by the biggest range difference
	if rg.dif_x >= rg.dif_y {dif = rg.dif_x}else { dif = rg.dif_y}

	if !is_y{
		rt = int(scale * ((node.x-rg.min_x)/dif))
	}
	else {
		rt = int(scale * ((node.y-rg.min_y)/dif))
	}

	return rt
}

struct Node {
	name int
	x f32
	y f32
}

struct Edge {
	name string
	first int
	last  int
	len   f32
}

struct Graph {
mut:
	nodes []Node
	edges []Edge
}

struct App {
mut:
	gg         &gg.Context
	start_time i64
	last_tick  i64
	gph        Graph
	range			 RangeStruct
	flip int 
}



fn on_frame(mut app App) {
	app.gg.begin()

	now := time.ticks()

	if now - app.last_tick >= tick_rate_ms {
		app.last_tick = now
	}

	txt_size := gx.TextCfg{size: 16 }
	app.gg.draw_rect_empty(margin,canvas_size-margin-scale,scale,scale,gx.red)
	mut count := 0
	for node in app.gph.nodes {
		//if count > 5000 {break}
		count++
		if count % 2 == app.flip {
			app.gg.draw_pixel(
				margin + (convert(app.range,node,true)),
				canvas_size - margin - (convert(app.range,node,false)), 
				gx.blue
		)}
	}
	for edge in app.gph.edges{
		count++
		if count % 8 == app.flip {
			app.gg.draw_line(
				margin + (convert(app.range,app.gph.nodes[edge.first],true)),
				canvas_size - margin - (convert(app.range,app.gph.nodes[edge.first],false)),
				margin + (convert(app.range,app.gph.nodes[edge.last],true)),
				canvas_size - margin - (convert(app.range,app.gph.nodes[edge.last],false)),
				gx.purple
			)
		}
	}
			app.gg.draw_text(50,0,count.str(),txt_size)
	if app.flip == 0 {app.flip = 1}
	else {app.flip=0}
	app.gg.end()
}

fn main() {
		mut font_path := "C:\\Users\\morge\\AppData\\Local\\Microsoft\\Windows\\Fonts\\IBMPlexMono-Regular.ttf"

	mut app := App{
		gg: 0
		gph: Graph{[]Node{}, []Edge{}}
	}

	
	file := os.read_lines('monroe.txt') or { panic(err) }

	for line in file {
		split := line.split('\t') 
		if split[0]=='i' {
			name := split[1].trim_left('i').int()
			app.gph.nodes << Node{name,split[2].f32(),split[3].f32()}
			if app.range.min_x > split[2].f32() {app.range.min_x = split[2].f32()}
			if app.range.min_y > split[3].f32() {app.range.min_y = split[3].f32()}
			if app.range.max_x < split[2].f32() {app.range.max_x = split[2].f32()}
			if app.range.max_y < split[3].f32() {app.range.max_y = split[3].f32()}
		}
		else {
			name := split[1].trim_left('r')
			app.gph.edges << Edge{name,split[2].trim_left('i').int(),split[3].trim_left('i').int(),-1.0}
		}
	}


	app.range.dif_x = app.range.max_x - app.range.min_x
	app.range.dif_y = app.range.max_y - app.range.min_y

	app.gg = gg.new_context(
		bg_color: gx.white
		frame_fn: on_frame
		user_data: &app
		width: canvas_size
		height: canvas_size
		create_window: true
		resizable: false
		font_path: font_path
		window_title: 'graph'
	)

	app.gg.run()
}
