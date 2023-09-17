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
      , Random : Type -> Type
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
              , Random :
                  { Natural : Text -> output.Random output.Natural
                  , Integer : Text -> output.Random output.Integer
                  }
              , Text : Text -> output.Text
              }
          , Ability :
              { Natural : { char : Target, name : Text } -> output.Natural
              , Integer : { char : Target, name : Text } -> output.Integer
              , Random :
                  { Natural :
                      { char : Target, name : Text } ->
                        output.Random output.Natural
                  , Integer :
                      { char : Target, name : Text } ->
                        output.Random output.Integer
                  }
              , Text : { char : Target, name : Text } -> output.Text
              }
          , Attribute :
              { Natural : { char : Target, name : Text } -> output.Natural
              , Integer : { char : Target, name : Text } -> output.Integer
              , Random :
                  { Natural :
                      { char : Target, name : Text } ->
                        output.Random output.Natural
                  , Integer :
                      { char : Target, name : Text } ->
                        output.Random output.Integer
                  }
              , Text : { char : Target, name : Text } -> output.Text
              }
          , Input :
              { Natural : Text -> Optional output.Natural -> output.Natural
              , Integer : Text -> Optional output.Integer -> output.Integer
              , Text : Text -> Optional output.Text -> output.Text
              , Random :
                  { Natural :
                      Text ->
                      Optional (output.Random output.Natural) ->
                        output.Random output.Natural
                  , Integer :
                      Text ->
                      Optional (output.Random output.Integer) ->
                        output.Random output.Integer
                  }
              , Command : Text -> Optional output.Command -> output.Command
              }
          , DropdownOption :
              { Natural :
                  Text -> output.Natural -> output.DropdownOption output.Natural
              , Integer :
                  Text -> output.Integer -> output.DropdownOption output.Integer
              , Random :
                  { Natural :
                      Text ->
                      output.Random output.Natural ->
                        output.DropdownOption (output.Random output.Natural)
                  , Integer :
                      Text ->
                      output.Random output.Integer ->
                        output.DropdownOption (output.Random output.Integer)
                  }
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
              , Random :
                  { Natural :
                      output.DropdownOption (output.Random output.Natural) ->
                      output.DropdownOption (output.Random output.Natural) ->
                        output.DropdownOptions (output.Random output.Natural)
                  , Integer :
                      output.DropdownOption (output.Random output.Integer) ->
                      output.DropdownOption (output.Random output.Integer) ->
                        output.DropdownOptions (output.Random output.Integer)
                  }
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
              , Random :
                  { Natural :
                      Text ->
                      output.DropdownOptions (output.Random output.Natural) ->
                        output.Random output.Natural
                  , Integer :
                      Text ->
                      output.DropdownOptions (output.Random output.Integer) ->
                        output.Random output.Integer
                  }
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
          , ToInteger :
              { Natural : output.Natural -> output.Integer
              , Random :
                  { Natural :
                      output.Random output.Natural ->
                        output.Random output.Integer
                  }
              }
          , AbsoluteValue :
              { Integer : output.Integer -> output.Natural
              , Random :
                  { Integer :
                      output.Random output.Integer ->
                        output.Random output.Natural
                  }
              }
          , Dice :
              { Natural :
                  output.Natural ->
                  output.Natural ->
                    output.Random output.Natural
              , Random :
                  output.Random output.Natural ->
                  output.Random output.Natural ->
                    output.Random output.Natural
              }
          , ToRandom :
              { Natural : output.Natural -> output.Random output.Natural
              , Integer : output.Integer -> output.Random output.Integer
              }
          , Labeled :
              { Integer : output.Text -> output.Integer -> output.Integer
              , Natural : output.Text -> output.Natural -> output.Natural
              , Random :
                  { Natural :
                      output.Random output.Natural ->
                      output.Random output.Natural ->
                        output.Random output.Natural
                  , Integer :
                      output.Random output.Integer ->
                      output.Random output.Integer ->
                        output.Random output.Integer
                  }
              }
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
                  , Random :
                      { Natural :
                          output.DropdownOption
                            (output.Random output.Natural) ->
                          output.DropdownOptions
                            (output.Random output.Natural) ->
                            output.DropdownOptions
                              (output.Random output.Natural)
                      , Integer :
                          output.DropdownOption
                            (output.Random output.Integer) ->
                          output.DropdownOptions
                            (output.Random output.Integer) ->
                            output.DropdownOptions
                              (output.Random output.Integer)
                      }
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
          , PlusPlus :
              { Text : output.Text -> output.Text -> output.Text
              , TableEntries :
                  output.TableEntries ->
                  output.TableEntries ->
                    output.TableEntries
              , Table : output.Table -> output.TableEntries -> output.Table
              , Commands : output.Commands -> output.Commands -> output.Commands
              }
          , Add :
              { Integer : output.Integer -> output.Integer -> output.Integer
              , Natural : output.Natural -> output.Natural -> output.Natural
              , Random :
                  { Natural :
                      output.Random output.Natural ->
                      output.Random output.Natural ->
                        output.Random output.Natural
                  , Integer :
                      output.Random output.Integer ->
                      output.Random output.Integer ->
                        output.Random output.Integer
                  }
              }
          , Multiply :
              { Integer : output.Integer -> output.Integer -> output.Integer
              , Natural : output.Natural -> output.Natural -> output.Natural
              , Random :
                  { Natural :
                      output.Random output.Natural ->
                      output.Random output.Natural ->
                        output.Random output.Natural
                  , Integer :
                      output.Random output.Integer ->
                      output.Random output.Integer ->
                        output.Random output.Integer
                  }
              }
          , Show :
              { Integer : output.Integer -> output.Text
              , Natural : output.Natural -> output.Text
              , Random :
                  { Natural : output.Random output.Natural -> output.Text
                  , Integer : output.Random output.Integer -> output.Text
                  }
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
          , Roll :
              { Natural : output.Random output.Natural -> output.Command
              , Integer : output.Random output.Integer -> output.Command
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

let Ast/Random/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Random output.Natural

let Ast/Random/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.Random output.Integer

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

let Ast/DropdownOption/Random/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption (output.Random output.Natural)

let Ast/DropdownOption/Random/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOption (output.Random output.Integer)

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

let Ast/DropdownOptions/Random/Natural
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions (output.Random output.Natural)

let Ast/DropdownOptions/Random/Integer
    : Type
    = forall (output : Ast/Output) ->
      forall (cs : Ast/Constructors output) ->
        output.DropdownOptions (output.Random output.Integer)

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

let renderTarget =
      \(x : Target) ->
        merge
          { Implicit = ""
          , Selected = "selected|"
          , Named = \(name : Text) -> name ++ "|"
          }
          x

let inParens = \(x : Text) -> "(${x})"

let inDoubleBrackets = \(x : Text) -> "[[${x}]]"

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

let render
    : Ast/Commands -> Text
    = \(x : Ast/Commands) ->
        x
          { Integer = Text
          , Natural = Text
          , Random = \(a : Type) -> Text
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

                    let name = merge { None = "", Some = Text/id } optionalName

                    let nameEntry = "{{name=${name}${escapedEndBraces}"

                    in  "&{template:default${escapedEndBracket} ${nameEntry}${entries}"
              , Macro =
                  let f = \(t : Text) -> "#${t}"

                  let fNum = \(t : Text) -> inParens (f t)

                  let fRand = \(t : Text) -> inDoubleBrackets (f t)

                  in  { Natural = fNum
                      , Integer = fNum
                      , Random = { Natural = fRand, Integer = fRand }
                      , Text = f
                      }
              , Ability =
                  let f =
                        \(x : { char : Target, name : Text }) ->
                          "%{${renderTarget x.char}${x.name}}"

                  let fNum =
                        \(x : { char : Target, name : Text }) -> inParens (f x)

                  let fRand =
                        \(x : { char : Target, name : Text }) ->
                          inDoubleBrackets (f x)

                  in  { Natural = fNum
                      , Integer = fNum
                      , Random = { Natural = fRand, Integer = fRand }
                      , Text = f
                      }
              , Attribute =
                  let f =
                        \(x : { char : Target, name : Text }) ->
                          "@{${renderTarget x.char}${x.name}}"

                  let fNum =
                        \(x : { char : Target, name : Text }) -> inParens (f x)

                  let fRand =
                        \(x : { char : Target, name : Text }) ->
                          inDoubleBrackets (f x)

                  in  { Natural = fNum
                      , Integer = fNum
                      , Random = { Natural = fRand, Integer = fRand }
                      , Text = f
                      }
              , Input =
                  let f =
                        \(name : Text) ->
                        \(optionalDefault : Optional Text) ->
                              "?{"
                          ++  name
                          ++  merge
                                { None = ""
                                , Some =
                                    \(default : Text) ->
                                      renderQueryPipe queryDepth ++ default
                                }
                                optionalDefault
                          ++  renderQueryClosingBracket queryDepth

                  in  { Natural = f
                      , Integer = f
                      , Random = { Natural = f, Integer = f }
                      , Text = f
                      , Command = f
                      }
              , DropdownOption =
                  let f =
                        \(key : Text) ->
                        \(value : Text) ->
                          key ++ renderQueryComma queryDepth ++ value

                  in  { Natural = f
                      , Integer = f
                      , Random = { Natural = f, Integer = f }
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
                      , Random = { Natural = f, Integer = f }
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
                      , Random = { Natural = f, Integer = f }
                      , Text = f
                      , TableEntries = f
                      , Table = f
                      , Command = f
                      }
              , ToInteger = { Natural = Text/id, Random.Natural = Text/id }
              , AbsoluteValue =
                  let f = \(t : Text) -> "abs(${t})"

                  in  { Integer = f, Random.Integer = f }
              , Dice =
                { Natural =
                    \(count : Text) -> \(sides : Text) -> "${count}d${sides}"
                , Random =
                    \(count : Text) ->
                    \(sides : Text) ->
                      "[[${count}]]d[[${sides}]]"
                }
              , ToRandom = { Natural = Text/id, Integer = Text/id }
              , Labeled =
                  let f = \(label : Text) -> \(x : Text) -> "${x}[${label}]"

                  in  { Integer = f
                      , Natural = f
                      , Random = { Integer = f, Natural = f }
                      }
              , Cons =
                { DropdownOptions =
                    let f =
                          \(x : Text) ->
                          \(xs : Text) ->
                            x ++ renderQueryPipe queryDepth ++ xs

                    in  { Natural = f
                        , Integer = f
                        , Random = { Natural = f, Integer = f }
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
              , PlusPlus =
                { Text = \(a : Text) -> \(b : Text) -> a ++ b
                , TableEntries = \(a : Text) -> \(b : Text) -> a ++ " " ++ b
                , Table = \(a : Text) -> \(b : Text) -> a ++ " " ++ b
                , Commands = \(a : Text) -> \(b : Text) -> a ++ "\n" ++ b
                }
              , Add =
                  let f = \(a : Text) -> \(b : Text) -> "(${a} + ${b})"

                  in  { Integer = f
                      , Natural = f
                      , Random = { Natural = f, Integer = f }
                      }
              , Multiply =
                  let f = \(a : Text) -> \(b : Text) -> "(${a} * ${b})"

                  in  { Integer = f
                      , Natural = f
                      , Random = { Integer = f, Natural = f }
                      }
              , Show =
                  let f = \(t : Text) -> "[[${t}]]"

                  in  { Integer = f
                      , Natural = f
                      , Random = { Natural = f, Integer = f }
                      }
              , Broadcast = { Text = Text/id, Table = Text/id }
              , BroadcastAs =
                { Text = renderBroadcastAs, Table = renderBroadcastAs }
              , Emote = Text/id
              , EmoteAs = renderEmoteAs
              , Whisper = { Text = renderWhisper, Table = renderWhisper }
              , Roll =
                  let f = \(r : Text) -> "/r ${r}"

                  in  { Natural = f, Integer = f }
              }
          )

let literal/Integer
    : Integer -> Ast/Integer
    = \(x : Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Integer x

let literal/Natural
    : Natural -> Ast/Natural
    = \(x : Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Natural x

let literal/Text
    : Text -> Ast/Text
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Literal.Text x

let tableEntries/Empty
    : Ast/TableEntries
    = \(output : Ast/Output) -> \(cs : Ast/Constructors output) -> (cs 0).Empty

let singleton/TableEntries
    : Ast/Text -> Ast/Text -> Ast/TableEntries
    = \(key : Ast/Text) ->
      \(value : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Singleton.TableEntries (key output cs) (value output cs)

let singleton/Commands
    : Ast/Command -> Ast/Commands
    = \(command : Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Singleton.Commands (command output cs)

let toTable
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

let macro/Integer
    : Text -> Ast/Integer
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Integer x

let macro/Natural
    : Text -> Ast/Natural
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Natural x

let macro/Text
    : Text -> Ast/Text
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Text x

let macro/Random/Integer
    : Text -> Ast/Random/Integer
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Random.Integer x

let macro/Random/Natural
    : Text -> Ast/Random/Natural
    = \(x : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Macro.Random.Natural x

let ability/Integer
    : { char : Target, name : Text } -> Ast/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Integer x

let ability/Natural
    : { char : Target, name : Text } -> Ast/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Natural x

let ability/Text
    : { char : Target, name : Text } -> Ast/Text
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Text x

let ability/Random/Integer
    : { char : Target, name : Text } -> Ast/Random/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Random.Integer x

let ability/Random/Natural
    : { char : Target, name : Text } -> Ast/Random/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Random.Natural x

let attribute/Integer
    : { char : Target, name : Text } -> Ast/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Integer x

let attribute/Natural
    : { char : Target, name : Text } -> Ast/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Natural x

let attribute/Random/Integer
    : { char : Target, name : Text } -> Ast/Random/Integer
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Random.Integer x

let attribute/Random/Natural
    : { char : Target, name : Text } -> Ast/Random/Natural
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Random.Natural x

let attribute/Text
    : { char : Target, name : Text } -> Ast/Text
    = \(x : { char : Target, name : Text }) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Text x

let input/Natural
    : Text -> Optional Ast/Natural -> Ast/Natural
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Natural
          name
          ( Optional/map
              Ast/Natural
              output.Natural
              (\(default : Ast/Natural) -> default output cs)
              optionalDefault
          )

let input/Integer
    : Text -> Optional Ast/Integer -> Ast/Integer
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Integer
          name
          ( Optional/map
              Ast/Integer
              output.Integer
              (\(default : Ast/Integer) -> default output cs)
              optionalDefault
          )

let input/Text
    : Text -> Optional Ast/Text -> Ast/Text
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Text
          name
          ( Optional/map
              Ast/Text
              output.Text
              (\(default : Ast/Text) -> default output cs)
              optionalDefault
          )

let input/Command
    : Text -> Optional Ast/Command -> Ast/Command
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Command
          name
          ( Optional/map
              Ast/Command
              output.Command
              (\(default : Ast/Command) -> default output cs)
              optionalDefault
          )

let input/Random/Natural
    : Text -> Optional Ast/Random/Natural -> Ast/Random/Natural
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Random.Natural
          name
          ( Optional/map
              Ast/Random/Natural
              (output.Random output.Natural)
              (\(default : Ast/Random/Natural) -> default output cs)
              optionalDefault
          )

let input/Random/Integer
    : Text -> Optional Ast/Random/Integer -> Ast/Random/Integer
    = \(name : Text) ->
      \(optionalDefault : Optional Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Input.Random.Integer
          name
          ( Optional/map
              Ast/Random/Integer
              (output.Random output.Integer)
              (\(default : Ast/Random/Integer) -> default output cs)
              optionalDefault
          )

let toDropdownOption/Natural
    : Text -> Ast/Natural -> Ast/DropdownOption/Natural
    = \(key : Text) ->
      \(value : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Natural
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Integer
    : Text -> Ast/Integer -> Ast/DropdownOption/Integer
    = \(key : Text) ->
      \(value : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Integer
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Random/Natural
    : Text -> Ast/Random/Natural -> Ast/DropdownOption/Random/Natural
    = \(key : Text) ->
      \(value : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Random.Natural
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Random/Integer
    : Text -> Ast/Random/Integer -> Ast/DropdownOption/Random/Integer
    = \(key : Text) ->
      \(value : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Random.Integer
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Text
    : Text -> Ast/Text -> Ast/DropdownOption/Text
    = \(key : Text) ->
      \(value : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Text
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/TableEntries
    : Text -> Ast/TableEntries -> Ast/DropdownOption/TableEntries
    = \(key : Text) ->
      \(value : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.TableEntries
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Table
    : Text -> Ast/Table -> Ast/DropdownOption/Table
    = \(key : Text) ->
      \(value : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Table
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOption/Command
    : Text -> Ast/Command -> Ast/DropdownOption/Command
    = \(key : Text) ->
      \(value : Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).DropdownOption.Command
          key
          (value output (\(d : Natural) -> cs (d + 1)))

let toDropdownOptions/Natural
    : Ast/DropdownOption/Natural ->
      Ast/DropdownOption/Natural ->
        Ast/DropdownOptions/Natural
    = \(a : Ast/DropdownOption/Natural) ->
      \(b : Ast/DropdownOption/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Natural (a output cs) (b output cs)

let toDropdownOptions/Integer
    : Ast/DropdownOption/Integer ->
      Ast/DropdownOption/Integer ->
        Ast/DropdownOptions/Integer
    = \(a : Ast/DropdownOption/Integer) ->
      \(b : Ast/DropdownOption/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Integer (a output cs) (b output cs)

let toDropdownOptions/Random/Natural
    : Ast/DropdownOption/Random/Natural ->
      Ast/DropdownOption/Random/Natural ->
        Ast/DropdownOptions/Random/Natural
    = \(a : Ast/DropdownOption/Random/Natural) ->
      \(b : Ast/DropdownOption/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Random.Natural (a output cs) (b output cs)

let toDropdownOptions/Random/Integer
    : Ast/DropdownOption/Random/Integer ->
      Ast/DropdownOption/Random/Integer ->
        Ast/DropdownOptions/Random/Integer
    = \(a : Ast/DropdownOption/Random/Integer) ->
      \(b : Ast/DropdownOption/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Random.Integer (a output cs) (b output cs)

let toDropdownOptions/Text
    : Ast/DropdownOption/Text ->
      Ast/DropdownOption/Text ->
        Ast/DropdownOptions/Text
    = \(a : Ast/DropdownOption/Text) ->
      \(b : Ast/DropdownOption/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Text (a output cs) (b output cs)

let toDropdownOptions/TableEntries
    : Ast/DropdownOption/TableEntries ->
      Ast/DropdownOption/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(a : Ast/DropdownOption/TableEntries) ->
      \(b : Ast/DropdownOption/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.TableEntries (a output cs) (b output cs)

let toDropdownOptions/Table
    : Ast/DropdownOption/Table ->
      Ast/DropdownOption/Table ->
        Ast/DropdownOptions/Table
    = \(a : Ast/DropdownOption/Table) ->
      \(b : Ast/DropdownOption/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Table (a output cs) (b output cs)

let toDropdownOptions/Command
    : Ast/DropdownOption/Command ->
      Ast/DropdownOption/Command ->
        Ast/DropdownOptions/Command
    = \(a : Ast/DropdownOption/Command) ->
      \(b : Ast/DropdownOption/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToDropdownOptions.Command (a output cs) (b output cs)

let dropdown/Natural
    : Text -> Ast/DropdownOptions/Natural -> Ast/Natural
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Natural name (options output cs)

let dropdown/Integer
    : Text -> Ast/DropdownOptions/Integer -> Ast/Integer
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Integer name (options output cs)

let dropdown/Random/Natural
    : Text -> Ast/DropdownOptions/Random/Natural -> Ast/Random/Natural
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Random.Natural name (options output cs)

let dropdown/Random/Integer
    : Text -> Ast/DropdownOptions/Random/Integer -> Ast/Random/Integer
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Random.Integer name (options output cs)

let dropdown/Text
    : Text -> Ast/DropdownOptions/Text -> Ast/Text
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Text name (options output cs)

let dropdown/TableEntries
    : Text -> Ast/DropdownOptions/TableEntries -> Ast/TableEntries
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.TableEntries name (options output cs)

let dropdown/Table
    : Text -> Ast/DropdownOptions/Table -> Ast/Table
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Table name (options output cs)

let dropdown/Command
    : Text -> Ast/DropdownOptions/Command -> Ast/Command
    = \(name : Text) ->
      \(options : Ast/DropdownOptions/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dropdown.Command name (options output cs)

let toInteger/Natural
    : Ast/Natural -> Ast/Integer
    = \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToInteger.Natural (x output cs)

let toInteger/Random/Natural
    : Ast/Random/Natural -> Ast/Random/Integer
    = \(x : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToInteger.Random.Natural (x output cs)

let absoluteValue/Integer
    : Ast/Integer -> Ast/Natural
    = \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).AbsoluteValue.Integer (x output cs)

let absoluteValue/Random/Integer
    : Ast/Random/Integer -> Ast/Random/Natural
    = \(x : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).AbsoluteValue.Random.Integer (x output cs)

let dice/Natural
    : Ast/Natural -> Ast/Natural -> Ast/Random/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dice.Natural (x output cs) (y output cs)

let dice/Random
    : Ast/Random/Natural -> Ast/Random/Natural -> Ast/Random/Natural
    = \(x : Ast/Random/Natural) ->
      \(y : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Dice.Random (x output cs) (y output cs)

let toRandom/Natural
    : Ast/Natural -> Ast/Random/Natural
    = \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToRandom.Natural (x output cs)

let toRandom/Integer
    : Ast/Integer -> Ast/Random/Integer
    = \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).ToRandom.Integer (x output cs)

let label/Integer
    : Ast/Text -> Ast/Integer -> Ast/Integer
    = \(label : Ast/Text) ->
      \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Labeled.Integer (label output cs) (x output cs)

let label/Natural
    : Ast/Text -> Ast/Natural -> Ast/Natural
    = \(label : Ast/Text) ->
      \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Labeled.Natural (label output cs) (x output cs)

let cons/DropdownOptions/Natural
    : Ast/DropdownOption/Natural ->
      Ast/DropdownOptions/Natural ->
        Ast/DropdownOptions/Natural
    = \(x : Ast/DropdownOption/Natural) ->
      \(xs : Ast/DropdownOptions/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Natural (x output cs) (xs output cs)

let cons/DropdownOptions/Integer
    : Ast/DropdownOption/Integer ->
      Ast/DropdownOptions/Integer ->
        Ast/DropdownOptions/Integer
    = \(x : Ast/DropdownOption/Integer) ->
      \(xs : Ast/DropdownOptions/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Integer (x output cs) (xs output cs)

let cons/DropdownOptions/Random/Natural
    : Ast/DropdownOption/Random/Natural ->
      Ast/DropdownOptions/Random/Natural ->
        Ast/DropdownOptions/Random/Natural
    = \(x : Ast/DropdownOption/Random/Natural) ->
      \(xs : Ast/DropdownOptions/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Random.Natural (x output cs) (xs output cs)

let cons/DropdownOptions/Random/Integer
    : Ast/DropdownOption/Random/Integer ->
      Ast/DropdownOptions/Random/Integer ->
        Ast/DropdownOptions/Random/Integer
    = \(x : Ast/DropdownOption/Random/Integer) ->
      \(xs : Ast/DropdownOptions/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Random.Integer (x output cs) (xs output cs)

let cons/DropdownOptions/Text
    : Ast/DropdownOption/Text ->
      Ast/DropdownOptions/Text ->
        Ast/DropdownOptions/Text
    = \(x : Ast/DropdownOption/Text) ->
      \(xs : Ast/DropdownOptions/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Text (x output cs) (xs output cs)

let cons/DropdownOptions/TableEntries
    : Ast/DropdownOption/TableEntries ->
      Ast/DropdownOptions/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(x : Ast/DropdownOption/TableEntries) ->
      \(xs : Ast/DropdownOptions/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.TableEntries (x output cs) (xs output cs)

let cons/DropdownOptions/Table
    : Ast/DropdownOption/Table ->
      Ast/DropdownOptions/Table ->
        Ast/DropdownOptions/Table
    = \(x : Ast/DropdownOption/Table) ->
      \(xs : Ast/DropdownOptions/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Table (x output cs) (xs output cs)

let cons/DropdownOptions/Command
    : Ast/DropdownOption/Command ->
      Ast/DropdownOptions/Command ->
        Ast/DropdownOptions/Command
    = \(x : Ast/DropdownOption/Command) ->
      \(xs : Ast/DropdownOptions/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Command (x output cs) (xs output cs)

let cons/Commands
    : Ast/Command -> Ast/Commands -> Ast/Commands
    = \(command : Ast/Command) ->
      \(list : Ast/Commands) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.Commands (command output cs) (list output cs)

let plusPlus/Text
    : Ast/Text -> Ast/Text -> Ast/Text
    = \(x : Ast/Text) ->
      \(y : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).PlusPlus.Text (x output cs) (y output cs)

let plusPlus/TableEntries
    : Ast/TableEntries -> Ast/TableEntries -> Ast/TableEntries
    = \(x : Ast/TableEntries) ->
      \(y : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).PlusPlus.TableEntries (x output cs) (y output cs)

let plusPlus/Table
    : Ast/Table -> Ast/TableEntries -> Ast/Table
    = \(x : Ast/Table) ->
      \(y : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).PlusPlus.Table (x output cs) (y output cs)

let plusPlus/Commands
    : Ast/Commands -> Ast/Commands -> Ast/Commands
    = \(x : Ast/Commands) ->
      \(y : Ast/Commands) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).PlusPlus.Commands (x output cs) (y output cs)

let add/Integer
    : Ast/Integer -> Ast/Integer -> Ast/Integer
    = \(x : Ast/Integer) ->
      \(y : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Integer (x output cs) (y output cs)

let add/Natural
    : Ast/Natural -> Ast/Natural -> Ast/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Natural (x output cs) (y output cs)

let add/Random/Natural
    : Ast/Random/Natural -> Ast/Random/Natural -> Ast/Random/Natural
    = \(x : Ast/Random/Natural) ->
      \(y : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Random.Natural (x output cs) (y output cs)

let add/Random/Integer
    : Ast/Random/Integer -> Ast/Random/Integer -> Ast/Random/Integer
    = \(x : Ast/Random/Integer) ->
      \(y : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Add.Random.Integer (x output cs) (y output cs)

let multiply/Integer
    : Ast/Integer -> Ast/Integer -> Ast/Integer
    = \(x : Ast/Integer) ->
      \(y : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Integer (x output cs) (y output cs)

let multiply/Natural
    : Ast/Natural -> Ast/Natural -> Ast/Natural
    = \(x : Ast/Natural) ->
      \(y : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Natural (x output cs) (y output cs)

let multiply/Random/Integer
    : Ast/Random/Integer -> Ast/Random/Integer -> Ast/Random/Integer
    = \(x : Ast/Random/Integer) ->
      \(y : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Random.Integer (x output cs) (y output cs)

let multiply/Random/Natural
    : Ast/Random/Natural -> Ast/Random/Natural -> Ast/Random/Natural
    = \(x : Ast/Random/Natural) ->
      \(y : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Multiply.Random.Natural (x output cs) (y output cs)

let show/Integer
    : Ast/Integer -> Ast/Text
    = \(x : Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Integer (x output cs)

let show/Natural
    : Ast/Natural -> Ast/Text
    = \(x : Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Natural (x output cs)

let show/Random/Natural
    : Ast/Random/Natural -> Ast/Text
    = \(x : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Random.Natural (x output cs)

let show/Random/Integer
    : Ast/Random/Integer -> Ast/Text
    = \(x : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Show.Random.Integer (x output cs)

let broadcast/Text
    : Ast/Text -> Ast/Command
    = \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Broadcast.Text (message output cs)

let broadcast/Table
    : Ast/Table -> Ast/Command
    = \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Broadcast.Table (message output cs)

let broadcastAs/Text
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).BroadcastAs.Text (char output cs) (message output cs)

let broadcastAs/Table
    : Ast/Text -> Ast/Table -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).BroadcastAs.Table (char output cs) (message output cs)

let emote
    : Ast/Text -> Ast/Command
    = \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Emote (message output cs)

let emoteAs
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(char : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).EmoteAs (char output cs) (message output cs)

let whisper/Text
    : Ast/Text -> Ast/Text -> Ast/Command
    = \(to : Ast/Text) ->
      \(message : Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Whisper.Text (to output cs) (message output cs)

let whisper/Table
    : Ast/Text -> Ast/Table -> Ast/Command
    = \(to : Ast/Text) ->
      \(message : Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Whisper.Table (to output cs) (message output cs)

let roll/Natural
    : Ast/Random/Natural -> Ast/Command
    = \(random : Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Roll.Natural (random output cs)

let roll/Integer
    : Ast/Random/Integer -> Ast/Command
    = \(random : Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Roll.Integer (random output cs)

let exampleAstBasicaMultiplication =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( show/Integer
                          ( multiply/Integer
                              (literal/Integer -3)
                              (toInteger/Natural (literal/Natural 4))
                          )
                      )
                  )
              )
        ===  "[[((-3) * 4)]]"

let exampleAstUseTextualAttribute =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( plusPlus/Text
                          ( plusPlus/Text
                              (literal/Text "I called ")
                              ( attribute/Text
                                  { char = Target.Implicit, name = "attribute" }
                              )
                          )
                          (literal/Text " just now")
                      )
                  )
              )
        ===  "I called @{attribute} just now"

let exampleAstSelectDiceSidesFromMathOnAttributesAndAbilities =
        assert
      :     render
              ( singleton/Commands
                  ( roll/Natural
                      ( dice/Natural
                          (literal/Natural 4)
                          ( add/Natural
                              ( attribute/Natural
                                  { char = Target.Selected, name = "some_att" }
                              )
                              ( multiply/Natural
                                  ( ability/Natural
                                      { char = Target.Implicit
                                      , name = "some_ab"
                                      }
                                  )
                                  (literal/Natural 5)
                              )
                          )
                      )
                  )
              )
        ===  "/r 4d((@{selected|some_att}) + ((%{some_ab}) * 5))"

let exampleAstSelectDiceSidesARandomValue =
        assert
      :     render
              ( singleton/Commands
                  ( roll/Natural
                      ( dice/Random
                          (toRandom/Natural (literal/Natural 4))
                          ( add/Random/Natural
                              ( dice/Natural
                                  (literal/Natural 1)
                                  (literal/Natural 6)
                              )
                              (toRandom/Natural (literal/Natural 2))
                          )
                      )
                  )
              )
        ===  "/r [[4]]d[[(1d6 + 2)]]"

let exampleAstNestedStringQueries =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( dropdown/Text
                          "A"
                          ( toDropdownOptions/Text
                              (toDropdownOption/Text "1" (literal/Text "A1"))
                              ( toDropdownOption/Text
                                  "2"
                                  ( plusPlus/Text
                                      ( literal/Text
                                          "You called the second level: "
                                      )
                                      ( dropdown/Text
                                          "B"
                                          ( toDropdownOptions/Text
                                              ( toDropdownOption/Text
                                                  "1"
                                                  (literal/Text "A2B1")
                                              )
                                              ( toDropdownOption/Text
                                                  "2"
                                                  (literal/Text "A2B2")
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
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( dropdown/Text
                          "A"
                          ( toDropdownOptions/Text
                              (toDropdownOption/Text "1" (literal/Text "A1"))
                              ( toDropdownOption/Text
                                  "2"
                                  ( plusPlus/Text
                                      ( literal/Text
                                          "You called the second level: "
                                      )
                                      ( show/Natural
                                          ( dropdown/Natural
                                              "B"
                                              ( toDropdownOptions/Natural
                                                  ( toDropdownOption/Natural
                                                      "1"
                                                      (literal/Natural 1221)
                                                  )
                                                  ( toDropdownOption/Natural
                                                      "2"
                                                      (literal/Natural 1222)
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
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( show/Natural
                          ( dropdown/Natural
                              "Dropdown"
                              ( cons/DropdownOptions/Natural
                                  ( toDropdownOption/Natural
                                      "A"
                                      (literal/Natural 1)
                                  )
                                  ( toDropdownOptions/Natural
                                      ( toDropdownOption/Natural
                                          "B"
                                          (literal/Natural 2)
                                      )
                                      ( toDropdownOption/Natural
                                          "C"
                                          (literal/Natural 3)
                                      )
                                  )
                              )
                          )
                      )
                  )
              )
        ===  "[[?{Dropdown|A,1|B,2|C,3}]]"

in {=}
