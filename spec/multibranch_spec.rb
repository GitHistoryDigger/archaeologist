#!/usr/bin/env ruby -wKU

require_relative "../lib/archaeologist";

describe "Multi Branch" do
  describe "With Email" do
    before :example do
      walker = Archaeologist::RepoWalker.new(File.join(
        File.dirname(__FILE__), "repos", "multibranch"
      ), "5356011+hiroaki-yamamoto@users.noreply.github.com")
      @commits = []
      walker.each { |c, lang|
        @commits << [c, lang]
      }
    end
    it "Should have proper ruby and python changes" do
      results = JSON.parse(@commits.map { |el|
        c = el[0]
        lang = el[1]
        a = Archaeologist::GitStatLangAnalyser.new(c, lang)
        ar = a.analyze()
        { 'oid': c.oid, 'languages': ar, 'time': c.time.utc.to_i }
      }.to_json())
      expect(results).to eql JSON.parse([
        {
          "oid": '9fb8d2b9dac1d76c66f93e6f0da0a267f32e0f8d',
          "languages": {
            "Python": { "add": 0, "del": 48 },
            "Ruby": {"add": 172, "del": 0}
          },
          "time": 1547553220
        }
      ].to_json())
    end
  end
  describe "Without Email" do
    before :example do
      walker = Archaeologist::RepoWalker.new(
        File.join(File.dirname(__FILE__), "repos", "multibranch"), nil
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
        a = Archaeologist::GitStatLangAnalyser.new(c, lang)
        ar = a.analyze()
        { 'oid': c.oid, 'languages': ar, 'time': c.time.utc.to_i }
      }.to_json())
      expect(results).to match_array JSON.parse([
        {
          "oid": "0c7377bff42588dbb596b65bfba91977f41eb5c9",
          "languages": { "Python": { "add": 22, "del": 0 } },
          "time": 1547512442
        },
        {
          "oid": "ce2672b453c35b76b37c3beeac6b7308097a83be",
          "languages": { "Python": { "add": 34, "del": 1 } },
          "time": 1547513192
        },
        {
          "oid": "a6617fec33cd3bba4e243b467c29596c28331953",
          "languages": { "Python": { "add": 4, "del": 11 } },
          "time": 1547513215
        },
        {
          "oid": 'cddcaa40e9e160c7aec09bc79d2c2d25c3e6bb88',
          "languages": { "Python": { "add": 6, "del": 6 } },
          "time": 1547516099
        },
        {
          "oid"=>"9eb9d80f358538df8c43eb986b3c7b7047be8756",
          "languages": {},
          "time": 1547547935
        },
        {
          "oid": '9fb8d2b9dac1d76c66f93e6f0da0a267f32e0f8d',
          "languages": {
            "Python": { "add": 0, "del": 48 },
            "Ruby": {"add": 172, "del": 0}
          },
          "time": 1547553220
        }
      ].to_json)
    end
  end
end
