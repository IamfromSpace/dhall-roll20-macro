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
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 6)

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
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

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

### Parameters

In the above example we create a check with a fixed modifier.
Sometimes, this is fine, but usually we expect our characters to get stronger, and our modifiers to change over time.
We'll introduce two ways to do this: referencing roll20 abilities, or using Dhall functions to parameterize our macro definitions.

#### Using Attributes (or Macros, or Abilities)

When our character increases in level, we just want to pop into the character sheet and change some stuff and have our macro immediately pick up those changes.
Let's make the same macro as before, but instead of a static +4 strength bonus, we'll reference our character's strength.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

-- Define d20 + strength modifier
let d20PlusStrength : Ast.Random/Natural =
  -- Say we're going to add two random things
  Ast.add/Random/Natural
    -- The left hand side, our die roll defined above
    d20
    -- The right hand side, a reference to strength
    (Ast.toRandom/Natural
      (Ast.attribute/Natural { char = Ast.Target.Implicit, name = "strength_modifier" })
    )

-- Define a variable that says what to do with our check: broadcast it!
let attributeCheckCommand : Ast.Command =
  Ast.roll/Random/Natural d20PlusStrength

-- Define a variable with finished macro
let attributeCheckMacro : Text =
  -- Turn the commands into a finished macro
  Ast.render
    -- Turn our single command into the multiple commands type
    (Ast.singleton/Commands attributeCheckCommand)

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : attributeCheckMacro === "/r (1d20 + @{strength_modifier})"

-- Use the final macro as the output of this file
in attributeCheckMacro
```

Only a bit has changed here.
Now, instead of adding a literal, we add the attribute.
We create the attribute with `Ast.attribute/Natural`.
It might seem odd that we need to specify the type of the attribute here--we can't actually know what the attribute holds!
However, if we know what type to expect, we can construct a macro that is more likely to work with this reference.

We also need to specify the details of our attribute reference.
Here we say that the character is an `Implicit` target.
So we're not specifying exactly who's strength we're using, we let the context decide.
This is handy for creating reusable macros for abilities as token actions.
Lastly, we just have to provide the name of the attribute, which in this case is `"strength_modifier"`.

In roll20, we'll have to wire it all up to make this work, which is the downside of this approach.

Referencing macros and abilities is similar, we just use functions like `macro/Natural` and `ability/Natural` to do so.

#### Dhall Functions

In some cases, it's easier to just regenerate the entire macro with a new value, rather than use attributes.
For a GM, fiddling with attributes for every new encounter is more tedious than helpful.
Or, if a mega-macro is defined that has everything, there's no need to reference attributes and such.
Dhall gives us the perfect tool to easy regenerate macros (or varieties of the same macro) when they change: functions!
Let's take a look at some code for this approach:

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

let functionCheckMacro : Natural -> Text =
  \(modifier : Natural) ->

    -- Define d20 + the modifier
    let d20PlusModifier : Ast.Random/Natural =
      -- Say we're going to add two random things
      Ast.add/Random/Natural
        -- The left hand side, our die roll defined above
        d20
        -- The right hand side, a reference to our function's input parameter
        (Ast.toRandom/Natural
          (Ast.literal/Natural modifier)
        )

    -- Define a variable that says what to do with our check: broadcast it!
    let functionCheckCommand : Ast.Command =
      Ast.roll/Random/Natural d20PlusModifier

    -- return then finished macro
    in
      -- Turn the commands into a finished macro
      Ast.render
        -- Turn our single command into the multiple commands type
        (Ast.singleton/Commands functionCheckCommand)

-- We make sure our function works with a couple examples
let test1 =
  assert : functionCheckMacro 1 === "/r (1d20 + 1)"

let test5 =
  assert : functionCheckMacro 5 === "/r (1d20 + 5)"

-- Name the value we're going to pass into the function for better readability
let myCurrentStrength = 6

-- Use the final macro as the output of this file
in functionCheckMacro myCurrentStrength
```

