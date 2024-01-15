use gtk::prelude::*;
use gtk::{glib, Application, Button, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.lb2";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn click_cb(_btn: &Button) {
    println!("Clicked.");
}

fn app_activate(app: &Application) {
    let btn = Button::builder().label("Click me").build();
    btn.connect_clicked(click_cb);

    let win = Window::builder()
        .application(app)
        .title("lb1")
        .default_width(400)
        .default_height(300)
        .child(&btn)
        .build();

    win.present()
}
