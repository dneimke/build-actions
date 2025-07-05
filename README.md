# Build Actions - .NET Monorepo

Welcome to the Build Actions project! This is a .NET 8 monorepo using Nx for efficient project management and build orchestration.

## 🚀 Quick Start for New Developers

### Prerequisites

Before you begin, make sure you have the following installed:

- **.NET 8 SDK** - [Download here](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Node.js 18+** - [Download here](https://nodejs.org/)
- **Git** - [Download here](https://git-scm.com/)

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd build-actions

# Install Node.js dependencies
npm install

# Restore .NET packages
npm run prepare
```

### 2. Test Your Local Environment

Let's verify everything is working correctly:

```bash
# Test .NET installation
dotnet --version  # Should show 8.x.x

# Test Node.js installation  
node --version    # Should show 18.x.x or higher

# Test Nx installation
npx nx --version  # Should show 21.x.x

# Build the shared library
npx nx build shared

# Build the EchoAPI
npx nx build echo-api
```

### 3. Run the Application

```bash
# Start the EchoAPI in development mode
npx nx serve echo-api
```

The API will be available at:
- **API**: https://localhost:7001
- **Swagger UI**: https://localhost:7001/swagger

### 4. Test the API

Once the server is running, you can test the endpoints:

```bash
# Test GET endpoint
curl "https://localhost:7001/echo/hello"

# Test POST endpoint  
curl -X POST "https://localhost:7001/echo" \
  -H "Content-Type: application/json" \
  -d '{"message": "hello world", "uppercase": true}'

# Test PUT endpoint
curl -X PUT "https://localhost:7001/echo/test?count=3"

# Test DELETE endpoint
curl -X DELETE "https://localhost:7001/echo/goodbye"
```

## 📁 Project Structure

```
build-actions/
├── apps/
│   └── EchoAPI/              # .NET 8 Web API application
│       ├── Controllers/      # API controllers
│       ├── Program.cs        # Application entry point
│       └── EchoAPI.csproj    # Project file
├── libs/
│   └── Shared/              # Shared .NET library
│       ├── EchoService.cs   # Business logic service
│       ├── EchoRequest.cs   # Request models
│       └── Shared.csproj    # Project file
├── nx.json                  # Nx workspace configuration
├── package.json             # Node.js dependencies
└── MonoRepoSolution.sln     # Visual Studio solution
```

## 🛠 Development Workflow

### Building Projects

```bash
# Build all projects
npx nx run-many --target=build --all

# Build specific project
npx nx build echo-api
npx nx build shared

# Build with watch mode
npx nx build echo-api --watch
```

### Running Tests

```bash
# Run tests for all projects
npx nx run-many --target=test --all

# Run tests for specific project
npx nx test shared
```

### Development Commands

```bash
# Start development server
npx nx serve echo-api

# Type checking
npx nx typecheck

# Linting (if configured)
npx nx lint

# Format code
npx prettier --write .
```

## 🔧 Nx Commands

This project uses Nx for monorepo management. Here are the most useful commands:

```bash
# View project graph
npx nx graph

# Generate new library
npx nx g @nx-dotnet/core:lib my-library

# Generate new API
npx nx g @nx-dotnet/core:app my-api

# Check affected projects
npx nx affected:graph

# Run tasks on affected projects
npx nx affected --target=build
```

## 🧪 Testing Your Changes

### Unit Tests

```bash
# Run all tests
npx nx run-many --target=test --all

# Run tests for specific project
npx nx test shared
```

### Integration Tests

```bash
# Start the API
npx nx serve echo-api

# In another terminal, run your integration tests
# (Add your integration test commands here)
```

### Manual Testing

1. Start the API: `npx nx serve echo-api`
2. Open Swagger UI: https://localhost:7001/swagger
3. Test the endpoints through the interactive documentation

## 🚀 Deployment

### Building for Production

```bash
# Build all projects for production
npx nx run-many --target=build --all --configuration=production

# Build specific project for production
npx nx build echo-api --configuration=production
```

### Docker (if applicable)

```bash
# Build Docker image
docker build -t echo-api ./apps/EchoAPI

# Run Docker container
docker run -p 7001:7001 echo-api
```

## 📚 Additional Resources

### Nx Documentation
- [Nx Core Concepts](https://nx.dev/concepts/why-monorepos)
- [Nx .NET Plugin](https://nx.dev/plugins/dotnet/overview)
- [Nx Commands Reference](https://nx.dev/reference/nx-commands)

### .NET Documentation
- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)
- [ASP.NET Core](https://docs.microsoft.com/en-us/aspnet/core/)

### Getting Help

- Check the [Nx Discord](https://go.nx.dev/community)
- Review the [Nx documentation](https://nx.dev)
- Ask questions in your team's communication channel

## 🔄 Common Issues and Solutions

### SSL Certificate Issues
If you get SSL certificate errors when testing the API:

```bash
# Trust the development certificate
dotnet dev-certs https --trust
```

### Port Already in Use
If port 7001 is already in use:

```bash
# Check what's using the port
netstat -ano | findstr :7001

# Kill the process or use a different port
npx nx serve echo-api --port 7002
```

### Build Failures
If builds are failing:

```bash
# Clean all builds
npx nx reset

# Restore packages
npm run prepare

# Try building again
npx nx build echo-api
```

---

**Happy coding! 🎉**

If you run into any issues during setup, don't hesitate to ask your team for help.
