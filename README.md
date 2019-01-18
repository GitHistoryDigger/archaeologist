# Archeologist

## What this?
This repo measures coding language in the specified git repository per a commit.

## Why I create this?
When I was a university student, I had to analyze around 5k repositories to check
what coding languages were used. I used [the fork of ohcount] at that time,
and as my training of ruby language, I tried to re-code a part of my code into ruby
language.

Not only "just-recoding", I changed the analyzer from [the fork of ohcount]
to [linguist] provided by [github].

[the fork of ohcount]: https://github.com/blackducksoftware/ohcount
[linguist]: https://github.com/github/linguist
[github]: https://github.com/github

## Installation
`bundle add archaeologist`

## How to use
First, this lib has 2 scripts:

* `repowalker`: Parse commit object by walking on the specified repository.
* `analyzer`: Analyze what coding languages are used **in the object**. Note
   that the granularity of the analysis is per-commit, not per-repo.
