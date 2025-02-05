pipeline {
  agent any

  stages {
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
          post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
            }
          }
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
            sh '''
                mvn clean verify sonar:sonar \
                -Dsonar.projectKey=test \
                -Dsonar.projectName='test' \
                -Dsonar.host.url=http://localhost:9001 \
                -Dsonar.token=sqp_ad7728601464bf0dab9614b6a217a237efca61b3
               '''
          }
        }


        // stage('Build & Push Docker Image') {
        //   steps {
        //     script {
        //       def dockerImage = "wissem200/devsecops:v1.0.0"  // Remplace avec ton nom d'image
        //       def dockerCredentials = "dockerhub"    // ID des credentials Jenkins

        //     // Connexion à Docker Hub
        //       withDockerRegistry([credentialsId: dockerCredentials, url: '']) {
        //         sh "docker build -t ${dockerImage} ."
        //         sh "docker push ${dockerImage}"
        //       }
        //     }
        //   }
        // }


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
}