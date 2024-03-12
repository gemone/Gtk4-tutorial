mod textview;

use gtk::prelude::*;
use gtk::{gio, glib, Application, Label, Notebook, ScrolledWindow, Widget, Window};

use textview::TfeTextView;

use anyhow::{anyhow, Result};
use thiserror::Error;

#[derive(Error, Debug)]
enum CastError {
    #[error("Cast Not Cast to {0}")]
    CanNotCast(String),
    #[error("unknown what happend, read you code")]
    Unknown,
}

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.tfe1";

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

fn cast_widget<T: IsA<Widget>>(wid: Option<Widget>) -> Result<T, CastError> {
    if let Some(wid) = wid {
        match wid.downcast::<T>().ok() {
            Some(t) => Ok(t),
            None => Err(CastError::CanNotCast("widget".to_string())),
        }
    } else {
        Err(CastError::Unknown)
    }
}

fn before_close(nb: &Notebook) -> Result<()> {
    for i in 0..nb.n_pages() {
        let scr: ScrolledWindow = cast_widget(nb.nth_page(Some(i)))?;
        let tv: TfeTextView = cast_widget(scr.child())?;
        let file = tv.get_file()?;
        let tb = tv.buffer();

        let (start_iter, end_iter) = tb.bounds();
        let contents = tb.text(&start_iter, &end_iter, false);

        if let Err(e) = file.replace_contents(
            contents.as_bytes(),
            None,
            true,
            gio::FileCreateFlags::NONE,
            gio::Cancellable::NONE,
        ) {
            return Err(anyhow!(e));
        }
    }

    Ok(())
}

fn app_open(app: &Application, files: &[gio::File], _hint: &str) {
    let nb = Notebook::new();
    let win = Window::builder()
        .application(app)
        .default_width(600)
        .default_height(400)
        .child(&nb)
        .title("file editor")
        .build();

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
        win.connect_close_request(move |_: &Window| {
            if let Err(e) = before_close(&nb) {
                eprintln!("{e:?}");
            }
            // to quit window
            glib::Propagation::Proceed
        });
        win.present();
    } else {
        win.destroy();
    }
}
