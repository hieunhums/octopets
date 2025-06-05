# 🤝 Contributing to Octopets

Thank you for your interest in contributing to Octopets! This guide will help you get started with contributing to our pet-friendly venue discovery platform.

## 📋 Table of Contents

1. [Getting Started](#-getting-started)
2. [Development Workflow](#-development-workflow)
3. [Project Structure](#-project-structure)
4. [Code Style Guidelines](#-code-style-guidelines)
5. [Making Changes](#-making-changes)
6. [Testing](#-testing)
7. [Submitting Changes](#-submitting-changes)
8. [Issue Reporting](#-issue-reporting)
9. [Common Tasks](#-common-tasks)

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have the required tools installed. See the [README.md](README.md#-prerequisites) for detailed prerequisites including:

- .NET SDK 9.0 or later
- Node.js v18.0.0 or later
- npm v10.0.0 or later
- Docker
- Visual Studio or Visual Studio Code with C# Dev Kit

### Setting Up Your Development Environment

1. **Fork and Clone the Repository**
   ```bash
   # Fork the repository on GitHub first, then clone your fork
   git clone https://github.com/YOUR_USERNAME/octopets.git
   cd octopets
   ```

2. **Install Dependencies**
   ```bash
   # Install frontend dependencies
   cd frontend
   npm install
   cd ..
   ```

3. **Start the Development Environment**
   ```bash
   # Start all services using .NET Aspire
   dotnet run --project apphost
   ```

4. **Access the Application**
   - The Aspire dashboard will open automatically
   - Frontend: Available through the dashboard
   - Backend API: Available with Scalar UI documentation
   - Monitoring and logs: Available in the Aspire dashboard

## 🔄 Development Workflow

### Local Development

Octopets uses .NET Aspire to orchestrate all services:

- **Start Services**: `dotnet run --project apphost`
- **Frontend Changes**: Hot reload automatically (React dev server)
- **Backend Changes**: Require service restart for C# code changes
- **Mock Data**: Automatically enabled in development mode

### Development Mode Features

- **Mock Data System**: Both frontend and backend use consistent mock data
- **In-Memory Database**: No persistent database required for development
- **Service Discovery**: Automatic service communication through Aspire
- **Hot Reload**: Frontend changes reflect immediately

## 🏗️ Project Structure

```
octopets/
├── frontend/           # React + TypeScript frontend
│   ├── src/
│   │   ├── components/ # Reusable React components
│   │   ├── pages/      # Page components
│   │   ├── data/       # Mock data and data services
│   │   └── styles/     # CSS styling
│   └── Dockerfile      # Frontend containerization
├── backend/            # ASP.NET Core backend
│   ├── Data/           # Entity Framework context and models
│   ├── Endpoints/      # Minimal API endpoints
│   ├── Models/         # Data models
│   └── Repositories/   # Repository pattern implementation
├── apphost/            # .NET Aspire orchestration
├── servicedefaults/    # Shared service configuration
└── docs/               # Project documentation
```

## 🎨 Code Style Guidelines

### Frontend (React + TypeScript)

- **Components**: Use functional components with hooks
- **TypeScript**: Use strict typing, avoid `any`
- **File Organization**: 
  - Pages in `frontend/src/pages/`
  - Reusable components in `frontend/src/components/`
  - Styles in `frontend/src/styles/`
- **Naming**: Use PascalCase for components, camelCase for functions/variables
- **CSS**: Use custom CSS with consistent variable usage

### Backend (ASP.NET Core)

- **API Pattern**: Use Minimal APIs approach
- **Repository Pattern**: Implement data access through repositories
- **Endpoints**: Organize in `backend/Endpoints/` by feature
- **Documentation**: Use OpenAPI attributes for API documentation
- **Naming**: Follow C# conventions (PascalCase for public members)

### General Guidelines

- **Commits**: Use descriptive commit messages
- **Comments**: Add comments for complex logic only
- **Documentation**: Update relevant documentation for new features

## 🔧 Making Changes

### Before You Start

1. **Check Existing Issues**: Look for related issues or discussions
2. **Create an Issue**: For new features or bugs, create an issue first
3. **Branch Naming**: Use descriptive branch names (e.g., `feature/add-search-filter`, `fix/listing-display-bug`)

### Development Process

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow the code style guidelines
   - Keep changes focused and atomic
   - Test your changes locally

3. **Update Documentation**
   - Update README.md if installation/setup changes
   - Add inline documentation for complex features
   - Update relevant documentation in `docs/`

## 🧪 Testing

### Frontend Testing
```bash
cd frontend
npm test
```

### Backend Testing
```bash
dotnet test
```

### Integration Testing
- Start the full application with `dotnet run --project apphost`
- Verify all services start correctly
- Test the complete user workflow
- Check the Aspire dashboard for service health

### Manual Testing Checklist
- [ ] Application starts successfully
- [ ] Frontend loads and displays correctly
- [ ] API endpoints respond correctly (check Scalar UI)
- [ ] Navigation between pages works
- [ ] Mock data displays properly
- [ ] Responsive design works on different screen sizes

## 📝 Submitting Changes

### Pull Request Process

1. **Update Your Branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Create a Pull Request**
   - Use a descriptive title
   - Include a detailed description of changes
   - Reference any related issues
   - Add screenshots for UI changes

3. **Pull Request Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Local testing completed
   - [ ] All services start correctly
   - [ ] No console errors

   ## Related Issues
   Closes #issue_number
   ```

### Review Process

- All PRs require review before merging
- Address review feedback promptly
- Keep PRs focused and reasonably sized
- Be responsive to questions and suggestions

## 🐛 Issue Reporting

### Bug Reports

When reporting bugs, include:

- **Environment**: OS, browser, .NET version, Node.js version
- **Steps to Reproduce**: Detailed steps to recreate the issue
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable
- **Console Logs**: Any error messages or logs

### Feature Requests

For new features:

- **Use Case**: Why is this feature needed?
- **Proposed Solution**: How should it work?
- **Alternatives**: Any alternative approaches considered?
- **Additional Context**: Screenshots, mockups, or examples

## 🛠️ Common Tasks

### Adding a New API Endpoint

1. Create endpoint in `backend/Endpoints/`
2. Follow Minimal API patterns
3. Add OpenAPI documentation attributes
4. Update repository if data access needed
5. Test with Scalar UI

### Adding a New Frontend Page

1. Create component in `frontend/src/pages/`
2. Add route in React Router configuration
3. Update navigation components
4. Add appropriate styling
5. Test responsive design

### Updating Mock Data

1. **Frontend**: Update `frontend/src/data/listingsData.ts`
2. **Backend**: Update seed data in `backend/Data/AppDbContext.cs`
3. Ensure data consistency between frontend and backend
4. Test both development modes

### Working with Aspire

- **View Logs**: Use the Aspire dashboard
- **Service Health**: Monitor in dashboard
- **Configuration**: Update in `apphost/Program.cs`
- **Environment Variables**: Set through Aspire configuration

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Documentation**: Check README.md and docs/ folder

## 📄 License

By contributing to Octopets, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Octopets! 🐾 Your contributions help make pet-friendly venue discovery better for everyone.