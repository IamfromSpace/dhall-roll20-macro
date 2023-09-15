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
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

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
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

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

### Hello, dice!

We've now seen how to broadcast a fixed piece of text, but that's not very interesting in of itself.
Let's get the core of what we're really trying to accomplish: roll some dice!
We'll start simple and roll a single six sided die.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a six sided die.
let d6 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  (Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 6)
  )

-- Define a variable that says how we want to roll our die: we want to broadcast it!
let diceCommand : Ast.Command =
  Ast.roll/Random/Natural d6

-- Define a variable with finished macro
let diceMacro : Text =
  -- Turn the commands into a finished macro
  Ast.render
    -- Turn our single command into the multiple commands type
    (Ast.singleton/Commands diceCommand)

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : diceMacro === "/r 1d6"

-- Use the final macro as the output of this file
in diceMacro
```

Structurally, a lot is the same here, despite changing a few names.
At the end, `diceMacro` handles some of the final boilerplate and the test is updated to reflect the new expectation.
The core of the change is in how we define `d6` and `diceCommand`.

First, we're going to define a variable that represents rolling a six sided die, named `d6`.
We use the `Ast.dice/Natural` function, which takes in two arguments, the number of dice rolled and the number of sides on each die.
However, these two arguments aren't just numbers, the are `Ast.Naturals`.
`Ast.Naturals` are always positive and they might actually be made up of math, attributes, abilities, other macros, or etc.
In this case though, we're not doing anything fancy, we just want a regular `Natural`.
We use a similar approach as we did with text, we use `Ast.literal/Natural` to say that we want a literal number to form this portion of our Abstract Syntax Tree.

Note that the output type of `Ast.dice/Natural` (and therefore type of the `d6` variable) is an `Ast/Random/Natural`.
This is like an `Ast/Natural`, but instead of being a known natural, it's a random one.
Certain functions only accept `Ast/Naturals` and others only accept `Ast/Random/Naturals`.
This may seem more challenging, but this allows the library to distinguish between cases where it needs to produce something like `1d6`, `1d(1+5)`, or `1d[[1d6]]` in a way that is always correct without obfuscating the result too much.
The type checking helps make sure you always get a macro built in the right way, without having to know all the rules (or at least having the type checker guide you if you try to break them).

With our die roll defined, we now have to use it.
We create a variable named `diceCommand` and use the function `Ast.roll/Random/Natural` to indicate that we want to broadcast the `d6` dice roll and to expect it to have the `Ast.Random/Natural` type.
We want this particular function instead of something like `Ast.gmRoll/Random/Integer`, which would send the roll only to the GM, and might give in negative numbers.
This turns our roll into an `Ast.Command`.

With an `Ast.Command` we're now ready to turn it into macro in the final step, as `diceMacro`.

### Hello, checks!

In the above section, we've seen how to roll dice, however, frequently a single roll isn't enough.
For real world macros we're often going to add other numbers like modifiers.

Doing math is a bit counter intuitive at first, since we need to define it in a tree structure, but we'll break it down a step at a time.
At a high level, even though we typically use _infix_ notation for math (like `2 + 2`), we're now going to use _Polish_ notation, where we have the operator first (like `+ 2 2`).
This probably looks pretty strange, but a major advantage of this is that precedence of operations is no longer ambiguous.
Parenthesis will automatically added to your macro output to make sure everything happens in the order you define.

Let's consider a macro for a strength check, where we add our characters strength (here, +4) to a d20 roll.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  (Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)
  )

-- Define "d20 + 4"
let d20Plus4 : Ast.Random/Natural =
  -- Say we're going to add two random things
  Ast.add/Random/Natural
    -- The left hand side, our die roll defined above
    d20
    -- The right hand side, a literal Natural (4) that we convert to a Random Natural
    (Ast.toRandom/Natural
      (Ast.literal/Natural 4)
    )

-- Define a variable that says what to do with our check: broadcast it!
let checkCommand : Ast.Command =
  Ast.roll/Random/Natural d20Plus4

-- Define a variable with finished macro
let checkMacro : Text =
  -- Turn the commands into a finished macro
  Ast.render
    -- Turn our single command into the multiple commands type
    (Ast.singleton/Commands checkCommand)

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : checkMacro === "/r (1d20 + 4)"

-- Use the final macro as the output of this file
in checkMacro
```

You can again see a lot of structural similarities to our previous example.
We define a die roll (this time a d20 instead of a d6), we eventually roll something, we turn that roll into a macro, test it, and output it.
The key difference is that instead of rolling only our die (the `d20` variable), we're going to roll the check that adds the bonus (the `d20Plus4` variable).

If we look at how we define the `d20Plus4` variable, you'll see the first thing is the `Ast.add/Random/Natural` function.
This is again because we're using Polish notation here, so the operator comes first, followed by the arguments.
The first argument (the left hand side in infix notation) is just the roll we already defined above: `d20`.
The second argument is a bit more complicated, because we need to get our types to line up, but it's ultimately just the `4` on the right hand side.

We've seen the `Ast.literal/Natural` function a couple times, allowing us to say that we want to create a type that _can_ be complicated, but in this case isn't.
Now we do something similar with `Ast.toRandom/Natural`.
Notably, when when dice get involved we don't have normal numbers, we have random numbers!
Random numbers obey different rules for how they're represented in our macros than normal numbers in certain situations.
So once we introduce a random number into the math, there's no going back.
You can't make something un-random.
But we can pretend that something that wasn't random was!
And that's what `Ast.toRandom/Natural` does.
We say that we have an `Ast.Natural`, but we'd like to treat it as if it were a random number going forward, so it can interact with other random numbers.

When we put it all together, we get the result we expect: broadcasting the strength check.

### Hello, multiple commands!

Our "Hello, world!" example at the moment mostly just makes us type a lot.
So let's take a look at a more complex macro, one that does in fact use multiple commands.
For our macro, we want to do three things: emote, broadcast, and roll.
Let's see our finished macro first, and then we'll break it down.

```dhall
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

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
