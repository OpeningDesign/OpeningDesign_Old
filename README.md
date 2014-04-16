OpeningDesign Rails Application
===============================

Enable architects, builders and engineers to collaborate on projects
and integrate etherpad technology for online collaboration.

## Installation for development

Ruby 1.9.3 and [bundler](http://gembundler.com/) are required,
[rvm](https://rvm.io/) is recommended for now (there's a `.rvmrc` file in the
root directory).

Also required is [ beanstalkd ](http://kr.github.com/beanstalkd/) as a queue.
You *can* run the app without it, but then you can't use `foreman`, you'd have
to use `rails server` to start; and consequentially, you wouldn't get any of
the asynchronous jobs executed, see `./config/worker.rb`.

Use `rake db:setup` to setup the dev database.

On Mac OSX, you can use [pow](http://pow.cx/manual.html) to run the app, by
placing a symbolic link to the project's root dir into `~/.pow`, see
[pow](http://pow.cx/manual.html) if in doubt.

Otherwise, run `foreman start` to start the app (via `spork`), the workers (via
`stalk`) and the clock (via `clockwork`).

## License

MIT or BSD... take your pick
