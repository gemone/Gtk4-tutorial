use gtk::prelude::*;
use gtk::{glib, Application, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.pr3";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(app: &Application) {
    let win = Window::builder().application(app).build();

    win.present()
}
