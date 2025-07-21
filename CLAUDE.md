# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup
```bash
bin/setup                    # Install all dependencies (Ruby gems + Node packages)
```

### Development Server
```bash
bin/dev                        # Start unified development environment (Gulp + Middleman)
bundle exec middleman server   # Start Middleman server only (requires separate Gulp)
mms                            # Alias for Middleman server only
```

**Recommended**: Use `bin/dev` for development as it handles both asset compilation and live reload.

### Building
```bash
bundle exec middleman build    # Build production site
mmb                            # Alias for above command (includes --clean)
```

### Testing
```bash
bin/rspec spec/                # Run all RSpec tests
```

### Asset Pipeline
The project uses Gulp.js for asset processing:
- In **development**: Gulp outputs assets directly to `source/assets/` (watched by `bin/dev`)
- In **production**: Gulp outputs to `.tmp/` via Middleman's external pipeline
- `yarn development` - Development asset build (manual)
- `yarn production` - Production asset build with minification

## Architecture Overview

### Technology Stack
- **Static Site Generator**: Middleman 4.x (Ruby-based)
- **Build Tool**: Gulp.js for asset compilation
- **Template Engine**: Haml for HTML, Sass for CSS
- **JavaScript**: Browserify for bundling
- **Testing**: RSpec with Capybara for feature tests

### Project Structure
```
source/                    # Middleman source files
├── assets/               # Assets processed by Gulp
│   ├── stylesheets/      # Sass files (Bourbon + Neat grid)
│   ├── javascripts/      # JS files bundled via Browserify
│   └── images/           # Images (optimized by Gulp)
├── layouts/              # Haml layout templates
├── partials/             # Reusable Haml partials
├── markdown/             # Markdown content files
└── blog/                 # Blog articles

data/                     # YAML data files
├── site.yml             # Site configuration and metadata
└── redirects.yml        # URL redirects

helpers/                  # Custom Middleman helpers
└── custom_helpers.rb    # Site-specific helper methods

environments/            # Environment-specific configurations
├── development.rb       # Development settings
├── production.rb        # Production settings
├── test.rb             # Test environment settings
└── console.rb          # Console environment settings
```

### Key Configuration Files
- `config.rb` - Main Middleman configuration
- `gulpfile.js` - Asset build pipeline configuration
- `Gemfile` - Ruby dependencies
- `package.json` - Node.js dependencies

### Development Workflow
1. Assets are processed by Gulp and output to `.tmp/` directory
2. Middleman watches `.tmp/` via external pipeline configuration
3. BrowserSync provides live reload for CSS/JS changes
4. Blog articles use Markdown with YAML front matter
5. Images have responsive versions generated (550w, 1200w, 2000w, etc.)

### Custom Helpers
The `CustomHelpers` module provides utility methods:
- `full_title()` - Constructs page titles with site name
- `inline_svg()` - Embeds SVG files directly in templates
- `social_link_for()` - Generates social media links from author data
- `smart_robots()` - Sets appropriate robots meta tags

### Testing Strategy
- Feature tests use RSpec + Capybara
- Tests verify page content, navigation, and form functionality
- Test files located in `spec/features/`
- Helper tests in `spec/helpers/`

### Deployment
- Site deploys to Amazon S3
- Production build includes asset minification and gzip compression
- Uses AWS Certificate Manager for SSL

### Environment Management
Four environments configured:
- `development` - Full external pipeline with live reload
- `production` - Optimized build with minification
- `test` - Minimal pipeline for faster test runs  
- `console` - No external pipeline for debugging

Use `-e <environment>` flag to specify: `bundle exec middleman server -e test`