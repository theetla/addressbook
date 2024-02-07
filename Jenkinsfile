pipeline {
    agent none

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "mymaven"
    }
    environment{
        BUILD_SERVER="ec2-user@172.31.7.115"
        IMAGE_NAME="theetla/java-mvn-cicdrepos"
        DEPLOY_SERVER="ec2-user@172.31.6.140"
    }

    stages {
        stage('compile') {
            agent any 
            steps {
                script{
                  echo "Compiling"
                  sh "mvn compile"
                }
            }
        }
        stage('test') {
            agent any
            steps {
                script{
                    echo "Running the test cases"
                    sh  "mvn test"
                }    
            }
            
         post{
            always{
                junit "target/surefire-reports/*.xml"
            }   
         }
        
        }
          stage('Build docker image') {
            agent any
            steps {

                script{
                    sshagent(['slave1']){ 
                        withCredentials([usernamePassword(credentialsId: 'buildserver', passwordVariable: 'mydockerhubpassword', usernameVariable: 'mydockerhubusername')]) {
                         sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                         sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'bash server-script.sh' ${IMAGE_NAME} ${BUILD_NUMBER} "
                         sh "ssh ${BUILD_SERVER} sudo docker login -u ${mydockerhubusername} -p ${mydockerhubpassword}"
                         sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                        // sh "mvn package"
                    }
                    }
                }   
            }
        }

        stage('deploy the docker container'){
             agent any
             steps{
                script{
                    sshagent(['slave1']){
                     withCredentials([usernamePassword(credentialsId: 'buildserver', passwordVariable: 'mydockerhubpassword', usernameVariable: 'mydockerhubusername')]) { 
                      sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo yum install docker -y"
                      sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                      sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${mydockerhubusername} -p ${mydockerhubpassword}"
                      sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}:${BUILD_NUMBER}"    
                    }

                }
             }
        }
    }
}
}