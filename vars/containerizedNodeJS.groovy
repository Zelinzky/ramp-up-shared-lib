// This is the template to create a containerized NodeJS application
// For it to run successfully the following parameters must be declared
// in the project's Jenkinsfile:
// registry = url of the registry to be used
// repository = name of the container repository to be used in the registry
// tag = name of the tag to be added to the created image
// registryCredentials = the credentials to be used to access the registry


def call(body) {
    def config = [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    pipeline {
        agent any
        stages {
            stage('Create Container') {
                steps {
                    script {
                        markAsLatest = (env.BRANCH_NAME == "master")
                        config.imageIDs = containers.createImage(config.registry, config.repository, config.tag, markAsLatest)
                        echo "Image Created, Full lenght tag(s):"
                        config.imageIDs.each { imageID ->
                            echo "$imageID.value"
                        }
                    }
                }
            }
            stage('Publish Container') {
                steps {
                    script {
                        containers.publish(config.registry, config.credentials, config.imageIDs)
                    }
                }
            }
        }
        post {
            cleanup {
                script {
                    containers.removeLocalImage(config.imageIDs.tag)
                    sh "docker image ls --all"
                }
            }
        }
    }
}