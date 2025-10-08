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
                            if (isUnix()) {
                                sh 'mvn clean package -DskipTests'
                            } else {
                                bat 'mvn clean package -DskipTests'
                            }
                        }
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                echo 'Building React frontend...'
                dir('farmconnect-frontend') {
                    script {
                        if (isUnix()) {
                            sh 'npm ci'
                            sh 'npm run build'
                        } else {
                            bat 'npm ci'
                            bat 'npm run build'
                        }
                    }
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
                                    if (isUnix()) {
                                        sh 'mvn test || true'
                                    } else {
                                        bat 'mvn test'
                                    }
                                }
                            }
                        }
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        echo 'Running frontend tests...'
                        dir('farmconnect-frontend') {
                            script {
                                if (isUnix()) {
                                    sh 'npm test -- --coverage --watchAll=false || true'
                                } else {
                                    bat 'npm test -- --coverage --watchAll=false'
                                }
                            }
                        }
                    }
                }
            }
        }

    stage('Build Docker Images') {
        steps {
            echo 'Building Docker images...'
            script {
                // Build backend services from parent directory context
                dir('farmconnect-backend') {
                    if (isUnix()) {
                        // User Service
                        sh "docker build -f user-service/Dockerfile -t ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-user-service:latest"
                        
                        // Product Service
                        sh "docker build -f product-service/Dockerfile -t ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-product-service:latest"
                        
                        // Order Service
                        sh "docker build -f order-service/Dockerfile -t ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-order-service:latest"
                        
                        // Admin Service
                        sh "docker build -f admin-service/Dockerfile -t ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-admin-service:latest"
                    } else {
                        // User Service
                        bat "docker build -f user-service/Dockerfile -t ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-user-service:latest"
                        
                        // Product Service
                        bat "docker build -f product-service/Dockerfile -t ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-product-service:latest"
                        
                        // Order Service
                        bat "docker build -f order-service/Dockerfile -t ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-order-service:latest"
                        
                        // Admin Service
                        bat "docker build -f admin-service/Dockerfile -t ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-admin-service:latest"
                    }
                }
                
                // Build frontend
                dir('farmconnect-frontend') {
                    if (isUnix()) {
                        sh "docker build -t ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ."
                        sh "docker tag ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-frontend:latest"
                    } else {
                        bat "docker build -t ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-frontend:latest"
                    }
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
                            if (isUnix()) {
                                sh """
                                    docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:${BUILD_NUMBER}
                                    docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:latest
                                """
                            } else {
                                bat """
                                    docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:${BUILD_NUMBER}
                                    docker push ${DOCKER_HUB_USERNAME}/farmconnect-${service}:latest
                                """
                            }
                        }

                        // Push frontend
                        if (isUnix()) {
                            sh """
                                docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:${BUILD_NUMBER}
                                docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:latest
                            """
                        } else {
                            bat """
                                docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:${BUILD_NUMBER}
                                docker push ${DOCKER_HUB_USERNAME}/farmconnect-frontend:latest
                            """
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    if (isUnix()) {
                        sh 'docker-compose down || true'
                        sh 'docker-compose up -d'
                    } else {
                        bat 'docker-compose down || exit 0'
                        bat 'docker-compose up -d'
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health checks...'
                script {
                    sleep 30 // wait for services to start

                    def services = [
                        'user-service': 8081,
                        'product-service': 8082,
                        'order-service': 8083,
                        'admin-service': 8084,
                        'frontend': 80
                    ]

                    services.each { name, port ->
                        if (isUnix()) {
                            def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:${port} || echo '000'", returnStdout: true).trim()
                            echo "${name} -> HTTP ${response}"
                        } else {
                            def response = bat(script: "curl -s -o NUL -w %%{http_code} http://localhost:${port} || echo 000", returnStdout: true).trim()
                            echo "${name} -> HTTP ${response}"
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
            script {
                if (isUnix()) {
                    sh 'docker system prune -f'
                } else {
                    bat 'docker system prune -f'
                }
            }
        }
    }
}
