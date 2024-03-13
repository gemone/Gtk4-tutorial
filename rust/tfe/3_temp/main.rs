mod textview;
mod window;

use gtk::prelude::*;
use gtk::{gio, glib, Application, Label, ScrolledWindow};

use anyhow::anyhow;
use anyhow::Result;

use textview::TfeTextView;
use window::Window;

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.tfe3_r";

fn main() -> glib::ExitCode {
    // Register and include resources
    gio::resources_register_include!("tfe_3_temp.gresource").expect("Failed to register resources");

    let app = Application::builder()
        .application_id(APP_ID)
        .flags(gtk::gio::ApplicationFlags::HANDLES_OPEN)
        .build();

    app.connect_activate(app_activate);
    app.connect_open(app_open);
    app.run()
}

fn app_activate(_app: &Application) {
    eprintln!("You need a filename argument.\n");
}

fn file_open(file: Option<&gio::File>) -> Result<(String, String)> {
    if let Some(file) = file {
        let (contents, _) = file.load_contents(gio::Cancellable::NONE)?;
        let basename = file
            .basename()
            .unwrap_or_default()
            .to_str()
            .unwrap_or_default()
            .to_string();

        match String::from_utf8(contents.to_vec()) {
            Ok(contents) => Ok((basename, contents)),
            Err(e) => Err(anyhow!("load file contents fail, {e:?}")),
        }
    } else {
        Err(anyhow!("load file content fail"))
    }
}

fn app_open(app: &Application, files: &[gio::File], _hint: &str) {
    let win = Window::new(app);

    let files = files.to_vec();

    for file in files {
        match file_open(Some(&file)) {
            Ok((basename, contents)) => {
                let tv = TfeTextView::new();
                tv.set_wrap_mode(gtk::WrapMode::Char);
                tv.set_file(Some(file));

                let tb = tv.buffer();
                tb.set_text(&contents);

                let scr = ScrolledWindow::builder().child(&tv).build();
                let lab = Label::with_mnemonic(&basename);

                win.notebook_append_page(&scr, Some(&lab));
                // set page for scr
                let nbp = win.notebook_page(&scr);
                nbp.set_tab_expand(true);
            }
            Err(e) => {
                // print error
                eprintln!("{e}");
                break;
            }
        }
    }

    if win.notebook_page_number() > 0 {
        win.present();
    } else {
        win.destroy();
    }
}
