# Server API Endpoints Required

Your server needs these additional endpoints to support the new authentication system:

## 1. User Registration
```
POST /register_user
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",           // Optional
  "full_name": "John Doe",               // Required
  "phone_number": "+1234567890",         // Required
  "apple_id": "001234.56789abcd.1234",   // Optional (if using Apple Sign In)
  "created_at": "2025-06-08T18:42:00Z"   // ISO8601 timestamp
}

Response (Success):
{
  "status": "success",
  "user_id": "server_generated_user_id",
  "message": "User registered successfully"
}

Response (Error):
{
  "status": "error", 
  "message": "User already exists" // or other error
}
```

## 2. User Login
```
POST /login_user
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",      // Optional
  "phone_number": "+1234567890"     // Required
}

Response (Success):
{
  "status": "success",
  "user_id": "server_user_id",
  "email": "user@example.com",
  "full_name": "John Doe",
  "phone_number": "+1234567890",
  "apple_id": "001234.56789abcd.1234",
  "created_at": "2025-06-08T18:42:00Z"
}

Response (Error):
{
  "status": "error",
  "message": "User not found"
}
```

## 3. Get User by Phone Number
```
POST /get_user_by_phone
Content-Type: application/json

Request Body:
{
  "phone_number": "+1234567890"
}

Response (Success):
{
  "status": "success",
  "user_id": "server_user_id",
  "email": "user@example.com",
  "full_name": "John Doe", 
  "phone_number": "+1234567890",
  "apple_id": "001234.56789abcd.1234",
  "created_at": "2025-06-08T18:42:00Z"
}

Response (Error):
{
  "status": "error",
  "message": "User not found"
}
```

## 4. Save Call Recording (Enhanced)
```
POST /save_call
Content-Type: application/json

Request Body:
{
  "user_phone": "+1234567890",
  "target_phone": "+0987654321",
  "call_date": "2025-06-08T18:42:00Z",
  "recording_status": "started",         // "started", "completed", "failed"
  "recording_duration": 0,               // in seconds
  "transcription_status": "pending"      // "pending", "completed", "failed"
}

Response (Success):
{
  "status": "success",
  "call_id": "server_generated_call_id",
  "message": "Call recording saved"
}
```

## 5. Existing Endpoint (Already Working)
```
POST /get_calls_for_user
Content-Type: application/json

Request Body:
{
  "user_phone": "+1234567890"
}

Response: [Array of call records as currently implemented]
```

## Database Schema Suggestions

### Users Table
```sql
CREATE TABLE users (
  id VARCHAR PRIMARY KEY,
  email VARCHAR,
  full_name VARCHAR NOT NULL,
  phone_number VARCHAR UNIQUE NOT NULL,
  apple_id VARCHAR,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Calls Table (Update existing)
```sql
ALTER TABLE calls ADD COLUMN user_id VARCHAR;
-- Add foreign key reference to users table
```

## Implementation Notes

1. **Phone Number Validation**: Validate phone numbers are in international format (+country_code)
2. **Duplicate Handling**: Check for existing users by phone number before registration
3. **Apple ID Integration**: Store Apple ID for users who sign in with Apple
4. **Optional Email**: Email can be empty/null for phone-only registrations
5. **User Linking**: Link existing call records to users by phone number

## Authentication Flow

1. **New User Registration**: 
   - POST /register_user → Create account → Auto sign in
   
2. **Existing User Login**:
   - POST /login_user (with email + phone) → Sign in
   - POST /get_user_by_phone (phone only) → Sign in or create guest account
   
3. **Apple Sign In**:
   - POST /register_user (with Apple ID) → Create/link account → Sign in
   
4. **Guest Mode**:
   - No server calls → Local-only usage → Can upgrade to account later

The app handles all authentication states and will call these endpoints as needed.