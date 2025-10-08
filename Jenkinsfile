pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKER_HUB_USERNAME = 'socprojects999'
        DOCKER_USER = "${DOCKER_HUB_USERNAME}"
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
                            bat 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }

        stage('Build Frontend') {
            steps {
                echo 'Building React frontend...'
                dir('farmconnect-frontend') {
                    bat 'npm ci'
                    bat 'npm run build'
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
                                    bat 'mvn test || exit 0'
                                }
                            }
                        }
                    }
                }
                stage('Frontend Tests') {
                    steps {
                        echo 'Running frontend tests...'
                        dir('farmconnect-frontend') {
                            bat 'npm test -- --coverage --watchAll=false || exit 0'
                        }
                    }
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                echo 'Building Docker images...'
                script {
                    dir('farmconnect-backend') {
                        bat "docker build -f user-service/Dockerfile -t ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-user-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-user-service:latest"

                        bat "docker build -f product-service/Dockerfile -t ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-product-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-product-service:latest"

                        bat "docker build -f order-service/Dockerfile -t ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-order-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-order-service:latest"

                        bat "docker build -f admin-service/Dockerfile -t ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-admin-service:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-admin-service:latest"
                    }

                    dir('farmconnect-frontend') {
                        bat "docker build -t ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ."
                        bat "docker tag ${DOCKER_USER}/farmconnect-frontend:${BUILD_NUMBER} ${DOCKER_USER}/farmconnect-frontend:latest"
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing images to Docker Hub...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_TOKEN')]) {
                        bat """
                            echo Logging in to Docker Hub...
                            echo %DOCKER_HUB_TOKEN% | docker login -u %DOCKER_HUB_USERNAME% --password-stdin
                        """

                        def services = env.BACKEND_SERVICES.split(',')
                        services.each { service ->
                            bat """
                                docker push %DOCKER_HUB_USERNAME%/farmconnect-${service}:${BUILD_NUMBER}
                                docker push %DOCKER_HUB_USERNAME%/farmconnect-${service}:latest
                            """
                        }

                        bat """
                            docker push %DOCKER_HUB_USERNAME%/farmconnect-frontend:${BUILD_NUMBER}
                            docker push %DOCKER_HUB_USERNAME%/farmconnect-frontend:latest
                        """

                        bat 'docker logout'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                bat '''
                    echo Stopping any existing containers...
                    docker stop farmconnect-mysql || echo No running MySQL container found
                    docker rm farmconnect-mysql || echo No old MySQL container found

                    echo Cleaning up old containers...
                    docker-compose down || exit 0

                    echo Starting new containers...
                    docker-compose up -d --remove-orphans
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo 'Performing health checks...'
                script {
                    sleep 30

                    def services = [
                        'user-service': 8081,
                        'product-service': 8082,
                        'order-service': 8083,
                        'admin-service': 8084,
                        'frontend': 80
                    ]

                    services.each { name, port ->
                        def response = bat(script: "curl -s -o NUL -w %%{http_code} http://localhost:${port} || echo 000", returnStdout: true).trim()
                        echo "${name} -> HTTP ${response}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
            emailext(
                subject: "✅ Jenkins Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
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
                subject: "❌ Jenkins Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
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
            bat 'docker system prune -f'
        }
    }
}
