fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    println!("Building Android minimal version");
}
