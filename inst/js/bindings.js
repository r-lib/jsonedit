function json_modify(json, path, value, opts){
  var edit_result = jsonc.modify(json, path, value, opts);
  return jsonc.applyEdits(json, edit_result);
}

function json_format(json, opts){
  var edit_result = jsonc.format(json, undefined, opts);
  return jsonc.applyEdits(json, edit_result);
}
