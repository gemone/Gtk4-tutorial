fn main() {
    glib_build_tools::compile_resources(
        &["tfe/3_r/resources"],
        "tfe/3_r/resources/resources.gresource.xml",
        "tfe_3_r.gresource",
    );

    glib_build_tools::compile_resources(
        &["tfe/3_temp/resources"],
        "tfe/3_temp/resources/resources.gresource.xml",
        "tfe_3_temp.gresource",
    );
}
