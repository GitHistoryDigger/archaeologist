#!/usr/bin/env ruby -wKU

require 'json/ext'

require_relative "../lib/analyzer"
require_relative "../lib/repowalker"

describe "Single Branch" do
  describe "With Email" do
    before :example do
      walker = RepoWalker.new(File.join(
        File.dirname(__FILE__), "repos", "singlebranch"
      ), "testing@githistorydigger.com")
      @commits = []
      walker.each { |c, lang|
        @commits << [c, lang]
      }
    end
    it "Should be 6 add and 6 del with python code" do
      results = JSON.parse(@commits.map { |el|
        c = el[0]
        lang = el[1]
        a = GitStatLangAnalyser.new(c, lang)
        ar = a.analyze()
        { 'oid': c.oid, 'languages': ar, 'time': c.time }
      }.to_json())
      expect(results).to eql JSON.parse([
        {
          "oid": 'cddcaa40e9e160c7aec09bc79d2c2d25c3e6bb88',
          "languages": { "Python": { "add": 6, "del": 6 } },
          "time": "2019-01-15 10:34:59 +0900"
        }
      ].to_json())
    end
  end
  describe "Without Email" do
    before :example do
      walker = RepoWalker.new(
        File.join(File.dirname(__FILE__), "repos", "singlebranch"), nil
      )
      @commits = []
      walker.each { |c, lang|
        @commits << [c, lang]
      }
    end
    it "Should analyze all commits" do
      results = JSON.parse(@commits.map { |el|
        c = el[0]
        lang = el[1]
        a = GitStatLangAnalyser.new(c, lang)
        ar = a.analyze()
        { 'oid': c.oid, 'languages': ar, 'time': c.time }
      }.to_json())
      expect(results).to match_array JSON.parse([
        {
          "oid": "0c7377bff42588dbb596b65bfba91977f41eb5c9",
          "languages": { "Python": { "add": 22, "del": 0 } },
          "time": "2019-01-15 09:34:02 +0900"
        },
        {
          "oid": "ce2672b453c35b76b37c3beeac6b7308097a83be",
          "languages": { "Python": { "add": 34, "del": 1 } },
          "time": "2019-01-15 09:46:32 +0900"
        },
        {
          "oid": "a6617fec33cd3bba4e243b467c29596c28331953",
          "languages": { "Python": { "add": 4, "del": 11 } },
          "time": "2019-01-15 09:46:55 +0900"
        },
        {
          "oid": 'cddcaa40e9e160c7aec09bc79d2c2d25c3e6bb88',
          "languages": { "Python": { "add": 6, "del": 6 } },
          "time": "2019-01-15 10:34:59 +0900"
        },
        {
          "oid"=>"9eb9d80f358538df8c43eb986b3c7b7047be8756",
          "languages": {},
          "time": "2019-01-15 19:25:35 +0900"
        }
      ].to_json)
    end
  end
end
