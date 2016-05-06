util = require 'util'
cson = require 'cson'
ec2 = require('../../ec2.coffee')

restrictor =

  ensureFilters: (params) ->
    if not params['Filters']
      params['Filters'] = []
    return params

  addInstanceFilter: (msg, params, instances) ->
    params = restrictor.ensureFilters(params)
    params['Filters'].push {Name: 'instance-id', Values: instances}
    return params

  addSubnetFilter: (msg, params) ->
    params = restrictor.ensureFilters(params)
    config = cson.parseCSONFile process.env.HUBOT_AWS_EC2_RUN_CONFIG
    validSubnet = config["NetworkInterfaces"][0]["SubnetId"]
    params['Filters'].push {Name: 'subnet-id', Values: [validSubnet]}
    return params

  addUserCreatedFilter: (msg, params) ->
    params = restrictor.ensureFilters(params)
    email = msg.message.user["email_address"] || process.env.HUBOT_AWS_DEFAULT_CREATOR_EMAIL
    params['Filters'].push {Name: 'tag:Creator', Values:[email]}
    return params


  authorizeOperation: (msg, params, instances, cb) ->

    console.log "Inspecting instance [#{instances}] for permission to run this operation"

    params = restrictor.addInstanceFilter msg, params, instances
    params = restrictor.addSubnetFilter msg, params
    console.log util.inspect(params, false, null)

    # params is a bus for all args passed to the command, so we need to strip out all but the valid ec2 filters we're sending
    ec2Params = {Filters: params['Filters']}
    ec2.describeInstances ec2Params, (err, res) ->
        if err
          cb(err)
        else
          if res.Reservations.length == instances.length
            cb(null)
          else
            cb("Operation not permitted. Instance #{instances} does not exist in the approved subnet or wasn't created by you")

module.exports = restrictor
