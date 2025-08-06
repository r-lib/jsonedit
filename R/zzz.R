.onLoad <- function(lib, pkg) {
  assign("jsonc", V8::v8(), environment(.onLoad))
  jsonc$source(system.file("js/jsonc.js", package = pkg))
  jsonc$source(system.file("js/bindings.js", package = pkg))
}
