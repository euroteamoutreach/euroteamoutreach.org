# euroteamoutreach.org

[![Build Status](https://travis-ci.org/joshukraine/euroteamoutreach.org.svg?branch=master)](https://travis-ci.org/joshukraine/euroteamoutreach.org)

[euroteamoutreach.org](http://euroteamoutreach.org/) is the web site for Euro Team Outreach, Inc., a Christian organization dedicated to the advancement of the Gospel of Jesus Christ.

This site was built using [Middleman 4](https://middlemanapp.com/).

![euroteamoutreach.org screenshot](https://s3.amazonaws.com/images.euroteamoutreach.org/eto-screenshot.jpg)

### Setup

To get started, clone the repo, cd into it, and run the setup script.

```sh
$ bin/setup
```

### Development

This project uses [Gulp](http://gulpjs.com/) with Middleman's new [`external_pipeline`](https://middlemanapp.com/advanced/external-pipeline/) feature introduced in v4. When running the local development server, append `-e gulp` to [set the environment](https://middlemanapp.com/basics/upgrade-v4/#environments-and-changes-to-configure-blocks) to `gulp` and invoke the external pipeline.

    # With Gulp
    $ bundle exec middleman server -e gulp
    
    # Without Gulp
    $ bundle exec middleman server

### Deployment

euroteamoutreach.org is currently deployed on Amazon S3. [Detailed instructions](http://docs.aws.amazon.com/gettingstarted/latest/swh/website-hosting-intro.html) are available from Amazon.
