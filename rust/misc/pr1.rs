use gtk::prelude::*;
use gtk::{glib, Application};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.pr1";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.run()
}
