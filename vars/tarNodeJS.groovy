// This is the template to create a tar compresed NodeJS application
// For it to run successfully the following parameters must be declared
// in the project's Jenkinsfile:
// artifactoryRepo = the name of the repository in the artifactory server
// org = name of the organization responsible for the package

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
                        artifactory.upload("tar.gz", "${config.artifactoryRepo}/${config.org}/${JOB_BASE_NAME}/")
                    }
                }
            }
        }
        post {
            cleanup {
                script {
                    sh "rm -f artifacts/*"
                }
            }
        }
    }
}