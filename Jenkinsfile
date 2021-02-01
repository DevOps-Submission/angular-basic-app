pipeline {
    agent none
    stages {
        stage('Build and Test the project') {
            agent {
                dockerfile {
                    filename 'dockerfile-agent'
                    args '-v $HOME/.m2:/root/.m2 -u 0 -p 9876:9876'
                }
            }
            stages {
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
                        stage('Unit tests') {
                            steps { 
                              sh 'npm run-script test'
                            }
                        }
                    }
                }   
                stage('Build') {
                    steps { sh 'npm run-script build' }
                }
            }

            post {
                success {
                    echo 'Success!'
                    archiveArtifacts artifacts: 'dist/angular-project/*', followSymlinks: false, onlyIfSuccessful: true
                }
            }
        }
      
        stage('Build and Upload Docker Image') {
            agent any
            stages {
                stage('Lint Dockerfile') {
                    steps {
                        sh 'hadolint Dockerfile'
                    }
                }
                stage('Build Docker Image') {
                    steps {
                        sh 'docker build -t yaraamrallah/angular-basic-app:v .'
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
                stage('Image Security Scan') {
                    steps {
                        writeFile file: 'anchore_images', text: 'docker.io/yaraamrallah/angular-basic-app:v'
                        anchore name: 'anchore_images'
                    }
                }
                stage('Run Image') {
                    steps {
                        sh 'docker run -d -p 80:80 --name angular-app yaraamrallah/angular-basic-app:v'
                        input message: "Finished Testing?"
                        sh 'docker stop angular-app'
                        sh 'docker rm angular-app'
                        sh 'docker rmi yaraamrallah/angular-basic-app:v'
                    }
                } 
            }
        }
    }
}

/*
post {

  failure {
      // You can add slack or email notification here.
      // Example: https://github.com/YaraAmrallah/CI-CD-Project1/blob/master/Workflow%20Documentation.pdf
  } 
} */
