run_vco_workflow
================

A simple REST client for vCenter Orchestrator. Run the workflow with INPUT parameters.
You need rest-client https://github.com/rest-client/rest-client.

Usage is following. Also you can specify those parameters in ruby script.

Usage: ruby kick_vco_workflow.rb {options}
    -w, --workflow VALUE             Workflow Name
    -u, --username VALUE             vCO User Name
    -p, --password VALUE             Password
    -h, --host VALUE                 vCO Host
