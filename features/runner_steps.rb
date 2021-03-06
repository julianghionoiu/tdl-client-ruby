require 'fileutils'

require_relative './runner/wiremock_process'
require_relative './runner/test_audit_stream'
require_relative './runner/noisy_implementation_runner'
require_relative './runner/quiet_implementation_runner'

audit_stream = TestAuditStream.new
implementation_runner = QuietImplementationRunner.new
working_directory = './'

Given(/^There is a challenge server running on "([^"]*)" port (\d+)$/) do |hostname, port|
  @challenge_hostname = hostname
  @port = port

  @challenge_server_stub = WiremockProcess.new(hostname, port)
  @challenge_server_stub.reset
end

Given(/^There is a recording server running on "([^"]*)" port (\d+)$/) do |hostname, port|
  @recording_server_stub = WiremockProcess.new(hostname, port)
  @recording_server_stub.reset
end

Given(/^the challenge server exposes the following endpoints$/) do |table|
  table.hashes.each do |config|
    @challenge_server_stub.create_new_mapping(config)
  end
end

Given(/^the recording server exposes the following endpoints$/) do |table|
  table.hashes.each do |config|
    @recording_server_stub.create_new_mapping(config)
  end
end

Given(/^the challenge server returns (\d+) for all requests$/) do |return_code|
  #HACK to get the unirest ruby client to NOT follow the redirect
  (return_code.to_i.equal? 301) ? _return_code = 306 : _return_code = return_code

  puts ">>>>>>>>>#{_return_code},#{return_code}"
  @challenge_server_stub.create_new_mapping({
    endpointMatches: '^(.*)',
    status: _return_code,
    verb: 'ANY'
  })
end

Given(/^the challenge server returns (\d+), response body "([^"]*)" for all requests$/) do |return_code, body|
  @challenge_server_stub.create_new_mapping({
    endpointMatches: '^(.*)',
    status: return_code,
    verb: 'ANY',
    responseBody: body
  })
end

Given(/^the challenges folder is empty$/) do
  FileUtils.rm_rf(Dir.glob('challenges/*'))
end

Given(/^the action input comes from a provider returning "([^"]*)"$/) do |s|
  @action_provider_callback = ->() {s}
end

Given(/^there is an implementation runner that prints "([^"]*)"$/) do |s|
  @implementation_runner_message = s
  implementation_runner = NoisyImplementationRunner.new(s, audit_stream)
end

Given(/^recording server is returning error/) do
  @recording_server_stub.reset
end

Given(/^journeyId is "([^"]*)"$/) do |journey_id|
  @journey_id = journey_id
end

Given(/^the challenge server is broken$/) do
  @challenge_server_stub.reset
end

When(/^user starts client$/) do
  audit_stream.clear

  config = TDL::ChallengeSessionConfig.for_journey_id(@journey_id)
    .with_server_hostname(@challenge_hostname)
    .with_port(@port)
    .with_colours(true)
    .with_audit_stream(audit_stream)
    .with_recording_system_should_be_on(true)
    .with_working_directory(working_directory)

  TDL::ChallengeSession.for_runner(implementation_runner)
    .with_config(config)
    .with_action_provider(@action_provider_callback)
    .start
end

Then(/^the server interaction should contain the following lines:$/) do |expected_output|
  total = audit_stream.get_log.strip
  lines = expected_output.split("\n")
  lines.each do |line|
    line = line.strip
    unless line.empty?
      assert total.include?(line), 'Expected string is not contained in output'
    end
  end
end

Then(/^the server interaction should look like:$$/) do |expected_output|
  total = audit_stream.get_log.strip
  assert_equal total, expected_output.strip.gsub(/\r/,''), 'Expected string is not contained in output'
end

Then(/^the recording system should be notified with "([^"]*)"$/) do |expected_output|
  audit_stream.get_log
  assert @recording_server_stub.verify_endpoint_was_hit('/notify', 'POST', expected_output)
end

Then(/^the recording system should have received a stop signal$/) do
  audit_stream.get_log
  assert @recording_server_stub.verify_endpoint_was_hit('/stop', 'POST', "")
end

Then(/^the file "([^"]*)" should contain$/) do |file, text|
  content = File.read(file)
  assert_equal content.strip, text.strip.gsub(/\r/,''), 'Contents of the file is not what is expected'
end

Then(/^the implementation runner should be run with the provided implementations$/) do
  total = audit_stream.get_log
  assert total.include?(@implementation_runner_message)
end

Then(/^the client should not ask the user for input$/) do
  total = audit_stream.get_log
  assert !total.include?('Selected action is:')
end
