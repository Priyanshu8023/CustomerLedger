# 📒 CustomerLedger API

A RESTful JSON API built with **Ruby on Rails 8** for managing a customer ledger. Each registered user can maintain their own isolated list of customers. Authentication is handled via **JWT (JSON Web Tokens)**.

---

## 🛠️ Tech Stack

| Technology | Version |
|---|---|
| Ruby on Rails | ~> 8.1.3 |
| Database | SQLite3 |
| Web Server | Puma |
| Authentication | JWT (`jwt` gem) + `bcrypt` |

---

## 🚀 Getting Started

### Prerequisites
- Ruby (see `.ruby-version`)
- Bundler

### Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate

# Start the server
bin/rails server
```

The API will be available at `http://localhost:3000`.

---

## 🔐 Authentication

Protected routes require a **Bearer token** in the `Authorization` header, obtained from the `/login` or `/signup` endpoints.

```
Authorization: Bearer <your_jwt_token>
```

Alternatively, you can pass the token via the `x-access-token` header.

---

## 📌 Base URL

```
http://localhost:3000
```

---

## 📋 API Endpoints

### Health Check

| Method | URL | Auth Required |
|--------|-----|---------------|
| `GET` | `/up` | No |

Returns `200 OK` if the application is running correctly.

---

### 👤 Authentication & Users

#### `POST /signup` — Register a New User

Creates a new user account and returns a JWT token.

**Request Body**

