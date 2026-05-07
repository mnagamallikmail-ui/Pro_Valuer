# ProValuer-VR Monorepo

This repository contains the source code for the ProValuer-VR application, migrated from Railway to a dedicated VPS.

## Project Structure
- `BwVrBackend/`: Spring Boot Java backend.
- `BwVrFrontend/`: Flutter Web frontend.
- `.github/workflows/`: Automated CI/CD deployment pipeline.

## Deployment Overview
The application is deployed to a Linux VPS using Docker Compose and Nginx.

### Local Development
- **Backend**: Run `./gradlew bootRun` inside `BwVrBackend`.
- **Frontend**: Run `flutter run -d chrome` inside `BwVrFrontend`.

### Production Deployment
Deployment is automated via GitHub Actions on every push to the `main` branch.

#### 1. VPS Provisioning
Run the `provision.sh` script on a fresh Ubuntu 22.04 VPS to install Docker and Nginx.

#### 2. Configuration
Secrets are managed via GitHub Repository Secrets:
- `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`
- `DB_NAME`, `DB_USER`, `DB_PASSWORD`
- `JWT_SECRET`, `CORS_ALLOWED_ORIGINS`

#### 3. Database Restore
To restore from a backup:
```bash
docker exec -i bwvr-db psql -U postgres -d railway < ./db-dump/bwvr_prod.sql
```

## License
Proprietary.
