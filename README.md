# hanami-papercraft

## Use Papercraft templates with Hanami

> **Note**: this project is still in an experimental stage.

The `hanami-papercraft` gem lets you create Hanami views using Papercraft
templates. Papercraft is an innovaive new gem for generating HTML using plain
Ruby. For more information on Papercraft please visit the Papercraft website:
[papercraft.noteflakes.com](https://papercraft.noteflakes.com).

This gem introduces a new view class called `Hanami::PapercraftView`, which you
can use instead of `Hanami::View` as the base class of your app's views.

## Usage

For the sake of simplicity, we'll base the following instructions on the Hanami
[getting started
guide](https://guides.hanamirb.org/v2.3/introduction/building-a-web-app/).
Please keep in mind that `hanami-papercraft` is still in a very early stage of
development, so things might not work as you expect, especially if you use the
more advanced features of Hanami.

### 1. Add hanami-papercraft

In your `Gemfile`, add the following line:

```ruby
gem "hanami-papercraft"
```

Then run `bundle install` to update your dependencies.

### 2. Set your app's basic view class 

In `app/view.rb`, change the `View` classes superclass to `Hanami::PapercraftView`:

```ruby
# app/view.rb

module Bookshelf
  class View < Hanami::PapercraftView
  end
end
```

### 3. Use a Papercraft layout template

Replace the app's layout template stored in `app/templates/layouts/app.html.erb`
with a file named `app/templates/layouts/app.papercraft.rb`:

```ruby
# app/templates/layouts/app.papercraft.rb

->(config:, context:, **props) {
  html(lang: "en") {
    head {
      meta charset: "UTF-8"
      meta name: "viewport", content: "width=device-width, initial-scale=1.0"
      title "Bookshelf"
      favicon_tag
      stylesheet_tag(context, "app")
    }
    body {
      render_children(config:, context:, **props)
      javascript_tag(context, "app")
    }
  }
}
```

### 4. Use Papercraft view templates

You can now start writing your view templates with Papercraft, e.g.:

```ruby
# app/templates/books/index.papercraft.rb

->(context:, books:, **props) {
  h1 "Books"

  ul {
    books.each do |book|
      Kernel.p book
      li book[:title]
    end
  }
}

```

## Passing Template Parameters

While theoretically you have access to the view class in your templates (through
`self`), you should use explicit arguments in your templates, as shown in the
examples above. The `PapercraftView` class always passes template parameters as
keyword arguments to the layout and the view templates.

In the view template above, the `books` keyword argument is defined because the
view class exposes such a parameter:

```ruby
# app/views/books/index.rb

module Bookshelf
  module Views
    module Books
      class Index < Bookshelf::View
        expose :books do
          [
            {title: "Test Driven Development"},
            {title: "Practical Object-Oriented Design in Ruby"}
          ]
        end
      end
    end
  end
end
```

## Contributing


Please feel free to contribute issues and PR's...
