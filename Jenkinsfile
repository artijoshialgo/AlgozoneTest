#!groovy
import groovy.json.JsonSlurper

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
	def DEPLOYDIR = props['DEPLOYDIR'];
	  
    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
	def lastSuccessfulCommit = getLastSuccessfulCommit()
        def currentCommit = commitHashForBuild( currentBuild.rawBuild )
      if (lastSuccessfulCommit) {
	commits = sh(
	  script: "git rev-list $currentCommit \"^$lastSuccessfulCommit\"",
	  returnStdout: true
	).split('\n')
	println "Commits are: $commits"
      }
    }
	
    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
	
        stage('Authorize Org') {
            
			env.SFDX_AUDIENCE_URL= sourceOrgLoginUrl
			
			println "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${sourceOrgSecretId} --username ${sourceOrgUserName} --jwtkeyfile ${toolbelt1}/server.key  --instanceurl https://login.salesforce.com"
			
            rc = sh returnStdout: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --json --clientid ${sourceOrgSecretId} --username ${sourceOrgUserName} --jwtkeyfile ${toolbelt1}/server.key  --setdefaultdevhubusername --instanceurl ${sourceOrgLoginUrl}"
			
			println rc
			def jsonSlurper = new JsonSlurper()
			def robj = jsonSlurper.parseText(rc)

            if (robj.status != 0) {
                error 'hub org authorization failed' 
            }else {
                println 'Org authorization is successful for' + robj.result.orgId
				devhubOrdId = robj.result.orgId
            }
        }
		
		stage('Deploy Code') {
		
			println "${toolbelt}/sfdx force:mdapi:deploy --wait 10 --deploydir ${DEPLOYDIR} -u ${sourceOrgUserName}"
			
            rc = sh returnStdout: true, script: "${toolbelt}/sfdx force:source:deploy -w 10 -p ${DEPLOYDIR} -u ${sourceOrgUserName} --json"
		    
			println rc
			def jsonSlurper = new JsonSlurper()
			def robj = jsonSlurper.parseText(rc)

            if (robj.status != 0) {
                error 'Salesforce deployment failed.'
            }else {
                println 'Salesforce deployment is successful.'
            }
			
        }
		 
    }
}

def getLastSuccessfulCommit() {
  def lastSuccessfulHash = null
  def lastSuccessfulBuild = currentBuild.rawBuild.getPreviousSuccessfulBuild()
  if ( lastSuccessfulBuild ) {
    lastSuccessfulHash = commitHashForBuild( lastSuccessfulBuild )
  }
  return lastSuccessfulHash
}

/**
 * Gets the commit hash from a Jenkins build object, if any
 */
@NonCPS
def commitHashForBuild( build ) {
  def scmAction = build?.actions.find { action -> action instanceof jenkins.scm.api.SCMRevisionAction }
  return scmAction?.revision?.hash
}
