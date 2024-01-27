pipeline {
    agent any

    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        maven "mymaven"
    }

    stages {
        stage('compile') {
            steps {
                
                echo "compiling the source code"
            }
        }
        stage('test') {
            steps {
                
                
                echo "testing using junit framework"
            }
        }
          stage('package') {
            steps {
                
                
                echo "generating ready to be deployable files"
            }
        }
    }
}
