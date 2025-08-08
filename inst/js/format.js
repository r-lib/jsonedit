function ffi_text_format(text, formatting_options){
  var edit_result = jsonc.format(text, undefined, formatting_options);
  return jsonc.applyEdits(text, edit_result);
}
