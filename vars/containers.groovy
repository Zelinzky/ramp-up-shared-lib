def createImage(String registry, String repository, String tag, Boolean markAsLatest) {
    def imageIDs = [tag :"$registry/$repository:$tag"]
    docker.build(imageIDs[0])
    if (markAsLatest) {
        imageIDs.latest = "$registry/$repository:latest"
        sh "docker tag $imageIDs.tag $imageIDs.latest"
    }
    return imageIDs
}

def publish(String registry, String credential, imageIDs) {
    docker.withRegistry("https://$registry", credential) {
        imageIDs.each { imageID ->
            sh "docker push $imageID.value"
        }
    }
}

def removeLocalImage(String imageID) {
    sh "docker image rm -f $imageID"
}