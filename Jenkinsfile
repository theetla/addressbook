
pipeline {
   agent none
   tools{
         jdk 'myjava'
         maven 'mymaven'
   }
   environment{
       BUILD_SERVER_IP='ec2-user@172.31.8.25'
       IMAGE_NAME='theetla/java-mvn-cicdrepos:$BUILD_NUMBER'
   }
    stages {
        stage('Compile') {
           agent any
            steps {
              script{
                  echo "BUILDING THE CODE"
                  sh 'mvn compile'
              }
            }
            }
        stage('UnitTest') {
        agent any
        steps {
            script{
              echo "TESTING THE CODE"
              sh "mvn test"
              }
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
            }
        stage('PACKAGE+BUILD DOCKERIMAGE AND PUSH TO DOKCERHUB') {
            agent any            
            steps {
                script{
                sshagent(['slave1']) {
                withCredentials([usernamePassword(credentialsId: 'buildserver', passwordVariable: 'mydockerhubpassword', usernameVariable: 'mydockerhubusername')]) {
                echo "Packaging the apps"
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER_IP}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER_IP} 'bash ~/server-script.sh'"
                sh "ssh ${BUILD_SERVER_IP} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/addressbook"
                sh "ssh ${BUILD_SERVER_IP} sudo docker login -u $mydockerhubusername -p $mydockerhubpassword"
                sh "ssh ${BUILD_SERVER_IP} sudo docker push ${IMAGE_NAME}"
              }
            }
            }
        }
        }
       stage('Provision the server with TF'){
            environment{
                   AWS_ACCESS_KEY_ID =credentials("ACCESS_KEY")
                   AWS_SECRET_ACCESS_KEY=credentials("SECRET_ACCESS_KEY")
            }
           agent any
           steps{
               script{
                   echo "RUN THE TF Code"
                   dir('terraform'){
                       sh "terraform init"
                       sh "terraform apply --auto-approve"
                    EC2_PUBLIC_IP=sh(
                        script: "terraform output ec2-ip",
                        returnStdout: true
                    ).trim()
                   }
                                     
               }
           }
       }
       stage("Deploy on EC2 instance created by TF"){
          agent any
           steps{
               script{
                   echo "Deployin on the instance"
                    echo "${EC2_PUBLIC_IP}"
                     sshagent(['slave1']) {
                withCredentials([usernamePassword(credentialsId: 'buildserver', passwordVariable: 'mydockerhubpassword', usernameVariable: 'mydockerhubusername')]){
                      sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} sudo docker login -u $mydockerhubusername -p $mydockerhubpassword"
                      sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker run -itd -p 8080:8080 ${IMAGE_NAME}"
                     
                }
            }
            }
                }
                }
                   }
}
