# 🏢 Enterprise Case Management System (ECMS)

> An enterprise-style Case Management System built using **Progress OpenEdge ABL (4GL)**, **PASOE**, **OpenEdge RDBMS**, **REST/JSON APIs**, and **React**.

![Progress OpenEdge](https://img.shields.io/badge/Progress-OpenEdge-5CE500?style=for-the-badge)
![ABL](https://img.shields.io/badge/Language-ABL-0078D4?style=for-the-badge)
![PASOE](https://img.shields.io/badge/Application_Server-PASOE-orange?style=for-the-badge)
![REST API](https://img.shields.io/badge/API-REST%20%2F%20JSON-success?style=for-the-badge)
![React](https://img.shields.io/badge/Frontend-React-61DAFB?style=for-the-badge&logo=react&logoColor=black)

---

## 📖 Overview

The **Enterprise Case Management System (ECMS)** is a hands-on enterprise application developed to demonstrate application development using the Progress OpenEdge technology stack.

The project separates application responsibilities across the frontend, REST/service layer, ABL business logic, repository/data-access layer, and OpenEdge database.

The application includes modules for:

- 👤 Customer Management
- 📁 Case Management
- 👨‍💼 Employee Management
- 🔗 Case Assignments
- 📎 Attachments
- 📝 Notes
- 📋 Audit Information

---

## 🏗️ Architecture

```text
┌───────────────────────────────┐
│        React Frontend         │
│       UI / User Actions       │
└──────────────┬────────────────┘
               │
               │ REST / JSON
               ▼
┌───────────────────────────────┐
│             PASOE             │
│ Progress Application Server   │
│        for OpenEdge           │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│       ABL Service Layer       │
│                               │
│ Business Logic & Validation   │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│     ABL Repository Layer      │
│                               │
│ Queries & Database Access     │
└──────────────┬────────────────┘
               │
               ▼
┌───────────────────────────────┐
│       OpenEdge RDBMS          │
│                               │
│   Enterprise Application DB   │
└───────────────────────────────┘
```

### 🔄 Typical Request Flow

```text
React
  ↓
REST / JSON
  ↓
PASOE
  ↓
ABL Service
  ↓
ABL Repository
  ↓
OpenEdge Database
  ↓
ABL
  ↓
PASOE
  ↓
JSON Response
  ↓
React
```

---

## ⚙️ Technology Stack

| Layer | Technology |
|---|---|
| Frontend | React / JavaScript |
| API Communication | REST / JSON |
| Application Server | Progress Application Server for OpenEdge (PASOE) |
| Business Logic | Progress OpenEdge ABL |
| Data Access | ABL Repository Procedures |
| Database | Progress OpenEdge RDBMS |
| Data Structures | Temp-Tables / ProDataSets |
| Testing | ABL Test Procedures |
| Version Control | Git / GitHub |

---

## 🧠 OpenEdge Concepts Demonstrated

This project demonstrates several important Progress OpenEdge development concepts.

<details>
<summary><b>🔹 ABL Service Layer</b></summary>

<br>

Service procedures separate business operations from direct database access.

Examples include:

- `CustomerService.p`
- `CaseService.p`
- `EmployeeService.p`
- `AssignmentService.p`
- `AttachmentService.p`
- `NotesService.p`

This structure helps keep business logic separate from repository and database operations.

</details>

<details>
<summary><b>🔹 Repository / Data Access Layer</b></summary>

<br>

Repository procedures are responsible for database-oriented operations.

Examples include:

- `CustomerRepository.p`
- `CaseRepository.p`
- `EmployeeRepository.p`
- `AssignmentRepository.p`
- `AttachmentRepository.p`
- `NotesRepository.p`
- `AuditRepository.p`

This provides separation between business logic and database access.

</details>

<details>
<summary><b>🔹 CRUD Operations</b></summary>

<br>

The project contains ABL procedures demonstrating Create, Read, Update and Delete operations.

The Customer module includes:

```text
CustomerCreate.p
CustomerRead.p
CustomerUpdate.p
CustomerDelete.p
CustomerService.p
CustomerRepository.p
```

</details>

<details>
<summary><b>🔹 Temp-Tables & ProDataSets</b></summary>

<br>

The project uses OpenEdge data structures for structured business-data exchange.

Examples:

```text
CaseDetailsDataSet.p
CaseDetailsJson.p
```

These components demonstrate working with structured application data and JSON-oriented integration.

</details>

<details>
<summary><b>🔹 PASOE & REST Integration</b></summary>

<br>

The application contains PASOE content and REST service configuration used to expose OpenEdge application functionality to external clients.

The frontend communicates using REST/JSON while ABL handles backend business and data-access operations.

</details>

<details>
<summary><b>🔹 Testing</b></summary>

<br>

ABL test procedures are included for multiple application areas:

```text
AssignmentTest.p
AttachmentTest.p
CaseDetailsDataSetTest.p
CaseDetailsJsonTest.p
CaseTest.p
CustomerTest.p
DatabaseConnectionTest.p
EmployeeTest.p
NotesTest.p
```

</details>

---

## 📦 Application Modules

### 👤 Customer Management

Handles customer-related operations.

```text
CustomerCreate.p
CustomerRead.p
CustomerUpdate.p
CustomerDelete.p
CustomerRepository.p
CustomerService.p
```

### 📁 Case Management

```text
CaseRepository.p
CaseService.p
```

### 👨‍💼 Employee Management

```text
EmployeeRepository.p
EmployeeService.p
```

### 🔗 Assignment Management

```text
AssignmentRepository.p
AssignmentService.p
```

### 📎 Attachment Management

```text
AttachmentRepository.p
AttachmentService.p
```

### 📝 Notes Management

```text
NotesRepository.p
NotesService.p
```

### 📋 Audit

```text
AuditRepository.p
```

---

## 📂 Project Structure

```text
Enterprise-Case-Management-System/
│
├── database/
│   └── ecms/
│       └── ecms.db
│
├── workspace/
│   └── Enterprise_Case_Management_System/
│
│       ├── src/
│       │   ├── assignment/
│       │   ├── attachment/
│       │   ├── audit/
│       │   ├── caseManagement/
│       │   ├── customer/
│       │   ├── employee/
│       │   ├── notes/
│       │   ├── proDataSets/
│       │   └── tests/
│       │
│       ├── frontend/
│       │   ├── src/
│       │   │   ├── components/
│       │   │   ├── pages/
│       │   │   └── services/
│       │   ├── package.json
│       │   └── vite.config.js
│       │
│       └── PASOEContent/
│
├── .gitignore
└── README.md
```

---

## 🔍 Example: Customer Processing Architecture

```text
React Customer Page
        │
        │ REST Request
        ▼
      PASOE
        │
        ▼
 CustomerService.p
        │
        ▼
CustomerRepository.p
        │
        ▼
 OpenEdge Database
```

This pattern allows the application to keep presentation, service/business logic, and database-access responsibilities separated.

---

## 🧪 Testing Structure

The project includes dedicated ABL procedures for testing individual application modules.

```text
src/tests/
├── AssignmentTest.p
├── AttachmentTest.p
├── CaseDetailsDataSetTest.p
├── CaseDetailsJsonTest.p
├── CaseTest.p
├── CustomerTest.p
├── DatabaseConnectionTest.p
├── EmployeeTest.p
└── NotesTest.p
```

This makes individual backend components easier to validate during development and troubleshooting.

---

## 💡 Key Development Areas

Through this project, the following areas of Progress OpenEdge development are explored:

- Progress ABL programming
- OpenEdge database interaction
- Service and repository architecture
- CRUD operations
- Temp-Tables
- ProDataSets
- REST services
- JSON data exchange
- PASOE application deployment structure
- Frontend-to-backend integration
- Modular ABL development
- Application testing and troubleshooting

---

## 🚀 Future Enhancements

The following technologies and architectural improvements can be incorporated as the application evolves:

- Spring Boot integration layer
- OAuth 2.0 / JWT authentication
- Role-Based Access Control (RBAC)
- Apache Kafka event-driven messaging
- Centralized application logging
- Standardized exception handling
- Retry and error-recovery mechanisms
- API gateway / rate limiting
- Containerized deployment
- Cloud deployment
- CI/CD pipeline
- Automated integration testing

> **Note:** The items in this section represent planned enhancements and are not presented as currently implemented functionality.

---

## 🎯 Project Purpose

The purpose of ECMS is to provide hands-on experience building an enterprise-style application using **Progress OpenEdge ABL**, **PASOE**, **OpenEdge RDBMS**, **REST APIs**, and a modern frontend.

The project focuses on understanding how an OpenEdge application can be organized into maintainable application layers while supporting structured data exchange between the frontend, application server, business logic, and database.

---

## 👨‍💻 Developer

**Phanindra**

Progress OpenEdge / ABL Application Development

---

⭐ This repository is being used for continued learning and development with the Progress OpenEdge technology stack.
