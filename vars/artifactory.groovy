def upload(String extension) {
    def server = Artifactory.server 'art-main'
    server.upload(getUploadSpec("artifacts/*.${extension}", "movie-analyst/psl/${JOB_BASE_NAME}/"))
}

def getUploadSpec(pattern,target) {
    return """{
        "files": [{
            "pattern": "${pattern}",
            "target": "${target}"
        }]
    }"""
}