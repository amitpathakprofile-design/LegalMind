# LegalMind - AI-Powered Legal Document Analysis

LegalMind provides AI-powered contract review, risk detection, and intelligent document management for legal professionals.

## Getting Started

### Prerequisites

- Node.js & npm installed - [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

### Installation

```sh
# Step 1: Clone the repository
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the project directory
cd legalmind-project

# Step 3: Install dependencies
npm install

# Step 4: Create .env file with your Supabase credentials
# VITE_SUPABASE_URL=your_supabase_url
# VITE_SUPABASE_ANON_KEY=your_supabase_anon_key

# Step 5: Start the development server
npm run dev
```

## Technologies

This project is built with:

- **Vite** - Build tool and dev server
- **TypeScript** - Type safety
- **React** - UI framework
- **shadcn-ui** - Component library
- **Tailwind CSS** - Styling
- **Supabase** - Backend and authentication
- **React Router** - Routing

## Features

- 🔐 Secure authentication with email confirmation
- 📄 Document upload and management
- 🤖 AI-powered document analysis
- 💬 Chat interface for document queries
- 📊 Risk assessment and scoring
- 📱 Responsive mobile-first design

## Project Structure

```
src/
├── components/     # Reusable UI components
├── contexts/       # React contexts (Auth, etc.)
├── hooks/          # Custom React hooks
├── integrations/   # Third-party integrations (Supabase)
├── lib/            # Utility functions and validations
├── pages/          # Page components
└── main.tsx        # Application entry point
```

## Deployment

Build the project for production:

```sh
npm run build
```

The built files will be in the `dist` directory, ready to be deployed to your hosting provider.
