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

  describe "#clone_url" do
    it "should return nil by default" do
      expect(subject.clone_url).to be_nil
    end

    it "should return the :ssh URL by default" do
      subject.clone_urls[:ssh] = 'ssh://user@host:repo.git'
      subject.clone_urls[:http] = 'https://example.com/repo.git'
      expect(subject.clone_url).to eq('ssh://user@host:repo.git')
    end

    it "should return the specified URL" do
      subject.clone_urls[:ssh] = 'ssh://user@host:repo.git'
      subject.clone_urls[:http] = 'https://example.com/repo.git'
      expect(subject.clone_url(:http)).to eq('https://example.com/repo.git')
    end
  end

  describe "#clone_to" do
    let(:dest){ '/path/to/repo' }
    let(:executed_commands){ [] }
    let(:printed_lines){ [] }
    let(:clone_url){ 'ssh://user@host:repo.git' }

    before :each do
      subject.clone_urls[:ssh] = clone_url
      allow(Gitload::CommandLine).to receive(:execute){ |*args| executed_commands << args }
      allow(Gitload::CommandLine).to receive(:print){ |*args| printed_lines << args }
    end

    it "should clone the repo" do
      mock_file_exists dest, false
      subject.clone_to dest
      expect_executed_command :git, :clone, clone_url, dest
    end

    it "should print the clone command with the :dry_run option" do
      mock_file_exists dest, false
      subject.clone_to dest, dry_run: true
      expect_printed_lines([
        { message: Gitload::CommandLine.escape([ :git, :clone, clone_url, dest ]), color: :yellow }
      ])
    end

    def mock_file_exists file, exists
      allow(File).to receive(:exists?).and_return(false)
    end

    def expect_executed_command *args
      expect(executed_commands).to have(1).item
      expect(executed_commands.first).to eq([ args ])
    end

    def expect_printed_lines lines
      expect(printed_lines).to have(lines.length).items
    end
  end
end
