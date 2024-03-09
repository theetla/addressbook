pipeline {
    agent none

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "mymaven"
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
          stage('package') {
            agent any
            steps {

                script{
                    sshagent(['slave1']){
                         sh "scp -o StrictHostKeyChecking=no server-script.sh ec2-user@172.31.45.250:/home/ec2-user"
                         sh "ssh -o StrictHostKeyChecking=no  ec2-user@172.31.45.250 'bash server-script.sh' "
                         echo "generating ready to be deployable files"
                         sh "mvn package"
                    }
                }   
            }
        }
    }
}
