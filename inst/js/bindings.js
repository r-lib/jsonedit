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

function json_get_path(json, path) {
  const errors = [];
  const root = jsonc.parseTree(json, errors);
  if (errors.length > 0) {
    throw new Error("Internal error. Expected no parse errors.");
  }

  const node = jsonc.findNodeAtLocation(root, path);

  if (node) {
    return json_get_node_value(node);
  } else {
    return undefined;
  }
}

function json_get_node_value(node) {
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
    return json_get_node_value_array(node)
  }
  if (type == "object") {
    return json_get_node_value_object(node)
  }
  if (type == "property") {
    throw new Error("Properties should only appear within objects.");
  }

  throw new Error("Unexpected `Node` type.");
}

function json_get_node_value_array(node) {
  const values = [];

  for (child of node.children) {
    values.push(json_get_node_value(child))
  }

  return values;
}

function json_get_node_value_object(node) {
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

    values[key.value] = json_get_node_value(value);
  }

  return values;
}
