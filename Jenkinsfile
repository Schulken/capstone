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
         stage('Lint Dockerfile') { 
             steps { 
                 script { 
                     docker.image('hadolint/hadolint:latest-debian').inside() { 
                             sh 'hadolint ./Dockerfile | tee -a hadolint_lint.txt' 
                             sh ''' 
                                 lintErrors=$(stat --printf="%s"  hadolint_lint.txt) 
                                 if [ "$lintErrors" -gt "0" ]; then 
                                     echo "Errors have been found, please see below" 
                                     cat hadolint_lint.txt 
                                     exit 1 
                                 else 
                                     echo "There are no erros found on Dockerfile!!" 
                                 fi 
                             ''' 
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
         stage('Remove Unused Docker Image') { 
            steps{ 
              sh "docker rmi $registry:$BUILD_NUMBER" 
            } 
          } 
           stage('Deploying to AWS') {
              steps{
                  echo 'Deploying to AWS!'
                  withAWS(credentials: '526933929369', region: 'us-east-2') {
                      sh "aws eks --region us-east-2 update-kubeconfig --name capstone2"
                      sh "kubectl config use-context arn:aws:eks:us-east-2:526933929369:cluster/capstone2"
                      sh "kubectl apply -f deployment/deployment.yml"
                      sh "kubectl apply -f deployment/deployment-service.yml"  
                      sh "kubectl get nodes"
                      sh "kubectl get deployment"
                      sh "kubectl get pod -o wide"
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
