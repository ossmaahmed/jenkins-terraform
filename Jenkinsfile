pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    parameters {
        choice(
            name: 'env',
            choices: ['dev', 'stage', 'prod'],
            description: 'Choose the Terraform workspace and variables file'
        )
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'terraform init -input=false'
            }
        }

        stage('Select Terraform Workspace') {
            steps {
                bat "terraform workspace select ${params.env}"
            }
        }

        stage('Terraform Format') {
            steps {
                bat 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                bat 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                bat "terraform plan -input=false -var-file=${params.env}.tfvars -out=tfplan"
            }
        }

        stage('Approval') {
            steps {
                input(
                    message: "Terraform plan for ${params.env} is ready. Approve to continue to apply, or abort to stop.",
                    ok: 'Approve'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished (success, failure, or aborted).'
            bat 'if exist tfplan del /q tfplan'
        }

        success {
            echo 'Terraform plan and apply completed successfully.'
            emailext(
                to: 'o09204135@gmail.com',
                subject: "[Jenkins] SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """تم تنفيذ Terraform بنجاح.

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
Environment: ${params.env}
الرابط: ${env.BUILD_URL}
"""
            )
        }

        failure {
            emailext(
                to: 'o09204135@gmail.com',
                subject: "[Jenkins] FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """الـ Pipeline فشل.

Job: ${env.JOB_NAME}
Build: #${env.BUILD_NUMBER}
الرابط: ${env.BUILD_URL}

آخر 150 سطر من سجل البناء:
\${BUILD_LOG, maxLines=150, escapeHtml=false}
"""
            )
        }
        

        aborted {
            echo 'Pipeline was aborted!'
        }
    }
}
