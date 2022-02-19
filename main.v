
import gg
import gx
import time

const (
	canvas_size = 700
	tick_rate_ms = 100
)


struct Node{
	name int
	//x int
	//y int
}

struct Edge{
	first int
	last int
		len int
}

struct Graph{
	mut:
	nodes []Node
	edges []Edge

}
struct App {
mut:
	gg         &gg.Context
		start_time i64
	last_tick  i64
	gph Graph
}

fn on_frame(mut app App) {
	app.gg.begin()

	now := time.ticks()

	if now - app.last_tick >= tick_rate_ms {
		app.last_tick = now
	}

	for node in app.gph.nodes{
		app.gg.draw_circle_filled(50,500-(node.name*10 + 50),2, gx.black)
	}
	
	

	app.gg.end()
}


fn main(){
	
	//println(gph)
	mut app := App{
		gg: 0
		gph: Graph{[]Node{len:5,init:Node{it}},[]Edge{}}
	}

	for val in [[0,1],[0,2],[0,4],[3,4]] {
		app.gph.edges << Edge{val[0],val[1],-1}
	}
	app.gg = gg.new_context(
		bg_color: gx.white
		frame_fn: on_frame
		user_data: &app
		width: 500
		height: 500
		create_window: true
		resizable: false
		window_title: 'graph'
	)

	app.gg.run()

	
}