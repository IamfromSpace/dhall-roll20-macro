let Integer/abs =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Integer/abs.dhall
        sha256:35212fcbe1e60cb95b033a4a9c6e45befca4a298aa9919915999d09e69ddced1

let Integer/greaterThan =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Integer/greaterThan.dhall
        sha256:d23affd73029fc9aaf867c2c7b86510ca2802d3f0d1f3e1d1a93ffd87b7cb64b

let Optional/map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Optional/map.dhall
        sha256:501534192d988218d43261c299cc1d1e0b13d25df388937add784778ab0054fa

let Text/replicate =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Text/replicate.dhall
        sha256:1b398b1d464b3a6c7264a690ac3cacb443b5683b43348c859d68e7c2cb925c4f

let List/drop =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/drop.dhall
        sha256:af983ba3ead494dd72beed05c0f3a17c36a4244adedf7ced502c6512196ed0cf

let List/foldLeft =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/foldLeft.dhall
        sha256:3c6ab57950fe644906b7bbdef0b9523440b6ee17773ebb8cbd41ffacb8bfab61

let Text/id = \(x : Text) -> x

let List/monoFold =
      \(a : Type) ->
      \(mappend : a -> a -> a) ->
      \(mempty : a) ->
      \(xs : List a) ->
        merge
          { None = mempty
          , Some =
              \(first : a) -> List/foldLeft a (List/drop 1 a xs) a mappend first
          }
          (List/head a xs)

let Character = < Target | Selected | Named : Text | Implicit >

let DropdownOption = \(a : Type) -> { label : Text, value : a }

let dropdownOption =
      \(a : Type) -> \(label : Text) -> \(value : a) -> { label, value }

let DropdownOption/map =
      \(a : Type) ->
      \(b : Type) ->
      \(f : a -> b) ->
      \(x : DropdownOption a) ->
        { label = x.label, value = f x.value }

