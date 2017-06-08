Start = __ ParseObject __

ParseObject = BeginObject __
  subobjects: ((ObjectParameter / ParseObject / CustomProperty) __)*
EndObject {
  return { type : "object"
    , value : {
      objects: subobjects.map(p => p[0]) } };
}

WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"

LineTerminator
  = [\n\r\u2028\u2029]

Equal = "="
WordValue = chars: ([a-z0-9_]i / '.')+ {
  return chars.join("");
}

ParameterValue = PathValue
  / ClassPathValue
  / NodePathValue
  / StringValue
  / LocStringValue
  / ObjectValue
  / BoolValue
  / NumberValue
  / HexValue
  / NoneValue
  
BoolValue = val:("true"i / "false"i) {
  return { type: "Boolean", value: val.toLowerCase() == "true" };
}
NumberValue = num:([+-]?([0-9]/".")+) !("." / [a-z]i) {
  return { type: "Number", value: (num[0] ? num[0] : "") + num[1].join("") };
}
HexValue = chars:[0-9a-f]i+ !("." / [a-z]i) {
  return { type: "Hex", value: chars.join("") };
}
PathValue = path:("/" WordValue)+ {
  return { type: "Path", value: path.map(function (s) { return s.join(""); }).join("") };
}
ClassPathValue = ("Class"i / "BlueprintGeneratedClass"i) "'" path:PathValue "'" {
  return { type: "ClassPath", value: path };
}
NodePathValue = node:(WordValue) "'" npath:WordValue "'" {
  return { type: "NodePath", value: { type: node, path: npath } };
}
StringValue = '"' chars:[^"]* '"' {
  return { type: "String", value: chars.join("") };
}
LocStringValue = "NSLOCTEXT"i "(" strs:(StringValue __ ","? __ )+ ")" {
  return { type: "LocString", value: strs.map(p => p[0]) };
}
ObjectValue = '(' __ param:(ObjectParameter ','?)* __ ')' {
  return { type: "Struct", value: param.map(p => p[0]) };
}
NoneValue = "None"i {
  return { type: "None" };
}

Keyword = Begin / End / Object / CustomProperties

Begin = "Begin"i
End = "End"i
Object = "Object"i
CustomProperties = "CustomProperties"i

ObjectParameterNames = !Keyword name:WordValue ("(" [0-9]+ ")")? { return name; }
ObjectParameter = pname:ObjectParameterNames (Equal/WhiteSpace) pvalue:ParameterValue {
  return { type : "Parameter", value : { name : pname, value : pvalue } };
}

CustomProperty = CustomProperties __ "pin"i __ ObjectValue

BeginObject = Begin __ Object
EndObject = End __ Object

__
  = (WhiteSpace / LineTerminator)*
