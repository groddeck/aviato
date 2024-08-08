# Use the official Ruby image as the base image
FROM ruby:3.1.2

# Set environment variables
ENV RAILS_ENV=development
ENV NODE_ENV=development

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn

# Install additional dependencies
RUN apt-get install -y sqlite3

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock files
COPY Gemfile Gemfile.lock ./

# Install the Ruby dependencies
RUN gem install bundler && bundle install

# Copy the application code
COPY . .

# Navigate to the Next.js directory and install Node.js packages
WORKDIR /app/ui
RUN npm install

# Build the Next.js frontend
ENV NODE_ENV=production
RUN npm run build

# Link the Next.js build output directory to the Rails public directory
WORKDIR /app
RUN ln -s /app/ui/out /app/public

# Create and set up the database
RUN bundle exec rails db:create
RUN bundle exec rails db:migrate

# Expose port 3001 for the Rails server
EXPOSE 3001

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3001"]
