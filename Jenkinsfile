pipeline {
    agent any
    environment{
        NEW_VERSION = '1.3.3'
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                echo 'Building stage'
            }
        }
        stage('Test') {
            when{
                expression {
                   env.BRANCH_NAME = dev || env.BRANCH_NAME = main
                }
            }
            // Below code only execute when branch is DEV or master 
            steps {
                echo 'Testing..'
                echo 'Testing stage'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
                echo "Deploying with version ${NEW_VERSION}"
            }
        }
    }
    // Defining post conditions
    post {
        always{
            // sending email to team  in every condition like fail success
        }
        success{
            // Only when success
        }
        failure{
            // Onlyu when failure
        }
    }
}

