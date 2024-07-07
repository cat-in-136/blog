---
layout: post
title: 'Build Complex CLI Apps in Rust: Derive and Builder APIs for Argument Order'
tags:
- rustlang
- howto
- cui
date: '2024-07-08T00:57:03+09:00'
last_modified_at: '2024-07-08T00:57:03+09:00'
---
[clap](https://crates.io/crates/clap) is a popular library for building command-line interfaces (CLIs) in Rust.
Its user-friendly API allows to create feature-rich CLIs with minimal code.
clap provides two main approaches to define command-line options.

* The derive API: This is a simpler approach defining a struct and decorate it with the `#[derive(clap)]` attribute.
  The derive API automatically generates options based on the struct fields, but it provides limited customization.
* The builder API: This approach uses the `clap::App` structure to define options individually.
  It provides more flexibility and allows for detailed configuration.

The [clap FAQ page](https://docs.rs/clap/latest/clap/_faq/index.html) states that the derive API cannot handle the argument order, so the builder API should be used for such use cases.

> The [Builder API](https://docs.rs/clap/latest/clap/_tutorial/index.html) is a lower-level API that someone might want to use for
> - Faster compile times if you aren't already using other procedural macros
> - More flexibility, e.g. you can look up an [arguments values](https://docs.rs/clap/latest/clap/struct.ArgMatches.html#method.get_many),
>   their [ordering with other arguments](https://docs.rs/clap/latest/clap/struct.ArgMatches.html#method.indices_of), and [what set
>   them](https://docs.rs/clap/latest/clap/struct.ArgMatches.html#method.value_source).  The Derive API can only report values and not
>   indices of or other data.

I wanted to implement something that would take care of the argument order, but I wanted to enjoy the convenience of the derive API.

Consider the following code.

```rust
use clap::Parser;

#[derive(Parser, Debug)]
struct Cli {
    #[arg(short = 'f', long)]
    foo: bool,
    #[arg(short = 'b', long)]
    bar: Option<String>,
    #[arg(long, value_delimiter = ',')]
    baz: Vec<String>,
}

fn main() {
    let args = Cli::parse();

    println!("{args:?}");
}
```

The argument specification for this short program is as follows:

- `foo`:.
   - Boolean flag argument.
   - Specified with the short option `-f` or the long option `--foo`.
   - `true` if given, `false` if absent.
- `bar`: Optional string argument.
   - Optional string argument.
   - Specified with the short option `-b` or the long option `--bar`.
   - The value is the string if specified, `None` if absent.
- `baz`:: Comma separated list of strings.
   - comma-separated list of strings.
   - Specified only with long option `--baz`.
   - Multiple values can be specified separated by commas (e.g., `--baz value1,value2,value3`)

The result of the execution is as follows, where the order of each option is not given.

```console
$ cargo run -- --baz baz1,baz2 -f -b bar --baz baz3
    Finished dev [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/clap-with-order --baz baz1,baz2 -f -b bar --baz baz3`
Cli { foo: true, bar: Some("bar"), baz: ["baz1", "baz2", "baz3"] }
```

I want to get the order like `baz=baz1`, `baz=baz2`, `foo`, `bar=bar`, `baz=baz3`, etc. `

The implementation of [`Parser::parse()`](https://docs.rs/clap/latest/clap/trait.Parser.html#method.parse) is as follows:

```rust
    fn parse() -> Self {
        let mut matches = <Self as CommandFactory>::command().get_matches();
        let res = <Self as FromArgMatches>::from_arg_matches_mut(&mut matches)
            .map_err(format_error::<Self>);
        match res {
            Ok(s) => s,
            Err(e) => {
                // Since this is more of a development-time error, we aren't doing as fancy of a quit
                // as `get_matches`
                e.exit()
            }
        }
    }
```

Interestingly, the `matches: ArgMatches` is returned in the process of this function, which is used in the builder API.
But it is immediately taken into the `from_arg_matches_mut()` function, and the lifetime of the `matches` is consumed here.

So I thought that if I could get `matches`, I could use the builder API while enjoying the convenience of derive API argument definitions.
I can use the derive API for unordered argument options, and use the builder API only for the ones I need to take into account. In this example, the order of all options `foo`, `bar`, and `baz` needs to be considered.


```rust
use clap::{CommandFactory, FromArgMatches, Parser};

#[derive(Parser, Debug)]
struct Cli {
    #[arg(short = 'f', long)]
    foo: bool,
    #[arg(short = 'b', long)]
    bar: Option<String>,
    #[arg(long, value_delimiter = ',')]
    baz: Vec<String>,
}

fn main() {
    let matches = <Cli as CommandFactory>::command().get_matches();
    let args = <Cli as FromArgMatches>::from_arg_matches_mut(&mut matches.clone());

    println!("{args:?}");

    let foo_indices = matches
        .indices_of("foo")
        .map(|v| v.collect::<Vec<_>>())
        .unwrap_or_default();
    let bar_indices = matches
        .indices_of("bar")
        .map(|v| v.collect::<Vec<_>>())
        .unwrap_or_default();
    let baz_indices = matches
        .indices_of("baz")
        .map(|v| v.collect::<Vec<_>>())
        .unwrap_or_default();
    println!("foo-indices {foo_indices:?}");
    println!("bar-indices {bar_indices:?}");
    println!("baz-indices {baz_indices:?}");
}
```

The result of this execution is shown below, which shows the order in which each option is specified:

```
cargo run -- --baz baz1,baz2 -f -b bar --baz baz3
   Compiling clap-with-order v0.1.0
    Finished dev [unoptimized + debuginfo] target(s) in 0.69s
     Running `target/debug/clap-with-order --baz baz1,baz2 -f -b bar --baz baz3`
Ok(Cli { foo: true, bar: Some("bar"), baz: ["baz1", "baz2", "baz3"] })
foo-indices [4]
bar-indices [6]
baz-indices [2, 3, 8]
```

To take the arguments in the order just like `baz=baz1`, `baz=baz2`, `foo`, `bar=bar`, `baz=baz3`, make a vector consisting of pair tuple of the derive API value and the argument order of the builder API as shown below, and sort it by argument order.

```rust
use clap::{CommandFactory, FromArgMatches, Parser};

#[derive(Parser, Debug)]
struct Cli {
    #[arg(short = 'f', long)]
    foo: bool,
    #[arg(short = 'b', long)]
    bar: Option<String>,
    #[arg(long, value_delimiter = ',')]
    baz: Vec<String>,
}

#[derive(Debug)]
enum FooBarBaz {
    Foo(bool),
    Bar(String),
    Baz(String),
}

fn main() {
    let matches = <Cli as CommandFactory>::command().get_matches();
    let args = <Cli as FromArgMatches>::from_arg_matches_mut(&mut matches.clone()).unwrap();

    println!("{args:?}");

    let mut foobarbaz = Vec::new();
    if let Some(mut indices) = matches.indices_of("foo") {
        if let Some(index) = indices.next() {
            foobarbaz.push((index, FooBarBaz::Foo(args.foo)));
        }
    }
    if let Some(mut indices) = matches.indices_of("bar") {
        if let (Some(v), Some(i)) = (args.bar, indices.next()) {
            foobarbaz.push((i, FooBarBaz::Bar(v)));
        }
    }
    if let Some(indices) = matches.indices_of("baz") {
        for (v, i) in args.baz.iter().zip(indices) {
            foobarbaz.push((i, FooBarBaz::Baz(v.clone())));
        }
    }

    foobarbaz.sort_by_key(|v| v.0);
    println!("foobarbaz: {foobarbaz:?}");
}
```

This gives us what I wanted.

```console
$ cargo run -- --baz baz1,baz2 -f -b bar --baz baz3
   Compiling clap-with-order v0.1.0
    Finished dev [unoptimized + debuginfo] target(s) in 0.65s
     Running `target/debug/clap-with-order --baz baz1,baz2 -f -b bar --baz baz3`
Cli { foo: true, bar: Some("bar"), baz: ["baz1", "baz2", "baz3"] }
foobarbaz: [(2, Baz("baz1")), (3, Baz("baz2")), (4, Foo(true)), (6, Bar("bar")), (8, Baz("baz3"))]
```

In this result, the argument order is left, but if not needed, the following processing can be added at the end to take out only the values.

```rust
let foobarbaz = foobarbaz.drain(..).map(|v| v.1).collect::<Vec<_>>();
println!("foobarbaz: {foobarbaz:?}");
```

```console
cargo run -- --baz baz1,baz2 -f -b bar --baz baz3
   Compiling clap-with-order v0.1.0
    Finished dev [unoptimized + debuginfo] target(s) in 0.65s
     Running `target/debug/clap-with-order --baz baz1,baz2 -f -b bar --baz baz3`
Cli { foo: true, bar: Some("bar"), baz: ["baz1", "baz2", "baz3"] }
foobarbaz: [Baz("baz1"), Baz("baz2"), Foo(true), Bar("bar"), Baz("baz3")]
```

This article describes how to use the clap library to create command line tools using both the derive API, which does not handle argument order but is easy to use, and the builder API, which does handle argument order but is complex. By using both the derive API and the builder API in this way, it is possible to build more complex and flexible command line interfaces.