You can see this does create a more significant structural change.
We define a function that creates a macro, rather than defining the macro itself.
A function uses parameters to use variable that don't yet have a decided value.
So in this case `modifier` is a Natural, but we're not yet sure exactly which one!
It could be 12, or 30, or 9999, or all of the above since we can reuse the function as many times as we'd like.

Now, rather than just one test, we have multiple to ensure that our function is as dynamic as we expect.
We define a `myCurrentStrength` value so it's easy to increment and regenerate our macro when things change.

For trivial examples like these, functions probably don't help much.
However, functions open a door to making extremely powerful macros that are reusable in many contexts.
As an example, if we instead make our function accept an `Ast.Natural`, we can have our cake and eat it to: we can decide later if we want to use static value, or reference an attribute, or use it both ways!

### Input boxes

In some cases, we don't just want something that can change over time, we want something that can change each time we use it.
For simple cases, an input box is a great way to handle this.
We'll also explore dropdown inputs later, but these are much more advanced.
For the moment, we'll add the ability to add situational modifiers for our attack above.
Rather than always have a +4 to attack, we'll start with that as a baseline, and then prompt the user to add any current situational modifiers.
To help them out, we'll also default this to 0, so they can just quickly press okay during typical circumstances.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

-- Define "d20 + 4 + a value from an input"
let d20Plus4PlusModifier : Ast.Random/Integer =
  -- Add two random Integers
  Ast.add/Random/Integer
    (Ast.toInteger/Random d20)
    -- Our two modifiers are regular Integers, we convert the sum to a Random Integer
    (Ast.toRandom/Integer
      -- Add together two Integer numbers
      (Ast.add/Integer
        -- The first is a static value: 4
        (Ast.literal/Integer +4)
        -- The second is an input
        (Ast.input/Integer
          -- The name of this input is "Modifier"
          "Modifier"
          -- There is a default input, which we indicate via Some
          (Some
            -- The default input is the static value 0
            (Ast.literal/Integer +0)
          )
        )
      )
    )

-- Define a variable that says what to do with our check: broadcast it!
let dynamicCheckCommand : Ast.Command =
  Ast.roll/Random/Integer d20Plus4PlusModifier

-- Define a variable with finished macro
let dynamicCheckMacro : Text =
  -- Turn the commands into a finished macro
  Ast.render
    -- Turn our single command into the multiple commands type
    (Ast.singleton/Commands dynamicCheckCommand)

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : dynamicCheckMacro === "/r (1d20 + (4 + ?{Modifier|0}))"

-- Use the final macro as the output of this file
in dynamicCheckMacro
```

Now we have something that can be adjusted on the fly during a game.
Each time the macro executes, the user is prompted for the Modifier, which is added to the check.
We can see that defining `d20Plus4PlusModifier` has a number of steps involved.
You'll note that this time, we're not using Naturals, we're using Integers.
We do this because there's a decent chance the user will enter a negative number into an input, due to adverse situational effects.
We can't be sure exactly what the user will enter into the input, but if we use the type that's most likely to match, or macro is much more likely to behave correctly.

Alternatively, to using two different add functions, we can use `Ast.sum/Random/Integer` to sum over a list, in order to avoid nesting addition functions.
If we rewrite it with this, we get the following.

```dhall
let d20Plus4PlusModifier : Ast.Random/Integer =
  Ast.sum/Random/Integer
    [ Ast.toInteger/Random d20
    , Ast.toRandom/Integer
        (Ast.literal/Integer +4)
    , Ast.toRandom/Integer
        (Ast.input/Integer
          "Modifier"
          (Some
            (Ast.literal/Integer +0)
          )
        )
    ]
