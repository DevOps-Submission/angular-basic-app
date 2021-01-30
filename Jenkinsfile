pipeline {
    stages {
      agent none
      stages('Build and Test Software') {
            agent {
        docker {
            image 'node:latest'
            args '-v $HOME/.m2:/root/.m2 -u 0 -rm -d'
        }
        }
        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }
        stage('Test') {
            parallel {
              stage('Static code analysis') {
                steps { sh 'npm run-script lint' }
        }
    /*    stage('Unit tests') {
            steps { sh 'npm run-script test' }
         }*/
       }
        }   
       stage('Build') {
      steps { sh 'npm run-script build' }
    }
      }
      
      
      stages('Build and Upload Docker Image') {
        agent any 
        stage('Build Docker Image') {
          steps {
            sh 'docker build -t yaraamrallah/angular-basic-app:v'
          }
        }
        stage('Push Image') {
          steps {
            withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
              sh 'docker login --username $USERNAME --password $PASSWORD'
              sh 'docker push yaraamrallah/angular-basic-app:v'
            }
          }
        }
      }
    }
}
