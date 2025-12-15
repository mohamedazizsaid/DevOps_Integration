pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        SONARQUBE_URL = 'http://localhost:9000'
        PROJECT_KEY = 'student-management'
        PROJECT_NAME = 'Student Management System'
        EMAIL_TO = 'saidazizz132@gmail.com'
        DOCKER_IMAGE = 'student-management'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "📥 Checking out repository..."
                    checkout scm
                    echo "✅ Repository cloned successfully"
                }
            }
        }

        stage('Build & Unit Tests') {
            steps {
                script {
                    echo "🔨 Building and running unit tests..."
                    if (isUnix()) {
                        sh 'mvn clean test'
                    } else {
                        bat 'mvn clean test'
                    }
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                    echo "📊 Unit test reports generated"
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "🔍 Analyzing code quality with SonarQube..."
                    withSonarQubeEnv('sonarqube') {
                        if (isUnix()) {
                            sh """
                                mvn sonar:sonar \
                                  -Dsonar.projectKey=${PROJECT_KEY} \
                                  -Dsonar.projectName='${PROJECT_NAME}' \
                                  -Dsonar.host.url=${SONARQUBE_URL} \
                                  -Dsonar.java.binaries=target/classes \
                                  -Dsonar.sources=src/main/java \
                                  -Dsonar.tests=src/test/java
                            """
                        } else {
                            bat """
                                mvn sonar:sonar ^
                                  -Dsonar.projectKey=${PROJECT_KEY} ^
                                  -Dsonar.projectName="${PROJECT_NAME}" ^
                                  -Dsonar.host.url=${SONARQUBE_URL} ^
                                  -Dsonar.java.binaries=target/classes ^
                                  -Dsonar.sources=src/main/java ^
                                  -Dsonar.tests=src/test/java
                            """
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    echo "🚦 Waiting for Quality Gate..."
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: false
                    }
                }
            }
        }

        stage('Package') {
            steps {
                script {
                    echo "📦 Packaging application..."
                    if (isUnix()) {
                        sh 'mvn package -DskipTests'
                    } else {
                        bat 'mvn package -DskipTests'
                    }
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, allowEmptyArchive: true
                    echo "✅ Artifact archived successfully"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Building Docker image..."
                    if (isUnix()) {
                        sh """
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        """
                    } else {
                        bat """
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                            docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                        """
                    }
                    echo "✅ Docker image built: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                script {
                    echo "🚀 Deploying application with Docker Compose..."
                    if (isUnix()) {
                        sh '''
                            docker-compose down || true
                            docker-compose up -d
                        '''
                    } else {
                        bat '''
                            docker-compose down
                            docker-compose up -d
                        '''
                    }
                    echo "✅ Application deployed successfully"
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "🏥 Performing health check..."
                    sleep(time: 30, unit: 'SECONDS')
                    
                    if (isUnix()) {
                        sh '''
                            curl -f http://localhost:8089/student/actuator/health || \
                            curl -f http://localhost:8089/student/ || \
                            echo "Application may still be starting..."
                        '''
                    } else {
                        bat '''
                            curl -f http://localhost:8089/student/actuator/health || echo "Checking..."
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🎓 Pipeline finished: ${currentBuild.currentResult}"
            echo "📈 Build URL: ${env.BUILD_URL}"
            echo "⏱️  Duration: ${currentBuild.durationString}"
            
            // Cleanup
            cleanWs(
                deleteDirs: true,
                disableDeferredWipeout: true,
                notFailBuild: true
            )
        }
        
        success {
            script {
                def sonarUrl = "${SONARQUBE_URL}/dashboard?id=${PROJECT_KEY}"
                emailext(
                    to: "${EMAIL_TO}",
                    subject: "✅ SUCCESS - Student Management Build #${env.BUILD_NUMBER}",
                    body: """
                        <h2>Build Successful! 🎉</h2>
                        
                        <h3>Build Information:</h3>
                        <ul>
                            <li><b>Project:</b> ${PROJECT_NAME}</li>
                            <li><b>Build Number:</b> #${env.BUILD_NUMBER}</li>
                            <li><b>Duration:</b> ${currentBuild.durationString}</li>
                            <li><b>Status:</b> ${currentBuild.currentResult}</li>
                        </ul>
                        
                        <h3>Links:</h3>
                        <ul>
                            <li><a href="${env.BUILD_URL}">Jenkins Build</a></li>
                            <li><a href="${sonarUrl}">SonarQube Dashboard</a></li>
                            <li><a href="${env.BUILD_URL}console">Console Output</a></li>
                        </ul>
                        
                        <h3>Deployment:</h3>
                        <p>Application deployed at: <a href="http://localhost:8089/student">http://localhost:8089/student</a></p>
                        
                        <p><i>Generated by Jenkins Pipeline</i></p>
                    """,
                    mimeType: 'text/html'
                )
            }
        }
        
        failure {
            script {
                emailext(
                    to: "${EMAIL_TO}",
                    subject: "❌ FAILED - Student Management Build #${env.BUILD_NUMBER}",
                    body: """
                        <h2>Build Failed! ❌</h2>
                        
                        <h3>Build Information:</h3>
                        <ul>
                            <li><b>Project:</b> ${PROJECT_NAME}</li>
                            <li><b>Build Number:</b> #${env.BUILD_NUMBER}</li>
                            <li><b>Duration:</b> ${currentBuild.durationString}</li>
                            <li><b>Status:</b> ${currentBuild.currentResult}</li>
                        </ul>
                        
                        <h3>Action Required:</h3>
                        <p>Please check the console output to identify the issue:</p>
                        <ul>
                            <li><a href="${env.BUILD_URL}">Jenkins Build</a></li>
                            <li><a href="${env.BUILD_URL}console">Console Output</a></li>
                        </ul>
                        
                        <p><i>Generated by Jenkins Pipeline</i></p>
                    """,
                    mimeType: 'text/html'
                )
            }
        }
        
        unstable {
            script {
                emailext(
                    to: "${EMAIL_TO}",
                    subject: "⚠️ UNSTABLE - Student Management Build #${env.BUILD_NUMBER}",
                    body: """
                        <h2>Build Unstable! ⚠️</h2>
                        
                        <p>The build completed but some tests failed or quality gates were not met.</p>
                        
                        <h3>Links:</h3>
                        <ul>
                            <li><a href="${env.BUILD_URL}">Jenkins Build</a></li>
                            <li><a href="${env.BUILD_URL}testReport">Test Report</a></li>
                            <li><a href="${SONARQUBE_URL}/dashboard?id=${PROJECT_KEY}">SonarQube Dashboard</a></li>
                        </ul>
                        
                        <p><i>Generated by Jenkins Pipeline</i></p>
                    """,
                    mimeType: 'text/html'
                )
            }
        }
    }
}