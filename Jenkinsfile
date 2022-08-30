pipeline {
    agent any


    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
post {
    always { 
        echo 'I will always say Hello again!'
    }
    success {
        echo 'I will say Hello only if job is success'
    }
    failure {
        echo 'I will say Hello only if job is failure'
    }
} 
