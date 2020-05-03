#!groovy
import groovy.json.JsonSlurperClassic

node {

    def SFDC_USERNAME

    def HUB_ORG=env.HUB_ORG_DH
    def SFDC_HOST = env.SFDC_HOST_DH
    def JWT_KEY_CRED_ID = env.JWT_CRED_ID_DH
    def CONNECTED_APP_CONSUMER_KEY=env.CONNECTED_APP_CONSUMER_KEY_DH
    def OPNSSL=env.OPENSSL
    def SFDXHOME =env.SFDX_HOME
    
    println HUB_ORG
    println SFDC_HOST
    println JWT_KEY_CRED_ID
    println CONNECTED_APP_CONSUMER_KEY
    println SFDXHOME
    println OPNSSL
    
    def toolbelt = tool 'SFDX'
    def toolbelt1 = tool 'SSL'
	
	def props = readProperties file:'pipeline.properties';
	
	def sourceOrgUserName = props['sourceOrgUserName'];
	def sourceOrgSecretId = props['sourceOrgSecretId'];
	def sourceOrgLoginUrl = props['sourceOrgLoginUrl'];
	
	  
    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }
	
    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
	
        stage('Authorize Org') {
            
			env.SFDX_AUDIENCE_URL= sourceOrgLoginUrl
			
			println "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${sourceOrgSecretId} --username ${sourceOrgUserName} --jwtkeyfile ${toolbelt1}/server.key  --instanceurl https://login.salesforce.com"
			
            rc = sh returnStdout: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --json --clientid ${sourceOrgSecretId} --username ${sourceOrgUserName} --jwtkeyfile ${toolbelt1}/server.key  --setdefaultdevhubusername --instanceurl ${sourceOrgLoginUrl}"
			
			println rc
			def jsonSlurper = new JsonSlurperClassic()
			def robj = jsonSlurper.parseText(rc)

            if (robj.status != 0) {
                error 'hub org authorization failed' 
            }else {
                println 'Org authorization is successful for' + robj.result.orgId
				devhubOrdId = robj.result.orgId
            }
        }
		
		stage('Deploy Code') {
		
			println "${toolbelt}/sfdx force:mdapi:deploy --wait 10 -d ${DEPLOYDIR} -u ${sourceOrgUserName}"
			
            rc = sh returnStdout: true, script: "${toolbelt}/sfdx force:mdapi:deploy --wait 10 -d ${DEPLOYDIR} -u ${sourceOrgUserName}"
		    
			println rc
			def jsonSlurper = new JsonSlurperClassic()
			def robj = jsonSlurper.parseText(rc)

            if (robj.status != 0) {
                error 'Salesforce deployment failed.'
            }else {
                error 'Salesforce deployment is successful.'
            }
			
        }
		 
    }
}