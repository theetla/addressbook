
pipeline {
   agent none
   tools{
         jdk 'myjava'
         maven 'mymaven'
   }
   environment{
       BUILD_SERVER_IP='ec2-user@172.31.15.230'
       IMAGE_NAME='theetla/java-mvn-cicdrepos:$BUILD_NUMBER'
       ACM_IP='ec2-user@172.31.43.33'
       AWS_ACCESS_KEY_ID =credentials("ACCESS_KEY")
       AWS_SECRET_ACCESS_KEY =credentials("SECRET_ACCESS_KEY")
       DOCKER_REG_PASSWORD=credentials("DOCKER_REG_PASSWORD")
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
                sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER_IP} 'bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                //sh "ssh ${BUILD_SERVER_IP} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/addressbook"
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
                    ANSIBLE_TARGET_EC2_PUBLIC_IP=sh(
                        script: "terraform output ec2-ip",
                        returnStdout: true
                    ).trim()
                     echo "${ANSIBLE_TARGET_EC2_PUBLIC_IP}"
                   }
                                     
               }
           }
       }
             stage("RUN ansible playbook on ACM"){
            agent any
            steps{
            script{
                echo "copy ansible files on ACM and run the playbook"
               sshagent(['slave1']) {
    sh "scp -o StrictHostKeyChecking=no ansible/* ${ACM_IP}:/home/ec2-user"
    //copy the ansible target key on ACM as private key file
    withCredentials([sshUserPrivateKey(credentialsId: 'ANSIBLE_TARGET_KEY',keyFileVariable: 'keyfile',usernameVariable: 'user')]){ 
    sh "scp -o StrictHostKeyChecking=no $keyfile ${ACM_IP}:/home/ec2-user/.ssh/id_rsa"    
    }
    sh "ssh -o StrictHostKeyChecking=no ${ACM_IP} bash /home/ec2-user/prepare-playbook.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${DOCKER_REG_PASSWORD} ${IMAGE_NAME}"
      }
        }
        }    
    }
    }

}
