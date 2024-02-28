use gtk::prelude::*;
use gtk::{gio, glib, Application, Label, Notebook, ScrolledWindow, TextView, Window};

use gio::{Cancellable, File};
use glib::{error::Error, FileError};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.tfv4";

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
    let nb = Notebook::new();
    let win = Window::builder()
        .application(app)
        .default_width(600)
        .default_height(400)
        .child(&nb)
        .title("file viewer")
        .build();

    let files = files.to_vec();

    for file in files {
        match file_open(Some(&file)) {
            Ok((basename, contents)) => {
                let tv = TextView::builder()
                    .wrap_mode(gtk::WrapMode::Char)
                    .editable(false)
                    .build();
                let tb = tv.buffer();
                tb.set_text(&contents);

                let scr = ScrolledWindow::builder().child(&tv).build();
                let lab = Label::with_mnemonic(&basename);

                nb.append_page(&scr, Some(&lab));
                // set page for scr
                let nbp = nb.page(&scr);
                nbp.set_tab_expand(true);
            }
            Err(e) => {
                // print error
                eprintln!("{e}");
                break;
            }
        }
    }

    if nb.n_pages() > 0 {
        win.present();
    } else {
        win.destroy();
    }
}
