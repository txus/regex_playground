# regex_playground

__Warning open-source warriors: this code is a spike, not really useful yet.__

A compiler that turns (a small subset of) regular expressions into finite
state machines (FSM). And for now it just shows them as visual graphs for you
to enjoy!

This is an excuse to play around with different regular expression
implementation algorithms and learn about them without having to code the whole
thing in C. Of course, a real implementation would need to be really low level
to be useful.

## Install

    $ brew install graphviz
    $ git clone git://github.com/txus/regex_playground
    $ cd regex_playground
    $ bundle install && rake

## Current status

For now it just understands terminals such as "a", "b", "28" or "9{yfooabr",
and the special character "+".

So as an example, the following regexen can be compiled:

    abc
    ab+c
    aaabbb+
    metherfeck+er

It's hacky just yet, very WIP.

## Who's talking?

This was made by [Josep M. Bach (Txus)](http://txustice.me) under the MIT
license. I'm [@txustice](http://twitter.com/txustice) on twitter (where you
should probably follow me!).
