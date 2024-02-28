use gtk::prelude::*;
use gtk::{gio, glib, Application, ScrolledWindow, TextView, Window};

use gio::{Cancellable, File};
use glib::{error::Error, FileError};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.tfv3";

fn main() -> glib::ExitCode {
    let app = Application::builder()
        .application_id(APP_ID)
        .flags(gtk::gio::ApplicationFlags::HANDLES_OPEN)
        .build();

    app.connect_activate(app_activate);
    app.connect_open(app_open);
    app.run()
}

fn app_activate(_app: &Application) {
    println!("You need a filename argument.\n");
}

fn file_open(file: Option<&File>) -> Result<(String, String), Error> {
    if let Some(file) = file {
        let (contents, _) = file.load_contents(Cancellable::NONE)?;
        let basename = file
            .basename()
            .unwrap_or_default()
            .to_str()
            .unwrap_or_default()
            .to_string();

        match String::from_utf8(contents.to_vec()) {
            Ok(contents) => Ok((basename, contents)),
            Err(e) => Err(Error::new(
                FileError::Fault,
                &format!("load file contents fail, {e}"),
            )),
        }
    } else {
        Err(Error::new(FileError::Fault, "load file content fail"))
    }
}

fn app_open(app: &Application, files: &[File], _hint: &str) {
    let tv = TextView::new();
    let tb = tv.buffer();
    tv.set_wrap_mode(gtk::WrapMode::Char);
    tv.set_editable(false);

    let scr = ScrolledWindow::builder().child(&tv).build();

    let win = Window::builder()
        .application(app)
        .default_width(400)
        .default_height(300)
        .child(&scr)
        .build();

    match file_open(files.get(0)) {
        Ok((basename, contents)) => {
            win.set_title(Some(&basename));

            tb.set_text(&contents);
            win.present();
        }
        Err(e) => {
            eprintln!("{e}");
            win.destroy();
        }
    }
}
