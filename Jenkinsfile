pipeline { 
      agent any 
      environment { 
          registry = "schulken/capstone" 
          registryCredential = 'dockerhub' 
          hadolintres = '' 
          dockerImage = '' 
      } 
      stages { 
         stage('Build') {
              steps {
                  sh 'echo Building...'
              }
         }
         stage('Lint HTML') {
              steps {
                  sh 'tidy -q -e *.html'
              }
         }
         stage ("Lint Dockerfile") { 
               agent { 
                   docker { 
                       image 'hadolint/hadolint:latest-debian' 
                   } 
               } 
               steps { 
                   script { 
                        hadolintres = sh(script: 'hadolint Dockerfile', returnStdout: true).trim() 
                        echo "${hadolintres}"   
                        if (hadolintres != '') { 
                             currentBuild.result = 'FAILURE' 
                        } 
                   } 
               } 
         } 
         stage('Build Docker Image') { 
              steps{ 
                   script { 
                     dockerImage = docker.build registry 
                   } 
              } 
         } 
         stage('Push Docker Image') { 
            steps{ 
                 script { 
                     docker.withRegistry( '', registryCredential ) { 
                          dockerImage.push("$BUILD_NUMBER") 
                         dockerImage.push("latest") 
                     } 
                 } 
            } 
         } 
         stage('Remove Unused docker image') { 
            steps{ 
              sh "docker rmi $registry:$BUILD_NUMBER" 
            } 
          } 
           stage('Deploy Kubernetes') { 
                steps { 
                     checkout scm 
                    withAWS(region:'us-east-2',credentials:'schulken') { 
                          sh "/var/lib/jenkins/kubectl apply -f deployment.yml" 
                          sh "/var/lib/jenkins/kubectl apply -f deployment-service.yml"     
                     } 
                } 
           } 
            stage("Cleaning up") {
              steps{
                    echo 'Cleaning up...'
                    sh "docker system prune"
              }
           }
      } 
 } 
