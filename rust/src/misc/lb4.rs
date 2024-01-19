use glib::clone;
use gtk::prelude::*;
use gtk::{glib, Application, Box, Button, Orientation, Window};

const APP_ID: &str = "com.github.gemone.GTK4-Tutorial.lb4";

fn click1_cb(btn: &Button) {
    let s = btn.label();
    match s {
        Some(sl) if sl == "Hello." => btn.set_label("Good-bye."),
        _ => {
            btn.set_label("Hello.");
        }
    }
}

fn click2_cb(win: &Window) {
    win.destroy()
}

fn main() -> glib::ExitCode {
    let app = Application::builder().application_id(APP_ID).build();

    app.connect_activate(app_activate);
    app.run()
}

fn app_activate(app: &Application) {
    let btn1 = Button::builder().label("Hello.").build();
    let btn2 = Button::builder().label("Close").build();

    let gtkbox = Box::new(Orientation::Vertical, 5);
    gtkbox.set_homogeneous(true);
    gtkbox.append(&btn1);
    gtkbox.append(&btn2);

    let win = Window::builder()
        .application(app)
        .title("lb4")
        .default_width(400)
        .default_height(300)
        .child(&gtkbox)
        .build();

    btn1.connect_clicked(clone!(@weak btn1 => move |_| {
    click1_cb(&btn1);
    }));
    btn2.connect_clicked(clone!(@weak win => move|_| {
    click2_cb(&win);
    }));

    win.present()
}
