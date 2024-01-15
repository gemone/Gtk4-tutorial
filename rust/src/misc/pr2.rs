use gtk::prelude::*;
use gtk::{glib, Application};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.pr2";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(_app: &Application) {
    println!("GtkApplication is activated.");
}
