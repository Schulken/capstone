pipeline { 
      agent any 
      environment { 
          registry = "schulken/capstone" 
          registryCredential = 'dockerhub' 
          hadolintres = '' 
          dockerImage = '' 
      } 
      stages { 
         stage ("lint dockerfile") { 
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
         stage('Prepare docker image') { 
              steps{ 
                   script { 
                     dockerImage = docker.build registry 
                   } 
              } 
         } 
         stage('Deploy Image') { 
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
           stage('Deploy kubernetes') { 
                steps { 
                     checkout scm 
                     withAWS(region:'us-west-2',credentials:'marksun') { 
                          sh "/var/lib/jenkins/kubectl apply -f deployment.yml" 
                          sh "/var/lib/jenkins/kubectl apply -f deployment-service.yml"     
                     } 
                } 
           } 
      } 
 } 
