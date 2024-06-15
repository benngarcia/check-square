# Use the official Ruby image
FROM ruby:3.3.0

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    wget \
    gnupg2 \
    unzip \
    curl \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    xdg-utils

# Install Chromium
RUN apt-get install -y chromium

# Install bundler
RUN gem install bundler

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy the Ruby script
COPY main.rb .

# Set the BROWSER_PATH environment variable
ENV BROWSER_PATH="/usr/bin/chromium"

# Run the Ruby script
CMD ["ruby", "main.rb"]
