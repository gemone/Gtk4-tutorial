mod imp;

use glib::Object;
use gtk::gio;
use gtk::glib;
use gtk::subclass::prelude::*; // the trait to use self.imp()

use anyhow::Result;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum TextViewError {
    #[error("No File here")]
    NoFile,
}

glib::wrapper! {
    pub struct TfeTextView(ObjectSubclass<imp::TfeTextView>)
        @extends gtk::TextView, gtk::Widget,
        @implements gtk::Accessible, gtk::Buildable, gtk::ConstraintTarget, gtk::Scrollable;
}

impl Default for TfeTextView {
    fn default() -> Self {
        Object::new()
    }
}

/// you should define custom method here
impl TfeTextView {
    pub fn new() -> Self {
        Object::builder().build()
    }

    pub fn set_file(&self, file: Option<gio::File>) {
        let imp = self.imp();
        imp.file.replace(file);
    }

    pub fn get_file(&self) -> Result<gio::File, TextViewError> {
        let imp = self.imp();
        let file = imp.file.borrow_mut().take();

        match file {
            Some(f) => Ok(f),
            None => Err(TextViewError::NoFile),
        }
    }
}
