## Overview

`bbt` stands for `Black Box Tester`.

`bbt` is a simple tool to check the behavior of an executable.
The expected behavior of the executable under test is described using the [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) *Given* / *When* / *Then* usual pattern, in a simple Markdown format. 

It can be as simple as :
```md
## Scenario : Command line version option

- When I run `uut --version`
- Then the output contains `version 1.0`
```

Here is the magic : `bbt` understand some of the words in the step description (that is words afters `When`, `Then`, etc.). It has it's own simple DSL, and interpret `run`, `contains`, etc. 

It as not dependencies on external lib or tools (diff tools, for example), and therefore is platform independent. You can execute it transparently on Windows, Linux, etc. 
> Describe behavior once, verify everywhere!

And because it is dedicated to black box testing, it is completely programming language independent.

> [!NOTE] 
> `bbt` objective is command line tools testing.  
> For GUI testing, or complex configurations, move on! (and don't expect to find something as simple as `bbt`) :-)



## Basic Concepts

Basic concepts of `bbt` file are illustrated in the previous example :

1. **the BDD usual keywords** : `Scenario`, `When`, `Then`, etc.  
   `bbt` use a subset of the [Gerkhin language](https://en.wikipedia.org/wiki/Cucumber_(software)#Gherkin_language).  
   For the Markdown format, `bbd` uses (a subset of) [Markdown with Gherkin](https://github.com/cucumber/gherkin/blob/main/MARKDOWN_WITH_GHERKIN.md#markdown-with-gherkin) format.

2. [**`bbt` keywords**](#Keywords) : `run`, `output`, `contains`, etc. 
  This is where `bbt` magic is, it as it's own DSL.
  Refer to XXX for a complete list.
  
3. **glue word** : *I*, *the*
  Glue word are ignored by `bbt`. Their only aim is to give users a more flexible way to write. This is an important `bbt` feature, not to be rigid like a compiler, as long as this is not creating ambiguity.
   
4. [**code span**](https://spec.commonmark.org/0.31.2/#code-spans), that is text surrounded by backticks : `uut --version`, `version 1.0`  
  `bbt` uses code span to express a command, a file name, some expected out.

1. [**Fenced code block**](https://spec.commonmark.org/0.31.2/#fenced-code-blocks), that is lines between ``` or ~~~  
Fenced code block are used to specify multiline output or file content, as in 

~~~md
## [Scenario]: : Command line help

- When I run `uut -h`
- Then the output is
```
uut [options] [-I directory]
options :
-h : help
-r : recurse
```
~~~


## Keywords 

Recognized subset of the [Gerkhin language](https://en.wikipedia.org/wiki/Cucumber_(software)#Gherkin_language) :
- Feature
- Scenario
- et.


`bbt` own DSL :
- file
- no
- running
- created
- contains
- ignoring blanks
- returned
- output
- error
- is / should be


And later :

- diff
- environment

## Cookbook 



# Why, existing tools and design decision and references

## What make it different :

  - Very simple : 

  - Write once :
        test cases are written in almost plain English
        within a Gherkin classical frame (given … when … then)
        using Markdown (or more precisely, [Markdown with Gherkin (MDG)]( https://github.com/cucumber/gherkin/blob/main/MARKDOWN_WITH_GHERKIN.md), that is a strict superset of GFM)
        the test driver directly consume this file, no intermediate step

        **“documentation is the code“**

  - Run everywhere :
        Language Independent (no fixture, stub, moq… )
        It’s written in Ada, but you don’t care, could be whatever

        Platform independent (run on Linux/Windows/MacOS) :
        No more unreadable makefile, no more CI complex script

## What I don’t want :

  - Cram uses snippets of interactive shell sessions. This is not portable, unless providing a complete “bash like” environment in Windows, for example.
    And it’s using a “shell like” syntax, with meaningful indentation (horror), a $ sign at the beginning of the command, and a > sign for continuation line.
    I want something clear, as close as English as possible, with no cryptic signs.
    Same apply to output : when comparing the actual output with the expected one, I don’t care to have a classical [unified diff format](https://en.wikipedia.org/wiki/Diff#Unified_format) that could be used by some other tools.
    What a want is directly a clear side by side diff that is understandable by humans.

    [Exactly ]( https://github.com/emilkarlen/exactly/tree/master) is doing the job, and actually much more than what I need, but with a specialized language :

```
[setup]
stdin = -contents-of some-test-contacts.txt

[act]
my-contacts-program get-email --name 'Pablo Gauss'

[assert]
exit-code == 0

stdout equals <<EOF
pablo@gauss.org
EOF

stderr is-empty

```
Not as easy to read as English, and not suitable for immediate insertion in documentation.

- [BATS]( https://github.com/bats-core/bats-core) example :

          @test "addition using bc" {
            result="$(echo 2+2 | bc)"
            [ "$result" -eq 4 ]
          }

## TDL, What is not (yet) implemented :

    - Command line Interactive testing (if the command prompt Y/N before continuing…)
    - no new files feature
    - Functionnalité intéressante pour le futur sur les interactive command line interface a mettre dans la TDL
    - regexp

     
## What it is not mean for :

    UI testing
    Obviously white box testing, checking internal states
    Note that you can have a kind of “grey box” testing with an exe providing “observability” features, interesting discussion on this and TTD [here](https://www.youtube.com/watch?v=prLRI3VEVq4&t=2190s)
    Very complex interaction with the file system
    Web interaction (could be done with some kind of stubbing?)


## Design

### AST

Gerkhin file data model :  https://github.com/cucumber/gherkin?tab=readme-ov-file#abstract-syntax-tree-ast

### Markdown compliance and vocabulary
The BBT Markdown subset try to comply with [CommonMark Spec](https://spec.commonmark.org/)

Only [ATX Heading](https://spec.commonmark.org/0.31.2/#atx-headings) are supported, not [Setext](https://spec.commonmark.org/0.31.2/#setext-headings), meaning that you can write :
```
## Feature
```
but not
```
Feature
-------
```
in the test file.

### References
https://github.com/briot/gnatbdd/tree/master
https://github.com/dcurtis/markdown-mark


I know that both `BDD` and `bbt`, maybe be confusing, therefor the method always appears in upper case, and the tool in lower case.
And there is also MDG (for Markdown Gherkin)

[Specification as a ubiquitous language](https://en.wikipedia.org/wiki/Behavior-driven_development#Specification_as_a_ubiquitous_language)
*A ubiquitous language is a (semi-)formal language that is shared by all members of a software development team — both software developers and non-technical personnel.*