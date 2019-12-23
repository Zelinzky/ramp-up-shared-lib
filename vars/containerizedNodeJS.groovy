// This is the template to create a containerized NodeJS application
// For it to run successfully the following parameters must be declared
// in the project's Jenkinsfile:
// registry =
// repository =
// tag =
// credentials =


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
                        markAsLatest = (env.BRANCH == master)
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
                    removeLocalImage(config.imageIDs.tag)
                }
            }
        }
    }
}