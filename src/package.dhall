let Integer/abs =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Integer/abs.dhall

let Integer/greaterThan =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Integer/greaterThan.dhall

let Optional/map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Optional/map.dhall

let Text/replicate =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Text/replicate.dhall

let Text/id = \(x : Text) -> x

let Target = < Selected | Named : Text | Implicit >

let Ast/Output =
      { Natural : Type
      , Integer : Type
      , Text : Type
      , TableEntries : Type
      , Table : Type
      , Command : Type
      , Commands : Type
      , DropdownOption : Type -> Type
      , DropdownOptions : Type -> Type
      }

let Ast/Constructors =
    -- TODO: We can also do markdown formatting so we Literal is really Regular, and then we need Bold, Italic, Preformatted, and Links.
    -- TODO: We should escape things that would otherwise be evaluated (which is a pretty substantial list).
    -- TODO: Decimal (which includes float/ceil, division)
    -- TODO: Comparisons (and thereby booleans)
    -- TODO: It is possible to do Boolean logic (not x = x * (-1) + 1; and x = x*x; nand => you can do anything), and it's possible to do IF/THEN/ELSE for numbers via `if p then t else f = p*(t - f) + f`.  But not for text since there's no associated trick (with control characters you theoretically could, where -f is backspace repeated for length(f), but roll20 shows BS as a special character).
    -- TODO: Weird ass set behaviors, like {{0,5}>4}, which returns 1, because 4 is greater than one of the items in the set.
    -- TODO: Custom roll templates are really a whole other thing in order to rigidly type, because it's up to the template to define what keys have special meaning.  The default template has a special "name" key, which we handle here.  You must explicitly convert to a Table to include it, and if you try and set the key "name," we escape it, so it acts like a regular key.  Ideally, we'd have a plugable way to do something equivalent for arbitrary roll templates.
      \(output : Ast/Output) ->
        Natural ->
          { Literal :
              { Natural : Natural -> output.Natural
              , Integer : Integer -> output.Integer
              , Text : Text -> output.Text
              }
          , Empty : output.TableEntries
          , Singleton :
              { TableEntries : output.Text -> output.Text -> output.TableEntries
              , Commands : output.Command -> output.Commands
              }
          , ToTable :
              Optional output.Text -> output.TableEntries -> output.Table
          , Macro :
              { Natural : Text -> output.Natural
              , Integer : Text -> output.Integer
              , Text : Text -> output.Text
              }
          , Ability :
              { Natural : { char : Target, name : Text } -> output.Natural
              , Integer : { char : Target, name : Text } -> output.Integer
              , Text : { char : Target, name : Text } -> output.Text
              }
          , Attribute :
              { Natural : { char : Target, name : Text } -> output.Natural
              , Integer : { char : Target, name : Text } -> output.Integer
              , Text : { char : Target, name : Text } -> output.Text
              }
          , EmptyInput :
              { Natural : Text -> output.Natural
              , Integer : Text -> output.Integer
              , Text : Text -> output.Text
              , Command : Text -> output.Command
              }
          , DefaultedInput :
              { Natural : Text -> output.Natural -> output.Natural
              , Integer : Text -> output.Integer -> output.Integer
              , Text : Text -> output.Text -> output.Text
              , Command : Text -> output.Command -> output.Command
              }
          , DropdownOption :
              { Natural :
                  Text -> output.Natural -> output.DropdownOption output.Natural
              , Integer :
                  Text -> output.Integer -> output.DropdownOption output.Integer
              , Text : Text -> output.Text -> output.DropdownOption output.Text
              , TableEntries :
                  Text ->
                  output.TableEntries ->
                    output.DropdownOption output.TableEntries
              , Table :
                  Text -> output.Table -> output.DropdownOption output.Table
              , Command :
                  Text -> output.Command -> output.DropdownOption output.Command
              }
          , ToDropdownOptions :
              { Natural :
                  output.DropdownOption output.Natural ->
                  output.DropdownOption output.Natural ->
                    output.DropdownOptions output.Natural
              , Integer :
                  output.DropdownOption output.Integer ->
                  output.DropdownOption output.Integer ->
                    output.DropdownOptions output.Integer
              , Text :
                  output.DropdownOption output.Text ->
                  output.DropdownOption output.Text ->
                    output.DropdownOptions output.Text
              , TableEntries :
                  output.DropdownOption output.TableEntries ->
                  output.DropdownOption output.TableEntries ->
                    output.DropdownOptions output.TableEntries
              , Table :
                  output.DropdownOption output.Table ->
                  output.DropdownOption output.Table ->
                    output.DropdownOptions output.Table
              , Command :
                  output.DropdownOption output.Command ->
                  output.DropdownOption output.Command ->
                    output.DropdownOptions output.Command
              }
          , Dropdown :
              { Natural :
                  Text ->
                  output.DropdownOptions output.Natural ->
                    output.Natural
              , Integer :
                  Text ->
                  output.DropdownOptions output.Integer ->
                    output.Integer
              , Text : Text -> output.DropdownOptions output.Text -> output.Text
              , TableEntries :
                  Text ->
                  output.DropdownOptions output.TableEntries ->
                    output.TableEntries
              , Table :
                  Text -> output.DropdownOptions output.Table -> output.Table
              , Command :
                  Text ->
                  output.DropdownOptions output.Command ->
                    output.Command
              }
          , ToInteger : output.Natural -> output.Integer
          , AbsoluteValue : output.Integer -> output.Natural
          , Dice : output.Natural -> output.Natural -> output.Natural
          , Labeled :
              { Integer : output.Text -> output.Integer -> output.Integer
              , Natural : output.Text -> output.Natural -> output.Natural
              }
          , PlusPlus : output.Text -> output.Text -> output.Text
          , Cons :
              { DropdownOptions :
                  { Natural :
                      output.DropdownOption output.Natural ->
                      output.DropdownOptions output.Natural ->
                        output.DropdownOptions output.Natural
                  , Integer :
                      output.DropdownOption output.Integer ->
                      output.DropdownOptions output.Integer ->
                        output.DropdownOptions output.Integer
                  , Text :
                      output.DropdownOption output.Text ->
                      output.DropdownOptions output.Text ->
                        output.DropdownOptions output.Text
                  , TableEntries :
                      output.DropdownOption output.TableEntries ->
                      output.DropdownOptions output.TableEntries ->
                        output.DropdownOptions output.TableEntries
                  , Table :
                      output.DropdownOption output.Table ->
                      output.DropdownOptions output.Table ->
                        output.DropdownOptions output.Table
                  , Command :
                      output.DropdownOption output.Command ->
                      output.DropdownOptions output.Command ->
                        output.DropdownOptions output.Command
                  }
              , Commands : output.Command -> output.Commands -> output.Commands
              }
          , Extend :
              { TableEntries :
                  output.TableEntries ->
                  output.TableEntries ->
                    output.TableEntries
              , Table : output.Table -> output.TableEntries -> output.Table
              , Commands : output.Commands -> output.Commands -> output.Commands
              }
          , Add :
              { Integer : output.Integer -> output.Integer -> output.Integer
              , Natural : output.Natural -> output.Natural -> output.Natural
              }
          , Multiply :
              { Integer : output.Integer -> output.Integer -> output.Integer
              , Natural : output.Natural -> output.Natural -> output.Natural
              }
          , Show :
              { Integer : output.Integer -> output.Text
              , Natural : output.Natural -> output.Text
              }
          , Broadcast :
              { Text : output.Text -> output.Command
              , Table : output.Table -> output.Command
              }
          , BroadcastAs :
              { Text : output.Text -> output.Text -> output.Command
              , Table : output.Text -> output.Table -> output.Command
              }
          , Emote : output.Text -> output.Command
          , EmoteAs : output.Text -> output.Text -> output.Command
          , Whisper :
              { Text : output.Text -> output.Text -> output.Command
              , Table : output.Text -> output.Table -> output.Command
              }
          }

