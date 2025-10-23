pipeline {
  agent any
  options { timestamps() }

  parameters {
    string(name: 'PYPI_URL', description: 'Optional custom PyPI/simple index URL')
    string(name: 'DEV_DIR',  defaultValue: '/devlopment', description: 'Destination directory (absolute or relative)')
    // string(name: 'NEXUS_DOCKER_URL', description: 'Nexus docker URL.')
    string(name: 'NEXUS_CREDS_ID', description: 'Jenkins credentialsId (username+password). Leave empty to use params below.')
    string(name: 'NEXUS_USER', description: 'Only used if NEXUS_CREDS_ID is empty')
    password(name: 'NEXUS_PASS', description: 'Only used if NEXUS_CREDS_ID is empty')
    string(name: 'BUILD_NUMBER', description: 'Airflow Image')
    
  }

  environment {
    VENV_DIR     = '.venv'
    PYPI         = "${params.PYPI_URL}"
    DEV_DIR_RAW  = "${params.DEV_DIR}"
    // NEXUS_DOCKER_URL = "${params.NEXUS_DOCKER_URL}"
    BUILD_NUMBER = "${params.BUILD_NUMBER}"
  }

  stages {

    stage('Checkout') {
      steps {
        script {
          echo "Cleaning and preparing workspace..."
          cleanWs()
          checkout scm
          echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
          echo "Workspace: ${env.WORKSPACE}"
        }
      }
    }

    stage('Prepare') {
      steps {
        script {
          // Normalize DEV_DIR for current agent OS
          env.DEV_DIR = isUnix()
            ? env.DEV_DIR_RAW.replace('\\', '/')
            : env.DEV_DIR_RAW.replace('/', '\\')

          // Use Jenkins credentials if provided, else fall back to params
     
          def prep = {
            if (isUnix()) {
              sh '''
              set -euo pipefail
              set -euo pipefail
              printf "%s" "${NEXUS_USER}" > "./nexus_user"
              printf "%s" "${NEXUS_PASS}" > "./nexus_pass"
              curl -fsSL -o "./requirements.txt" \
                  "https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt"

              '''
            } else {
              bat '''
              echo %NEXUS_USER% > ".\nexus_user"
              echo %NEXUS_PASS% > ".\nexus_pass"
              curl -L -o ".\requirements.txt" ^
                  https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt

              '''
            }

          if (params.NEXUS_CREDS_ID?.trim()) {
              withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
              prep()
              }
          } else {
              withEnv(["NEXUS_USER=${params.NEXUS_USER}", "NEXUS_PASS=${params.NEXUS_PASS}"]) {
              prep()
              }
          }

          
        }
      }
    }

    stage('Build up services') {
      steps {
        script {

          def shell = { String cmd ->
            if (isUnix()) {
              sh(script: cmd)
            } else {
              bat(script: cmd)
            }
          }

          shell('''
          docker compose version
          docker compose up -d
          ''')
   
        }
      }
    }
  }
}

  post {
    always {
      // Optional: keep logs/artifacts if you want
      echo "DEV_DIR resolved to: ${env.DEV_DIR}"
    }
  }
}
