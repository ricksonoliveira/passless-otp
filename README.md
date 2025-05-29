# Passless

A secure, passwordless authentication service built with Elixir and Phoenix.

## 🚀 Features

- Phone number based authentication
- One-Time Password (OTP) verification
- JWT token based session management
- RESTful API design
- Interactive API documentation with Swagger UI

## 🛠 Setup

### Prerequisites

- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 13+

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/passless.git
   cd passless
   ```

2. Install dependencies:

   ```bash
   mix deps.get
   ```

3. Set up the database:

   ```bash
   mix ecto.setup
   ```

4. Start the Phoenix server:

   ```bash
   mix phx.server
   ```

5. Visit `http://localhost:4000` in your browser to access the Swagger UI.

## 📚 API Documentation

Interactive API documentation is available at `http://localhost:4000/api/swagger`.

## 🔌 API Endpoints

### Request OTP

```http
POST /api/v1/auth/request_otp?phone_number=+1234567890
```

**Response**

```json
{
  "data": {
    "message": "OTP sent successfully"
  }
}
```

### Verify OTP

```http
POST /api/v1/auth/verify_otp?phone_number=+1234567890&code=123456
```

**Success Response**

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "1",
      "phone_number": "+1234567890"
    }
  }
}
```

**Error Response**

```json
{
  "errors": {
    "detail": "Invalid or expired OTP code"
  }
}
```

## 🏗 Project Structure

```
lib/
├── passless/                # Core business logic
│   ├── auth/                # Authentication context
│   │   ├── otp.ex           # OTP schema and logic
│   │   ├── user.ex          # User schema
│   │   └── auth.ex          # Authentication logic
│   └── repo.ex              # Database repository
│
├── passless_web/           # Web interface
│   ├── controllers/         # Request handlers
│   │   └── api/
│   │       └── v1/         # API version 1
│   │           └── auth_controller.ex
│   ├── schemas/             # API schemas
│   └── router.ex            # Routes definition
│
└── passless_web.ex         # Web interface definition

test/                       # Test files
config/                     # Configuration files
priv/                       # Private files (migrations, static files)
```

## 📦 Dependencies

- Phoenix - Web framework
- Ecto - Database wrapper
- Guardian - JWT authentication
- Phoenix Swagger - API documentation
- Cachex - Caching

## 🚀 Deployment

For production deployment, please refer to the [Phoenix deployment guide](https://hexdocs.pm/phoenix/deployment.html).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
