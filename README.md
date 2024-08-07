
# Aviato Project

This project consists of a Ruby on Rails backend with a nested Next.js frontend. Follow the steps below to set up, install dependencies, build, run, and use the application.

## Prerequisites

- Ruby (version 3.1.2)
- Node.js (version 18 or higher)
- NPM
- Sqlite

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/groddeck/aviato.git
cd aviato
```

### 2. Install Backend Dependencies

Ensure you have Bundler installed:

```bash
gem install bundler
```

Install the necessary Ruby gems:

```bash
bundle install
```

### 3. Install Frontend Dependencies

Navigate to the Next.js directory under ui:

```bash
cd ui
```

Install the necessary Node.js packages:

```bash
npm install
```

### 4. Database Setup

Go back to the root directory of the Rails project:

```bash
cd ..
```

Set up the database:

```bash
rails db:create
rails db:migrate
```

### 5. Environment Variables

Create a `.env` file in the root directory to store environment variables. Example:

```bash
cp .env.example .env
```

Update the `.env` file with your configuration.

### 6. Build the Frontend

Navigate to the Next.js directory and build the frontend:

```bash
cd ui
npm run build
```

Then navigate back to the root directory and link the ui build output directory as the rails public directory:

```bash
cd ..
ln -s ui/out public
```

### 7. Run the Application

#### Run the Rails server:

```bash
rails s -p 3001
```

### 8. Access the Application

- The Rails backend should be running at `http://localhost:3001`.

## Usage

### Accessing the Application

- Open your browser and go to `http://localhost:3001` to use the chat tool.
- Aviato is an AI chat tool, specializing in information about travel.
- Try asking about the weather in a desired destination, or about flight availability, price, etc.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
