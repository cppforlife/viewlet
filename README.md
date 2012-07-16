## Goals

* to ease creation of view components

  Problem: Most likely your site has few similar view structures that
  are repeated throughout the site (e.g. *list* of members, groups, etc.).
  One solution is to refactor such code into a shared partial
  (may be `_list_section.html.haml`) and pass customization options
  via locals hash; however, with this approach it can become quite
  challenging/inelegant to apply customizations.

* to organize HTML/JS/CSS files based on a feature rather than file type

  Problem: As soon as you start extracting reusable view components
  from your pages it becomes weird to have HTML/CSS/JS component files
  spread out in three different directories. Turning your component into a
  gem remedies that problem since gems can have separate `assets`
  directory; however, I don't see a benefit in making every single
  component into a gem, especially when it's application specific.

## Installation

```ruby
gem "viewlet", :git => "https://github.com/cppforlife/viewlet.git"
```

## Usage

Let's say we have `GroupsController#show` that lists group members.
Here is how `show.html.haml` could look:

```haml
%h1= "Group: #{@group.name}"
%p= @group.description

= viewlet(:list_section) do |s|
  - s.heading "Group members"
  - s.empty_description "No members in this group"

  - s.collapse_button false
  - s.add_button do
    = link_to "Invite Members", new_group_member_path(@group)

  - s.items @group.members
  - s.row do |member|
    .left
      .name= member.name
      .summary= member.summary
    .right
      = render :partial => "some_other_partial", :locals => {:member => member}
```

Now let's define list_section viewlet. Viewlets live in `app/viewlets`
and each one must have at least `plugin.html.haml`.

In `app/viewlets/list_section/plugin.html.haml`:

```haml
.list_section
  %h2
    = heading
    - if add_button
      %small= add_button
    - if collapse_button
      %small.collapse_button= link_to "Collapse", "#"

  - if items.empty?
    %p= empty_description
  - else
    %ul
      - items.each do |item|
        %li{:class => cycle("odd", "even", :name => :list_section)}
          = capture(item, &row)
```

All viewlet options (heading, add_button, etc.) set in `show.html.haml`
become available in `plugin.html.haml` as local variables. None of
those options are special and you can make up as many as you want.

### CSS & JS

You can also add other types of files to `app/viewlets/list_section/`.
Idea here is that your viewlet is self-contained and
encapsulates all needed parts - HTML, CSS, and JS.

In `app/viewlets/list_section/plugin.css.scss`:

```scss
.list_section {
  width: 300px;

  ul {
    margin: 0;
  }

  li {
    border: 1px solid #ccc;
    margin-bottom: -1px;
    padding: 10px;
    list-style-type: none;
    overflow: hidden;
  }

  .left {
    float: left;
  }

  .right {
    float: right;
  }
}
```

To include list_section viewlet CSS in your application add

    *= require list_section/plugin

to your `application.css`

In `app/viewlets/list_section/plugin.js`:

```javascript
// Probably define listSection() jQuery plugin
```

To include list_section viewlet JS in your application add

```javascript
//= require list_section/plugin
```

to your `application.js`

## Misc

* Let's say we decide to make our list_section viewlet use
third-party list re-ordering library (e.g. `orderable-list.js`).
You can add `orderable-list.js` javascript file to
`app/viewlets/list_section` and require it from `plugin.js`:

```javascript
//= require ./orderable-list
```

* Let's say our `plugin.js` defined jQuery plugin `listSection`
so that in our `application.js` we can do something like this:

```javascript
$(document).ready(function(){
  $(".list_section").listSection();
});
```

This is fine; however, that means that our component is not
really functional until we add that javascript piece somewhere.
Alternatively you can put it right after HTML so everytime
list_section is rendered it will be automatically initialized.

For example in `plugin.html.haml`:

```haml
.list_section{:id => unique_id}
  %h2= heading
  ...

- unless defined?(no_script)
  :javascript
    $(document).ready(function(){
      $("##{unique_id}").listSection();
    });
```

Every viewlet has a predefined local variable `unique_id`
that could be used as HTML id.

* It's trivial to subclass `Viewlet::Base` to add new functionality.
`class_name` option lets you set custom viewlet class:

```haml
= viewlet(:list_section, :class_name => "CustomListSectionViewlet") do
  ...
```

* You do not have to pass in block to `viewlet`:

```haml
= viewlet(:password_strength)
```

## Todo

* come up with a better name for main files - *plugin* doesn't sound that good
* `lib/viewlets/` as fallback viewlet lookup path
* automatically load custom Viewlet::Base subclass from `some_viewlet/plugin.rb`
