pipeline {
    agent {
        docker {
            image 'node:latest'
            args '-v $HOME/.m2:/root/.m2'
        }
    }
    stages {
        stage('Install dependencies') {
            steps {
                sh 'echo "$(whoami)"'
                sh 'echo "$(ll)"'
                sh 'echo "$(pwd)"'
                sh 'echo "$(ll $HOME)"'
                sh 'echo "$(ll /)"'
                sh 'sudo chown -R $(whoami) "$HOME/.npm"'
                sh 'npm install'
            }
        }
        stage('Test') {
            parallel {
              stage('Static code analysis') {
                steps { sh 'npm run-script lint' }
        }
        stage('Unit tests') {
            steps { sh 'npm run-script test' }
         }
       }
        }
      
      
       stage('Build') {
      steps { sh 'npm run-script build' }
    }
    }
}
