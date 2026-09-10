pipeline {
    agent any

    tools {
        nodejs 'node20'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '20'))
    }

    environment {
        CI = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install') {
            steps {
                bat 'npm install --legacy-peer-deps'
            }
        }

        stage('Lint') {
            steps {
                bat 'npm run lint'
            }
        }

        stage('Test') {
            steps {
                bat 'npm run test:ci'
            }
        }

        stage('Build') {
            steps {
                bat 'npm run build'
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: '.output/**, coverage/**', allowEmptyArchive: true, fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'HostelFix pipeline succeeded: tests passed and build produced.'
        }
        failure {
            echo 'HostelFix pipeline failed. Check the Test stage output first.'
        }
        always {
            cleanWs(deleteDirs: true, notFailBuild: true)
        }
    }
}
