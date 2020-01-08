def upload(String extension, String target) {
    def server = Artifactory.server 'art-main'
    server.upload(getUploadSpec("artifacts/*.${extension}", target))
}

def getUploadSpec(pattern,target) {
    return """{
        "files": [{
            "pattern": "${pattern}",
            "target": "${target}"
        }]
    }"""
}