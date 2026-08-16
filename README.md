# Enterprise Case Management System (ECMS)

Enterprise Case Management System developed using Progress OpenEdge ABL, PASOE, OpenEdge Database, REST services, and React.

## Technology Stack

- Progress OpenEdge ABL (4GL)
- Progress Application Server for OpenEdge (PASOE)
- OpenEdge RDBMS
- REST / JSON APIs
- React
- JavaScript

## Application Architecture

React Frontend
      |
      | REST / JSON
      v
PASOE
      |
      v
OpenEdge ABL Service Layer
      |
      v
Repository / Data Access Layer
      |
      v
OpenEdge Database

## Features

The application contains functionality for:

- Customer management
- Case management
- Employee management
- Assignments
- Attachments
- Notes
- Audit information

## OpenEdge Development

The backend demonstrates several OpenEdge development concepts, including:

- ABL service and repository layers
- CRUD operations
- Temp-Tables and ProDataSets
- JSON-based data exchange
- PASOE REST service exposure
- OpenEdge database access
- Separation of business logic and data-access logic
- Test procedures for application modules

## Project Structure

`src/` - OpenEdge ABL source code

`PASOEContent/` - PASOE REST application content and configuration

`frontend/` - React frontend

`database/` - OpenEdge database

## Purpose

This project was developed as a hands-on implementation of an enterprise-style application using Progress OpenEdge technologies, with emphasis on ABL development, REST integration, structured business logic, and database interaction.
