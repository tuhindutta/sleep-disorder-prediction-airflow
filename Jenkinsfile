pipeline {
  agent any
  options { timestamps() }

  parameters {
    string(name: 'PYPI_URL', defaultValue: '', description: 'Optional custom PyPI/simple index URL')
    string(name: 'DEV_DIR',  defaultValue: 'dev', description: 'Destination directory (absolute or relative)')
    string(name: 'NEXUS_CREDS_ID', defaultValue: '', description: 'Jenkins credentialsId (username+password). Leave empty to use params below.')
    string(name: 'NEXUS_USER', defaultValue: '', description: 'Only used if NEXUS_CREDS_ID is empty')
    password(name: 'NEXUS_PASS', defaultValue: '', description: 'Only used if NEXUS_CREDS_ID is empty')
  }

  environment {
    VENV_DIR     = '.venv'
    ARTIFACT_DIR = 'dist'
    PYPI         = "${params.PYPI_URL}"
    DEV_DIR_RAW  = "${params.DEV_DIR}"
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
          def doPrepare = {
            if (isUnix()) {
              sh '''
                set -euo pipefail
                mkdir -p "${DEV_DIR}"

                # write secrets without echoing quotes
                printf "%s" "${NEXUS_USER}" > "${DEV_DIR}/nexus_user"
                printf "%s" "${NEXUS_PASS}" > "${DEV_DIR}/nexus_pass"

                curl -fsSL -o "${DEV_DIR}/requirements.txt" \
                  "https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt"

                # recursive force copy of workspace contents to DEV_DIR
                cp -rf ./* "${DEV_DIR}"
              '''
            } else {
              bat '''
                if not exist "%DEV_DIR%" mkdir "%DEV_DIR%"

                > "%DEV_DIR%\\nexus_user" echo %NEXUS_USER%
                > "%DEV_DIR%\\nexus_pass" echo %NEXUS_PASS%

                curl -L -o "%DEV_DIR%\\requirements.txt" ^
                  https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt

                rem Robust recursive copy; treat RC 0–7 as success.
                robocopy . "%DEV_DIR%" /E /NFL /NDL /NJH /NJS /NP >NUL
                if %ERRORLEVEL% LEQ 7 (exit /b 0) else (exit /b %ERRORLEVEL%)
              '''
            }
          }

          if (params.NEXUS_CREDS_ID?.trim()) {
            withCredentials([usernamePassword(credentialsId: params.NEXUS_CREDS_ID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
              doPrepare()
            }
          } else {
            withEnv(["NEXUS_USER=${params.NEXUS_USER}", "NEXUS_PASS=${params.NEXUS_PASS}"]) {
              doPrepare()
            }
          }
        }
      }
    }

    stage('Build up services') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -euo pipefail
              cd "${DEV_DIR}"
              docker-compose up -d
            '''
          } else {
            bat '''
              cd /d "%DEV_DIR%"
              docker-compose up -d
            '''
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



// pipeline {
//   agent any
//   options { timestamps() }

//   environment {
//     VENV_DIR     = '.venv'
//     ARTIFACT_DIR = 'dist'
//     PYPI         = "${params.PYPI_URL}"
//     DEV_DIR      = "${params.DEV_DIR}"
//     NEXUS_USER   = "${params.NEXUS_USER}"
//     NEXUS_PASS   = "${params.NEXUS_PASS}"
//   }

//   stages {

//     stage('Checkout') {
//       steps {
//         script {
//           echo "Cleaning and preparing workspace..."
//           cleanWs()
//           checkout scm
//           echo "Branch: ${env.BRANCH_NAME ?: 'N/A'}"
//           echo "Workspace: ${env.WORKSPACE}"
//         }
//       }
//     }

//     stage('Prepare the environment') {
//         steps {
//             script {
//             if (isUnix()) {
//                 sh '''
//                 set -euo pipefail
//                 mkdir -p "${DEV_DIR}"

//                 printf "%s" "${NEXUS_USER}" > "${DEV_DIR}/nexus_user"
//                 printf "%s" "${NEXUS_PASS}" > "${DEV_DIR}/nexus_pass"

//                 curl -fsSL -o "${DEV_DIR}/requirements.txt" \
//                     "https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt"

//                 cp -rf ./* "${DEV_DIR}"
//                 '''
//             } else {
//                 bat '''
//                 if not exist "%DEV_DIR%" mkdir "%DEV_DIR%"

//                 > "%DEV_DIR%\\nexus_user" echo %NEXUS_USER%
//                 > "%DEV_DIR%\\nexus_pass" echo %NEXUS_PASS%

//                 curl -L -o "%DEV_DIR%\\requirements.txt" ^
//                     https://raw.githubusercontent.com/tuhindutta/sleep-disorder-prediction/main/requirements.txt

//                 robocopy . "%DEV_DIR%" /E /NFL /NDL /NJH /NJS /NP >NUL
//                 if %ERRORLEVEL% LEQ 7 (exit /b 0) else (exit /b %ERRORLEVEL%)
//                 '''
//             }
//             }
//         }
//         }


//     stage('Build') {
//       steps {
//         script {
//           if (isUnix()) {
//             sh """
//             cd "${DEV_DIR}"
//             docker-compose up -d
//             """
//           } else {
//             bat """
//             cd "${DEV_DIR}"
//             docker-compose up -d
//             """
//           }
//         }
//       }
//     }


//   }
// }