# MERN Todo App: Full-Stack Project with AWS Deployment

## Overview
This is a production-ready MERN (MongoDB, Express.js, React, Node.js) Todo App with JWT authentication. Users can register/login, add/delete tasks (CRUD), and tasks are saved per user in MongoDB. The app demonstrates secure auth, Docker containerization, and AWS deployment (S3/CloudFront for frontend, EC2 for backend/Mongo).

**Key Features**:
- JWT-based authentication (register/login with email/password validation).
- User-specific tasks (add, list, delete).
- Responsive UI with React Router.
- Secure backend with CORS, bcrypt hashing, and Mongoose models.
- Docker for local/prod consistency.
- AWS: Static frontend on S3 + CloudFront CDN, dynamic backend on EC2 with Docker.

**Live Demo**: [https://dqcq644qwvh13.cloudfront.net](https://dqcq644qwvh13.cloudfront.net) (Register with email/password, add todos). Replace with your own deployed URL.

## Tech Stack
- **Frontend**: React 18, Axios (HTTP client), React Router (routing), Material-UI (UI components).
- **Backend**: Node.js/Express, Mongoose (MongoDB ODM), JWT (auth), Bcrypt (hashing), Validator (input validation).
- **Database**: MongoDB (via Docker).
- **DevOps**: Docker (containerization), GitHub Actions (CI/CD), AWS S3/CloudFront (frontend), AWS EC2 (backend).
- **Other**: Tailwind CSS (styling), ESLint (linting).

## Local Setup
### Prerequisites
- Node.js v18+ (install from [nodejs.org](https://nodejs.org)).
- Docker (for Mongo) [docker.com](https://docker.com).
- AWS CLI configured ([docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli)).
- Git.

### 1. Clone Repo
```
git clone https://github.com/yourusername/mern-todo-aws-deploy.git
cd mern-todo-aws-deploy
```

### 2. Backend Setup
```
cd backend
npm install  # Install deps
cp .env.example .env  # Copy env template
# Edit .env: MONGO_URI=mongodb://admin:pass123@localhost:27017/tododb?authSource=admin, JWT_SECRET=your-secret-key
npm start  # Run on port 8001
```

### 3. MongoDB Setup (Docker)
```
docker run -d --name my-mongo-db -p 27017:27017 \
  -v mongo-data:/data/db \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=pass123 \
  --restart unless-stopped \
  mongo:latest
sleep 30  # Wait startup
docker logs my-mongo-db  # Confirm "Waiting for connections"
# Init auth (one-time)
docker exec -it my-mongo-db mongosh -u admin -p pass123 --authenticationDatabase admin --eval "db.createUser({user: 'admin', pwd: 'pass123', roles: ['root']})" || true
```

### 4. Frontend Setup
```
cd ../frontend
npm install  # Install deps
cp .env.production.example .env.production  # Copy env
# Edit .env.production: REACT_APP_API_URL=http://localhost:8001 (local) or YOUR_EC2_PUBLIC_IP:8001 (prod)
npm start  # Run on port 3000
```

### 5. Local Test
- Backend: `curl -X POST http://localhost:8001/api/user/register -H "Content-Type: application/json" -d '{"name":"Test","email":"test@example.com","password":"StrongPass123!"}'` (201 token).
- Frontend: localhost:3000 pe ja—register/login, add todo (calls localhost:8001).
- Mongo: `docker exec -it my-mongo-db mongosh tododb` → `db.users.find()` (users) or `db.tasks.find()` (tasks).

## AWS Deployment
### 1. Frontend: S3 + CloudFront
- **S3 Bucket**: Create "todo-frontend-2025" (static website hosting enable, index.html error document).
- Bucket Policy (public read):
  ```
  {
    "Version": "2012-10-17",
    "Statement": [{"Sid": "PublicReadGetObject", "Effect": "Allow", "Principal": "*", "Action": "s3:GetObject", "Resource": "arn:aws:s3:::todo-frontend-2025/*"}]
  }
  ```
- **Deploy**:
  ```
  cd frontend
  npm run build
  aws s3 sync build/ s3://todo-frontend-2025 --delete
  ```
- **CloudFront**: Create distribution, origin S3 bucket, default root "index.html", HTTPS viewer policy.
- **Invalidate Cache**: `aws cloudfront create-invalidation --distribution-id E19AAP1V4BQ097 --paths "/*"`.
- **URL**: https://dqcq644qwvh13.cloudfront.net (main). Replace with your own distribution URL.

### 2. Backend & Mongo: EC2 + Docker
- **Launch EC2**: t3.micro, Amazon Linux/Ubuntu, key pair "todo-key.pem", SG with inbound SSH (22), TCP 8001 (API), 27017 (Mongo).
- **SSH**: `ssh -i todo-key.pem ubuntu@YOUR_EC2_PUBLIC_IP` (Ubuntu) or ec2-user@ (Amazon Linux).
- **Install Docker**: `sudo apt update && sudo apt install docker.io -y && sudo systemctl start docker && sudo usermod -aG docker ubuntu` (relogin).
- **Add Swap**: `sudo fallocate -l 1G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab`.
- **Transfer Code**: Local: `scp -i todo-key.pem -r backend ubuntu@YOUR_EC2_PUBLIC_IP:~`.
- **Deploy Mongo**: See Local Setup Step 3 (same commands).
- **Deploy Backend**:
  ```
  cd ~/backend
  docker build -t todo-backend:latest .
  docker run -d --name todo-backend -p 8001:8001 --cpus=1 --memory=512m --link my-mongo-db:mongo -e MONGO_URI="mongodb://admin:pass123@mongo:27017/tododb?authSource=admin" -e JWT_SECRET="your-secret" --restart unless-stopped todo-backend:latest
  ```
- **Test**: `curl -X POST http://YOUR_EC2_PUBLIC_IP:8001/api/user/register -H "Content-Type: application/json" -d '{"name":"Test","email":"test@example.com","password":"StrongPass123!"}'` (201).

### 3. GitHub Actions CI/CD (Separate Pipelines)
Repo: mern-todo-aws-deploy (monorepo with frontend/backend).

- **Secrets**: GitHub Settings > Secrets > Actions:
  - AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (IAM with S3/EC2 perms).
  - EC2_HOST=YOUR_EC2_PUBLIC_IP, EC2_USER=ubuntu, EC2_KEY=base64 pem (`base64 -w 0 todo-key.pem`).

- **Frontend Workflow** (.github/workflows/frontend-deploy.yml):


- **Backend Workflow** (.github/workflows/backend-deploy.yml):


- **Test CI/CD**: Small change push kar (e.g., console.log add)—Actions tab mein run dekh (green tick).

### Usage: How to Run This Project
1. **Local**: Clone repo, cd backend, npm install, run Mongo Docker, npm start backend. cd frontend, npm install, npm start frontend.
2. **Deploy**: AWS CLI configure, run S3 sync for frontend, SCP code to EC2, Docker run backend/Mongo.
3. **Access**: https://dqcq644qwvh13.cloudfront.net (prod). Replace with your own distribution URL. Register/login, add todos.
4. **Customize**: .env edit kar (secrets), SG rules tweak for security.

### Troubleshooting
- **Localhost Error**: .env.production mein REACT_APP_API_URL set kar, rebuild.
- **EC2 Connect Fail**: SG inbound 8001 open kar, key perms 400.
- **CI/CD Fail**: Secrets check kar, logs dekh (Actions tab).
- **Mixed-Content**: Backend HTTPS bana (nginx + Certbot).
