use gtk::prelude::*;
use gtk::{glib, Application, ScrolledWindow, TextView, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.tfv1";

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(app: &Application) {
    let text = "Once upon a time, there was an old man who was called Taketori-no-Okina. 
It is a japanese word that means a man whose work is making bamboo baskets.
One day, he went into a hill and found a shining bamboo. 
\"What a mysterious bamboo it is!,\" he said. 
He cut it, then there was a small cute baby girl in it. 
The girl was shining faintly. 
He thought this baby girl is a gift from Heaven and took her home.
His wife was surprized at his story. 
They were very happy because they had no children. 
";

    let tv = TextView::new();
    let tb = tv.buffer();
    tb.set_text(text);

    tv.set_wrap_mode(gtk::WrapMode::Char);

    let scr = ScrolledWindow::builder().child(&tv).build();

    let win = Window::builder()
        .application(app)
        .title("Taketori")
        .default_width(400)
        .default_height(300)
        .child(&scr)
        .build();

    win.present()
}
