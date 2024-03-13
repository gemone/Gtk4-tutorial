fn main() {
    glib_build_tools::compile_resources(
        &["tfe/3_r/resources"],
        "tfe/3_r/resources/resources.gresource.xml",
        "tfe_3_r.gresource",
    )
}
