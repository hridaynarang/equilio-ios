# Equilio Backend

FastAPI backend for the Equilio iOS application.

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
```
Edit `.env` with your configuration.

4. Set up PostgreSQL:
- Create a database named `equilio`
- Update the `DATABASE_URL` in `.env` with your database credentials

5. Run the application:
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Project Structure

```
equilio-backend/
├── main.py              # FastAPI application entry point
├── database.py          # Database configuration
├── requirements.txt     # Project dependencies
├── .env                 # Environment variables
├── routers/            # API route handlers
│   ├── auth.py         # Authentication endpoints
│   └── users.py        # User management endpoints
├── models/             # SQLAlchemy models
│   └── user.py         # User model
├── schemas/            # Pydantic models
│   └── user.py         # User schemas
└── auth/              # Authentication utilities
    └── jwt.py         # JWT handling
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. To access protected endpoints:

1. Register a new user at `/auth/register`
2. Login at `/auth/token` to get an access token
3. Include the token in the Authorization header: `Bearer <token>` 