mod imp;

use glib::subclass::prelude::*;
use glib::Object;
use gtk::prelude::*;
use gtk::{gio, glib, Application, NotebookPage, Widget};

glib::wrapper! {
    pub struct Window(ObjectSubclass<imp::Window>)
        @extends gtk::ApplicationWindow, gtk::Window, gtk::Widget,
        @implements gio::ActionGroup, gio::ActionMap, gtk::Accessible, gtk::Buildable,
                    gtk::ConstraintTarget, gtk::Native, gtk::Root, gtk::ShortcutManager;
}

impl Window {
    pub fn new(app: &Application) -> Self {
        // Create new window
        Object::builder().property("application", app).build()
    }

    pub fn notebook_append_page(
        &self,
        child: &impl IsA<Widget>,
        tab_label: Option<&impl IsA<Widget>>,
    ) -> u32 {
        let imp = self.imp();
        imp.notebook.append_page(child, tab_label)
    }

    pub fn notebook_page(&self, child: &impl IsA<Widget>) -> NotebookPage {
        let imp = self.imp();
        imp.notebook.page(child)
    }

    pub fn notebook_page_number(&self) -> u32 {
        let imp = self.imp();
        imp.notebook.n_pages()
    }
}
