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
                        sh 'docker build -t yaraamrallah/angular-basic-app:g .'
                    }
                }
                stage('Push Image') {
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            sh 'docker login --username $USERNAME --password $PASSWORD'
                            sh 'docker push yaraamrallah/angular-basic-app:g'
                        }
                    }
                }
                stage('Image Security Scan') {
                    steps {
                        writeFile file: 'anchore_images', text: 'docker.io/yaraamrallah/angular-basic-app:g'
                        anchore name: 'anchore_images'
                    }
                }
                stage('AWS Credentials') {
                    steps {
                        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'JenkinsAWS', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                            sh """
                            mkdir -p ~/.aws
                            echo "[default]" >~/.aws/credentials
                            echo "aws_access_key_id=${AWS_ACCESS_KEY_ID}" >> ~/.aws/credentials
                            echo "aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" >> ~/.aws/credentials
                            """
                        }
                      sh 'pip3 install boto'
                      sh 'pip3 install boto3'
                      sh 'chmod 400 Ansible/aws/aws-keys/pipeline.pem'
                    }
                }
                stage('Create EC2 Instance') {
                    steps {
                      dir('Ansible/ansible-green') {
                        ansiblePlaybook playbook: 'main-provision.yaml'
                      }
                    }
                } 
                stage('Deploy to EC2 Instance') {
                    steps {
                        dir('Ansible/ansible-green') {
                          ansiblePlaybook playbook: 'main-deploy.yaml'
                        }
                          input message: "Forward to users?"
                    }
                }
                stage('Forward to users') {
                    steps {
                      dir('Ansible/ansible-green') {
                        ansiblePlaybook playbook: 'main-expose.yaml'
                      }
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
