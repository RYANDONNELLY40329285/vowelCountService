# Use an official Ruby image
FROM ruby:3.2-alpine

# Install build tools and dependencies needed for native gems (like puma)
RUN apk add --no-cache build-base

# Create app directory
WORKDIR /app

# Install only runtime gems first (faster Docker caching)
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'development test' \
  && bundle install

# Copy the rest of the app
COPY . .

# Environment
ENV RACK_ENV=production

# Expose Sinatra/Rack port
EXPOSE 4567

# Start the app using rackup and your config.ru
CMD ["bundle", "exec", "rackup", "config.ru", "-p", "4567", "-o", "0.0.0.0"]