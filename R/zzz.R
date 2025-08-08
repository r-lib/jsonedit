.onLoad <- function(lib, pkg) {
  assign("jsonc", V8::v8(), environment(.onLoad))
  jsonc$source(system.file("js/jsonc.js", package = pkg))
  jsonc$source(system.file("js/modify.js", package = pkg))
  jsonc$source(system.file("js/format.js", package = pkg))
  jsonc$source(system.file("js/parse.js", package = pkg))
}
