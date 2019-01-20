#!/usr/bin/env ruby -wKU

require 'rugged'
require 'linguist'

class Linguist::Repository
  protected
  def compute_stats(old_commit_oid, cache = nil)
    # Patch normal compute_stats to calculate deleted files.
    return {} if current_tree.count_recursive(MAX_TREE_SIZE) >= MAX_TREE_SIZE

    old_tree = old_commit_oid && Rugged::Commit.lookup(repository, old_commit_oid).tree
    read_index
    diff = Rugged::Tree.diff(repository, old_tree, current_tree)

    # Clear file map and fetch full diff if any .gitattributes files are changed
    if cache && diff.each_delta.any? { |delta| File.basename(delta.new_file[:path]) == ".gitattributes" }
      diff = Rugged::Tree.diff(repository, old_tree = nil, current_tree)
      file_map = {}
    else
      file_map = cache ? cache.dup : {}
    end

    diff.each_delta { |delta|
      file_map.delete(delta.old_file[:path])
      next if delta.binary || ![:added, :modified, :deleted].include?(delta.status)

      # Skip submodules and symlinks
      file = [:added, :modified].include?(delta.status) ? delta.new_file : delta.old_file
      mode = file[:mode]
      mode_format = (mode & 0170000)
      next if [0120000, 040000, 0160000].include?(mode_format)

      blob = Linguist::LazyBlob.new(repository, file[:oid], file[:path], mode.to_s(8))
      file_map[file[:path]] = [blob.language.group.name, blob.size] if blob.include_in_language_stats?
      blob.cleanup!
    }

    file_map
  end
end

module Archaeologist
  class RepoWalker
    def initialize(repo, email)
      @repo = Rugged::Repository.new(repo)
      @email = email
    end

    def each()
      walker = Rugged::Walker.new(@repo)
      already_walked = []
      @repo.branches.each { |br|
        cur_l = nil
        cur_oid = nil
        walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
        walker.push(br.target_id)
        walker.each { |c|
          cur_l = c.parents.empty? ?
            Linguist::Repository.new(@repo, c.oid) :
            Linguist::Repository.incremental(
              @repo, c.oid, cur_oid, cur_l.cache
            )
          cur_oid = c.oid
          if (c.author[:email] == @email || !@email&.size) &&
              !already_walked.include?(c.oid)
              already_walked << c.oid
            yield(c, cur_l)
          end
        }
      }
      walker.reset()
    end
  end
end
