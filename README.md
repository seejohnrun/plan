# Plan

Plan is a simple command-line TODO manager written for [CodeBrawl](http://codebrawl.com/contests/command-line-todo-lists).  It takes a heirarchial approach to managing TODOs, so you can openly group items into projects.

## Intallation

Installation is as simple as `gem install plan`

## Creating Items

To create an item you can use the `plan create` command, like so:

``` bash
$ plan create open-source
```

If the item that you want to create has spaces or special symbols, just surround it with `"`'s like:

``` bash
$ plan create "open source"
```

## Lists

You can list the current items in your TODO list by using `plan list`:

``` bash
$ plan list
todo
-- open source
```

Once you have items in your list you can add sub-items like:

``` bash
$ plan create open-source "add that cool feature"
```

which will place `"add that cool feature"` underneath `open-source` in the heirarchy:

``` bash
$ plan list
todo
-- open source
---- add that cool feature
```

As a quicker way to add tasks you can use substrings like:

``` bash
$ plan create op "add cool feature"
$ plan create op "do other thing"
```

do add sub-items to the `open-source` item quickly and easily.

## Finish

When you have finished a task, you can select the same way, like

``` bash
$ plan finish "open-source" "add cool feature"
```

To mark an item as finished.  This works with groups and single items like you'd imagine: by finishing all sub-items.

You can use shorthand here also, so something like:

``` bash
$ plan finish open cool
```

would be equivelant to the above.

## Unfinish

If you mistakently mark something finished, you can use `unfinish` to reverse it just the same:

``` bash
# do nothing
$ plan finish open cool
$ plan unfinish open cool
```

## Cleanup

The dates you finish things will show up in `list` calls, until you run `cleanup` on a selection to hide them.  The same selectors work, and the cascading is taken care of automatically.

``` bash
$ plan list open
open-source
--- something (finished)
$ plan clean open
open-source
```

### Author

[John Crepezzi](http://seejohncode.com)

### License

MIT License (See attached `LICENSE` file)
