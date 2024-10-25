{
  function Program(body) { return { type: "Program", body: body }; }
  function VariableDeclaration(name, varType, value) { return { type: "VariableDeclaration", name: name, varType: varType, value: value }; }
  function SetStatement(name, operator, value) { return { type: "SetStatement", name: name, operator: operator, value: value }; }
  function PrintStatement(value) { return { type: "PrintStatement", value: value }; }
  function InterpolatedString(parts) { return { type: "InterpolatedString", parts: parts }; }
  function TextPart(text) { return { type: "TextPart", text: text }; }
  function InterpolatedExpression(expression) { return { type: "InterpolatedExpression", expression: expression }; }
  function StringLiteral(value) { return { type: "StringLiteral", value: value }; }
  function IntegerLiteral(value) { return { type: "IntegerLiteral", value: parseInt(value, 10) }; }
  function FloatLiteral(value) { return { type: "FloatLiteral", value: parseFloat(value) }; }
  function BooleanLiteral(value) { return { type: "BooleanLiteral", value: value === "true" }; }
  function Identifier(name) { return { type: "Identifier", name: name }; }
  function Type(name) { return { type: "Type", name: name }; }
  function BinaryExpression(left, operator, right) { return { type: "BinaryExpression", left: left, operator: operator, right: right }; }
  function UnaryExpression(operator, expression) { return { type: "UnaryExpression", operator: operator, expression: expression }; }
  function IfStatement(condition, body) { return { type: "IfStatement", condition: condition, body: body }; }
  function LoopStatement(body) { return { type: "LoopStatement", body: body }; }
  function BreakStatement() { return { type: "BreakStatement" }; }
}

Start
  = Program

Program
  = statements:Statement* { return Program(statements); }

Statement
  = VariableDeclaration
  / SetStatement
  / PrintStatement
  / IfStatement
  / LoopStatement
  / BreakStatement

VariableDeclaration
  = "var" _ name:Identifier _ ":" _ varType:Type _ "=" _ value:Expression _ {
      return VariableDeclaration(name, varType, value);
    }

SetStatement
  = "set" _ name:Identifier _ operator:AssignmentOperator _ value:Expression _ {
      return SetStatement(name, operator, value);
    }

PrintStatement
  = "Print" _ "(" _ value:InterpolatedString _ ")" _ {
      return PrintStatement(value);
    }

IfStatement
  = "if" _ "(" _ condition:Expression _ ")" _ ":" _ body:Statement+ {
      return IfStatement(condition, body);
    }

LoopStatement
  = "loop" _ ":" _ body:Statement+ {
      return LoopStatement(body);
    }

BreakStatement
  = "break" _ { return BreakStatement(); }

InterpolatedString
  = '"' parts:InterpolatedPart* '"' { return InterpolatedString(parts); }

InterpolatedPart
  = TextPart
  / InterpolatedExpression

TextPart
  = text:$[^"{]+ { return TextPart(text); }

InterpolatedExpression
  = "{" _ expr:Expression _ "}" { return InterpolatedExpression(expr); }

Expression
  = LogicalExpression

LogicalExpression
  = left:ComparisonExpression _ operator:LogicalOperator _ right:LogicalExpression {
      return BinaryExpression(left, operator, right);
    }
  / ComparisonExpression

ComparisonExpression
  = left:AdditiveExpression _ operator:ComparisonOperator _ right:ComparisonExpression {
      return BinaryExpression(left, operator, right);
    }
  / AdditiveExpression

AdditiveExpression
  = left:MultiplicativeExpression _ operator:AdditiveOperator _ right:AdditiveExpression {
      return BinaryExpression(left, operator, right);
    }
  / MultiplicativeExpression

MultiplicativeExpression
  = left:UnaryExpression _ operator:MultiplicativeOperator _ right:MultiplicativeExpression {
      return BinaryExpression(left, operator, right);
    }
  / UnaryExpression

UnaryExpression
  = operator:UnaryOperator _ expression:UnaryExpression {
      return UnaryExpression(operator, expression);
    }
  / PostfixExpression

PostfixExpression
  = expression:PrimaryExpression "?" { return UnaryExpression("?", expression); }
  / PrimaryExpression

PrimaryExpression
  = StringLiteral
  / FloatLiteral
  / IntegerLiteral
  / BooleanLiteral
  / Identifier
  / "(" _ expr:Expression _ ")" { return expr; }

LogicalOperator
  = "and" / "or"

ComparisonOperator
  = ">" / "<" / ">=" / "<="

AdditiveOperator
  = "+" / "-"

MultiplicativeOperator
  = "*" / "/"

UnaryOperator
  = "not"

AssignmentOperator
  = "=" / "+="

StringLiteral
  = '"' value:$[^"]* '"' { return StringLiteral(value); }

IntegerLiteral
  = value:$("-"? [0-9]+) { return IntegerLiteral(value); }

FloatLiteral
  = value:$("-"? [0-9]+ "." [0-9]+) { return FloatLiteral(value); }

BooleanLiteral
  = value:("true" / "false") { return BooleanLiteral(value); }

Identifier
  = name:$[a-zA-Z_][a-zA-Z0-9_]* { return Identifier(name); }

Type
  = name:$("float" / "int" / "string" / "logic") { return Type(name); }

_ "whitespace"
  = [ \t\n\r]*