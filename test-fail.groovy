package passthroughpipelines;

def cmd_exec(command) {
    return bat(returnStdout: true, script: "${command}").trim()
}

node {


    def build_ok = true

    stage('one') {
        echo cmd_exec('echo "Build ONE starting..."')
        cmd_exec('Exit /B 0')
        cmd_exec('Echo %errorlevel%')
    }

    try{
        stage('two') {
            echo cmd_exec('echo "Build TWO starting..."')
            echo cmd_exec('Exit /B 5')
            echo cmd_exec('Echo %errorlevel%')
        }
    } catch(e) {
        build_ok = false
        echo "Error try/catch " + e.toString()
    }

    stage('three') {
        echo cmd_exec('echo "Build THREE starting..."')
        echo cmd_exec('Exit /B 0')
        echo cmd_exec('Echo %errorlevel%')
    }

    stage('success or fail') {
        script{
            if(build_ok) {
                echo "build build_ok SUCCESS"
                currentBuild.result = "SUCCESS"
            } else {
                currentBuild.result = "FAILURE"
                echo "build NOT build_ok FAILURE"
            }
        }
    }
}
