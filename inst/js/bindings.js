function json_modify(json, path, value, opts){
  var edit_result = jsonc.modify(json, path, value, opts);
  return jsonc.applyEdits(json, edit_result);
}

function json_format(json, opts){
  var edit_result = jsonc.format(json, undefined, opts);
  return jsonc.applyEdits(json, edit_result);
}

function json_parse_errors(json){
  const errors = [];
  jsonc.parseTree(json, errors);
  return errors;
}
