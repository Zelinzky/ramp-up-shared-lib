// This is the template to create a tar compresed NodeJS application
// For it to run successfully the following parameters must be declared
// in the project's Jenkinsfile:

def call(body) {
    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    pipeline {
        agent any
        stages {
            stage("install app and check dependencies") {
                steps {
                    nodejs('NodeLTS'){
                        sh 'npm ci --production'
                    }
                }
            }
            stage("create tar.gz artifact"){
                steps {
                    script {
                        tar.compressCurrentDirectory("${JOB_BASE_NAME}-${BUILD_NUMBER}")
                    }
                }
            }
            stage("Publish artifact to artifactory repository") {
                steps {
                    script {
                        artifactory.upload("tar.gz")
                    }
                }
            }
        }
    }
}