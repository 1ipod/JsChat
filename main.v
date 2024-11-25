import veb
import time

pub fn (app &App) index(mut ctx Context) veb.Result {
    return $veb.html()
}

pub fn (app &App) recv(mut ctx Context) veb.Result {
	s := ctx.query["state"].i64()
	rlock app.state{ 
	if s < app.state.t.unix() {
		n := app.state.t.unix()
		t := app.state.txt
		j := app.state.js
		ts :=app.state.t.hhmm()
		return ctx.text(	'<div hx-get="/recv?&state=$n"hx-trigger="load delay:1s"hx-swap="outerHTML"></div><div>$ts: $t<script>$j</script></div>')
	}}
	return ctx.text('<div hx-get="/recv?&state=$s"hx-trigger="load delay:1s"hx-swap="outerHTML"></div>')
}

const lib  = veb.RawHtml('<script src="https://unpkg.com/htmx.org@2.0.3" integrity="sha384-0895/pl2MU10Hqc6jd4RvrthNlDiE9U1tWmX7WRESftEDRosgxNsQG/Ze9YMRzHq" crossorigin="anonymous"></script>')

pub struct Msg {
	txt string
	js string
	t time.Time
}

pub struct App {
	state shared Msg
}

struct Context {
	veb.Context
}

@[post]
pub fn (mut app App) send(mut ctx Context,js string, txt string) veb.Result {
	lock app.state{
		app.state = Msg{ctx.ip() + ": " + txt,js,time.now()}
	}
	return ctx.text('')
}

fn main() {
	println('veb example')
	// veb.run(&App{}, port)
	mut app := &App{}
	veb.run_at[App, Context](mut app, port: 8080, family: .ip, timeout_in_seconds: 2) or {
		panic(err)
	}
}