function ffi_text_modify(text, path, value, modification_options){
  var edit_result = jsonc.modify(text, path, value, modification_options);
  return jsonc.applyEdits(text, edit_result);
}

function ffi_text_format(text, formatting_options){
  var edit_result = jsonc.format(text, undefined, formatting_options);
  return jsonc.applyEdits(text, edit_result);
}

function ffi_parse_errors(text, parse_options){
  const errors = [];
  jsonc.parseTree(text, errors, parse_options);
  return errors;
}

function ffi_text_paths(json, path, parse_options) {
  const errors = [];
  const root = jsonc.parseTree(json, errors, parse_options);
  if (errors.length > 0) {
    throw new Error("Internal error. Expected no parse errors.");
  }

  const node = jsonc.findNodeAtLocation(root, path);

  if (node) {
    return get_node_value(node);
  } else {
    return undefined;
  }
}

function get_node_value(node) {
  const type = node.type;

  if (type == "null") {
    return node.value;
  }
  if (type == "boolean") {
    return node.value;
  }
  if (type == "number") {
    return node.value;
  }
  if (type == "string") {
    return node.value;
  }
  if (type == "array") {
    return get_array_value(node)
  }
  if (type == "object") {
    return get_object_value(node)
  }
  if (type == "property") {
    throw new Error("Properties should only appear within objects.");
  }

  throw new Error("Unexpected `Node` type.");
}

function get_array_value(node) {
  const values = [];

  for (child of node.children) {
    values.push(get_node_value(child))
  }

  return values;
}

function get_object_value(node) {
  const values = {};

  for (child of node.children) {
    if (child.type != "property") {
      throw new Error("Every object child should be a property.");
    }
    const key = child.children[0];
    const value = child.children[1];

    if (key.type != "string") {
      throw new Error("Every property's first child should be a string.");
    }

    values[key.value] = get_node_value(value);
  }

  return values;
}
