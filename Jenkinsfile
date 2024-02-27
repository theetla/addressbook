pipeline {
    agent none
    tools{
        maven 'mymaven'
        jdk 'myjava'
    }

    parameters{
         string(name: 'ENV', defaultValue: 'DEV', description: 'env to compile')
         booleanParam(name: 'executeTest', defaultValue: true, description: 'decide to run tc')
         choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'], description: 'Pick app version')
    }

    environment{
        BUILD_SERVER='ec2-user@172.31.32.218'
        IMAGE_NAME='devopstrainer/java-mvn-privaterepos'
        //DEPLOY_SERVER='ec2-user@172.31.36.141'
    }

    stages {
        stage('Compile') {
            agent any
            steps {
                script{   
           // sshagent(['build-server']) {
                         
                echo "Compiling in ${params.ENV} environment"
                sh 'mvn compile'
                
           // }
            }
            } 
        }
        stage("UnitTest"){
            agent any
            when{
                expression{
                    params.executeTest == true
                }
            }
            steps{
                script{
                echo "Run the Unit test cases"
                sh 'mvn test'
            }
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage("Dockerise"){
            agent any
            steps{
                script{
               sshagent(['slave1']) {
               withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {          
                echo "Containerising in ${params.ENV} environment"
                //sh 'mvn compile'
                sh "scp -o StrictHostKeyChecking=no server-config.sh ${BUILD_SERVER}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'bash ~/server-config.sh ${IMAGE_NAME} ${BUILD_NUMBER}'"
                sh "ssh ${BUILD_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"

            }
                }
                }
            }
        }
        stage("Provision deploy server with TF"){
            environment{
                   AWS_ACCESS_KEY_ID =credentials("jenkins_aws_access_key_id")
                   AWS_SECRET_ACCESS_KEY=credentials("jenkins_aws_secret_access_key")
            }
             agent any
                   steps{
                       script{
                           dir('terraform'){
                           sh "terraform init"
                           sh "terraform apply --auto-approve"
                           EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2-public-ip",
                            returnStdout: true
                           ).trim()
                           sh "terraform destroy --auto-approve"
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
                      sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP}  docker login -u $mydockerhubusername -p $mydockerhubpassword"
                      sh "ssh ec2-user@${EC2_PUBLIC_IP}  docker run -itd -p 8080:8080 ${IMAGE_NAME}"
                     
                }
            }
            }
                }
                }
        // stage("K8s deploy"){
        //     agent any
        //        steps{
        //         script{
        //             echo "apply k8s manifest files"
        //             sh 'envsubst < java-mvn-app.yml | kubectl apply -f -'
        //         }
        //        }
        // }
    }
}