```

This helps illustrate that we're adding together three terms.
The first is the d20 roll, which produces a random Natural.
Since we're summing Integers, we need to use `Ast.toInteger/Random` to convert it.
It's free to convert Naturals to Integers, just not the other way around!

The second and third terms are of the `Ast.Integer` type, but they need to be of the `Ast.Random/Integer` type so all the types in the list match.
We convert them via the `Ast.toRandom/Integer` function.
The second term is just our static +4 strength bonus.
In Dhall, we need to prefix the sign when defining an Integer, so this is why we write `+4` instead of just `4`.

The third term is the where we define a user input with a default.
We use the `Ast.input/Integer` because the user could enter a positive or negative number.
We can't be sure what they'll actually enter, but by using this function it will work if they enter anything like `-3` or `(-3)` or `4-5` or `+4`.

Each user input needs a name (using the same name twice results in roll20 remembering the previous choice), we call this one just "Modifier."
And then we define our optional default input.
Optional types are tagged `Some` or `None`.
If don't want a default, we would say `None` and then the associated type, so here it would be `None Ast/Integer`.
Since we want a default, we use the function `Some` and pass it the static Integer +0.

We've done quite a lot all told, but in the end, the macro user has a very convenient experience.
When they call the macro, they don't have to do mental math on the result to account for the current game state, they just enter in the modifier the accounts for the current situation.

### Multiple commands

In our previous examples, we always use the `Ast.singleton/Commands`, even though it doesn't seem to do anything for us.
Let's get a better understanding of how it can be useful by creating a macro with multiple commands: a typical attack roll.
We want to do three things: emote, roll for attack (with a +4), and roll for damage (a d6).
Let's see our finished macro first, and then we'll break it down.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a six sided die.
let d6 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 6)

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

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

-- Create an emote based on static text
let emoteCommand : Ast.Command =
  Ast.emote/Text
    (Ast.literal/Text "swings his sword!")

-- Turn our d20Plus4 roll into a command
let attackCommand : Ast.Command =
  Ast.roll/Natural d20Plus4

-- Turn our d6 roll into a command
let damageCommand : Ast.Command =
  Ast.roll/Natural d6

-- Combine all of our individual commands together
-- NOTE: We'll show more readable way to do this at the end!
let attackCommands : Ast.Commands =
  -- With cons, we can put a new command at the front of a list of commands
  Ast.cons/Commands
    emoteCommand
    (Ast.cons/Commands
      attackCommand
      -- With singleton we start a list of commands from one
      (Ast.singleton/Commands
        damageCommand
      )
    )

-- Turn our list of commands into the final macro
let attackMacro : Text =
  Ast.render attackCommands

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : attackMacro ===
    ''
    /em swings his sword!
    /r (1d20 + 4)
    /r 1d6
    ''

-- Use the final macro as the output of this file
in attackMacro
```

Now we have something a pretty interesting!
Our attack and damage rolls can be a lot more complex by mixing in previous and future concepts, but for now we just start with a static +4 to attack and damage of a 1d6.

Creating each command and testing the output should look pretty familiar now, so let's jump right into how we combine our commands together.
By using `Ast.cons/Commands` we can put a new command at the front of some previously defined list of commands.
So we can stack these `Ast.cons/Commands` functions as much as we like, we just need a list of commands to start the process.
To do that, we use what we've been using all along: `Ast.singleton/Command`, which can treat a single `Ast.Command` as if it were a list of commands (an `Ast.Commands`).

Alternatively, if we have two lists of commands, we can use `Ast.plusPlus/Commands` to put the two lists together.
This is handy in many cases, and the `Ast.cons/Commands` can't handle this situation!

As a final note, the deeper and deeper indentation of nesting further and further is pretty ugly.
So lets introduce a helper function that let's us do this more easily: `Ast.fromList/Commands`.
This function takes a list of individual commands and does all the `Ast.cons/Commands` for us.
If we re-write that part, we get the following:

```dhall
let attackCommands : Ast.Commands =
  Ast.fromList/Commands
    [ emoteCommand
    , attackCommand
    , damageCommand
    ]
```

Much nicer!

