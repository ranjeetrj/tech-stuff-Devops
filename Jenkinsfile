pipeline {
    agent any
    environment{
        NEW_VERSION = '1.3.3'
        SERVER_CREDENTIALS = credentials('ranjeetrj')
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
                   env.BRANCH_NAME == 'dev' || env.BRANCH_NAME == 'main'
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
                echo "Deploying with version ${SERVER_CREDENTIALS}"
            }
        }
    }
    // Defining post conditions
    post {
        always{
            echo "sending email to team  in every condition like fail success"
        }
        success{
            echo  "Only when success"
        }
        failure{
            echo "Onlyu when failure"
        }
    }
}

