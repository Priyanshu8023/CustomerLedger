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
| API Styles | REST + GraphQL (`graphql` gem) |

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
  "user_id": 1,
  "user_name": "John Doe",
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Error Response — `401 Unauthorized`**

```json
{
  "error": "Unsuccefull login"
}
```

---

#### `POST /logout` — User Logout

Validates the current JWT token and returns a logout success response. Because authentication uses stateless JWTs, the client should remove the stored token after this response.

**Headers**
```
Authorization: Bearer <token>
```

**Success Response — `200 OK`**

```json
{
  "message": "Logged out successfully"
}
```

**Error Response — `401 Unauthorized`**

```json
{
  "error": "Missing token"
}
```

---

### 📊 Dashboard

> **The dashboard endpoint requires authentication.**  
> Metrics are calculated only from the authenticated user's customers and orders.

#### `GET /dashboard` — Get Dashboard Metrics

Returns customer/order counts, revenue totals, today's order count, and the five most recent orders.

**Headers**
```
Authorization: Bearer <token>
```

**Success Response — `200 OK`**

```json
{
  "total_customers": 3,
  "total_orders": 8,
  "completed_orders": 5,
  "pending_orders": 3,
  "total_revenue": "2500.75",
  "today_orders": 2,
  "recent_orders": [
    {
      "id": 12,
      "order_number": "ORD-0012",
      "customer_id": 4,
      "customer_name": "Acme Corp",
      "total_amount": "500.25",
      "status": "Completed",
      "order_date": "2026-06-29"
    }
  ]
}
```

**Error Response — `401 Unauthorized`**

```json
{
  "error": "Missing token"
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

## 🔎 GraphQL API

The GraphQL endpoint is available at:

```text
POST /graphql
```

GraphQL requests require the same JWT authentication as the protected REST endpoints.

**Headers**

```text
Authorization: Bearer <token>
Content-Type: application/json
```

The GraphQL controller passes the authenticated user into the GraphQL context, so `customers`, `orders`, and mutations operate only on the current user's records.

### Available Queries

#### List Customers

```graphql
query {
  customers {
    id
    name
    email
    phone
    address
    orders {
      id
      orderNumber
      status
      totalAmount
      orderDate
    }
  }
}
```

#### List Orders

```graphql
query {
  orders {
    id
    orderNumber
    status
    totalAmount
    orderDate
    notes
    customer {
      id
      name
      email
    }
  }
}
```

### Available Mutations

#### Create Customer

```graphql
mutation {
  createCustomer(
    input: {
      name: "Acme Corp"
      email: "contact@acme.com"
      phone: "9876543210"
      address: "123 Business Park, Mumbai"
    }
  ) {
    customer {
      id
      name
      email
      phone
      address
    }
    errors
  }
}
```

**Example HTTP Request**

```bash
curl -X POST http://localhost:3000/graphql \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { createCustomer(input: { name: \"Acme Corp\", email: \"contact@acme.com\", phone: \"9876543210\", address: \"123 Business Park, Mumbai\" }) { customer { id name email phone address } errors } }"
  }'
```

**Success Response**

```json
{
  "data": {
    "createCustomer": {
      "customer": {
        "id": "1",
        "name": "Acme Corp",
        "email": "contact@acme.com",
        "phone": "9876543210",
        "address": "123 Business Park, Mumbai"
      },
      "errors": []
    }
  }
}
```

**Validation Error Response**

```json
{
  "data": {
    "createCustomer": {
      "customer": null,
      "errors": ["Name can't be blank"]
    }
  }
}
```

#### Update Customer

```graphql
mutation {
  updateCustomer(
    input: {
      id: "1"
      name: "Acme Corporation"
      phone: "1234567890"
      address: "456 New Street, Delhi"
    }
  ) {
    customer {
      id
      name
      email
      phone
      address
    }
    errors
  }
}
```

#### Delete Customer

```graphql
mutation {
  deleteCustomer(input: { id: "1" }) {
    success
    errors
  }
}
```

Deleting a customer also deletes that customer's orders because the Rails model uses `dependent: :destroy`.

#### Create Order

```graphql
mutation {
  createOrder(
    input: {
      customerId: "1"
      totalAmount: 500.25
      status: "Pending"
      orderDate: "2026-06-30"
      notes: "First order"
    }
  ) {
    order {
      id
      orderNumber
      status
      totalAmount
      orderDate
      notes
      customer {
        id
        name
      }
    }
    errors
  }
}
```

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
│   ├── authentication_controller.rb # POST /login, POST /logout
│   ├── customers_controller.rb      # Customer CRUD
│   ├── dashboard_controller.rb      # GET /dashboard
│   ├── graphql_controller.rb        # POST /graphql
│   ├── orders_controller.rb         # Order endpoints and summary
│   └── users_controller.rb          # POST /signup
├── graphql/
│   ├── customer_ledger_schema.rb    # GraphQL schema
│   ├── mutations/
│   │   ├── create_customer.rb       # createCustomer mutation
│   │   ├── create_order.rb          # createOrder mutation
│   │   ├── delete_customer.rb       # deleteCustomer mutation
│   │   └── update_customer.rb       # updateCustomer mutation
│   └── types/
│       ├── customer_type.rb         # Customer GraphQL type
│       ├── mutation_type.rb         # Root GraphQL mutations
│       ├── order_type.rb            # Order GraphQL type
│       └── query_type.rb            # Root GraphQL queries
├── models/
│   ├── customer.rb                  # belongs_to :user
│   ├── order.rb                     # belongs_to :user and :customer
│   └── user.rb                      # has_many :customers, has_many :orders
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
| `POST` | `/logout` | ✅ | Logout the authenticated user |
| `POST` | `/graphql` | ✅ | Run authenticated GraphQL queries and mutations |
| `GET` | `/dashboard` | ✅ | Get dashboard metrics and recent orders |
| `POST` | `/customer` | ✅ | Create a new customer |
| `GET` | `/customer` | ✅ | List all your customers |
| `GET` | `/customer/:id` | ✅ | Get a specific customer |
| `PATCH` | `/customer/:id` | ✅ | Update a customer |
| `PUT` | `/customer/:id` | ✅ | Update a customer (full) |
| `DELETE` | `/customer/:id` | ✅ | Delete a customer |
| `GET` | `/up` | ❌ | Health check |