All together, we now have a macro that does multiple things for us all at once.

### Complex Text

The previous macro was starting to look useful, but it's not the most attractive way to present the two rolls.
We also don't label what the rolls are, which is going to be challenging to decipher if we need to add more.
Combining learnings from previous sections we could add additional commands that broadcast text before each roll to act as a label.
But instead, let's do something new and put all our rolls in a single line embedded in text.
We'll drop the emote for now, but you could add this in if you wanted.
Here's the finished macro, which we'll then break down.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a six sided die.
let d6 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 6)

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

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

-- Create a complex piece of text out of multiple pieces
-- NOTE: Like with cons/fromList we'll show a more readable way to do this
let attackWithDamage : Ast.Text =
  -- Continually chain together the joining of text
  Ast.plusPlus/Text
    (Ast.literal/Text "Attack: ")
    (Ast.plusPlus/Text
      -- Convert our d20Plus4 random value into a Ast.Text
      (Ast.show/Random/Natural d20Plus4)
      (Ast.plusPlus/Text
        (Ast.literal/Text "; Damage: ")
        (Ast.plusPlus/Text
          -- Convert our d6 random value into a Ast.Text
          (Ast.show/Random/Natural d6)
          (Ast.literal/Text ".")
        )
      )
    )

-- Turn our text into the final broadcasting macro
let attackWithDamageMacro : Text =
  Ast.render
    (Ast.singleton/Commands
      (Ast.broadcast/Text attackWithDamage)
    )

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : attackWithDamageMacro ===
    "Attack: [[(1d20 + 4)]]; Damage: [[1d6]]."

-- Use the final macro as the output of this file
in attackWithDamageMacro
```

When joining two pieces of text, like doing math, we use Polish notation, so the function comes first then the left hand text and then finally the right hand text.
With this many elements all joined together, our nesting gets pretty hard to read.
So lets immediately see how we can make this more readable with `Ast.concat/Text`.

```dhall
-- Create a complex piece of text out of multiple pieces
let attackWithDamage : Ast.Text =
  -- Join together multiple pieces of Ast.Text
  Ast.concat/Text
    [ Ast.literal/Text "Attack: "
    , Ast.show/Random/Natural d20Plus4
    , Ast.literal/Text "; Damage: "
    , Ast.show/Random/Natural d6
    , Ast.literal/Text "."
    ]
```

That's at least a little easier on the eyes.
This function still expects that each item in the list is of type `Ast.Text`, so that's where the remaining work is done.
We use `Ast.literal/Text` to convert static pieces of text, and we use `Ast.show/Random/Natural` to convert our dice rolls into text.

We convert this into a command by saying we want to broadcast it, turn that command into a list of commands, and finally render it to the final macro, give that a test, and then output it.
Popping that result into roll20 we get a nicely formatted output all on a single line!

### Tables

Combining text together can give some nice results, but when we have this sort of `Damage: [[1d6]];` structure, we should really use the right tool for the job: tables!
This library especially shines in eliminating a lot of the gotchas around building them.

Let's create a variant of the above example, one that outputs a table instead of text.

```dhall
-- Import the library
let Ast = https://raw.githubusercontent.com/IamfromSpace/dhall-roll20-macro/main/src/package.dhall

-- Define a variable that represents rolling a six sided die.
let d6 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 6)

-- Define a variable that represents rolling a 20 sided die.
let d20 : Ast.Random/Natural =
  -- How we create dice rolls, which always takes two Ast.Naturals
  Ast.dice/Natural
    -- Create an Ast/Natural from regular Natural, the number of dice
    (Ast.literal/Natural 1)
    -- Create an Ast/Natural from regular Natural, the number of sides
    (Ast.literal/Natural 20)

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

