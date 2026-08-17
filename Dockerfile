FROM ruby:3.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    fonts-noto-cjk \
    git \
    librsvg2-bin \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv/jekyll

COPY Gemfile ./

RUN bundle install

EXPOSE 4000

CMD ["sh", "-lc", "bundle exec ruby _scripts/generate_ogp_images.rb --config .jekyll-cache/ogp.yml --output _site && bundle exec jekyll serve --config _config.yml,.jekyll-cache/ogp.yml --host 0.0.0.0 --livereload"]
