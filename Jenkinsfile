pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building project...'
                // Your build command here
                sh 'make build'  // Replace with your build command
            }
        }
    }
    
    post {
        success {
            mail(
                to: 'team@example.com',
                subject: "SUCCESS: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Build succeeded!\nView details: ${env.BUILD_URL}"
            )
        }
        failure {
            mail(
                to: 'team@example.com',
                subject: "FAILURE: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Build failed!\nView details: ${env.BUILD_URL}"
            )
        }
    }
}