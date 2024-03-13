/// imp just define subclass struct
/// if you include data in subclass, the method should be defined in mod.rs
///
/// imp.rs impl trait from ParentType
///
/// https://gtk-rs.org/gtk4-rs/stable/latest/book/g_object_subclassing.html

use std::cell::RefCell;


use gtk::gio;
use gtk::glib;
use gtk::subclass::prelude::*;

#[derive(Default)]
pub struct TfeTextView {
    // save file in textview
    // just need the file pointer
    pub file: RefCell<Option<gio::File>>,
}

#[glib::object_subclass]
impl ObjectSubclass for TfeTextView {
    const NAME: &'static str = "GtkAppTfeTextView";
    type Type = super::TfeTextView;
    type ParentType = gtk::TextView;
}

impl ObjectImpl for TfeTextView {}

impl WidgetImpl for TfeTextView {}

impl TextViewImpl for TfeTextView {}
