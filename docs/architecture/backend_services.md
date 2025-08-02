# Aura Backend Services (FastAPI)

This document outlines the structure, key services, and endpoints of the custom FastAPI backend for the Aura application. It details the specialized logic and AI integrations that Supabase alone cannot handle, as well as how it integrates with the Supabase platform and adheres to its security model.

## 1. Overview

The FastAPI backend serves as the "brain" of the Aura application. It handles complex business logic, AI-powered features (like clothing item analysis and personalized recommendations), and acts as an intermediary for actions that require more sophisticated processing than standard CRUD operations.

It is designed as a separate service from Supabase, communicating with it via its REST API or database connections when necessary, and with the Flutter frontend primarily via RESTful endpoints. It rigorously enforces security, aligning with the Row Level Security (RLS) policies defined in `DATABASE_SCHEMA.md` and the authentication strategy in `API_INTEGRATION.md`.

## 2. Core Architecture

*   **Framework:** Python FastAPI
*   **ASGI Server:** Uvicorn (or Hypercorn)
*   **API Style:** Primarily RESTful. GraphQL might be considered for specific complex internal queries if needed, but the public API will be REST.
*   **Authentication:** Relies on JWT tokens issued by Supabase Auth. Endpoints validate these tokens using the Supabase JWT secret (`SUPABASE_JWT_SECRET`) and libraries like `PyJWT` or `jose`. <sup>[[1]](https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/)</sup>
*   **Data Access:**
    *   **Supabase REST API (Primary):** For standard CRUD and simple queries, use the Supabase REST API endpoints from Python (e.g., using `httpx` or `postgrest-py`). This is the recommended default for loose coupling and leveraging Supabase's built-in RLS. <sup>[[2]](https://supabase.com/docs/guides/api)</sup>
    *   **Direct Database (Secondary/Advanced):** For complex analytical queries, aggregations, or performance-critical operations that the REST API cannot efficiently handle (e.g., fetching large datasets for AI training), connect directly to the Supabase PostgreSQL database using `asyncpg` with `SQLAlchemy` (async). This requires careful management of database credentials, connection pooling, and manual RLS logic or specific service roles. This approach is used sparingly. <sup>[[3]](https://docs.sqlalchemy.org/)</sup>
*   **AI Integration:**
    *   **External Services (Primary):** AI tasks like image analysis are performed by calling external, managed AI services (e.g., Google Vertex AI, AWS SageMaker). This keeps the FastAPI service lightweight and leverages scalable, managed infrastructure for compute-intensive tasks. Calls are made using service-specific SDKs.
    *   **Internal Logic (Secondary):** Recommendation algorithms and style DNA calculations are primarily rule-based or lightweight ML models running within the FastAPI service or triggered as separate background jobs. For heavier models, a dedicated AI worker pool (e.g., using Celery or a custom solution) might be integrated later.
*   **Asynchronous Tasks:** Long-running operations (like AI processing, batch recommendations) are handled asynchronously. FastAPI's `BackgroundTasks` is used for simple fire-and-forget tasks. For more robust queuing and worker management, a system like Celery with Redis/RabbitMQ (or a managed equivalent) is recommended for future scalability. <sup>[[4]](https://fastapi.tiangolo.com/tutorial/background-tasks/)</sup>
*   **Deployment:** Containerized (Docker) for easy deployment and scaling. Can be deployed on platforms like Render, Heroku, or cloud providers' container services. CI/CD for this service is managed by Codemagic as outlined in `CI_CD_GUIDE.md`.
*   **Communication with Supabase (Triggers/Webhooks):** While the primary client-side real-time communication is via Supabase Realtime, the FastAPI backend can receive webhooks from Supabase (e.g., via Edge Functions or direct HTTP calls configured in Supabase) to trigger background processing (e.g., initiate AI analysis when a new item is added).

## 3. Project Structure (Example)

```
fastapi_service/
├── app/
│   ├── api/                 # API route definitions
│   │   ├── v1/
│   │   │   ├── routes/      # Individual route files (e.g., items.py, recommendations.py, ai.py)
│   │   │   └── api.py       # Main API router, includes routes from `routes/`
│   │   └── deps.py          # Dependency injection (e.g., get_db, get_current_user, get_supabase_client)
│   ├── core/                # Core configurations, security, logging, utilities
│   │   ├── config.py        # Environment variables and settings (Pydantic Settings)
│   │   ├── security.py      # JWT verification logic
│   │   └── logging.py       # Structured logging configuration (includes X-Request-ID)
│   ├── models/              # (Optional) Data models for interacting with Supabase DB directly (SQLAlchemy if used)
│   ├── schemas/             # Pydantic models for request/response validation and serialization
│   ├── services/            # Business logic implementation (where the core work happens)
│   │   ├── ai_service.py    # AI interaction logic (orchestrates calls to external AI services)
│   │   ├── recommendation_service.py # Recommendation engine logic
│   │   ├── wardrobe_service.py # Complex wardrobe-related logic
│   │   └── ...              # Other specific services
│   ├── utils/               # Utility functions (e.g., data transformation, helpers)
│   ├── background/          # Definitions for background tasks and workers (e.g., Celery tasks)
│   └── main.py              # Application entry point (creates FastAPI app, includes routers, sets up middleware)
├── tests/                   # Unit and integration tests (pytest)
├── Dockerfile
├── requirements.txt         # Python dependencies
└── ...
```

## 4. Key Services & Endpoints

### 4.1. AI Clothing Item Analysis Service

**Purpose:** Analyze uploaded clothing item images to automatically generate tags, categories, colors, and other attributes using an external AI service.

**Endpoint:** `POST /api/v1/ai/analyze-clothing-item`

**Request Body (Schema Example):**
```json
{
  "clothing_item_id": "uuid-of-the-item-in-supabase"
  // image_url might be fetched internally using the ID, or passed if needed
}
```

**Process:**
1.  **Authentication & Authorization:** Validate the JWT token. Ensure the `clothing_item_id` belongs to the requesting user. This is critical for data isolation. FastAPI validates the token's signature and expiration. The user ID (`uid`) is extracted from the token payload.
2.  **Fetch Item Data:** Retrieve item details (including `image_url`) from Supabase REST API. The request is made by the FastAPI backend *on behalf of the user*. The JWT token is passed in the `Authorization: Bearer <token>` header. Because Supabase RLS policies (`user_id = auth.uid()`) are enforced at the database level for every query, the backend can only fetch the item if it truly belongs to the user ID encoded in the token. This ensures data security without the backend needing to manually check ownership in every query.
3.  **AI Processing (External Call):** Call the external AI service (e.g., Vertex AI endpoint) with the image URL. Handle potential timeouts or service errors gracefully.
4.  **Result Formatting:** Parse the AI response and format it into a structure compatible with the `clothing_items` table schema (e.g., `ai_tags` JSONB).
5.  **Update Supabase:** Make a `PATCH` request to the Supabase `clothing_items` REST endpoint to update the relevant fields (`ai_tags`, `category`, etc.) for the given `clothing_item_id`. Crucially, the FastAPI backend includes the *same* JWT token in the `Authorization: Bearer <token>` header for this request. Supabase RLS again ensures that the update can *only* happen if the `clothing_item_id` belongs to the user identified by the token. This maintains data integrity throughout the process.
6.  **Response:** Return a success message or a summary of the updated fields.

**Response (Success - 200 OK):**
```json
{
  "message": "Item analyzed and updated successfully.",
  "updated_fields": ["ai_tags", "category"]
}
```

### 4.2. Personalized Recommendation Service

**Purpose:** Generate personalized clothing combinations and item suggestions based on the user's wardrobe and preferences.

**Endpoint:** `GET /api/v1/recommendations/`

**Query Parameters (Examples):**
*   `type`: `combinations` (default), `items` (for specific item suggestions like "buy this shoe")
*   `limit`: Number of recommendations to return (default 10).

**Process:**
1.  **Authentication:** Validate the JWT token to identify the user. Extract the `uid`.
2.  **Fetch User Data:** Retrieve the user's wardrobe items and style preferences from Supabase (using REST API). The backend passes the JWT token in the request header. RLS ensures it only fetches data belonging to the authenticated `uid`.
3.  **Analysis/Algorithm:** Apply a recommendation algorithm (initially rule-based, potentially evolving). This might involve filtering items, using `ai_tags` for similarity, considering `last_worn_date`.
4.  **(Optional) External Data Integration:** For `type=items`, potentially integrate with external APIs or use internal logic for suggestions.
5.  **Response Formatting:** Structure the recommendations.
6.  **Response:** Return the list of recommendations.

**Response (Success - 200 OK):**
```json
{
  "recommendations": [
    {
      "type": "combination",
      "items": ["item-uuid-1", "item-uuid-2", "item-uuid-3"],
      "name": "Casual Friday Mix"
    },
    {
      "type": "item",
      "item": {
        "name": "Stylish Sneakers",
        "description": "Perfect match for your jeans.",
        "image_url": "...",
        "affiliate_link": "https://..."
      }
    }
  ]
}
```

### 4.3. Style DNA Calculation Service (Future/Advanced)

**Purpose:** Analyze a user's wardrobe and interactions to build/update their personal "Style DNA" profile.

**Endpoint:** `POST /api/v1/ai/calculate-style-dna` (Potentially triggered by a background task or webhook)

**Process:**
1.  **Authentication:** Validate the JWT token. Extract the `uid`.
2.  **Data Aggregation:** Gather extensive data from Supabase: `clothing_items`, `combinations`, `likes`, `comments`. The backend uses the JWT token for all requests, ensuring RLS protects access to only the authenticated user's data.
3.  **Analysis:** Use data analysis or lightweight ML models (running within FastAPI or a worker) to identify patterns.
4.  **Storage:** Store the calculated DNA profile in the `profiles.preferred_style` JSONB field (or a dedicated `ai_profiles` table) in Supabase via REST API. The JWT token is passed with the request, ensuring the backend can only update the profile for the user it represents (`user_id = auth.uid()` in the `ai_profiles` table RLS policy).
5.  **Response:** Return success and a summary.

### 4.4. Swap Market Validation & Enrichment Service (Example)

**Purpose:** Perform complex validation or processing for swap market listings.

**Endpoint:** `POST /api/v1/swap-market/process-listing`

**Process:**
1.  **Authentication:** Validate the JWT token. Extract the `uid`.
2.  **Validation Logic:** Perform checks (e.g., profanity filtering using a library like `profanity-check`).
3.  **(Optional) AI Enrichment:** Use AI to suggest better keywords/tags.
4.  **Response:** Return validation result and potentially enriched data.

**Response (Success/Error):**
```json
// Success
{
  "valid": true,
  "message": "Listing processed successfully.",
  "enriched_data": { "suggested_tags": ["vintage", "winter"] }
}

// Error
{
  "valid": false,
  "errors": ["Description contains inappropriate language."]
}
```

## 5. Integration with Supabase

*   **Authentication:** FastAPI services validate Supabase JWTs using `jose` or similar libraries. A dependency in `deps.py` handles this.
*   **Data Access:**
    *   **REST API (Primary):** Use `httpx` or `postgrest-py` to interact with Supabase tables. RLS is handled automatically by Supabase at the database level for every request made with a valid JWT token. The FastAPI backend includes this token in its requests, ensuring that data access is always filtered according to the user's identity (`auth.uid()`).
    *   **Direct Database (Secondary):** Use `asyncpg` with `SQLAlchemy` for complex queries. When connecting directly, the backend *must* manually enforce security, often by connecting with a specific database role and ensuring queries incorporate user-specific filters (`WHERE user_id = :user_id` passed from the validated JWT `uid`). RLS is *not* automatically applied to direct DB connections, so extra care is required.
*   **Webhooks/Realtime:** Supabase can be configured to send HTTP requests (webhooks) to FastAPI endpoints for specific database events (e.g., `INSERT` on `clothing_items`). FastAPI handles these to trigger background tasks like AI analysis.

## 6. Security Considerations

*   **JWT Validation:** Robustly validate all incoming JWT tokens. Handle expired/invalid tokens with 401 responses.
*   **Input Validation:** Use Pydantic models for all request bodies and query parameters. This provides automatic validation and sanitization against common attacks (e.g., type confusion, injection if directly used in raw SQL - which is avoided by using ORMs/REST).
*   **Environment Variables:** Store all secrets (JWT secret, DB credentials, AI service keys) in environment variables. Use `python-dotenv` for local dev and secure vaults in production.
*   **Rate Limiting:** Implement rate limiting (e.g., using `slowapi`) on API endpoints, especially AI-heavy ones, to prevent abuse and manage costs. Aligns with `SECURITY_GUIDE.md`.
*   **Dependency Management:** Keep Python dependencies up-to-date. Use tools like `pip-audit`.
*   **Logging & Tracing:** Use structured logging. Include a unique `X-Request-ID` in log messages for each request to trace actions across services (frontend -> FastAPI -> Supabase). This ID can be generated in middleware and added to the request context. See `MONITORING_AND_LOGGING.md`.
*   **CORS:** Configure CORS policies appropriately to allow requests only from the Flutter app's origin(s).
*   **Alignment with Supabase Security:** The FastAPI backend acts as a trusted agent for the authenticated user. It uses the user's JWT token to make requests to Supabase. This delegates access control to Supabase's RLS, ensuring that the backend cannot accidentally bypass user data boundaries. Every interaction with Supabase (REST or DB) is filtered by the `auth.uid()` extracted from the JWT, maintaining data isolation as defined in `DATABASE_SCHEMA.md`.

## 7. Performance & Scalability

*   **Caching:** Implement caching (e.g., using `Redis`) for frequently requested, computationally expensive data (like popular recommendation results) to reduce load and latency.
*   **Asynchronous Operations:** Use FastAPI's `BackgroundTasks` or a dedicated task queue (like Celery) for long-running processes (AI analysis, batch jobs) to keep API responses fast.
*   **Database Optimization:** For direct DB access, ensure proper indexing and query optimization. Use connection pooling (`asyncpg` pool).
*   **Resource Management:** Ensure resources (file handles, network connections) opened during request processing are properly closed/disposed of.

## 8. Testing Strategy

*   **Unit Testing:** Test individual functions and methods within services using `pytest`. Mock external dependencies (Supabase client, AI service calls) using libraries like `pytest-mock` or `unittest.mock`.
*   **Integration Testing:** Test the interaction between different layers of the backend, and its integration with external systems (like Supabase REST API or Database).
    *   Use `pytest` and potentially `httpx` or `TestClient` from `fastapi.testclient`.
*   **AI Service Testing:** Test the logic that calls AI services by mocking the AI service response. Validate that the application correctly processes various types of AI outputs (including edge cases and errors).
*   **Load Testing:** Plan for load testing critical endpoints (especially recommendation engine) to identify bottlenecks.

## 9. API Documentation

*   **FastAPI Auto-docs:** Leverage FastAPI's built-in generation of interactive API documentation using Swagger UI (`/docs`) and ReDoc (`/redoc`). Ensure Pydantic models and docstrings are clear and descriptive.

## 10. Configuration Management

*   **Pydantic Settings:** Use `pydantic.BaseSettings` (or `pydantic-settings` in v2) to manage configuration. Load settings from environment variables.
*   **Environment-specific Config:** Define different settings classes or use `.env` files for `development`, `staging`, and `production` environments. Clearly document required environment variables (e.g., in a `.env.example` file).

## 11. Deployment & CI/CD

*   **Containerization:** Use Docker. The `Dockerfile` defines the runtime environment.
*   **CI/CD:** The build, test, and deployment pipeline for the FastAPI service is defined within the monorepo's Codemagic configuration (`codemagic.yaml`), likely as a separate workflow from the Flutter app. See `CI_CD_GUIDE.md`.
