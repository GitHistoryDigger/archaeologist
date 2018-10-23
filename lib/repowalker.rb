#!/usr/bin/env ruby -wKU

require 'rugged'
require 'linguist'

class RepoWalker
  def initialize(repo, email)
    @repo = Rugged::Repository.new(repo)
    @email = email
  end

  def each()
    walker = Rugged::Walker.new(@repo)
    walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
    walker.push(@repo.head.target_id)
    walker.each { |c|
      if c.author[:email] == @email
        yield(c, Linguist::Repository.new(@repo, c.oid))
      end
    }
    walker.reset()
  end
end