let Ast/Output =
      { Natural : Type
      , Integer : Type
      , Random : Type -> Type
      , Text : Type
      , TableEntries : Type
      , Table : Type
      , Command : Type
      , Commands : Type
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
          , Empty :
              { TableEntries : output.TableEntries, Commands : output.Commands }
          , Singleton :
              { TableEntries : output.Text -> output.Text -> output.TableEntries
              , Commands : output.Command -> output.Commands
              }
          , Pair :
              { DropdownOptions :
                  { Natural :
                      DropdownOption output.Natural ->
                      DropdownOption output.Natural ->
                        output.DropdownOptions output.Natural
                  , Integer :
                      DropdownOption output.Integer ->
                      DropdownOption output.Integer ->
                        output.DropdownOptions output.Integer
                  , Random :
                      { Natural :
                          DropdownOption (output.Random output.Natural) ->
                          DropdownOption (output.Random output.Natural) ->
                            output.DropdownOptions
                              (output.Random output.Natural)
                      , Integer :
                          DropdownOption (output.Random output.Integer) ->
                          DropdownOption (output.Random output.Integer) ->
                            output.DropdownOptions
                              (output.Random output.Integer)
                      }
                  , Text :
                      DropdownOption output.Text ->
                      DropdownOption output.Text ->
                        output.DropdownOptions output.Text
                  , TableEntries :
                      DropdownOption output.TableEntries ->
                      DropdownOption output.TableEntries ->
                        output.DropdownOptions output.TableEntries
                  , Table :
                      DropdownOption output.Table ->
                      DropdownOption output.Table ->
                        output.DropdownOptions output.Table
                  , Command :
                      DropdownOption output.Command ->
                      DropdownOption output.Command ->
                        output.DropdownOptions output.Command
                  }
              }
          , Table : Optional output.Text -> output.TableEntries -> output.Table
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
              { Natural : Character -> Text -> output.Natural
              , Integer : Character -> Text -> output.Integer
              , Random :
                  { Natural : Character -> Text -> output.Random output.Natural
                  , Integer : Character -> Text -> output.Random output.Integer
                  }
              , Text : Character -> Text -> output.Text
              }
          , Attribute :
              { Natural : Character -> Text -> output.Natural
              , Integer : Character -> Text -> output.Integer
              , Random :
                  { Natural : Character -> Text -> output.Random output.Natural
                  , Integer : Character -> Text -> output.Random output.Integer
                  }
              , Text : Character -> Text -> output.Text
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
                      DropdownOption output.Natural ->
                      output.DropdownOptions output.Natural ->
                        output.DropdownOptions output.Natural
                  , Integer :
                      DropdownOption output.Integer ->
                      output.DropdownOptions output.Integer ->
                        output.DropdownOptions output.Integer
                  , Random :
                      { Natural :
                          DropdownOption (output.Random output.Natural) ->
                          output.DropdownOptions
                            (output.Random output.Natural) ->
                            output.DropdownOptions
                              (output.Random output.Natural)
                      , Integer :
                          DropdownOption (output.Random output.Integer) ->
                          output.DropdownOptions
                            (output.Random output.Integer) ->
                            output.DropdownOptions
                              (output.Random output.Integer)
                      }
                  , Text :
                      DropdownOption output.Text ->
                      output.DropdownOptions output.Text ->
                        output.DropdownOptions output.Text
                  , TableEntries :
                      DropdownOption output.TableEntries ->
                      output.DropdownOptions output.TableEntries ->
                        output.DropdownOptions output.TableEntries
                  , Table :
                      DropdownOption output.Table ->
                      output.DropdownOptions output.Table ->
                        output.DropdownOptions output.Table
                  , Command :
                      DropdownOption output.Command ->
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
    = DropdownOption Ast/Natural

let Ast/DropdownOption/Integer
    : Type
    = DropdownOption Ast/Integer

let Ast/DropdownOption/Random/Natural
    : Type
    = DropdownOption Ast/Random/Natural

let Ast/DropdownOption/Random/Integer
    : Type
    = DropdownOption Ast/Random/Integer

let Ast/DropdownOption/Text
    : Type
    = DropdownOption Ast/Text

let Ast/DropdownOption/TableEntries
    : Type
    = DropdownOption Ast/TableEntries

let Ast/DropdownOption/Table
    : Type
    = DropdownOption Ast/Table

let Ast/DropdownOption/Command
    : Type
    = DropdownOption Ast/Command

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

let renderCharacter =
      \(x : Character) ->
        merge
          { Implicit = ""
          , Target = "target|"
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

let renderDropdownOption =
      \(queryDepth : Natural) ->
      \(x : DropdownOption Text) ->
        x.label ++ renderQueryComma queryDepth ++ x.value

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
              , Empty = { TableEntries = "", Commands = "" }
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
              , Pair.DropdownOptions
                =
                  let f =
                        \(a : DropdownOption Text) ->
                        \(b : DropdownOption Text) ->
                              renderDropdownOption queryDepth a
                          ++  renderQueryPipe queryDepth
                          ++  renderDropdownOption queryDepth b

                  in  { Natural = f
                      , Integer = f
                      , Random = { Natural = f, Integer = f }
                      , Text = f
                      , TableEntries = f
                      , Table = f
                      , Command = f
                      }
              , Table =
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
                        \(char : Character) ->
                        \(name : Text) ->
                          "%{${renderCharacter char}${name}}"

                  let fNum =
                        \(char : Character) ->
                        \(name : Text) ->
                          inParens (f char name)

                  let fRand =
                        \(char : Character) ->
                        \(name : Text) ->
                          inDoubleBrackets (f char name)

                  in  { Natural = fNum
                      , Integer = fNum
                      , Random = { Natural = fRand, Integer = fRand }
                      , Text = f
                      }
              , Attribute =
                  let f =
                        \(char : Character) ->
                        \(name : Text) ->
                          "@{${renderCharacter char}${name}}"

                  let fNum =
                        \(char : Character) ->
                        \(name : Text) ->
                          inParens (f char name)

                  let fRand =
                        \(char : Character) ->
                        \(name : Text) ->
                          inDoubleBrackets (f char name)

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
                          \(x : DropdownOption Text) ->
                          \(xs : Text) ->
                                renderDropdownOption queryDepth x
                            ++  renderQueryPipe queryDepth
                            ++  xs

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

let empty/TableEntries
    : Ast/TableEntries
    = \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Empty.TableEntries

let empty/Commands
    : Ast/Commands
    = \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Empty.Commands

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

let pair/DropdownOptions/Natural
    : DropdownOption Ast/Natural ->
      DropdownOption Ast/Natural ->
        Ast/DropdownOptions/Natural
    = \(a : DropdownOption Ast/Natural) ->
      \(b : DropdownOption Ast/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Natural
          ( DropdownOption/map
              Ast/Natural
              output.Natural
              (\(x : Ast/Natural) -> x output (\(d : Natural) -> cs (d + 1)))
              a
          )
          ( DropdownOption/map
              Ast/Natural
              output.Natural
              (\(x : Ast/Natural) -> x output (\(d : Natural) -> cs (d + 1)))
              b
          )

let pair/DropdownOptions/Integer
    : DropdownOption Ast/Integer ->
      DropdownOption Ast/Integer ->
        Ast/DropdownOptions/Integer
    = \(a : DropdownOption Ast/Integer) ->
      \(b : DropdownOption Ast/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Integer
          ( DropdownOption/map
              Ast/Integer
              output.Integer
              (\(x : Ast/Integer) -> x output (\(d : Natural) -> cs (d + 1)))
              a
          )
          ( DropdownOption/map
              Ast/Integer
              output.Integer
              (\(x : Ast/Integer) -> x output (\(d : Natural) -> cs (d + 1)))
              b
          )

let pair/DropdownOptions/Random/Natural
    : DropdownOption Ast/Random/Natural ->
      DropdownOption Ast/Random/Natural ->
        Ast/DropdownOptions/Random/Natural
    = \(a : DropdownOption Ast/Random/Natural) ->
      \(b : DropdownOption Ast/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Random.Natural
          ( DropdownOption/map
              Ast/Random/Natural
              (output.Random output.Natural)
              ( \(x : Ast/Random/Natural) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              a
          )
          ( DropdownOption/map
              Ast/Random/Natural
              (output.Random output.Natural)
              ( \(x : Ast/Random/Natural) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              a
          )

let pair/DropdownOptions/Random/Integer
    : DropdownOption Ast/Random/Integer ->
      DropdownOption Ast/Random/Integer ->
        Ast/DropdownOptions/Random/Integer
    = \(a : DropdownOption Ast/Random/Integer) ->
      \(b : DropdownOption Ast/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Random.Integer
          ( DropdownOption/map
              Ast/Random/Integer
              (output.Random output.Integer)
              ( \(x : Ast/Random/Integer) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              a
          )
          ( DropdownOption/map
              Ast/Random/Integer
              (output.Random output.Integer)
              ( \(x : Ast/Random/Integer) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              a
          )

let pair/DropdownOptions/Text
    : DropdownOption Ast/Text ->
      DropdownOption Ast/Text ->
        Ast/DropdownOptions/Text
    = \(a : DropdownOption Ast/Text) ->
      \(b : DropdownOption Ast/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Text
          ( DropdownOption/map
              Ast/Text
              output.Text
              (\(x : Ast/Text) -> x output (\(d : Natural) -> cs (d + 1)))
              a
          )
          ( DropdownOption/map
              Ast/Text
              output.Text
              (\(x : Ast/Text) -> x output (\(d : Natural) -> cs (d + 1)))
              b
          )

let pair/DropdownOptions/TableEntries
    : DropdownOption Ast/TableEntries ->
      DropdownOption Ast/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(a : DropdownOption Ast/TableEntries) ->
      \(b : DropdownOption Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.TableEntries
          ( DropdownOption/map
              Ast/TableEntries
              output.TableEntries
              ( \(x : Ast/TableEntries) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              a
          )
          ( DropdownOption/map
              Ast/TableEntries
              output.TableEntries
              ( \(x : Ast/TableEntries) ->
                  x output (\(d : Natural) -> cs (d + 1))
              )
              b
          )

let pair/DropdownOptions/Table
    : DropdownOption Ast/Table ->
      DropdownOption Ast/Table ->
        Ast/DropdownOptions/Table
    = \(a : DropdownOption Ast/Table) ->
      \(b : DropdownOption Ast/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Table
          ( DropdownOption/map
              Ast/Table
              output.Table
              (\(x : Ast/Table) -> x output (\(d : Natural) -> cs (d + 1)))
              a
          )
          ( DropdownOption/map
              Ast/Table
              output.Table
              (\(x : Ast/Table) -> x output (\(d : Natural) -> cs (d + 1)))
              b
          )

let pair/DropdownOptions/Command
    : DropdownOption Ast/Command ->
      DropdownOption Ast/Command ->
        Ast/DropdownOptions/Command
    = \(a : DropdownOption Ast/Command) ->
      \(b : DropdownOption Ast/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Pair.DropdownOptions.Command
          ( DropdownOption/map
              Ast/Command
              output.Command
              (\(x : Ast/Command) -> x output (\(d : Natural) -> cs (d + 1)))
              a
          )
          ( DropdownOption/map
              Ast/Command
              output.Command
              (\(x : Ast/Command) -> x output (\(d : Natural) -> cs (d + 1)))
              b
          )

let table
    : Optional Ast/Text -> Ast/TableEntries -> Ast/Table
    = \(optionalName : Optional Ast/Text) ->
      \(entries : Ast/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Table
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
    : Character -> Text -> Ast/Integer
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Integer char name

let ability/Natural
    : Character -> Text -> Ast/Natural
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Natural char name

let ability/Text
    : Character -> Text -> Ast/Text
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Text char name

let ability/Random/Integer
    : Character -> Text -> Ast/Random/Integer
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Random.Integer char name

let ability/Random/Natural
    : Character -> Text -> Ast/Random/Natural
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Ability.Random.Natural char name

let attribute/Integer
    : Character -> Text -> Ast/Integer
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Integer char name

let attribute/Natural
    : Character -> Text -> Ast/Natural
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Natural char name

let attribute/Random/Integer
    : Character -> Text -> Ast/Random/Integer
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Random.Integer char name

let attribute/Random/Natural
    : Character -> Text -> Ast/Random/Natural
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Random.Natural char name

let attribute/Text
    : Character -> Text -> Ast/Text
    = \(char : Character) ->
      \(name : Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Attribute.Text char name

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

let dropdownOption/Natural
    : Text -> Ast/Natural -> Ast/DropdownOption/Natural
    = dropdownOption Ast/Natural

let dropdownOption/Integer
    : Text -> Ast/Integer -> Ast/DropdownOption/Integer
    = dropdownOption Ast/Integer

let dropdownOption/Random/Natural
    : Text -> Ast/Random/Natural -> Ast/DropdownOption/Random/Natural
    = dropdownOption Ast/Random/Natural

let dropdownOption/Random/Integer
    : Text -> Ast/Random/Integer -> Ast/DropdownOption/Random/Integer
    = dropdownOption Ast/Random/Integer

let dropdownOption/Text
    : Text -> Ast/Text -> Ast/DropdownOption/Text
    = dropdownOption Ast/Text

let dropdownOption/TableEntries
    : Text -> Ast/TableEntries -> Ast/DropdownOption/TableEntries
    = dropdownOption Ast/TableEntries

let dropdownOption/Table
    : Text -> Ast/Table -> Ast/DropdownOption/Table
    = dropdownOption Ast/Table

let dropdownOption/Command
    : Text -> Ast/Command -> Ast/DropdownOption/Command
    = dropdownOption Ast/Command

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
    : DropdownOption Ast/Natural ->
      Ast/DropdownOptions/Natural ->
        Ast/DropdownOptions/Natural
    = \(x : DropdownOption Ast/Natural) ->
      \(xs : Ast/DropdownOptions/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Natural
          ( DropdownOption/map
              Ast/Natural
              output.Natural
              ( \(value : Ast/Natural) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Integer
    : DropdownOption Ast/Integer ->
      Ast/DropdownOptions/Integer ->
        Ast/DropdownOptions/Integer
    = \(x : DropdownOption Ast/Integer) ->
      \(xs : Ast/DropdownOptions/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Integer
          ( DropdownOption/map
              Ast/Integer
              output.Integer
              ( \(value : Ast/Integer) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Random/Natural
    : DropdownOption Ast/Random/Natural ->
      Ast/DropdownOptions/Random/Natural ->
        Ast/DropdownOptions/Random/Natural
    = \(x : DropdownOption Ast/Random/Natural) ->
      \(xs : Ast/DropdownOptions/Random/Natural) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Random.Natural
          ( DropdownOption/map
              Ast/Random/Natural
              (output.Random output.Natural)
              ( \(value : Ast/Random/Natural) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Random/Integer
    : DropdownOption Ast/Random/Integer ->
      Ast/DropdownOptions/Random/Integer ->
        Ast/DropdownOptions/Random/Integer
    = \(x : DropdownOption Ast/Random/Integer) ->
      \(xs : Ast/DropdownOptions/Random/Integer) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Random.Integer
          ( DropdownOption/map
              Ast/Random/Integer
              (output.Random output.Integer)
              ( \(value : Ast/Random/Integer) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Text
    : DropdownOption Ast/Text ->
      Ast/DropdownOptions/Text ->
        Ast/DropdownOptions/Text
    = \(x : DropdownOption Ast/Text) ->
      \(xs : Ast/DropdownOptions/Text) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Text
          ( DropdownOption/map
              Ast/Text
              output.Text
              ( \(value : Ast/Text) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/TableEntries
    : DropdownOption Ast/TableEntries ->
      Ast/DropdownOptions/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = \(x : DropdownOption Ast/TableEntries) ->
      \(xs : Ast/DropdownOptions/TableEntries) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.TableEntries
          ( DropdownOption/map
              Ast/TableEntries
              output.TableEntries
              ( \(value : Ast/TableEntries) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Table
    : DropdownOption Ast/Table ->
      Ast/DropdownOptions/Table ->
        Ast/DropdownOptions/Table
    = \(x : DropdownOption Ast/Table) ->
      \(xs : Ast/DropdownOptions/Table) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Table
          ( DropdownOption/map
              Ast/Table
              output.Table
              ( \(value : Ast/Table) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/DropdownOptions/Command
    : DropdownOption Ast/Command ->
      Ast/DropdownOptions/Command ->
        Ast/DropdownOptions/Command
    = \(x : DropdownOption Ast/Command) ->
      \(xs : Ast/DropdownOptions/Command) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.DropdownOptions.Command
          ( DropdownOption/map
              Ast/Command
              output.Command
              ( \(value : Ast/Command) ->
                  value output (\(d : Natural) -> cs (d + 1))
              )
              x
          )
          (xs output cs)

let cons/Commands
    : Ast/Command -> Ast/Commands -> Ast/Commands
    = \(command : Ast/Command) ->
      \(list : Ast/Commands) ->
      \(output : Ast/Output) ->
      \(cs : Ast/Constructors output) ->
        (cs 0).Cons.Commands (command output cs) (list output cs)

let fromList2 =
      \(t : Type) ->
      \(ts : Type) ->
      \(f : t -> ts -> ts) ->
      \(pair : t -> t -> ts) ->
      \(list : List t) ->
      \(secondToLast : t) ->
      \(last : t) ->
        List/fold t list ts f (pair secondToLast last)

let fromList2/DropdownOptions/Natural
    : List (DropdownOption Ast/Natural) ->
      DropdownOption Ast/Natural ->
      DropdownOption Ast/Natural ->
        Ast/DropdownOptions/Natural
    = fromList2
        (DropdownOption Ast/Natural)
        Ast/DropdownOptions/Natural
        cons/DropdownOptions/Natural
        pair/DropdownOptions/Natural

let fromList2/DropdownOptions/Integer
    : List (DropdownOption Ast/Integer) ->
      DropdownOption Ast/Integer ->
      DropdownOption Ast/Integer ->
        Ast/DropdownOptions/Integer
    = fromList2
        (DropdownOption Ast/Integer)
        Ast/DropdownOptions/Integer
        cons/DropdownOptions/Integer
        pair/DropdownOptions/Integer

let fromList2/DropdownOptions/Random/Natural
    : List (DropdownOption Ast/Random/Natural) ->
      DropdownOption Ast/Random/Natural ->
      DropdownOption Ast/Random/Natural ->
        Ast/DropdownOptions/Random/Natural
    = fromList2
        (DropdownOption Ast/Random/Natural)
        Ast/DropdownOptions/Random/Natural
        cons/DropdownOptions/Random/Natural
        pair/DropdownOptions/Random/Natural

let fromList2/DropdownOptions/Random/Integer
    : List (DropdownOption Ast/Random/Integer) ->
      DropdownOption Ast/Random/Integer ->
      DropdownOption Ast/Random/Integer ->
        Ast/DropdownOptions/Random/Integer
    = fromList2
        (DropdownOption Ast/Random/Integer)
        Ast/DropdownOptions/Random/Integer
        cons/DropdownOptions/Random/Integer
        pair/DropdownOptions/Random/Integer

let fromList2/DropdownOptions/Text
    : List (DropdownOption Ast/Text) ->
      DropdownOption Ast/Text ->
      DropdownOption Ast/Text ->
        Ast/DropdownOptions/Text
    = fromList2
        (DropdownOption Ast/Text)
        Ast/DropdownOptions/Text
        cons/DropdownOptions/Text
        pair/DropdownOptions/Text

let fromList2/DropdownOptions/TableEntries
    : List (DropdownOption Ast/TableEntries) ->
      DropdownOption Ast/TableEntries ->
      DropdownOption Ast/TableEntries ->
        Ast/DropdownOptions/TableEntries
    = fromList2
        (DropdownOption Ast/TableEntries)
        Ast/DropdownOptions/TableEntries
        cons/DropdownOptions/TableEntries
        pair/DropdownOptions/TableEntries

let fromList2/DropdownOptions/Table
    : List (DropdownOption Ast/Table) ->
      DropdownOption Ast/Table ->
      DropdownOption Ast/Table ->
        Ast/DropdownOptions/Table
    = fromList2
        (DropdownOption Ast/Table)
        Ast/DropdownOptions/Table
        cons/DropdownOptions/Table
        pair/DropdownOptions/Table

let fromList2/DropdownOptions/Command
    : List (DropdownOption Ast/Command) ->
      DropdownOption Ast/Command ->
      DropdownOption Ast/Command ->
        Ast/DropdownOptions/Command
    = fromList2
        (DropdownOption Ast/Command)
        Ast/DropdownOptions/Command
        cons/DropdownOptions/Command
        pair/DropdownOptions/Command

let fromList/Commands
    : List Ast/Command -> Ast/Commands
    = \(list : List Ast/Command) ->
        List/fold Ast/Command list Ast/Commands cons/Commands empty/Commands

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

let concat/Text
    : List Ast/Text -> Ast/Text
    = List/monoFold Ast/Text plusPlus/Text (literal/Text "")

let concat/TableEntries
    : List Ast/TableEntries -> Ast/TableEntries
    = List/monoFold Ast/TableEntries plusPlus/TableEntries empty/TableEntries

let concat/Commands
    : List Ast/Commands -> Ast/Commands
    = List/monoFold Ast/Commands plusPlus/Commands empty/Commands

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

let sum/Integer
    : List Ast/Integer -> Ast/Integer
    = List/monoFold Ast/Integer add/Integer (literal/Integer +0)

let sum/Natural
    : List Ast/Natural -> Ast/Natural
    = List/monoFold Ast/Natural add/Natural (literal/Natural 0)

let sum/Random/Integer
    : List Ast/Random/Integer -> Ast/Random/Integer
    = List/monoFold
        Ast/Random/Integer
        add/Random/Integer
        (toRandom/Integer (literal/Integer +0))

let sum/Random/Natural
    : List Ast/Random/Natural -> Ast/Random/Natural
    = List/monoFold
        Ast/Random/Natural
        add/Random/Natural
        (toRandom/Natural (literal/Natural 0))

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

let product/Integer
    : List Ast/Integer -> Ast/Integer
    = List/monoFold Ast/Integer multiply/Integer (literal/Integer +1)

let product/Natural
    : List Ast/Natural -> Ast/Natural
    = List/monoFold Ast/Natural multiply/Natural (literal/Natural 1)

let product/Random/Integer
    : List Ast/Random/Integer -> Ast/Random/Integer
    = List/monoFold
        Ast/Random/Integer
        multiply/Random/Integer
        (toRandom/Integer (literal/Integer +1))

let product/Random/Natural
    : List Ast/Random/Natural -> Ast/Random/Natural
    = List/monoFold
        Ast/Random/Natural
        multiply/Random/Natural
        (toRandom/Natural (literal/Natural 1))

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

let exampleFromList2DropdownText2 =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( dropdown/Text
                          "X"
                          ( fromList2/DropdownOptions/Text
                              ([] : List Ast/DropdownOption/Text)
                              (dropdownOption/Text "a" (literal/Text "1"))
                              (dropdownOption/Text "b" (literal/Text "2"))
                          )
                      )
                  )
              )
        ===  "?{X|a,1|b,2}"

let exampleFromList2DropdownText3 =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( dropdown/Text
                          "X"
                          ( fromList2/DropdownOptions/Text
                              [ dropdownOption/Text "a" (literal/Text "1") ]
                              (dropdownOption/Text "b" (literal/Text "2"))
                              (dropdownOption/Text "c" (literal/Text "3"))
                          )
                      )
                  )
              )
        ===  "?{X|a,1|b,2|c,3}"

let exampleFromList2DropdownText4 =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( dropdown/Text
                          "X"
                          ( fromList2/DropdownOptions/Text
                              [ dropdownOption/Text "a" (literal/Text "1")
                              , dropdownOption/Text "b" (literal/Text "2")
                              ]
                              (dropdownOption/Text "c" (literal/Text "3"))
                              (dropdownOption/Text "d" (literal/Text "4"))
                          )
                      )
                  )
              )
        ===  "?{X|a,1|b,2|c,3|d,4}"

let exampleFromListCommand0 =
      assert : render (fromList/Commands ([] : List Ast/Command)) === ""

let exampleFromListCommand1 =
        assert
      :     render (fromList/Commands [ broadcast/Text (literal/Text "a") ])
        ===  ''
             a
             ''

let exampleFromListCommandN =
        assert
      :     render
              ( fromList/Commands
                  [ broadcast/Text (literal/Text "a")
                  , broadcast/Text (literal/Text "b")
                  , broadcast/Text (literal/Text "c")
                  ]
              )
        ===  ''
             a
             b
             c
             ''

let exampleConcatText0 =
        assert
      :     render
              ( singleton/Commands
                  (broadcast/Text (concat/Text ([] : List Ast/Text)))
              )
        ===  ""

let exampleConcatText1 =
        assert
      :     render
              ( singleton/Commands
                  (broadcast/Text (concat/Text [ literal/Text "a" ]))
              )
        ===  "a"

let exampleConcatTextN =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( concat/Text
                          [ literal/Text "a"
                          , literal/Text "b"
                          , literal/Text "c"
                          ]
                      )
                  )
              )
        ===  "abc"

let exampleSum0 =
        assert
      :     render
              ( singleton/Commands
                  ( roll/Integer
                      (toRandom/Integer (sum/Integer ([] : List Ast/Integer)))
                  )
              )
        ===  "/r 0"

let exampleSum1 =
        assert
      :     render
              ( singleton/Commands
                  ( roll/Integer
                      (toRandom/Integer (sum/Integer [ literal/Integer +1 ]))
                  )
              )
        ===  "/r 1"

let exampleSumN =
        assert
      :     render
              ( singleton/Commands
                  ( roll/Integer
                      ( toRandom/Integer
                          ( sum/Integer
                              [ literal/Integer +1
                              , literal/Integer -2
                              , literal/Integer +3
                              ]
                          )
                      )
                  )
              )
        ===  "/r ((1 + (-2)) + 3)"

let exampleAstUseTextualAttribute =
        assert
      :     render
              ( singleton/Commands
                  ( broadcast/Text
                      ( plusPlus/Text
                          ( plusPlus/Text
                              (literal/Text "I called ")
                              (attribute/Text Character.Implicit "attribute")
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
                              (attribute/Natural Character.Selected "some_att")
                              ( multiply/Natural
                                  (ability/Natural Character.Implicit "some_ab")
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
                          ( pair/DropdownOptions/Text
                              (dropdownOption/Text "1" (literal/Text "A1"))
                              ( dropdownOption/Text
                                  "2"
                                  ( plusPlus/Text
                                      ( literal/Text
                                          "You called the second level: "
                                      )
                                      ( dropdown/Text
                                          "B"
                                          ( pair/DropdownOptions/Text
                                              ( dropdownOption/Text
                                                  "1"
                                                  (literal/Text "A2B1")
                                              )
                                              ( dropdownOption/Text
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
                          ( pair/DropdownOptions/Text
                              (dropdownOption/Text "1" (literal/Text "A1"))
                              ( dropdownOption/Text
                                  "2"
                                  ( plusPlus/Text
                                      ( literal/Text
                                          "You called the second level: "
                                      )
                                      ( show/Natural
                                          ( dropdown/Natural
                                              "B"
                                              ( pair/DropdownOptions/Natural
                                                  ( dropdownOption/Natural
                                                      "1"
                                                      (literal/Natural 1221)
                                                  )
                                                  ( dropdownOption/Natural
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
                                  ( dropdownOption/Natural
                                      "A"
                                      (literal/Natural 1)
                                  )
                                  ( pair/DropdownOptions/Natural
                                      ( dropdownOption/Natural
                                          "B"
                                          (literal/Natural 2)
                                      )
                                      ( dropdownOption/Natural
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

in  { Character
    , DropdownOption
    , dropdownOption
    , Natural = Ast/Natural
    , Integer = Ast/Integer
    , Random/Natural = Ast/Random/Natural
    , Random/Integer = Ast/Random/Integer
    , Text = Ast/Text
    , TableEntries = Ast/TableEntries
    , Table = Ast/Table
    , Command = Ast/Command
    , Commands = Ast/Commands
    , DropdownOption/Natural = Ast/DropdownOption/Natural
    , DropdownOption/Integer = Ast/DropdownOption/Integer
    , DropdownOption/Random/Natural = Ast/DropdownOption/Random/Natural
    , DropdownOption/Random/Integer = Ast/DropdownOption/Random/Integer
    , DropdownOption/Text = Ast/DropdownOption/Text
    , DropdownOption/TableEntries = Ast/DropdownOption/TableEntries
    , DropdownOption/Table = Ast/DropdownOption/Table
    , DropdownOption/Command = Ast/DropdownOption/Command
    , DropdownOptions/Natural = Ast/DropdownOptions/Natural
    , DropdownOptions/Integer = Ast/DropdownOptions/Integer
    , DropdownOptions/Random/Natural = Ast/DropdownOptions/Random/Natural
    , DropdownOptions/Random/Integer = Ast/DropdownOptions/Random/Integer
    , DropdownOptions/Text = Ast/DropdownOptions/Text
    , DropdownOptions/TableEntries = Ast/DropdownOptions/TableEntries
    , DropdownOptions/Table = Ast/DropdownOptions/Table
    , DropdownOptions/Command = Ast/DropdownOptions/Command
    , render
    , literal/Integer
    , literal/Natural
    , literal/Text
    , empty/TableEntries
    , empty/Commands
    , singleton/TableEntries
    , singleton/Commands
    , pair/DropdownOptions/Natural
    , pair/DropdownOptions/Integer
    , pair/DropdownOptions/Random/Natural
    , pair/DropdownOptions/Random/Integer
    , pair/DropdownOptions/Text
    , pair/DropdownOptions/TableEntries
    , pair/DropdownOptions/Table
    , pair/DropdownOptions/Command
    , table
    , macro/Integer
    , macro/Natural
    , macro/Text
    , macro/Random/Integer
    , macro/Random/Natural
    , ability/Integer
    , ability/Natural
    , ability/Text
    , ability/Random/Integer
    , ability/Random/Natural
    , attribute/Integer
    , attribute/Natural
    , attribute/Random/Integer
    , attribute/Random/Natural
    , attribute/Text
    , input/Natural
    , input/Integer
    , input/Text
    , input/Command
    , input/Random/Natural
    , input/Random/Integer
    , dropdownOption/Natural
    , dropdownOption/Integer
    , dropdownOption/Random/Natural
    , dropdownOption/Random/Integer
    , dropdownOption/Text
    , dropdownOption/TableEntries
    , dropdownOption/Table
    , dropdownOption/Command
    , dropdown/Natural
    , dropdown/Integer
    , dropdown/Random/Natural
    , dropdown/Random/Integer
    , dropdown/Text
    , dropdown/TableEntries
    , dropdown/Table
    , dropdown/Command
    , toInteger/Natural
    , toInteger/Random/Natural
    , absoluteValue/Integer
    , absoluteValue/Random/Integer
    , dice/Natural
    , dice/Random
    , toRandom/Natural
    , toRandom/Integer
    , label/Integer
    , label/Natural
    , cons/DropdownOptions/Natural
    , cons/DropdownOptions/Integer
    , cons/DropdownOptions/Random/Natural
    , cons/DropdownOptions/Random/Integer
    , cons/DropdownOptions/Text
    , cons/DropdownOptions/TableEntries
    , cons/DropdownOptions/Table
    , cons/DropdownOptions/Command
    , cons/Commands
    , fromList2/DropdownOptions/Natural
    , fromList2/DropdownOptions/Integer
    , fromList2/DropdownOptions/Random/Natural
    , fromList2/DropdownOptions/Random/Integer
    , fromList2/DropdownOptions/Text
    , fromList2/DropdownOptions/TableEntries
    , fromList2/DropdownOptions/Table
    , fromList2/DropdownOptions/Command
    , fromList/Commands
    , plusPlus/Text
    , plusPlus/TableEntries
    , plusPlus/Table
    , plusPlus/Commands
    , concat/Text
    , concat/TableEntries
    , concat/Commands
    , add/Integer
    , add/Natural
    , add/Random/Natural
    , add/Random/Integer
    , sum/Integer
    , sum/Natural
    , sum/Random/Integer
    , sum/Random/Natural
    , multiply/Integer
    , multiply/Natural
    , multiply/Random/Integer
    , multiply/Random/Natural
    , product/Integer
    , product/Natural
    , product/Random/Integer
    , product/Random/Natural
    , show/Integer
    , show/Natural
    , show/Random/Natural
    , show/Random/Integer
    , broadcast/Text
    , broadcast/Table
    , broadcastAs/Text
    , broadcastAs/Table
    , emote
    , emoteAs
    , whisper/Text
    , whisper/Table
    , roll/Natural
    , roll/Integer
    }
