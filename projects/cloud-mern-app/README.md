# cloud-mern-app
Simple cloud task manager (React + Express + Redis). This repo includes a docker-compose setup for local testing and a GitHub Actions workflow template for pushing images to AWS ECR / ECS.

Local run
1. Ensure Docker and docker-compose are installed.
2. From repo root run:

```bash
docker-compose up --build
```

3. Frontend will be available at http://localhost:8080 and backend at http://localhost:5000

Frontend API url
- The frontend reads the API base URL from `VITE_API_URL` at build time. When using docker-compose the frontend container can call `http://backend:5000` directly. For local dev set `VITE_API_URL` in a `.env` file inside `frontend/`.

CI/CD and AWS
- A GitHub Actions workflow template is added at `.github/workflows/ci-cd.yml`. It requires repository secrets:
	- `ECR_REGISTRY` (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com)
	- `ECR_BACKEND_IMAGE` (image name for backend)
	- `ECR_FRONTEND_IMAGE` (image name for frontend)

The workflow builds and pushes images to ECR. The `ecs/taskdef.json` file is a starting template you can adapt for ECS / Fargate deployments.