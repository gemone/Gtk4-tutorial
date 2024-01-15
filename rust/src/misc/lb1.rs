use gtk::prelude::*;
use gtk::{glib, Application, Label, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.lb1";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(app: &Application) {
    let lab = Label::builder().label("Hello.").build();

    let win = Window::builder()
        .application(app)
        .title("lb1")
        .default_width(400)
        .default_height(300)
        .child(&lab)
        .build();

    win.present()
}
