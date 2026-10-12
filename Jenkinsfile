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
        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }
        stage('Create or Select Terraform Workspace') {
            steps {
                sh """
                terraform workspace list | grep -qw '${params.env}' || terraform workspace new '${params.env}'
                terraform workspace select '${params.env}'
                """
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -input=false -var-file='${params.env}.tfvars' -out=tfplan"
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
                sh 'terraform apply -input=false tfplan'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished (success, failure, or aborted).'
            sh 'rm -f tfplan'
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
\${BUILD_LOG, maxLines=10, escapeHtml=false}
"""
            )
        }
        

        aborted {
            echo 'Pipeline was aborted!'
        }
    }
}
