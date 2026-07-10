# Mobile App API Endpoints

Base path is mounted in `src/app.js` as:

- `/api/mobile` + routes from `src/routes/api/mobileAppRouter.js`

All endpoints that are authenticated require a JWT access token:

- `Authorization: Bearer <accessToken>`

## Common response format

All handlers use `buildResponse()` from `src/utils/mobileResponse.js`.

### Success
```json
{
  "isSuccess": true,
  "key": "SOME_KEY",
  "message": "Human readable message",
  "paging": { "totalRecords": 0, "pageSize": 12, "pageNumber": 1, "firstPage": -1, "lastPage": -1, "previousPage": -1, "nextPage": -1, "totalPages": -1, "firstItem": -1, "lastItem": -1, "withPaging": true },
  "data": { /* endpoint-specific */ },
  "dataList": null
}
```

### Error (example shape)
```json
{
  "isSuccess": false,
  "key": "ERR_400",
  "message": "Error message",
  "paging": { "totalRecords": 0, "pageSize": 12, "pageNumber": 1, "firstPage": -1, "lastPage": -1, "previousPage": -1, "nextPage": -1, "totalPages": -1, "firstItem": -1, "lastItem": -1, "withPaging": true },
  "data": null,
  "dataList": null
}
```

Auth failure uses `key: "AUTH_UNAUTHORIZED"`.

---

## 1) Auth

### 1.1 Signup
- **POST** `/api/mobile/auth/signup`
- **Auth:** none

**Request body**
```json
{
  "name": "string",
  "phone": "string|number",
  "password": "string"
}
```

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "SIGNUP_SUCCESS",
  "message": "Signup successful",
  "paging": { ... },
  "data": { "success": true },
  "dataList": null
}
```

---

### 1.2 Login
- **POST** `/api/mobile/auth/login`
- **Auth:** none

**Request body**
```json
{
  "phone": "string|number",
  "password": "string"
}
```

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "LOGIN_SUCCESS",
  "message": "Login successful",
  "paging": { ... },
  "data": {
    "accessToken": "JWT_ACCESS_TOKEN",
    "refreshToken": "JWT_REFRESH_TOKEN",
    "user": {
      "id": "string",
      "name": "string",
      "phone": "string",
      "balance": 0
    }
  },
  "dataList": null
}
```

---

### 1.3 Profile
- **GET** `/api/mobile/profile`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`

**Request body:** none

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "PROFILE_SUCCESS",
  "message": "Profile fetched",
  "paging": { ... },
  "data": {
    "user": {
      "id": "string",
      "name": "string",
      "phone": "string"
    },
    "balance": 0
  },
  "dataList": null
}
```

---

## 2) Wallet

### 2.1 Add credit (top-up)
- **POST** `/api/mobile/wallet/add-credit`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`

**Request body**
```json
{
  "amount": 1000
}
```

Notes:
- `amount` is in **Syrian pounds**.
- Server converts to cents internally.

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "ADD_CREDIT_SUCCESS",
  "message": "Credit added",
  "paging": { ... },
  "data": {
    "balance": 0
  },
  "dataList": null
}
```

---

### 2.2 Deduct credit for bus payment
- **POST** `/api/mobile/wallet/deduct`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`

**Request body**
```json
{
  "busId": "string"
}
```

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "DEDUCT_SUCCESS",
  "message": "Credit deducted",
  "paging": { ... },
  "data": {
    "balance": 0,
    "deductedAmount": 12345
  },
  "dataList": null
}
```

---

### 2.3 Wallet balance + transactions
- **GET** `/api/mobile/wallet/balance`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`

**Request body:** none

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "GET_BALANCE_SUCCESS",
  "message": "Balance fetched",
  "paging": { ... },
  "data": {
    "balance": 0
  },
  "dataList": [
    {
      "id": "transactionId",
      "type": "credit|debit",
      "amount": 10000,
      "busId": null,
      "purpose": "string",
      "timestamp": "ISO date string"
    }
  ]
}
```

---

### 2.4 Deduct price (no auth)
- **GET** `/api/mobile/wallet/deduct-price`
- **Auth:** none

**Request body:** none

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "DEDUCT_PRICE_SUCCESS",
  "message": "Deduct price fetched",
  "paging": { ... },
  "data": {
    "priceInPounds": 1
  },
  "dataList": null
}
```

---

## 3) Nearest bus (SSE)

### 3.1 Stream nearest upcoming bus for a route
- **POST** `/api/mobile/nearest-bus/stream`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`
- **Content-Type:** `application/json`

**Request body**
```json
{
  "routeId": "string",
  "latitude": 0,
  "longitude": 0
}
```

**Response**
- `Content-Type: text/event-stream`
- SSE events:
  - `nearest-bus`: payload contains `{ route, nearestBus }`
  - `done`: `{ ok: true }`
  - `error`: error payload

Example `nearest-bus` event data:
```json
{
  "route": {
    "id": "string",
    "routeName": "string",
    "path": { "type": "LineString", "coordinates": [] },
    "stops": [ /* stops */ ]
  },
  "nearestBus": {
    "id": "string",
    "deviceId": "string",
    "busNumber": "string",
    "status": "active|idle|maintenance",
    "lastLocation": { "type": "Point", "coordinates": [0,0] },
    "lastUpdate": "ISO date string",
    "distanceKm": 1.23
  }
}
```

---

## 4) Routes

### 4.1 Get all companies routes
- **GET** `/api/mobile/routes`
- **Auth:** required
  - `Authorization: Bearer <accessToken>`

**Request body:** none

**Response body (200)**
```json
{
  "isSuccess": true,
  "key": "GET_ALL_ROUTES_SUCCESS",
  "message": "Routes fetched",
  "paging": { ... },
  "data": null,
  "dataList": [
    { /* returned object(s) from listPublicRoutes() */ }
  ]
}
```

> The exact fields inside each route item are defined in `listPublicRoutes()` (in `src/services/busService.js`).

