# PaperWise

A web-based past paper management system built with Java EE (Servlets, JSP), PostgreSQL, and Apache Tomcat.

## Features

- User registration and login (Student / Admin roles)
- Upload, view, edit, and delete past papers
- Search and filter papers by subject, year, and difficulty
- Vote on paper difficulty and mark papers as useful
- Students can request papers not yet available
- Admin panel to manage papers, users, and requests

## Tech Stack

- Java EE (Servlets + JSP)
- PostgreSQL
- Apache Tomcat
- HTML/CSS/JavaScript

## Setup

### Prerequisites

- JDK 11+
- Apache Tomcat 9+
- PostgreSQL 13+
- NetBeans IDE (recommended)

### Database

1. Create a PostgreSQL database named `paperwise`
2. Run `database_setup.sql` to create the required tables
3. Run the additional SQL files if needed:
   - `create_votes_table.sql`
   - `create_difficulty_votes_table.sql`
   - `create_paper_requests_table.sql`

### Configuration

Update the database connection settings in `web/META-INF/context.xml`:

```xml
<Resource
  url="jdbc:postgresql://localhost:5432/paperwise"
  username="your_db_user"
  password="your_db_password"
/>
```

### Run

1. Open the project in NetBeans
2. Configure Tomcat server
3. Build and deploy (`Clean and Build` → `Run`)
4. Access at `http://localhost:8080/PaperWise`

## Project Structure

```
src/java/com/paperwise/
├── dao/          # Database access objects
├── filter/       # Auth filter
├── model/        # POJOs
└── servlet/      # Request handlers
web/
├── *.jsp         # View layer
└── META-INF/     # Tomcat context config
```

## License

MIT
