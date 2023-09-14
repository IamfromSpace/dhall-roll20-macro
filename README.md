# Make Roll20 Macros with Dhall

For many roll20 users, the macro  DSL (domain specific language) is undeniably accessible, offering a low barrier of entry to create simple helpers in their games.
However, as macros become more intricate, they can quickly evolve into bewildering collections gotchas where small errors are a nightmare to debug.
While the roll20 macro DSL be quite powerful, it's has clearly evolved in an ad hoc way that's made it a bit of a monster.

By leveraging Dhall, we can tame this beast a bit, as it provides numerous benefits:

  - **Strong Typing**: With this library, you can _only_ create valid macros.
    If it compiles it works, and it works predictably.
  - **Complex Escaping Handling**: The library takes care of the intricate task of handling numerous escaping rules, especially the madness of escaping nested queries.
  - **Variables and Functions**: Dhall brings variables and functions to the table, allowing you to break down complex macros and reuse common components.
  - **Total Language**: Dhall's totality ensures that you can't inadvertently create infinite loops or exceptions in your Dhall code.
    It compiles or it doesn't; if it compiles, it works.

If you're a Dhall programmer who knows nothing about roll20 macros, this project is an interesting semi-experimental exploration of advanced Dhall concepts in action.
It uses mutual recursion and GADT-like structures, showcasing how Dhall can wrangle even complex problems into something type safe.

As a final note, a downside of the type wizardry going on to enforce invariants, the compile errors one sees are unfortunately quite complex.

## Quick Start

In this section, we detail how to create a simple macro that just prints the text, "Hello, world!"

### Step 1: Install Dhall

[Install Dhall](https://docs.dhall-lang.org/tutorials/Getting-started_Generate-JSON-or-YAML.html#installation) on your system.

### Step 2: Write the Code

Create a file named `hello_world.dhall` and add the following content:

```dhall
let Ast = http://TODO

in Ast.render
    (Ast.singleton/Commands
      (Ast.broadcast/Text
        (Ast.literal/Text "Hello, world!")
      )
    )
```

### Step 3: Generate the final text

Run the following command to output the macro rendered as text to a file:

```bash
dhall text <<< './hello_world.dhall' > hello_world.txt
```

Inside the `hello_world.txt` file is the finished macro, which is ready to be copied into roll20.

## Tutorial

This tutorial will start with the basics and gradually build upon them to explore all full API available to us.

### Hello, World

To start with, let's take a look at how a "Hello, world!" macro can be defined, and why it works the way it does.

```dhall
-- Import the library
let Ast = http://TODO

-- Define a variable with our command
let helloWorldCommand : Ast.Command =
  -- Say what we want to do with this text: broadcast it!
  Ast.broadcast/Text
    -- Create an Ast/Text from regular Text
    (Ast.literal/Text "Hello, world!")

-- Define a variable with finished macro
let helloWorldMacro : Text =
  -- Turn the commands into a finished macro
  Ast.render
    -- Turn our single command into the multiple commands type
    (Ast.singleton/Commands helloWorldCommand)

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : helloWorldMacro === "Hello, world!"

-- Use the final macro as the output of this file
in helloWorldMacro
```

This is a lot of text to do something so basic!
So let's break it down.

First, we start by defining our command.
It may seem odd to say that "Hello, world" is a command at all, but it is: it's a command to broadcast text.
The broadcast command is so common, that within the roll20 macro language, no slash command is required; it's the default behavior.
With this library, were going to have to be more explicit, but we'll get a lot more help in constructing valid macros by doing so.
Since we can also broadcast other things, we need to use `Ast.broadcast/Text` specifically to indicate that we're broadcasting text, not something like a table.
While more verbose, this helps provide our strong type guarantees.

Also, when we say that we're going to broadcast text, our `Ast.broadcast/Text` function only accepts `Ast.Text` not regular `Text`.
`Ast.Text` is a more complicated, because it may be made up of lots of different things.
`Ast.Text` may be constructed from math, rolls, queries, other macros, and etc.
In this case we use `Ast.literal/Text` to say that we aren't doing any of that fancy stuff: the text we want is just a literal piece of `Text`.
And when we say "literal" text, we mean it!
You will literally see this exact text written, even if it contains things normally interpreted by roll20, like `[[1d6]]`.

Now that we have our `helloWorldCommand` defined, we need to render into text that we can put into roll20 chat.
To do so, we need `Ast.render` which causing a bit of boilerplate here, as it only works on the `Ast.Commands` type.
This is because, at the end of the day, a macro _is_ a list of commands, even if we typically only issue one at a time.

To bridge the gap, we're going to use `Ast.singleton/Commands`.
This function takes a single command converts it into a list with just one entry.

With all that put together, our `helloWorldMacro` is equivalent to the text "Hello, world!"

### Hello, World as a Check

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
