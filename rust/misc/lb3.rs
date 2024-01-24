use glib::clone;
use gtk::prelude::*;
use gtk::{glib, Application, Button, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.lb3";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(app: &Application) {
    let btn = Button::builder().label("Close").build();

    let win = Window::builder()
        .application(app)
        .title("lb3")
        .default_width(400)
        .default_height(300)
        .child(&btn)
        .build();

    btn.connect_clicked(clone!(@weak win => move |_| {
    win.destroy();
    }));

    win.present()
}
