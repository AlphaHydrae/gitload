require 'helper'

RSpec.describe Gitload::Repo do
  let(:source){ :github }
  let(:api_data){ { foo: 'bar' } }
  subject{ described_class.new source, api_data }

  it "should store its source and API data when constructed" do
    expect(subject.source).to eq(source)
    expect(subject.api_data).to eq(api_data)
  end

  %i(source api_data name fork owner owner_type).each do |attr|
    it "should have an attr accessor for #{attr}" do
      expect(subject.send(attr)).not_to eq('foo')
      subject.send "#{attr}=", 'foo'
      expect(subject.send(attr)).to eq('foo')
    end
  end

  describe "#fork?" do
    it "should indicate whether the repo is a fork" do
      expect(subject.fork?).to be(false)
      subject.fork = true
      expect(subject.fork?).to be(true)
    end
  end

  describe "#clone_url" do
    it "should return nil by default" do
      expect(subject.clone_url).to be_nil
    end

    it "should return the :http URL by default" do
      subject.clone_urls[:ssh] = 'ssh://user@host:repo.git'
      subject.clone_urls[:http] = 'https://example.com/repo.git'
      expect(subject.clone_url).to eq('https://example.com/repo.git')
    end

    it "should return the specified URL" do
      subject.clone_urls[:ssh] = 'ssh://user@host:repo.git'
      subject.clone_urls[:http] = 'https://example.com/repo.git'
      expect(subject.clone_url(:ssh)).to eq('ssh://user@host:repo.git')
    end
  end

  describe "#clone_to" do
    let(:dest){ '/path/to/repo' }
    let(:executed_commands){ [] }
    let(:printed_lines){ [] }
    let(:http_clone_url){ 'https://example.com/repo.git' }
    let(:ssh_clone_url){ 'ssh://user@host:repo.git' }

    before :each do
      subject.clone_urls[:http] = http_clone_url
      subject.clone_urls[:ssh] = ssh_clone_url
      allow(Gitload::CommandLine).to receive(:execute){ |*args| executed_commands << args }
      allow(Gitload::CommandLine).to receive(:print){ |*args| printed_lines << args }
    end

    it "should clone the repo" do
      mock_file_exists dest, false
      subject.clone_to dest
      expect_executed_command :git, :clone, http_clone_url, dest
    end

    it "should clone the repo with the specified URL" do
      mock_file_exists dest, false
      subject.clone_to dest, clone_url_type: :ssh
      expect_executed_command :git, :clone, ssh_clone_url, dest
    end

    it "mark the repo as cloned" do
      mock_file_exists dest, false
      expect(subject.cloned?).to be(false)
      subject.clone_to dest
      expect(subject.cloned?).to be(true)
    end

    it "should print the clone command with the :dry_run option" do
      mock_file_exists dest, false
      subject.clone_to dest, dry_run: true
      expect_printed_command :git, :clone, http_clone_url, dest
    end

    it "should not clone an already cloned repo by default" do
      mock_file_exists dest, false
      subject.cloned = true
      expect_no_command_executed
      subject.clone_to dest
    end

    it "should clone an already cloned repo with the :force option" do
      mock_file_exists dest, false
      subject.cloned = true
      subject.clone_to dest, force: true
      expect_executed_command :git, :clone, http_clone_url, dest
    end

    it "should not clone a repo if the target directory already exists" do
      mock_file_exists dest, true
      expect_no_command_executed
      subject.clone_to dest
      expect_printed_lines([
        [ "#{dest} already exists", color: :green ]
      ])
    end

    def mock_file_exists file, exists
      allow(File).to receive(:exists?).and_return(exists)
    end

    def expect_executed_command *args
      expect(executed_commands).to have(1).item
      expect(executed_commands.first).to eq([ args ])
    end

    def expect_no_command_executed
      expect(Gitload::CommandLine).not_to receive(:execute)
    end

    def expect_printed_command *args
      expect_printed_lines([
        [ Gitload::CommandLine.escape(args), color: :yellow ]
      ])
    end

    def expect_printed_lines lines
      expect(printed_lines).to have(lines.length).items
      expect(printed_lines).to eq(lines)
    end
  end
end
