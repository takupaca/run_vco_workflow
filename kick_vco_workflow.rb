#!/usr/local/bin/ruby
#
#    Usage: ruby kick_vco_workflow.rb {options}
#    -w, --workflow VALUE             Workflow Name
#    -u, --username VALUE             vCO User Name
#    -p, --password VALUE             Password
#    -h, --host VALUE                 vCO Host
#

require 'optparse'
username = "vcoadmin"
password = "vcoadmin"
vcohost = "172.20.1.7"
workflowname = ""

# specify the INPUT parameters if you need
parameters = <<"EOS"
<parameter name=\"vmname\" type=\"string\">
	<string>vmname</string>
</parameter>
<parameter name=\"vmnum\" type=\"number\">
	<number>5</number>
</parameter>
EOS

script_name = File.basename($0)
banner = "Usage: ruby #{script_name} {options}"
opt = OptionParser.new(banner)
opt.on('-w VALUE','--workflow VALUE','Workflow Name'){|v|
	workflowname = v
}
opt.on('-u VALUE','--username VALUE','vCO User Name'){|v|
	username = v
}
opt.on('-p VALUE','--password VALUE','Password'){|v|
	username = v
}
opt.on('-h VALUE','--host VALUE','vCO Host'){|v|
	vcohost = v
}
opt.parse!(ARGV)


class VcoWorkflow
	require 'rest-client'
	require 'uri'
	require 'json'
	attr_accessor :username,:password,:vcohost

	def initialize(username,password,vcohost)
		@username = username
		@password = password
		@vcohost = vcohost
	end
	
	def getWorkflowId(workflowname)
		uri = 'https://' + @username + ':' + @password + "@" + @vcohost + ':8281/api/workflows?conditions=name=' + URI.encode(workflowname)
		response = JSON.parse(RestClient.get uri, {:accept => :json})
		id = response["link"][0]["attributes"][1]["value"]
		return id
	end
	
	def executeWorkflow(id,parameters)
		uri = 'https://' + @username + ':' + @password + "@" + @vcohost + ':8281/api/workflows/' + id + '/executions/'
		xml = "<execution-context xmlns=\"http://www.vmware.com/vco\"><parameters>#{parameters}</parameters></execution-context>"
		RestClient.post(uri, xml, {:content_type => :xml}){ |response, request, result, &block|
			if [301, 302, 307].include? response.code
				response.follow_redirection(request, result, &block)
			else
				response.return!(request, result, &block)
			end
		}
	end
end

vco = VcoWorkflow.new(username,password,vcohost)
workflowid = vco.getWorkflowId(workflowname)
result = vco.executeWorkflow(workflowid,parameters)