```json
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "secret123",
    "password_confirmation": "secret123"
  }
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `user[name]` | string | ✅ Yes | Full name of the user |
| `user[email]` | string | ✅ Yes | Must be unique across all users |
| `user[password]` | string | ✅ Yes | Plain-text password (hashed via bcrypt) |
| `user[password_confirmation]` | string | ✅ Yes | Must match `password` |

**Success Response — `201 Created`**

```json
{
  "message": "User Created",
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Error Response — `422 Unprocessable Entity`**

```json
{
  "error": ["Email has already been taken", "Name can't be blank"]
}
```

---

#### `POST /login` — User Login

Authenticates an existing user and returns a JWT token.

**Request Body**

```json
{
  "email": "john@example.com",
  "password": "secret123"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | ✅ Yes | Registered email address |
| `password` | string | ✅ Yes | Account password |

**Success Response — `200 OK`**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2026-06-25T07:39:58.000Z",
    "updated_at": "2026-06-25T07:39:58.000Z"
  }
}
```

**Error Response — `401 Unauthorized`**

```json
{
  "error": "Unsuccefull login"
}
```

---

### 🏢 Customers

> **All customer endpoints require authentication.**  
> Each user can only access and manage their **own** customers.

---

#### `POST /customer` — Create a Customer

Creates a new customer record associated with the authenticated user.

**Headers**
```
Authorization: Bearer <token>
```

**Request Body**

```json
{
  "name": "Acme Corp",
  "email": "contact@acme.com",
  "phone": "9876543210",
  "address": "123 Business Park, Mumbai"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ✅ Yes | Customer name |
| `email` | string | ✅ Yes | Customer email address |
| `phone` | string | No | Customer phone number |
| `address` | string | No | Customer address (text) |

**Success Response — `201 Created`**

```json
{
  "id": 1,
  "name": "Acme Corp",
  "email": "contact@acme.com",
  "phone": "9876543210",
  "address": "123 Business Park, Mumbai",
  "user_id": 1,
  "created_at": "2026-06-25T07:39:58.000Z",
  "updated_at": "2026-06-25T07:39:58.000Z"
}
```

**Error Response — `422 Unprocessable Entity`**

```json
{
  "errors": ["Name can't be blank", "Email can't be blank"]
}
```

---

#### `GET /customer` — List All Customers

Returns all customers belonging to the authenticated user.

**Headers**
```
Authorization: Bearer <token>
```

**Success Response — `200 OK`**

```json
[
  {
    "id": 1,
    "name": "Acme Corp",
    "email": "contact@acme.com",
    "phone": "9876543210",
    "address": "123 Business Park, Mumbai",
    "user_id": 1,
    "created_at": "2026-06-25T07:39:58.000Z",
    "updated_at": "2026-06-25T07:39:58.000Z"
  },
  {
    "id": 2,
    "name": "Beta Ltd",
    "email": "hello@beta.com",
    "phone": null,
    "address": null,
    "user_id": 1,
    "created_at": "2026-06-25T08:00:00.000Z",
    "updated_at": "2026-06-25T08:00:00.000Z"
  }
]
```

---

#### `GET /customer/:id` — Get a Single Customer

Returns a specific customer by ID. The customer must belong to the authenticated user.

**Headers**
```
Authorization: Bearer <token>
```

**URL Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | The ID of the customer |

**Example Request**
```
GET /customer/1
```

**Success Response — `200 OK`**

```json
{
  "id": 1,
  "name": "Acme Corp",
  "email": "contact@acme.com",
  "phone": "9876543210",
  "address": "123 Business Park, Mumbai",
  "user_id": 1,
  "created_at": "2026-06-25T07:39:58.000Z",
  "updated_at": "2026-06-25T07:39:58.000Z"
}
```

---

#### `PATCH /customer/:id` — Update a Customer

Partially or fully updates a customer's details.

**Headers**
```
Authorization: Bearer <token>
```

**URL Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | The ID of the customer to update |

**Request Body** *(all fields optional)*

```json
{
  "phone": "1234567890",
  "address": "456 New Street, Delhi"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | Customer name |
| `email` | string | No | Customer email |
| `phone` | string | No | Customer phone number |
| `address` | string | No | Customer address |

**Success Response — `200 OK`**

```json
{
  "id": 1,
  "name": "Acme Corp",
  "email": "contact@acme.com",
  "phone": "1234567890",
  "address": "456 New Street, Delhi",
  "user_id": 1,
  "created_at": "2026-06-25T07:39:58.000Z",
  "updated_at": "2026-06-26T10:00:00.000Z"
}
```

**Error Response — `422 Unprocessable Entity`**

```json
{
  "errors": ["Name can't be blank"]
}
```

> `PUT /customer/:id` is also supported and behaves identically to `PATCH`.

---

#### `DELETE /customer/:id` — Delete a Customer

Permanently deletes a customer record.

**Headers**
```
Authorization: Bearer <token>
```

**URL Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | integer | The ID of the customer to delete |

**Example Request**
```
DELETE /customer/1
```

**Success Response — `204 No Content`**

*(Empty body)*

---

## ⚠️ Error Responses

### `401 Unauthorized`

Returned when the token is missing, invalid, or expired.

```json
{ "error": "Missing token" }
```
```json
{ "error": "Invalid token" }
```
```json
{ "error": "User not found" }
```

### `404 Not Found`

Returned when a requested customer does not exist or does not belong to the current user.

---

## 🗃️ Data Models

### User

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Auto-generated primary key |
| `name` | string | User's full name (required) |
| `email` | string | Unique email address |
| `password_digest` | string | bcrypt-hashed password (never exposed) |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Last update timestamp |

### Customer

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Auto-generated primary key |
| `name` | string | Customer name (required) |
| `email` | string | Customer email (required) |
| `phone` | string | Customer phone number (optional) |
| `address` | text | Customer address (optional) |
| `user_id` | integer | Foreign key → `users.id` |
| `created_at` | datetime | Record creation timestamp |
| `updated_at` | datetime | Last update timestamp |

---

## 📁 Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb   # JWT auth logic (authorize_request)
│   ├── authentication_controller.rb # POST /login
│   ├── customers_controller.rb      # Customer CRUD
│   └── users_controller.rb          # POST /signup
├── models/
│   ├── customer.rb                  # belongs_to :user
│   └── user.rb                      # has_many :customers
config/
└── routes.rb                        # All API route definitions
db/
└── schema.rb                        # Database schema
```

---

## 📬 Quick Reference Table

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/signup` | ❌ | Register a new user |
| `POST` | `/login` | ❌ | Login and get JWT token |
| `POST` | `/customer` | ✅ | Create a new customer |
| `GET` | `/customer` | ✅ | List all your customers |
| `GET` | `/customer/:id` | ✅ | Get a specific customer |
| `PATCH` | `/customer/:id` | ✅ | Update a customer |
| `PUT` | `/customer/:id` | ✅ | Update a customer (full) |
| `DELETE` | `/customer/:id` | ✅ | Delete a customer |
| `GET` | `/up` | ❌ | Health check |
