#!/usr/bin/env groovy

pipeline {
    agent any

    stages {
        stage('Test') {
            environment {
                GOPATH = '/root/go'
                GOMODCACHE = '/root/go/pkg/mod'
                GOCACHE = '/root/.cache/go-build'
                GOENV = '/root/.config/go/env'
            }

            agent {
                dockerfile {
                    filename 'Dockerfile'
                    dir '.'
                    additionalBuildArgs  '--target builder'
                    args '-v $HOME/go/pkg:/root/go/pkg --user 0'

                    reuseNode true
                }
            }

            steps {
                sh 'go get -u github.com/jstemmer/go-junit-report'
                sh 'go test -v ./... 2>&1 | /root/go/bin/go-junit-report > report.xml || true'
                junit skipPublishingChecks: true, testResults: 'report.xml'

                sh 'go test -covermode=count -coverprofile=count.out fmt'
                sh 'go tool cover -func=count.out'
                sh 'go tool cover -html=count.out -o cover.html'
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
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS' 
                }
            }

            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                        def customImage = docker.build("khaledemaradev/go-violin:${env.BUILD_ID}")
                        customImage.push()
                    }
                }
            }
        }
    }

    post {
        failure {
            mail to: 'mail@KhaledEmara.dev', subject: "${env.JOB_NAME}'s Pipeline Failed!", charset: 'UTF-8', mimeType: 'text/html', body: "Build Number: ${env.BUILD_NUMBER}"
        }
    }
}