let Ast/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Natural

let Ast/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Integer

let Ast/Text
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Text

let Ast/TableEntries
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.TableEntries

let Ast/Table
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Table

let Ast/Command
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Command

let Ast/Commands
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Commands

let Ast/DropdownOption/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.Natural

let Ast/DropdownOption/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.Integer

let Ast/DropdownOption/Text
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.Text

let Ast/DropdownOption/TableEntries
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.TableEntries

let Ast/DropdownOption/Table
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.Table

let Ast/DropdownOption/Command
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption output.Command

let Ast/DropdownOptions/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.Natural

let Ast/DropdownOptions/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.Integer

let Ast/DropdownOptions/Text
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.Text

let Ast/DropdownOptions/TableEntries
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.TableEntries

let Ast/DropdownOptions/Table
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.Table

let Ast/DropdownOptions/Command
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions output.Command

let renderMacro = \(t : Text) -> "#${t}"

let renderTarget =
      \(x : Target) ->
        merge
          { Implicit = ""
          , Selected = "selected|"
          , Named = \(name : Text) -> name ++ "|"
          }
          x

let renderAbility =
      \(x : { char : Target, name : Text }) ->
        "%{${renderTarget x.char}${x.name}}"

let renderAttribute =
      \(x : { char : Target, name : Text }) ->
        "@{${renderTarget x.char}${x.name}}"

