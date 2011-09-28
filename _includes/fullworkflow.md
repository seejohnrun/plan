### Creating items

_Plan_ is organized hierarchically, which just means that your list of TODOs is made of items and sub-items, nested as deeply as you'd like.  To add an item, we use `plan create`.  Let's add a group for things that we need to do at home:

{% highlight bash %}
# create an item
$ plan create home
plan
-- home
{% endhighlight %}

Now that we have an item we can add sub-items to it.  Let's add a sub-item for a kitchen remodeling:

{% highlight bash %}
$ plan create home "kitchen remodeling"
home
-- kitchen remodeling
{% endhighlight %}

Which is comprised of a few sub-tasks like "get new faucet".  We'll add that, and use a shorthand for "kitchen remodeling", typing "kitchen" instead - because it would just be annoying to have to type the whole thing out.  You can use any substring (case-insensitive) of the original item:

{% highlight bash %}
$ plan create home kitchen "get new faucet"
kitchen remodeling
-- get new faucet
{% endhighlight %}

---

### Listing your plan

Now that we've added some items, it'll be useful to be able to list what we have to do.  We can do this with `plan list`:

{% highlight bash %}
$ plan list
plan
-- home
---- kitchen remodeling
------ get new faucet
{% endhighlight %}

Or if we only want to see the things that we have to do in the home:

{% highlight bash %}
$ plan list home
home
-- kitchen remodeling
---- get new faucet
{% endhighlight %}

or even just in the kitchen:

{% highlight bash %}
$ plan list home kitchen
kitchen remodeling
-- get new faucet
{% endhighlight %}

---

### Finishing things

When you finish a task, you'd like to be able to mark it as completed, and record the time that it was completed.  You can do this with `plan finish` on an item and all of its children.  So when we finish our kitchen remodeling, we can finish it:

{% highlight bash %}
$ plan finish home kitchen
kitchen remodeling (finished @ Sep. 28, 2011 11:37 am)
-- get new faucet (finished @ Sep. 28, 2011 11:37 am)
{% endhighlight %}

Now when we view our list, the finished things stay around, with an indication of when they are finished:

{% highlight bash %}
$ plan list
plan
-- home
---- kitchen remodeling (finished @ Sep. 28, 2011 11:37 am)
------ get new faucet (finished @ Sep. 28, 2011 11:37 am)
{% endhighlight %}

You can similarly use `plan unfinish` to clear the finish date of an item

---

### Cleaning up

All of the things that you finished can easily get in the way of what you still have to accomplish.  For that we have `plan cleanup` and all it does is cleanup finished items (and sub-items) that you tell it to.  Used with no options - it will clean up the entire tree.  Let's give it a shot:

{% highlight bash %}
$ plan cleanup
plan
-- home
{% endhighlight %}

We can see that the finished items have been hidden from view, and `plan list` reflects the same:

{% highlight bash %}
$ plan list
plan
-- home
{% endhighlight %}

---

### Thanks!

I hope this was a good introduction to _Plan_ and how to use it.  Drop me a line on [GitHub](http://github.com/seejohnrun) and let me know what you think - and feel free to send along contributions or issues!
