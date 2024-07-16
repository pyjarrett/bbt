[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/bbt.json)](https://alire.ada.dev/crates/bbt.html)


# `bbt` README <!-- omit from toc -->

- [Overview](#overview)
  - [Scenario : I want to know uut version](#scenario--i-want-to-know-uut-version)
- [Main characteristics](#main-characteristics)
  - [Specification is the test](#specification-is-the-test)
  - [Tests are easy to write](#tests-are-easy-to-write)
  - [Tests are easy to run](#tests-are-easy-to-run)
  - [Tests are Self documented](#tests-are-self-documented)
- [Objective of the project](#objective-of-the-project)
- [Limitations](#limitations)
- [Installation](#installation)
- [Further reading](#further-reading)

## Overview

bbt is a simple tool to black box check the behavior of an executable (hence the name, bbt stands for *Black Box Tester*).  
**The beauty of btt is that it directly uses your behavior documentation as a the test script.**

The behavior is described using the [BDD](https://en.wikipedia.org/wiki/Behavior-driven_development) usual pattern *Given / When / Then*, and a subset of the existing [Markdown with Gherkin](https://github.com/cucumber/gherkin/blob/main/MARKDOWN_WITH_GHERKIN.md#markdown-with-gherkin) syntax.

It can be as simple as :

```md
### Scenario : I want to know uut version

- When I run `uut --version`
- Then the output contains `version 1.0`
```
That will render this way in your documentation:

### Scenario : I want to know uut version

- When I run `uut --version`
- Then the output contains `version 1.0`


Some more representative examples are available [here](docs/tests/examples_results.md).  
(This is the results page, click on "hello_word.md" for example to see the scenario).

Note that bbt is fully tested with bbt since 0.0.4 version.  
bbt own tests are based on feature descriptions available [here](docs/tests/features_results.md).

## Main characteristics

### Specification is the only source of truth

bbt most interesting feature is that the above scenario (that is *specification*) is directly executable : there is no intermediate code generation, no use of a shell"ish" language, no glue code, no configuration file.  

Just simple and readable English sentences, that may be written by non-coders.  

bbt is reading only specifics line in the specification, meaning that the rest of the file is yours : you can give as much context as you want, using all Markdown possibilities with very few limitations, and even Markdown extensions, including graphics (Give a try to [Mermaid](https://mermaid.js.org/intro/)).

Note also alternative tools exists, refer to [My quick overview of some comparable tools](docs/comparables.md), but as far as i know, none of them provide such a direct "run the doc" approach.

**Tests results** are generated when running `bbt`, by just using the `-o` option (--output). It's also a Markdown file.  
Each result has a link to the matching scenario file : if a test fail, just click on the link and you are in the scenario.  
To see what it looks like, there is an example in [bbt own tests](docs/tests/features_results.md).

### Tests are easy to write

bbt uses a (very) limited english subset, with a vocabulary dedicated to test with keywords like *run*, *output*, *contains*, etc.

Although simple, you don't have to learn this language by heart, you may ask for a template file with :  
> bbt -ct (or --create_template)  

or ask for the complete grammar with :  
> bbt -lg (or --list_grammar)

### Tests are easy to run

To run the test :  
> bbt my_scenario.md

Or to run all the tests files in the `tests` tree :
> bbt -r tests

That's it : no cascading Makefile, no script.

bbt as no dependencies on external lib or tools (diff, for example), and aims at reducing uses of other tools, and platform dependency.  

*Describe once, verify everywhere!*

## Objective of the project 

bbt project aim at exploring how far we can push the "specification is the test" assertion, while maintaining the main feature : ease of use. 

**If a newbie is able to use btt in a quarter of an hour, and an experienced user is able to write and run a test in less than 3 minutes, with no need to rewrite or post-process the generated documentation, I'll consider it as a great success.**    

bbt is by nature limited : it is dedicated to command line, taking some input and producing some output.
It is not meant for UI testing or Web interaction, Complex file system stuffs, White box testing (obviously), checking internal states, or extensive API testing. 

It probably won't be the only test tool of your project, **and do not aim at that!** .  


## Status of the project

As of version 0.0.4, bbt is in an early stage, meaning that his behavior is subject to changes.  
Feel free to make suggestions [in bbt discussions](https://github.com/LionelDraghi/bbt/discussions)). 

The code has grown fast in three months, and is far from being clean.  
And there is yet no design description. 

Nevertheless, bbt is working. It has as a [test base](docs/tests/features_results.md).
My own project [acc](https://github.com/LionelDraghi/ArchiCheck) started the migration of its large tests base to bbt.  

## Limitations

btt is currently tested only on my Linux amd64 platform.

## Installation

[![Alire](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/list_image.json)](https://alire.ada.dev/crates/list_image.html) is available thanks to the Alire package manager.  
1. To install Alire on your platform, refer to [Alire](https://alire.ada.dev/)  
   
2. Then to install bbt :
    > cd bbt  
    > alr build  

3. Move the bbt exec somewhere in your PATH

## Further reading
- [User Guide](docs/UG.md): concepts, command, line, features...
- [References](docs/references.md) : syntax, grammar, and more details on non obvious behavior
- [Project status](docs/project.md): changelog, tests, TDL...

