# Make Roll20 Macros with Dhall

This is an semi-experimental project to see if Dhall could reign in the chaos that is the ad hoc macro language for rolling dice in Roll20, which seems to fall under the classic, "whoops, we made a DSL" problem.
As such, it has some _very_ odd and unpredictable ways that things interact, especially when using nested.
We here attempt to use Dhall to enable the full suite of features (though many are still TODO), while capturing all type invariants.
By using GADT-like structures, we can even encode contextual operators that are still mutually recursive.
It's worth noting that the type magic here to do this can result in extremely unhelpful errors.
However, this approach has a useful outcome: anything that compiles is a valid macro that behaves predictably.

## Hello, World

```dhall
let Ast = http://TODO

let helloWorld : Text =
  Ast.render
    (Ast.singleton/Commands
      (Ast.broadcast/Text
        (Ast.literal/Text "Hello, world!")
      )
    )

in assert : helloWorld === "Hello, world!"
```

This is a lot more text just to do something basic!
So let's break it down.
Our `Ast.render` function takes an Abstract Syntax Tree representation of a macro and turns it into `Text`, which we can put into roll20 chat.
However, it's causing a lot of the boilerplate here, as it only works on the `Ast.Commands` type.
This is because, at the end of the day, a macro _is_ a list of commands, even if we frequently only issue one at a time.

Because "Hello, world" is only a single command, we're going to use `Ast.singleton/Commands` to bridge the gap.
This function takes a single command and treats it as if it were multiple.

It may seem odd to say that "Hello, world" is a command at all, but it is: it's a command to broadcast text.
The broadcast command is so common, that within the roll20 macro language, no prefix is required; it's the default behavior.
Here, were going to have to be more explicit, but we'll get a lot more help in constructing valid macros by doing so.
Since we can also broadcast other things, we need to use `Ast.broadcast/Text` specifically to indicate that we're broadcasting text, not something like a table.
While more verbose, this helps provide our strong type guarantees.

Finally, when we say that we're going to broadcast text, where going to broadcast `Ast.Text` not regular `Text`.
`Ast.Text` is a lot more complicated, because it may be made up of lots of different things.
The final rendered text may be constructed from math, rolls, queries, other macros, and etc.
In this case we use `Ast.literal/Text` to say that we aren't doing any of that fancy stuff: the text we want is just a literal piece of `Text`.
And when we say "literal" text, we mean it!
You will literally see this exact text written, even if it contains things normally interpreted by roll20, like `[[1d6]]`.

All together, and we get a "Hello, world!" command, which just so happens to look exactly like our literal text in this simple example.

By leveraging Dhall, we can use variables as well.
We'll often do this for reusing parts of the tree that are common, but variables can also help simply to name parts of the tree.
Naming chunks can make things clearer as it makes certain parts read from the inside out.
Let's take this to the extreme in our "Hello, world!" macro, just to better understand how our tree works.
Note that the result is exactly the same, we're just writing it out differently.

```dhall
let Ast = http://TODO

let helloWorldAsText : Text =
  "Hello, world!"

let helloWorldAsAstText : Ast.Text =
  Ast.literal/Text helloWorldAsText

let helloWorldAsCommand : Ast.Command =
  Ast.broadcast/Text helloWorldAsAstText

let helloWorldAsCommands : Ast.Commands =
  Ast.singleton/Commands helloWorldAsCommand

let helloWorld : Text =
  Ast.render helloWorldAsCommands

in assert : helloWorld === "Hello, world!"
```

This is uses variables to the point of being unhelpful, but it illustrates how variables let us change the order in which we read the macro.
In some cases it's easier to read from the outside in, and in other it will be easier to read from the inside out.

## Hello, World as a Check

Our "Hello, world!" example at the moment mostly just makes us type a lot.
So let's take a look at a more complex macro, one that does in fact use multiple commands.
For our macro, we want to do three things: emote, broadcast, and roll.
Let's see our finished macro first, and then we'll break it down.

```dhall
let Ast = http://TODO

let emoteCommand : Ast.Command =
  Ast.emote/Text
    (Ast.literal/Text "greets the world.")

let helloWorldCommand : Ast.Command =
  Ast.broadcast/Text
    (Ast.literal/Text "Hello, world!")

let rollCommand : Ast.Command =
  Ast.roll/Natural
    (Ast.dice 
      (Ast.value/Natural 1)
      (Ast.value/Natural 20)
    )

let helloWorldCheck : Text =
  Ast.render
    (Ast.cons/Commands
      emoteCommand
      (Ast.cons/Commands
        helloWorldCommand
        (Ast.singleton/Commands
          rollCommand
        )
      )
    )

in assert : helloWorldCheck ===
   ''
   /em greets the world
   Hello, world!
   /r 1d20
   ''
```

Now we have something a lot more interesting!
Structurally, we first create our three individual commands, we then construct a list out of them, and we then render the list to the final macro.
