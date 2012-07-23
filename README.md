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

  - s.row_title do |member|
    .name= member.name
    .summary= member.summary

  - s.row_details do |member|
    = render :partial => "some_other_partial", :locals => {:member => member}
```

Now let's define list_section viewlet. Viewlets live in `app/viewlets`
and each one must have at least `<name>.html.haml`.

In `app/viewlets/list_section/list_section.html.haml`:

```haml
.list_section
  %h2
    = heading

    - if add_button
      %small= add_button

    - if collapse_button
      %small.collapse_button= link_to "Collapse", "#"

  - if items.empty?
    - # outputs value regardless being defined as an argument-less block or a plain value
    %p= empty_description

  - else
    %ul
      - items.each do |item|
        %li{:class => cycle("odd", "even", :name => :list_section)}
          .left= list_section.row_title(item)

          - # alternative way of capturing block's content
          .right= capture(item, &row_details)
```

All viewlet options (heading, add_button, etc.) set in `show.html.haml`
become available in `list_section.html.haml` as local variables. None of
those options are special and you can make up as many as you want.

Note: If there aren't CSS or JS files you want to keep next to your viewlet
HTML file you don't need to create a directory for each viewlet; simply
put them in `app/viewlets` e.g. `app/viewlets/list_section.html.haml`.

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

## Tips

* You do not have to provide a block to `viewlet`:

```haml
= viewlet(:password_strength)
```

* You can use hash syntax (and block syntax):

```haml
= viewlet(:password_strength, :levels => %w(none weak good))

= viewlet(:password_strength, :levels => %w(none weak good)) do |ps|
  - ps.levels %w(none weak good excellent) # overrides levels
```

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

For example in `list_section.html.haml`:

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
= viewlet(:list_section, {}, :class_name => "CustomListSectionViewlet") do
  ...
```

* If you are using HAML you can use special syntax to output a viewlet:

```haml
%list_section_viewlet # viewlet name suffixed with '_viewlet'
  heading "Group members"
  empty_description "No members in this group"

  collapse_button false
  add_button do
    = link_to "Invite Members", new_group_member_path(@group)

  items @group.members

  row_title do |member|
    .name= member.name
    .summary= member.summary

  row_details do |member|
    = render :partial => "some_other_partial", :locals => {:member => member}

%password_strength_viewlet{:levels => %w(none weak good)}
```

## Todo

* come up with a better name for main files - *plugin* doesn't sound that good
* `lib/viewlets/` as fallback viewlet lookup path
* automatically load custom Viewlet::Base subclass from `some_viewlet/plugin.rb`