let renderEscapeDepth =
      \(unescaped : Text) ->
      \(code : Text) ->
      \(depth : Natural) ->
        if    Natural/isZero depth
        then  unescaped
        else      "&"
              ++  Text/replicate (Natural/subtract 1 depth) "amp"
              ++  "#"
              ++  code
              ++  ";"

let renderLowerN = renderEscapeDepth "n" "110"

let renderQueryPipe = renderEscapeDepth "|" "124"

let renderQueryComma = renderEscapeDepth "," "44"

let renderQueryClosingBracket = renderEscapeDepth "}" "125"

let renderToCommand =
      \(commandStr : Text) ->
      \(name : Text) ->
      \(message : Text) ->
        "/${commandStr} \"${name}\" ${message}"

let renderWhisper = renderToCommand "w"

let renderBroadcastAs = renderToCommand "as"

let renderEmoteAs = renderToCommand "emas"

let Ast/render
    : Ast/Commands -> Text
    = \(x : Ast/Commands) ->
        x
          { Integer = Text
          , Natural = Text
          , Text = Text
          , TableEntries = Text
          , Table = Text
          , Command = Text
          , Commands = Text
          , DropdownOption = \(a : Type) -> Text
          , DropdownOptions = \(a : Type) -> Text
          }
          ( \(queryDepth : Natural) ->
              { Literal =
                { Natural = \(x : Natural) -> Natural/show x
                , Integer =
                    \(x : Integer) ->
                      if    Integer/greaterThan x -1
                      then  Natural/show (Integer/abs x)
                      else  "(${Integer/show x})"
                , Text = \(x : Text) -> x
                }
              , Empty = ""
              , Singleton =
                { TableEntries =
                    \(key : Text) ->
                    \(value : Text) ->
                      let escapedName = renderLowerN (queryDepth + 1) ++ "ame"

                      let escapedEndBracket =
                            renderQueryClosingBracket queryDepth

                      let escapedEndBraces = Text/replicate 2 escapedEndBracket

                      let escapedKey = Text/replace "name" escapedName key

                      in  "{{${escapedKey}=${value}${escapedEndBraces}"
                , Commands = Text/id
                }
              , ToTable =
                  \(optionalName : Optional Text) ->
                  \(entries : Text) ->
                    let escapedEndBracket = renderQueryClosingBracket queryDepth

                    let escapedEndBraces = Text/replicate 2 escapedEndBracket

                    let nameEntry =
                          merge
                            { None = ""
                            , Some =
                                \(name : Text) ->
                                  "{{name=${name}${escapedEndBraces}"
                            }
                            optionalName

                    in  "&{template:default${escapedEndBracket} ${nameEntry}${entries}"
              , Macro =
                { Natural = renderMacro
                , Integer = renderMacro
                , Text = renderMacro
                }
              , Ability =
                { Natural = renderAbility
                , Integer = renderAbility
                , Text = renderAbility
                }
              , Attribute =
                { Natural = renderAttribute
                , Integer = renderAttribute
                , Text = renderAttribute
                }
              , EmptyInput =
                  -- TODO: Let's just make the default optional
                  let f =
                        \(name : Text) ->
                          "?{" ++ name ++ renderQueryClosingBracket queryDepth

                  in  { Natural = f, Integer = f, Text = f, Command = f }
              , DefaultedInput =
                  let f =
                        \(name : Text) ->
                        \(default : Text) ->
                              "?{"
                          ++  name
                          ++  renderQueryPipe queryDepth
                          ++  default
                          ++  renderQueryClosingBracket queryDepth

                  in  { Natural = f, Integer = f, Text = f, Command = f }
              , DropdownOption =
                  let f =
                        \(key : Text) ->
                        \(value : Text) ->
                          key ++ renderQueryComma queryDepth ++ value

                  in  { Natural = f
                      , Integer = f
                      , Text = f
                      , TableEntries = f
                      , Table = f
                      , Command = f
                      }
              , ToDropdownOptions =
                  let f =
                        \(a : Text) ->
                        \(b : Text) ->
                          a ++ renderQueryPipe queryDepth ++ b

                  in  { Natural = f
                      , Integer = f
                      , Text = f
                      , TableEntries = f
                      , Table = f
                      , Command = f
                      }
              , Dropdown =
                  let f =
                        \(name : Text) ->
                        \(options : Text) ->
                              "?{"
                          ++  name
                          ++  renderQueryPipe queryDepth
                          ++  options
                          ++  renderQueryClosingBracket queryDepth

                  in  { Natural = f
                      , Integer = f
                      , Text = f
                      , TableEntries = f
                      , Table = f
                      , Command = f
                      }
              , ToInteger = Text/id
              , AbsoluteValue = \(t : Text) -> "abs(${t})"
              , Dice = 
                  -- TODO: If a die roll uses simple math to calculate count or sides, that works with parens like (1+2)d6.  But if we determine the count or number of sides with dice we need double square brackets like [[1d6]]d6.  Note that we technically _can_ roll negative numbers: they just are always treated as 0.
                  -- TODO: We probably want a new Random type.  Integers and Naturals can be converted to Randoms.
                  \(count : Text) -> \(sides : Text) -> "${count}d${sides}"
              , Labeled =
                { Integer = \(label : Text) -> \(x : Text) -> "${x}[${label}]"
                , Natural = \(label : Text) -> \(x : Text) -> "${x}[${label}]"
                }
              , PlusPlus = \(a : Text) -> \(b : Text) -> a ++ b
              , Cons =
                { DropdownOptions =
                    let f =
                          \(x : Text) ->
                          \(xs : Text) ->
                            x ++ renderQueryPipe queryDepth ++ xs

                    in  { Natural = f
                        , Integer = f
                        , Text = f
                        , TableEntries = f
                        , Table = f
                        , Command = f
                        }
                , Commands =
                    \(command : Text) ->
                    \(list : Text) ->
                      command ++ "\n" ++ list
                }
              , Extend =
                { TableEntries = \(a : Text) -> \(b : Text) -> a ++ " " ++ b
                , Table = \(a : Text) -> \(b : Text) -> a ++ " " ++ b
                , Commands = \(a : Text) -> \(b : Text) -> a ++ "\n" ++ b
                }
              , Add =
                { Integer = \(a : Text) -> \(b : Text) -> "(${a} + ${b})"
                , Natural = \(a : Text) -> \(b : Text) -> "(${a} + ${b})"
                }
              , Multiply =
                { Integer = \(a : Text) -> \(b : Text) -> "(${a} * ${b})"
                , Natural = \(a : Text) -> \(b : Text) -> "(${a} * ${b})"
                }
              , Show =
                { Integer = \(t : Text) -> "[[${t}]]"
                , Natural = \(t : Text) -> "[[${t}]]"
                }
              , Broadcast = { Text = Text/id, Table = Text/id }
              , BroadcastAs =
                { Text = renderBroadcastAs, Table = renderBroadcastAs }
              , Emote = Text/id
              , EmoteAs = renderEmoteAs
              , Whisper = { Text = renderWhisper, Table = renderWhisper }
              }
          )