-- To create a table, we first need to construct the entries: each labeled valued
let attackTableEntries : Ast.TableEntries =
  -- Join together two different table entries as one
  -- When we have lots of entries to join together, we'll want to use Ast.concat/TableEntries
  Ast.plusPlus/TableEntries
    -- Create table entries from just a single labelled value
    (Ast.singleton/TableEntries
      -- The label is static text converted into an `Ast.Text`
      (Ast.literal/Text "Attack")
      -- The value is our attack roll converted into an `Ast.Text`
      (Ast.show/Random/Natural d20Plus4)
    )
    -- Create our damage entry in a similar way to how we created our attack roll entry
    (Ast.singleton/TableEntries
      (Ast.literal/Text "Damage")
      (Ast.show/Random/Natural d6)
    )

-- Create a finished table from the entries we created
let attackTable : Ast.Table =
  -- This function creates a table from an (optional) name and entries
  Ast.toTable
    -- By using Some, we indicate that we do want a name
    (Some
      -- Our table name here is a static piece of text converted into an `Ast.Text`
      (Ast.literal/Text "Attack with Sword")
    )
    -- The table entries we defined above
    attackTableEntries

-- Turn our table into the final broadcasting macro
let attackTableMacro : Text =
  Ast.render
    (Ast.singleton/Commands
      -- Since we don't have Ast.Text this time, we need to update our broadcast function too
      (Ast.broadcast/Table attackTable)
    )

-- For the purposes of this tutorial, a test validates the output
let test =
  assert : attackTableMacro ===
    "&{template:default} {{name=Attack with Sword}} {{Attack=[[(1d20 + 4)]]}} {{Damage=[[1d6]]}}"

-- Use the final macro as the output of this file
in attackTableMacro
```

You can see we need quite a bit of code to do this, but that the macro we output is also harder and harder to define by hand--and we're only scratching the surface.
The bulk of the interest here is in `attackTableEntries` and `attackTable`, but we should briefly note that when we convert this table into a command, we use `Ast.broadcast/Table` rather than `Ast.broadcast/Text`.
Tables have their own special broadcast command (and whisper) because they cannot safely be converted into text, but they can certainly be broadcast.

Before we dive into the details of this specific table, let's talk at a high level about how we build tables.
An `Ast.Table` is made of `Ast.TableEntries`.
This distinction is useful because `Ast.TableEntries` are always unnamed, but an `Ast.Table` has always had its name explicitly chosen (perhaps that there is none).
So `Ast.toTable` is the final step where we name (or explicitly don't name) `Ast.TableEntries`.

While `Ast.TableEntries` are lists of labeled values, we create a list with a single labeled value via `Ast.singleton/TableEntries`.
The first argument is the label, and the second argument is the value.
However, you'll notice that both are of type `Ast.Text`, which means we can do lots of fancy stuff with either of them.

While an `Ast.TableEntry` type could _theoretically_ exist, jumping right into lists makes more sense for building tables.
This way, we can use the `Ast.plusPlus/TableEntries` operator to continually combine both singletons and lists into larger and larger tables.
As our tables get larger, we can alternatively use `Ast.concat/TableEntries` to flatten out the code we write.
Let's see below what `attackTableEntries` would look like if we rewrote it in that style.

```dhall
let attackTableEntries : Ast.TableEntries =
  Ast.concat/TableEntries
    [ Ast.singleton/TableEntries
        (Ast.literal/Text "Attack")
        (Ast.show/Random/Natural d20Plus4)
    , Ast.singleton/TableEntries
        (Ast.literal/Text "Damage")
        (Ast.show/Random/Natural d6)
    ]
```

For the labels, we need to convert our desired `Text` into an `Ast.Text` with our frequently used `Ast.literal/Text` function.
For our values, since they are of type `Ast.Random/Natural`, we need to convert them into an `Ast.Text` via `Ast.show/Random/Natural`.

Ultimately, tables are a powerful tool for clean formatting of macros with lots and lots of various types of rolls.
When we start getting macros of this complexity, using Dhall really starts to shine, as it helps make sure that your macros work correctly, without having to remember all the various rules for getting things to work together nicely.
