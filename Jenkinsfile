pipeline {
    agent any
    
    stages {
        stage('Build') {
            steps {
                echo 'Building project...'
                // Your build command here
                sh 'mvn clean install'  // Replace with your build command
            }
        }
    }
    
    post {
        success {
            mail(
                to: 'saidazizz132@gmail.com',
                subject: "SUCCESS: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Build succeeded!\nView details: ${env.BUILD_URL}"
            )
        }
        failure {
            mail(
                to: 'saidazizz132@gmail.com',
                subject: "FAILURE: ${env.JOB_NAME} Build #${env.BUILD_NUMBER}",
                body: "Build failed!\nView details: ${env.BUILD_URL}"
            )
        }
    }
}