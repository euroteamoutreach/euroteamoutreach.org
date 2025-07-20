euroteamoutreach.org
====================

[euroteamoutreach.org][eto] is the official web site for Euro Team Outreach, Inc., a Christian organization dedicated to the advancement of the Gospel of Jesus Christ.

This site was built using [Middleman][middleman].

![euroteamoutreach.org screenshot][screenshot]

Requirements
------------

* [Middleman 4.x][middleman-docs]
* [Ruby 3.1.x][rbenv] (for Apple Silicon compatibility)
* [Node 20.x LTS][nvm] 
* [Yarn][yarn]
* [Gulp CLI][gulp-cli]
* [asdf][asdf] (recommended for version management)

**Apple Silicon (M1/M2) Note**: This project has been updated for full compatibility with Apple Silicon Macs. The `.tool-versions` file specifies the exact versions for asdf users.


Setup
-----

To get started, clone the repo, cd into it, and run the setup script.

```sh
$ bin/setup
```

**For asdf users**: The project includes a `.tool-versions` file that will automatically set the correct Ruby and Node.js versions:

```sh
$ asdf install        # Install required versions
$ asdf reshim         # Refresh shims if needed  
```

Development
-----------

This project uses [Gulp][gulp] with Middleman's [`external_pipeline`][external-pipeline] feature. The asset pipeline uses modern Sass (replacing the deprecated node-sass) for CSS compilation.

    # Run the development server with Gulp
    $ bundle exec middleman server
    
    # Build the site (also invokes Gulp)
    $ bundle exec middleman build

**Asset Pipeline**: CSS is compiled using [Dart Sass][dart-sass] via gulp-sass 5.x. JavaScript is bundled with Browserify. Live reload is provided by BrowserSync.

Environments
------------

Middleman has two default environments: `development` and `production`. This app is configured to run the external pipeline (Gulp in our case) in both. There are times, however, when the external pipeline should not run. Two good examples are tests and the console. We therefore define two additional environments: `test` and `console`.

Custom environments can be invoked on the command line with `-e` flag like so:

    # Start the console in the console enviroment
    $ bundle exec middleman console -e console

Code for custom environments is stored in `environments/<your-custom-env>.rb`. Note that custom environments can be invoked without the existence of a corresponding file in the `environments/` directory. If, for example, you merely wanted to start a server without the default `development` configs, you could run `middleman server -e <anything-here>`.

For completeness, all four environments used in this app have corresponding files:

```sh
environments/
├── console.rb
├── development.rb
├── production.rb
└── test.rb
```

Tests
-----

Testing is done with Rspec. Run the tests like so:

    $ bin/rspec spec/

Troubleshooting
---------------

**Apple Silicon (M1/M2) Issues**:
- Ensure you're using Ruby 3.1.x and Node 20.x as specified in `.tool-versions`
- If you encounter OpenSSL errors, make sure Ruby was compiled with the correct OpenSSL version
- Node-sass compilation errors are resolved by using the modern Sass implementation

**Common Issues**:
- **Build failures**: Try `rm -rf node_modules yarn.lock && yarn install` 
- **Asset compilation errors**: Ensure gulp-sass 5.x is installed and configured properly
- **Ruby version conflicts**: Use `asdf reshim ruby` after installing gems

Aliases
-------

Consider adding the following to your `.bashrc` or `.zshrc` file:

```sh
mm='bundle exec middleman'
mmb='bundle exec middleman build --clean'
mmc='bundle exec middleman console -e console'
mms='bundle exec middleman server'
```

Deployment
----------

euroteamoutreach.org is currently deployed on Amazon S3. [Detailed instructions][aws-s3-deployment] are available from Amazon.

**BONUS: If you deploy with Amazon, you can get a [free ssl certificate][aws-cert-manager] for your site!**

Legal
-----

Copyright &copy; 2025 Euro Team Outreach, Inc. Software is licensed under [MIT][license].

[asdf]: https://asdf-vm.com/
[aws-cert-manager]: https://aws.amazon.com/blogs/aws/new-aws-certificate-manager-deploy-ssltls-based-apps-on-aws/
[aws-s3-deployment]: http://docs.aws.amazon.com/gettingstarted/latest/swh/website-hosting-intro.html
[dart-sass]: https://sass-lang.com/dart-sass
[eto]: https://euroteamoutreach.org/
[external-pipeline]: https://middlemanapp.com/advanced/external-pipeline/
[gulp-cli]: https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md#getting-started
[gulp]: http://gulpjs.com/
[license]: https://github.com/euroteamoutreach/euroteamoutreach.org/blob/master/LICENSE
[middleman-docs]: https://middlemanapp.com/basics/install/
[middleman]: https://middlemanapp.com/
[nvm]: https://github.com/nvm-sh/nvm#readme
[rbenv]: https://github.com/rbenv/rbenv#readme
[screenshot]: https://s3.amazonaws.com/images.euroteamoutreach.org/eto-screenshot-2018-1200w.jpg
[yarn]: https://yarnpkg.com/en/
