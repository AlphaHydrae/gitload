require 'helper'

RSpec.describe Gitload::RepoChain do
  let(:config){ double }
  let(:options){ {} }

  let :repos do
    [
      double(name: 'UltraAccounting', owner: 'Peter', source: :github, fork?: false),
      double(name: 'AccountingUltra', owner: 'Peter', source: :bitbucket, fork?: true),
      double(name: 'Superman3virus', owner: 'Michael', source: :github, fork?: false),
      double(name: 'PrinterDriver', owner: 'Samir', source: :gitlab, fork?: true)
    ]
  end

  subject{ described_class.new config, repos.dup }

  it "should hold a list of repos" do
    expect(subject.repos).to eq(repos)
  end

  describe "#<<" do
    it "should add a repo" do
      new_repo = double
      subject << new_repo
      expect(subject.repos).to eq(repos + [ new_repo ])
    end
  end

  describe "#add" do
    it "should add repos" do
      new_repos = [ double, double ]
      subject.add new_repos
      expect(subject.repos).to eq(repos + new_repos)
    end
  end

  describe "#by" do
    it "should return a new chain with only repos by the specified owner" do
      expect_new_chain subject.by('Peter'), repos[0, 2]
    end

    it "should return a new chain with only repos by any of the specified owners" do
      expect_new_chain subject.by('Peter', 'Samir'), [ repos[0], repos[1], repos[3] ]
    end
  end

  describe "#on" do
    it "should return a new chain with only repos from the specified source" do
      expect_new_chain subject.from(:github), [ repos[0], repos[2] ]
    end

    it "should return a new chain with only repos from any of the specified sources" do
      expect_new_chain subject.from(:bitbucket, :gitlab), [ repos[1], repos[3] ]
    end
  end

  describe "#named" do
    it "should return a new chain with only the repo with the specified name" do
      expect_new_chain subject.named('PrinterDriver'), [ repos[3] ]
    end

    it "should return a new chain with only the repo with the specified case-insensitive name" do
      expect_new_chain subject.named('printerdriver'), [ repos[3] ]
    end

    it "should return a new chain with only repos matching the specified regexp" do
      expect_new_chain subject.named(/er/), repos[2, 2]
    end

    it "should return a new chain with only repos matching any of the specified criteria" do
      expect_new_chain subject.named(/ultra/i, 'PrinterDriver'), [ repos[0], repos[1], repos[3] ]
    end
  end

  describe "#forks" do
    it "should return a new chain with only repos that are forks" do
      expect_new_chain subject.forks, [ repos[1], repos[3] ]
    end
  end

  def expect_new_chain chain, repos
    expect(chain).to be_a(Gitload::RepoChain)
    expect(chain).not_to be(subject)
    expect(chain.repos).to eq(repos)
  end
end
