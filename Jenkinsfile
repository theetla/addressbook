pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "mymaven"
    }
    

    stages {
        stage('compile') {
            steps {
                script{
                  echo "Compiling"
                  sh "mvn compile"
                }
            }
        }
        stage('test') {
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
            steps {
                script{
                   echo "generating ready to be deployable files"
                   sh "mvn package"
                }   
            }
        }
    }
}