let Ast/Literal/Integer
    : Integer -> Ast/Integer
    = \(x : Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Integer x

let Ast/Literal/Natural
    : Natural -> Ast/Natural
    = \(x : Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Natural x

let Ast/Literal/Text
    : Text -> Ast/Text
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Text x

let Ast/TableEntries/Empty
    : Ast/TableEntries
    = \(output : Ast/Output) -> \(cs : Ast/Constructors output) -> (cs 0).Empty

let Ast/Singleton/TableEntries
    : Ast/Text -> Ast/Text -> Ast/TableEntries
    = \(key : Ast/Text) ->
      \(value : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Singleton.TableEntries (key output cs) (value output cs)

let Ast/Singleton/Commands
    : Ast/Command -> Ast/Commands
    = \(command : Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Singleton.Commands (command output cs)

let Ast/ToTable
    : Optional Ast/Text -> Ast/TableEntries -> Ast/Table
    = \(optionalName : Optional Ast/Text) ->
      \(entries : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToTable
          ( Optional/map
              Ast/Text
              output.Text
              (\(name : Ast/Text) -> name output cs)
              optionalName
          )
          (entries output cs)

let Ast/Macro/Integer
    : Text -> Ast/Integer
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Integer x

let Ast/Macro/Natural
    : Text -> Ast/Natural
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Natural x

let Ast/Macro/Text
    : Text -> Ast/Text
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Text x

let Ast/Ability/Integer
    : { char : Target, name : Text } -> Ast/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Integer x

let Ast/Ability/Natural
    : { char : Target, name : Text } -> Ast/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Natural x

let Ast/Ability/Text
    : { char : Target, name : Text } -> Ast/Text
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Text x

let Ast/Attribute/Integer
    : { char : Target, name : Text } -> Ast/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Integer x

let Ast/Attribute/Natural
    : { char : Target, name : Text } -> Ast/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Natural x

let Ast/Attribute/Text
    : { char : Target, name : Text } -> Ast/Text
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Text x

let Ast/EmptyInput/Natural
    : Text -> Ast/Natural
    = \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmptyInput.Natural name

let Ast/EmptyInput/Integer
    : Text -> Ast/Integer
    = \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmptyInput.Integer name

let Ast/EmptyInput/Text
    : Text -> Ast/Text
    = \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmptyInput.Text name

let Ast/EmptyInput/Command
    : Text -> Ast/Command
    = \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmptyInput.Command name

let Ast/DefaultedInput/Natural
    : Text -> Ast/Natural -> Ast/Natural
    = \(name : Text) ->
      \(default : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DefaultedInput.Natural name (default output cs)

let Ast/DefaultedInput/Integer
    : Text -> Ast/Integer -> Ast/Integer
    = \(name : Text) ->
      \(default : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DefaultedInput.Integer name (default output cs)

let Ast/DefaultedInput/Text
    : Text -> Ast/Text -> Ast/Text
    = \(name : Text) ->
      \(default : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DefaultedInput.Text name (default output cs)

let Ast/DefaultedInput/Command
    : Text -> Ast/Command -> Ast/Command
    = \(name : Text) ->
      \(default : Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DefaultedInput.Command name (default output cs)

let Ast/ToDropdownOption/Natural
    : Text -> Ast/Natural -> Ast/DropdownOption/Natural
    = \(key : Text) ->
      \(value : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Natural
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOption/Integer
    : Text -> Ast/Integer -> Ast/DropdownOption/Integer
    = \(key : Text) ->
      \(value : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Integer
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOption/Text
    : Text -> Ast/Text -> Ast/DropdownOption/Text
    = \(key : Text) ->
      \(value : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Text
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOption/TableEntries
    : Text -> Ast/TableEntries -> Ast/DropdownOption/TableEntries
    = \(key : Text) ->
      \(value : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.TableEntries
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOption/Table
    : Text -> Ast/Table -> Ast/DropdownOption/Table
    = \(key : Text) ->
      \(value : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Table
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOption/Command
    : Text -> Ast/Command -> Ast/DropdownOption/Command
    = \(key : Text) ->
      \(value : Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Command
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let Ast/ToDropdownOptions/Natural
    : Ast/DropdownOption/Natural ->
      Ast/DropdownOption/Natural ->
        Ast/DropdownOptions/Natural
    = \(a : Ast/DropdownOption/Natural) ->
      \(b : Ast/DropdownOption/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Natural (a output cs) (b output cs)

let Ast/ToDropdownOptions/Integer
    : Ast/DropdownOption/Integer ->
      Ast/DropdownOption/Integer ->
        Ast/DropdownOptions/Integer
    = \(a : Ast/DropdownOption/Integer) ->
      \(b : Ast/DropdownOption/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Integer (a output cs) (b output cs)

let Ast/ToDropdownOptions/Text
    : Ast/DropdownOption/Text ->
      Ast/DropdownOption/Text ->
        Ast/DropdownOptions/Text
    = \(a : Ast/DropdownOption/Text) ->
      \(b : Ast/DropdownOption/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Text (a output cs) (b output cs)

let Ast/ToDropdownOptions/TableEntries
    : Ast/DropdownOption/TableEntries ->
      Ast/DropdownOption/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(a : Ast/DropdownOption/TableEntries) ->
      \(b : Ast/DropdownOption/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.TableEntries (a output cs) (b output cs)

let Ast/ToDropdownOptions/Table
    : Ast/DropdownOption/Table ->
      Ast/DropdownOption/Table ->
        Ast/DropdownOptions/Table
    = \(a : Ast/DropdownOption/Table) ->
      \(b : Ast/DropdownOption/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Table (a output cs) (b output cs)

let Ast/ToDropdownOptions/Command
    : Ast/DropdownOption/Command ->
      Ast/DropdownOption/Command ->
        Ast/DropdownOptions/Command
    = \(a : Ast/DropdownOption/Command) ->
      \(b : Ast/DropdownOption/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Command (a output cs) (b output cs)

let Ast/Dropdown/Natural
    : Text -> Ast/DropdownOptions/Natural -> Ast/Natural
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Natural name (options output cs)

let Ast/Dropdown/Integer
    : Text -> Ast/DropdownOptions/Integer -> Ast/Integer
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Integer name (options output cs)

let Ast/Dropdown/Text
    : Text -> Ast/DropdownOptions/Text -> Ast/Text
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Text name (options output cs)

let Ast/Dropdown/TableEntries
    : Text -> Ast/DropdownOptions/TableEntries -> Ast/TableEntries
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.TableEntries name (options output cs)

let Ast/Dropdown/Table
    : Text -> Ast/DropdownOptions/Table -> Ast/Table
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Table name (options output cs)

let Ast/Dropdown/Command
    : Text -> Ast/DropdownOptions/Command -> Ast/Command
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Command name (options output cs)

let Ast/ToInteger
    : Ast/Natural -> Ast/Integer
    = \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToInteger (x output cs)

let Ast/AbsoluteValue
    : Ast/Integer -> Ast/Natural
    = \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).AbsoluteValue (x output cs)

let Ast/Dice
    : Ast/Natural -> Ast/Natural -> Ast/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dice (x output cs) (y output cs)

let Ast/Label/Integer
    : Ast/Text -> Ast/Integer -> Ast/Integer
    = \(label : Ast/Text) ->
      \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Labeled.Integer (label output cs) (x output cs)

let Ast/Label/Natural
    : Ast/Text -> Ast/Natural -> Ast/Natural
    = \(label : Ast/Text) ->
      \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Labeled.Natural (label output cs) (x output cs)

let Ast/PlusPlus
    : Ast/Text -> Ast/Text -> Ast/Text
    = \(x : Ast/Text) ->
      \(y : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).PlusPlus (x output cs) (y output cs)

let Ast/Cons/DropdownOptions/Natural
    : Ast/DropdownOption/Natural ->
      Ast/DropdownOptions/Natural ->
        Ast/DropdownOptions/Natural
    = \(x : Ast/DropdownOption/Natural) ->
      \(xs : Ast/DropdownOptions/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Natural (x output cs) (xs output cs)

let Ast/Cons/DropdownOptions/Integer
    : Ast/DropdownOption/Integer ->
      Ast/DropdownOptions/Integer ->
        Ast/DropdownOptions/Integer
    = \(x : Ast/DropdownOption/Integer) ->
      \(xs : Ast/DropdownOptions/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Integer (x output cs) (xs output cs)

let Ast/Cons/DropdownOptions/Text
    : Ast/DropdownOption/Text ->
      Ast/DropdownOptions/Text ->
        Ast/DropdownOptions/Text
    = \(x : Ast/DropdownOption/Text) ->
      \(xs : Ast/DropdownOptions/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Text (x output cs) (xs output cs)

let Ast/Cons/DropdownOptions/TableEntries
    : Ast/DropdownOption/TableEntries ->
      Ast/DropdownOptions/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(x : Ast/DropdownOption/TableEntries) ->
      \(xs : Ast/DropdownOptions/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.TableEntries (x output cs) (xs output cs)

let Ast/Cons/DropdownOptions/Table
    : Ast/DropdownOption/Table ->
      Ast/DropdownOptions/Table ->
        Ast/DropdownOptions/Table
    = \(x : Ast/DropdownOption/Table) ->
      \(xs : Ast/DropdownOptions/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Table (x output cs) (xs output cs)

let Ast/Cons/DropdownOptions/Command
    : Ast/DropdownOption/Command ->
      Ast/DropdownOptions/Command ->
        Ast/DropdownOptions/Command
    = \(x : Ast/DropdownOption/Command) ->
      \(xs : Ast/DropdownOptions/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Command (x output cs) (xs output cs)

let Ast/Cons/Commands
    : Ast/Command -> Ast/Commands -> Ast/Commands
    = \(command : Ast/Command) ->
      \(list : Ast/Commands) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.Commands (command output cs) (list output cs)

let Ast/Extend/TableEntries
    : Ast/TableEntries -> Ast/TableEntries -> Ast/TableEntries
    = \(x : Ast/TableEntries) ->
      \(y : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Extend.TableEntries (x output cs) (y output cs)

let Ast/Extend/Table
    : Ast/Table -> Ast/TableEntries -> Ast/Table
    = \(x : Ast/Table) ->
      \(y : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Extend.Table (x output cs) (y output cs)

let Ast/Extend/Commands
    : Ast/Commands -> Ast/Commands -> Ast/Commands
    = \(x : Ast/Commands) ->
      \(y : Ast/Commands) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Extend.Commands (x output cs) (y output cs)

let Ast/Add/Integer
    : Ast/Integer -> Ast/Integer -> Ast/Integer
    = \(x : Ast/Integer) ->
      \(y : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Integer (x output cs) (y output cs)

let Ast/Add/Natural
    : Ast/Natural -> Ast/Natural -> Ast/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Natural (x output cs) (y output cs)

let Ast/Multiply/Integer
    : Ast/Integer -> Ast/Integer -> Ast/Integer
    = \(x : Ast/Integer) ->
      \(y : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Integer (x output cs) (y output cs)

let Ast/Multiply/Natural
    : Ast/Natural -> Ast/Natural -> Ast/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Natural (x output cs) (y output cs)

let Ast/Show/Integer
    : Ast/Integer -> Ast/Text
    = \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Integer (x output cs)

let Ast/Show/Natural
    : Ast/Natural -> Ast/Text
    = \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Natural (x output cs)

let Ast/Broadcast/Text
    : Ast/Text -> Ast/Command
    = \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Broadcast.Text (message output cs)

let Ast/Broadcast/Table
    : Ast/Table -> Ast/Command
    = \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Broadcast.Table (message output cs)

let Ast/BroadcastAs/Text
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).BroadcastAs.Text (char output cs) (message output cs)

let Ast/BroadcastAs/Table
    : Ast/Text -> Ast/Table -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).BroadcastAs.Table (char output cs) (message output cs)

let Ast/Emote
    : Ast/Text -> Ast/Command
    = \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Emote (message output cs)

let Ast/EmoteAs
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmoteAs (char output cs) (message output cs)

let Ast/Whisper/Text
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(to : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Whisper.Text (to output cs) (message output cs)

let Ast/Whisper/Table
    : Ast/Text -> Ast/Table -> Ast/Command
    = \(to : Ast/Text) ->
      \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Whisper.Table (to output cs) (message output cs)

let exampleAstBasicaMultiplication =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/Show/Integer
                          ( Ast/Multiply/Integer
                              (Ast/Literal/Integer -3)
                              (Ast/ToInteger (Ast/Literal/Natural 4))
                          )
                      )
                  )
              )
        ===  "[[((-3) * 4)]]"

let exampleAstUseTextualAttribute =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/PlusPlus
                          ( Ast/PlusPlus
                              (Ast/Literal/Text "I called ")
                              ( Ast/Attribute/Text
                                  { char = Target.Implicit, name = "attribute" }
                              )
                          )
                          (Ast/Literal/Text " just now")
                      )
                  )
              )
        ===  "I called @{attribute} just now"

let exampleAstSelectDiceSidesFromMathOnAttributesAndAbilities =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/Show/Natural
                          ( Ast/Dice
                              (Ast/Literal/Natural 4)
                              ( Ast/Add/Natural
                                  ( Ast/Attribute/Natural
                                      { char = Target.Selected
                                      , name = "some_att"
                                      }
                                  )
                                  ( Ast/Multiply/Natural
                                      ( Ast/Ability/Natural
                                          { char = Target.Implicit
                                          , name = "some_ab"
                                          }
                                      )
                                      (Ast/Literal/Natural 5)
                                  )
                              )
                          )
                      )
                  )
              )
        ===  "[[4d(@{selected|some_att} + (%{some_ab} * 5))]]"

let exampleAstNestedStringQueries =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/Dropdown/Text
                          "A"
                          ( Ast/ToDropdownOptions/Text
                              ( Ast/ToDropdownOption/Text
                                  "1"
                                  (Ast/Literal/Text "A1")
                              )
                              ( Ast/ToDropdownOption/Text
                                  "2"
                                  ( Ast/PlusPlus
                                      ( Ast/Literal/Text
                                          "You called the second level: "
                                      )
                                      ( Ast/Dropdown/Text
                                          "B"
                                          ( Ast/ToDropdownOptions/Text
                                              ( Ast/ToDropdownOption/Text
                                                  "1"
                                                  (Ast/Literal/Text "A2B1")
                                              )
                                              ( Ast/ToDropdownOption/Text
                                                  "2"
                                                  (Ast/Literal/Text "A2B2")
                                              )
                                          )
                                      )
                                  )
                              )
                          )
                      )
                  )
              )
        ===  "?{A|1,A1|2,You called the second level: ?{B&#124;1&#44;A2B1&#124;2&#44;A2B2&#125;}"

let exampleAstQueryDepthIsPreservedByTheConversionFromNaturalToText =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/Dropdown/Text
                          "A"
                          ( Ast/ToDropdownOptions/Text
                              ( Ast/ToDropdownOption/Text
                                  "1"
                                  (Ast/Literal/Text "A1")
                              )
                              ( Ast/ToDropdownOption/Text
                                  "2"
                                  ( Ast/PlusPlus
                                      ( Ast/Literal/Text
                                          "You called the second level: "
                                      )
                                      ( Ast/Show/Natural
                                          ( Ast/Dropdown/Natural
                                              "B"
                                              ( Ast/ToDropdownOptions/Natural
                                                  ( Ast/ToDropdownOption/Natural
                                                      "1"
                                                      (Ast/Literal/Natural 1221)
                                                  )
                                                  ( Ast/ToDropdownOption/Natural
                                                      "2"
                                                      (Ast/Literal/Natural 1222)
                                                  )
                                              )
                                          )
                                      )
                                  )
                              )
                          )
                      )
                  )
              )
        ===  "?{A|1,A1|2,You called the second level: [[?{B&#124;1&#44;1221&#124;2&#44;1222&#125;]]}"

let exampleAstDropdownOptionList =
        assert
      :     Ast/render
              ( Ast/Singleton/Commands
                  ( Ast/Broadcast/Text
                      ( Ast/Show/Natural
                          ( Ast/Dropdown/Natural
                              "Dropdown"
                              ( Ast/Cons/DropdownOptions/Natural
                                  ( Ast/ToDropdownOption/Natural
                                      "A"
                                      (Ast/Literal/Natural 1)
                                  )
                                  ( Ast/ToDropdownOptions/Natural
                                      ( Ast/ToDropdownOption/Natural
                                          "B"
                                          (Ast/Literal/Natural 2)
                                      )
                                      ( Ast/ToDropdownOption/Natural
                                          "C"
                                          (Ast/Literal/Natural 3)
                                      )
                                  )
                              )
                          )
                      )
                  )
              )
        ===  "[[?{Dropdown|A,1|B,2|C,3}]]"

in {=}