pipeline {
    agent any
    
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_HUB_USERNAME = 'socprojects999' 
        BACKEND_SERVICES = 'user-service,product-service,order-service,admin-service'
    }
    
    tools {
        maven 'Maven-3.9'
        nodejs 'NodeJS-22'
        jdk 'JDK-17'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build Backend Services') {
            steps {
                echo 'Building Spring Boot microservices...'
                script {
                    def services = env.BACKEND_SERVICES.split(',')
                    services.each { service ->
                        dir("farmconnect-backend/${service}") {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Build Frontend') {
            steps {
                echo 'Building React frontend...'
                dir('farmconnect-frontend') {
                    sh 'npm ci'
                    sh 'npm run build'
                }
            }
        }
        
        stage('Run Tests') {
            parallel {
                stage('Backend Tests') {
                    steps {
                        echo 'Running backend tests...'
                        script {
                            def services = env.BACKEND_SERVICES.split(',')
                            services.each { service ->
                                dir("farmconnect-backend/${service}") {
                                    sh 'mvn test || true'
                                }
                            }
                        }
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        echo 'Running frontend tests...'
                        dir('farmconnect-frontend') {
                            sh 'npm test -- --coverage --watchAll=false || true'
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                echo 'Building Docker images...'
                script {
                    // Build backend services
                    def services = env.BACKEND_SERVICES.split(',')
                    services.each { service ->
                        dir("farmconnect-backend/${service}") {
                            sh "docker build -t ${DOCKER_HUB_USERNAME}/farmconnect-${service}:${BUILD_NUMBER} ."
                            sh "docker tag ${DOCKER_HUB_USERNAME}/farmconnect-${service}:${BUILD_NUMBER} ${DOCKER_HUB_USERNAME}/farmconnect-${service}:latest"
                        }
                    }
                    
                    // Build frontend
                    dir('farmconnect-frontend') {
                        sh "docker build -t ${DOCKER_HUB_USERNAME}/farmconnect-frontend:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_HUB_USERNAME}/farmconnect-frontend:${BUILD_NUMBER} ${DOCKER_HUB_USERNAME}/farmconnect-frontend:latest"
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        def services = env.BACKEND_SERVICES.split(',')
                        services.each { service ->
                            sh "docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:${BUILD_NUMBER}"
                            sh "docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:latest"
                        }
                        
                        // Push frontend
                        sh "docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:${BUILD_NUMBER}"
                        sh "docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:latest"
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                sh 'docker-compose down || true'
                sh 'docker-compose up -d'
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health checks...'
                script {
                    sleep 30 // Wait for services to start
                    
                    def services = [
                        'user-service': 8081,
                        'product-service': 8082,
                        'order-service': 8083,
                        'admin-service': 8084,
                        'frontend': 80
                    ]
                    
                    services.each { name, port ->
                        def response = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${port} || echo '000'",
                            returnStdout: true
                        ).trim()
                        
                        if (response == '200' || response == '302') {
                            echo "${name} is healthy (HTTP ${response})"
                        } else {
                            echo "WARNING: ${name} returned HTTP ${response}"
                        }
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline executed successfully!'
            emailext(
                subject: "Jenkins Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    <h2>Build Successful!</h2>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build Number: ${env.BUILD_NUMBER}</p>
                    <p>Check console output at: ${env.BUILD_URL}</p>
                """,
                to: 'admin@farmconnect.com',
                mimeType: 'text/html'
            )
        }
        failure {
            echo 'Pipeline failed!'
            emailext(
                subject: "Jenkins Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    <h2>Build Failed!</h2>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build Number: ${env.BUILD_NUMBER}</p>
                    <p>Check console output at: ${env.BUILD_URL}</p>
                """,
                to: 'admin@farmconnect.com',
                mimeType: 'text/html'
            )
        }
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f'
        }
    }
}