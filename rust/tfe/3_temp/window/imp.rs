use glib::subclass::InitializingObject;
use gtk::gio;
use gtk::subclass::prelude::*;
use gtk::{glib, prelude::*, CompositeTemplate, Notebook, ScrolledWindow};

use crate::textview::TfeTextView;

// ANCHOR: object
// Object holding the state
#[derive(CompositeTemplate, Default)]
#[template(resource = "/com/github/gemone/GTK4-Tutorial/tfe3_temp/window.ui")]
pub struct Window {
    #[template_child]
    pub notebook: TemplateChild<Notebook>,
}
// ANCHOR_END: object

// ANCHOR: subclass
// The central trait for subclassing a GObject
#[glib::object_subclass]
impl ObjectSubclass for Window {
    // `NAME` needs to match `class` attribute of template
    const NAME: &'static str = "MyGtkAppWindow";
    type Type = super::Window;
    type ParentType = gtk::ApplicationWindow;

    fn class_init(klass: &mut Self::Class) {
        klass.bind_template();
        // for template_callbacks
        klass.bind_template_callbacks();
    }

    fn instance_init(obj: &InitializingObject<Self>) {
        obj.init_template();
    }
}
// ANCHOR_END: subclass

#[gtk::template_callbacks]
impl Window {
    #[template_callback]
    fn on_close_reqeust(&self, _window: &gtk::Window) -> glib::Propagation {
        for i in 0..self.notebook.n_pages() {
            let scr = self
                .notebook
                .nth_page(Some(i))
                .and_downcast::<ScrolledWindow>();
            let tv = scr
                .expect("note text view here")
                .child()
                .and_downcast::<TfeTextView>();
            let file = tv.as_ref().expect("no file here").get_file().ok();

            let tb = tv
                .as_ref()
                .expect("can not get buffer from textview")
                .buffer();

            let (start_iter, end_iter) = tb.bounds();
            let contents = tb.text(&start_iter, &end_iter, false);

            file.expect("no such file")
                .replace_contents(
                    contents.as_bytes(),
                    None,
                    true,
                    gio::FileCreateFlags::NONE,
                    gio::Cancellable::NONE,
                )
                .expect("can not write to file");
        }

        // anyway close it
        glib::Propagation::Proceed
    }
}

// ANCHOR: object_impl
// Trait shared by all GObjects
impl ObjectImpl for Window {}
// ANCHOR_END: object_impl

// Trait shared by all widgets
impl WidgetImpl for Window {}

// Trait shared by all windows
impl WindowImpl for Window {}

// Trait shared by all application windows
impl ApplicationWindowImpl for Window {}
