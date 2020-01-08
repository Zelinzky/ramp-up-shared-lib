// This is the template to create a containerized NodeJS application
// For it to run successfully the following parameters must be declared
// in the project's Jenkinsfile:
// registry = url of the registry to be used
// repository = name of the container repository to be used in the registry
// tag = name of the tag to be added to the created image
// registryCredentials = the credentials to be used to access the registry
// artifactoryRepo = the name of the repository in the artifactory server
// org = name of the organization responsible for the package
// sonarCred = credentials to use with sonarqube


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
            stage('Create container image') {
                steps {
                    script {
                        markAsLatest = (env.BRANCH_NAME == "master")
                        config.imageIDs = containers.createImage(config.registry, config.repository, BUILD_NUMBER, markAsLatest)
                        echo "Image Created, Full lenght tag(s):"
                        config.imageIDs.each { imageID ->
                            echo "$imageID.value"
                        }
                    }
                }
            }
            stage('Publish artifacts') {
                steps {
                    script {
                        echo 'publish container to registry'
                        containers.publish(config.registry, config.registryCredentials, config.imageIDs)
                        echo 'publish artifact to artifactory'
                        artifactory.upload("tar.gz", "${config.artifactoryRepo}/${config.org}/${JOB_BASE_NAME}/")
                    }
                }
            }
        }
        post {
            cleanup {
                script {
                    echo 'removing local containers'
                    containers.removeLocalImage(config.imageIDs.tag)
                    sh "docker image ls --all"
                    echo 'removing local artifacts'
                    sh "rm -f artifacts/*"
                }
            }
        }
    }
}