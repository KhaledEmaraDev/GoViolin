#!/usr/bin/env groovy

pipeline {
    agent any

    stages {
        stage('Test') {
            // Conform to the environment specified in Dockerfile.
            environment {
                GOPATH = '/root/go'
                GOMODCACHE = '/root/go/pkg/mod'
                GOCACHE = '/root/.cache/go-build'
                GOENV = '/root/.config/go/env'
            }

            agent {
                // Use the Dockerfile from this repo as the agent.
                // This is the first method to run docker containers on Jenkins.
                // Could have used the Docker Pipeline Plugin, but I wanted to show off
                // another way.
                dockerfile {
                    filename 'Dockerfile'
                    dir '.'
                    additionalBuildArgs  '--target builder' // Stop at the builder stage
                                                            // , because it's the only
                                                            // stage with access to the
                                                            // test files.
                    args '-v $HOME/go/pkg:/root/go/pkg --user 0' // Run as root and
                                                                 // share pkg folder
                                                                 // between host and
                                                                 // docker for caching.

                    reuseNode true
                }
            }

            steps {
                // Get tool to convert go test results to JUnit XML reports.
                sh 'go get -u github.com/jstemmer/go-junit-report'
                // Redirect stderr to stdout and pipe both to the tool. Always return 0,
                // to be able to report test failures.
                sh 'go test -v ./... 2>&1 | /root/go/bin/go-junit-report > report.xml || true'
                // Archive test report.
                junit skipPublishingChecks: true, testResults: 'report.xml'

                // Generate coverage info.
                sh 'go test -covermode=count -coverprofile=count.out fmt'
                sh 'go tool cover -func=count.out'
                // Generate an HTML report from it.
                sh 'go tool cover -html=count.out -o cover.html'
                // Archive this report.
                publishHTML target: [
                    allowMissing: false,
                    alwaysLinkToLastBuild: false,
                    keepAll: false,
                    reportDir: '.',
                    reportFiles: 'cover.html',
                    reportName: 'Coverage Report'
                ]
            }
        }

        stage('Build') {
            // Run this stage only if the tests didn't fail.
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS' 
                }
            }

            steps {
                script {
                    // Connect to Docker registery with credentials 'docker-hub'.
                    // This could be used to run the container.
                    // Another way of building docker containers is using dind (Docker
                    // in Docker): https://hub.docker.com/_/docker
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                        // TAG image with the BUILD_ID.
                        def customImage = docker.build("khaledemaradev/go-violin:${env.BUILD_ID}")
                        // Push to the registery.
                        customImage.push()
                    }
                }
            }
        }
    }

    post {
        // Send email on failure.
        failure {
            mail to: 'mail@KhaledEmara.dev', subject: "${env.JOB_NAME}'s Pipeline Failed!", charset: 'UTF-8', mimeType: 'text/html', body: "Build URL: ${env.BUILD_URL}"
        }
    }
}
