function ffi_text_modify(text, path, value, modification_options){
  var edit_result = jsonc.modify(text, path, value, modification_options);
  return jsonc.applyEdits(text, edit_result);
}
