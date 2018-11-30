pipeline {
  agent any
  stages {
    stage('Compile') {
      steps {
        sh '''export GPG_TTY=$(tty);
mvn clean install'''
      }
    }
    stage('archive') {
      steps {
        junit(testResults: 'target/surefire-reports/*.xml', allowEmptyResults: true)
      }
    }
  }
}

