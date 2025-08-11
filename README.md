# euroteamoutreach.org

[euroteamoutreach.org][eto] is the official web site for Euro Team Outreach, Inc., a Christian organization dedicated to the advancement of the Gospel of Jesus Christ.

This site was built using [Middleman][middleman].

![euroteamoutreach.org screenshot][screenshot]

## Requirements

- [Middleman 4.x][middleman-docs]
- [Ruby 3.1.x][rbenv] (for Apple Silicon compatibility)
- [Node 20.x LTS][nvm]
- [Yarn][yarn]
- [Gulp CLI][gulp-cli]
- [asdf][asdf] (recommended for version management)

**Apple Silicon (M1/M2) Note**: This project has been updated for full compatibility with Apple Silicon Macs. The `.tool-versions` file specifies the exact versions for asdf users.

## Setup

To get started, clone the repo, cd into it, and run the setup script.

```sh
bin/setup
```

**For asdf users**: The project includes a `.tool-versions` file that will automatically set the correct Ruby and Node.js versions:

```sh
asdf install        # Install required versions
asdf reshim         # Refresh shims if needed
```

## Development

This project uses [Gulp][gulp] for asset processing with modern Sass (replacing deprecated node-sass) and Browserify for JavaScript bundling.

### Unified Development Server

**Recommended**: Use the unified development command for the best experience:

```sh
bin/dev
```

This single command:

- Builds initial CSS and JavaScript assets
- Starts Gulp watchers for live asset compilation
- Launches Middleman server with live reload
- Handles proper cleanup when stopped (Ctrl+C)

### Manual Development

If you prefer to run servers separately:

```sh
# Terminal 1: Start asset watcher
$ NODE_ENV=development npx gulp default

# Terminal 2: Start Middleman server
$ bundle exec middleman server
```

**Asset Pipeline**: CSS is compiled using [Dart Sass][dart-sass] via gulp-sass 5.x. JavaScript is bundled with Browserify. In development, assets are output directly to `source/assets/` to avoid external pipeline path issues.

## Build & Testing

### Building the Site

The project supports two build modes:

```sh
# Build for local testing (relative asset paths)
$ yarn build

# Build for production deployment (CDN asset paths)
$ yarn build:production
```

### Local Testing

Test the built site locally before deployment:

```sh
# Build the site for local testing
$ yarn build

# Serve the built site on http://localhost:8080
$ yarn serve
```

This serves the static files from the `build/` directory, allowing you to test the exact files that would be deployed.

### Running Tests

Testing is done with RSpec:

```sh
bin/rspec spec/
```

## Environments

This project uses multiple Middleman environments for different purposes:

- **`development`**: For local development with live reload
- **`staging`**: For building static sites with relative asset paths (ideal for local testing)
- **`production`**: For deployment with CDN asset hosting and optimizations
- **`test`**: For running tests without external pipeline
- **`console`**: For console access without external pipeline

Custom environments can be invoked on the command line with the `-e` flag:

```sh
# Start the console in the console environment
$ bundle exec middleman console -e console

# Build with a specific environment
$ bundle exec middleman build --clean --environment=staging
```

All environments have corresponding configuration files:

```sh
environments/
├── console.rb
├── development.rb
├── production.rb
├── staging.rb
└── test.rb
```

## Troubleshooting

**Apple Silicon (M1/M2) Issues**:

- Ensure you're using Ruby 3.1.x and Node 20.x as specified in `.tool-versions`
- If you encounter OpenSSL errors, make sure Ruby was compiled with the correct OpenSSL version
- Node-sass compilation errors are resolved by using the modern Sass implementation

**Common Issues**:

- **Build failures**: Try `rm -rf node_modules yarn.lock && yarn install`
- **Asset compilation errors**: Ensure gulp-sass 5.x is installed and configured properly
- **Ruby version conflicts**: Use `asdf reshim ruby` after installing gems

## Aliases

Consider adding the following to your `.bashrc` or `.zshrc` file:

```sh
# Legacy Middleman commands
alias mm='bundle exec middleman'
alias mmc='bundle exec middleman console -e console'

# Modern development workflow
alias dev='bin/dev'                    # Unified development server
alias build='yarn build'               # Build for local testing
alias build:prod='yarn build:production'  # Build for production
alias serve='yarn serve'               # Serve built site locally
alias deploy='bin/deploy production'   # Deploy to production
```

## Deployment

euroteamoutreach.org is deployed to Amazon S3 with CloudFront CDN distribution. The deployment process is automated using the `middleman-s3_sync` gem.

### Prerequisites

- AWS credentials configured (via environment variables or AWS CLI)

### Deploy to Production

```sh
# Deploy to production
$ bin/deploy production
```

This command will:

1. Confirm you want to deploy to production
2. Build the site with production settings (`--environment=production`)
3. Sync files to the S3 bucket with optimizations (gzip, caching headers)
4. Invalidate CloudFront cache as needed

#### Using 1Password CLI (Optional)

If you use [1Password CLI][op-cli] for credential management, you can deploy securely without storing AWS credentials in your environment:

```sh
# Deploy using 1Password for secure credential management
$ op run --no-masking -- bin/deploy production
```

### Infrastructure

- **S3 Bucket**: `euroteamoutreach.org`
- **CDN**: CloudFront distribution (`d2amb9pccla9r3.cloudfront.net`)
- **SSL Certificate**: AWS Certificate Manager provides free SSL
- **Caching**: Assets cached for 1 year, HTML files have no cache with `must-revalidate`

### Manual Deployment Commands

For advanced users or troubleshooting:

```sh
# Build for production
$ bundle exec middleman build --clean --environment=production

# Sync to S3 (requires AWS credentials)
$ bundle exec middleman s3_sync --environment=production
```

## Legal

Copyright &copy; 2025 Euro Team Outreach, Inc. Software is licensed under [MIT][license].

[asdf]: https://asdf-vm.com/
[dart-sass]: https://sass-lang.com/dart-sass
[eto]: https://euroteamoutreach.org/
[gulp-cli]: https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md#getting-started
[gulp]: http://gulpjs.com/
[license]: https://github.com/euroteamoutreach/euroteamoutreach.org/blob/master/LICENSE
[middleman-docs]: https://middlemanapp.com/basics/install/
[middleman]: https://middlemanapp.com/
[nvm]: https://github.com/nvm-sh/nvm#readme
[op-cli]: https://developer.1password.com/docs/cli/
[rbenv]: https://github.com/rbenv/rbenv#readme
[screenshot]: https://s3.amazonaws.com/images.euroteamoutreach.org/eto-screenshot-2018-1200w.jpg
[yarn]: https://yarnpkg.com/en/
