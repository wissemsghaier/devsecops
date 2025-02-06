pipeline {
  agent any
  environment {
        dockerImage = "wissem200/devsecops:v3.0.0"
        JAVA_HOME = '/usr/lib/jvm/java-8-openjdk-amd64' // Spécifier le JAVA_HOME sur l'agent
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }
  tools {
        jdk 'jdk8'  // Utilise la configuration JDK 'jdk8' dans Jenkins
        maven 'M3'  // Assurez-vous d'avoir Maven configuré dans Jenkins sous 'M3' ou une version que vous préférez
  }
  stages {
      stage('check version ') {
            steps {
              sh "java --version "
              sh " mvn --version"
            }
      }

      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }

        


        stage('Unit Tests - JUnit and Jacoco') {
          steps {
            sh "mvn test"
          }
          // post {
          //   always {
          //     junit 'target/surefire-reports/*.xml'
          //     jacoco execPattern: 'target/jacoco.exec'
          //   }
          // }
        }

        stage('Mutation Tests - PIT') {
          steps {
            sh "mvn org.pitest:pitest-maven:mutationCoverage"
          }
          post {
            always {
              pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            }
          }  
        } 


        stage('SonarQube - SAST') {
          steps {
            withSonarQubeEnv('SonarQube') {
              sh '''
                mvn clean verify sonar:sonar \
                -Dsonar.projectKey=test \
                -Dsonar.projectName='test' \
            
               '''
            }
            timeout(time: 2, unit: 'MINUTES') {
              script {
                waitForQualityGate abortPipeline: true
              }   
            }
          }
          
        }
        // stage('Vulnerability Scan - dependency ') {
        //   steps {
        //     sh "mvn dependency-check:check"
        //   }
        //   // post {
        //   //   always {
        //   //     dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        //   //   }
        //   // }
          
        // }


        stage('Vulnerability Scan - Docker') {
          steps {
            script {
            //   def imageName = "wissem200/devsecops:v1.0.0"
            
            // // Build Docker image from Dockerfile
            //     sh "docker build -t ${imageName} ."
            
                parallel(
                  "Dependency Scan": {
                    sh "mvn dependency-check:check"
                  },
                  "Trivy Scan": {
                    sh "bash trivy-docker-image-scan.sh"
                }
              )
            }
          }   
          post {
            always {
              archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
            }
          }
        }





          stage('Build & Push Docker Image') {
            steps {
              script {
                def dockerImage = "wissem200/devsecops:v3.0.0"  // Remplace avec ton nom d'image
                def dockerCredentials = "dockerhub"    // ID des credentials Jenkins

                // Connexion à Docker Hub
                withDockerRegistry([credentialsId: dockerCredentials, url: '']) {
                  sh "docker build -t ${dockerImage} ."
                  sh "docker push ${dockerImage}"
                }
              }
            }
          }
          stage('Vulnerability Scan - Trivy') {
            steps {
                script {
                    def dockerImage = "wissem200/devsecops:v3.0.0"
                    def exitCode = sh(script: "trivy image --exit-code 1 --severity CRITICAL --light ${dockerImage}", returnStatus: true)
                    if (exitCode != 0) {
                        error "❌ Des vulnérabilités CRITICAL ont été trouvées !"
                    } else {
                        echo "✅ Aucune vulnérabilité CRITICAL détectée."
                    }
                }
            }
            post {
                always {
                    sh 'trivy image --format json --output trivy-rapport.json ${dockerImage}'
                    archiveArtifacts artifacts: 'trivy-rapport.json', allowEmptyArchive: true
                }
            }
          }


        // stage('Kubernetes Deployment - DEV') {
        //   steps {
        //     script {
        //       def dockerImage = "wissem200/devsecops:v1.0.0"

        //       withKubeConfig([credentialsId: 'kube-config']) {
        //         sh """
        //             sed -i 's#image: replace#image: ${dockerImage}#g' k8s_deployment_service.yaml
        //             kubectl apply -f k8s_deployment_service.yaml
        //         """
        //       }
        //     }
        //   }
        // }



    }
    post {
      always {
        junit 'target/surefire-reports/*.xml'
        jacoco execPattern: 'target/jacoco.exec'
        
        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'

        
        
      }
    }
}