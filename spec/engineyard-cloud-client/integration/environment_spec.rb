require 'spec_helper'

describe EY::CloudClient::Environment do
  before(:each) do
    FakeWeb.allow_net_connect = true
    EY::CloudClient.endpoint = EY::CloudClient::Test::FakeAwsm.uri
  end

  subject do
    api = scenario_cloud_client "Linked App"
    result = EY::CloudClient::Environment.resolve(api, 'account_name' => 'main', 'app_name' => 'rails232app', 'environment_name' => 'giblets')
    result.matches.first
  end

  describe ".all" do
    it "finds all the environments" do
      api = scenario_cloud_client "One App Many Envs"
      envs = EY::CloudClient::Environment.all(api)
      envs.size.should == 3
      envs.map(&:name).should =~ %w[giblets bakon beef]
      envs.map(&:username).should =~ %w[turkey ham hamburger]
      envs.map(&:account_name).uniq.should == ['main']
      with_instances = envs.select {|env| env.instances_count > 0 }
      with_instances.size.should == 1
      with_instances.first.instances.map(&:amazon_id).should == ['i-ddbbdd92']
    end

    it "includes apps in environments" do
      api = scenario_cloud_client "One App Many Envs"
      envs = api.environments
      envs.map do |env|
        env.apps.first && env.apps.first.name
      end.should == ['rails232app', 'rails232app', nil] # 2 envs with the same app, 1 without
    end
  end

  describe ".resolve" do
    it "finds an environment" do
      api = scenario_cloud_client "Multiple Ambiguous Accounts"
      result = api.resolve_environments('environment_name' => 'giblets', 'account_name' => 'main' )
      result.should be_one_match
    end

    it "returns multiple matches with ambiguous query" do
      api = scenario_cloud_client "Multiple Ambiguous Accounts"
      result = EY::CloudClient::Environment.resolve(api, 'environment_name' => 'giblets' )
      result.should be_many_matches
    end

    it "parses errors when there are no matches" do
      api = scenario_cloud_client "Multiple Ambiguous Accounts"
      result = EY::CloudClient::Environment.resolve(api, 'environment_name' => 'notfound' )
      result.should be_no_matches
      result.errors.should_not be_empty
    end

    it "parses errors and suggestions when there are ambiguous matches" do
      api = scenario_cloud_client "Unlinked App"
      result = EY::CloudClient::Environment.resolve(api, 'app_name' => 'rails232app', 'environment_name' => 'giblets' )
      result.should be_no_matches
      result.errors.should_not be_empty
      result.suggestions.should_not be_empty
    end
  end

  context "with instances" do
    # main subject has instances

    it "requests instances when needed" do
      subject.bridge.role.should == 'app_master'
      subject.instances.size.should == subject.instances_count
    end

    it "adds a new instance" do
      instances_count = subject.instances_count
      begin
        instance = subject.add_instance({
          'role' => 'util',
          'name' => 'SirDigbyChickenCeasar',
          'size' => 'small',
          'volume_size' => '5',
        })
        subject.instances_count.should == (instances_count + 1)
        instance.role.should == 'util'
        instance.name.should == 'SirDigbyChickenCeasar'
        instance.status.should == 'starting'
      ensure
        instance.terminate if instance
      end
    end

    it "selects deploy_to_instances" do
      subject.deploy_to_instances.map(&:role).should =~ %w[app_master app util util]
    end

    it "updates the environment" do
      subject.update.should be_true
    end

    it "runs custom recipes" do
      subject.run_custom_recipes.should be_true
    end
  end

  context "without instances" do
    subject do
      api = scenario_cloud_client "Linked App Not Running"
      result = EY::CloudClient::Environment.resolve(api, 'account_name' => 'main', 'app_name' => 'rails232app', 'environment_name' => 'giblets')
      result.matches.first
    end

    it "doesn't request instances when instances_count is zero" do
      subject.instances_count.should == 0
      subject.instances.should == []
    end

    it "fails when you try to add an instance" do
      lambda {
        subject.add_instance({
          'role' => 'util',
          'name' => 'sirdigbychickenceasar',
        })
      }.should raise_error
    end
  end

  context "recipes" do
    it "uploads recipes" do
      res = subject.upload_recipes(Pathname.new('spec/support/fixture_recipes.tgz').expand_path.open('rb'))
      res.should be_true
    end

    it "uploads recipes at path" do
      res = subject.upload_recipes_at_path(Pathname.new('spec/support/fixture_recipes.tgz').expand_path.to_s)
      res.should be_true
    end

    it "raises if upload recipes path doesn't exist" do
      path = Pathname.new('spec/support/nothing')
      lambda {
        subject.upload_recipes_at_path(path)
      }.should raise_error(EY::CloudClient::Error, "Recipes file not found: #{path}")
    end

    it "downloads recipes" do
      subject.download_recipes
    end
  end


  context "logs" do
    it "returns logs" do
      log = subject.logs.first
      log.main.should == 'MAIN LOG OUTPUT'
      log.custom.should == 'CUSTOM LOG OUTPUT'
      log.role.should == 'app_master'
      log.instance_name.should == "app_master i-12345678"
    end
  end

end
