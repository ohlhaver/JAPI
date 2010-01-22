# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{japi}
  s.version = "1.2.0"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ram Singla"]
  s.date = %q{2010-01-21}
  s.description = %q{JAPI is ruby wrapper for Jurnalo RESTful API.}
  s.email = %q{ram.singla@gmail.com}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = [ 
    "History.txt",
    "README.markdown",
    "lib/JAPI.rb",
    "lib/JAPI/client.rb",
    "lib/JAPI/connect.rb",
    "lib/JAPI/models/author.rb",
    "lib/JAPI/models/author_preference.rb",
    "lib/JAPI/models/base.rb",
    "lib/JAPI/models/cluster.rb",
    "lib/JAPI/models/cluster_group.rb",
    "lib/JAPI/models/home_cluster_preference.rb",
    "lib/JAPI/models/home_display_preference.rb",
    "lib/JAPI/models/paginated_collection.rb",
    "lib/JAPI/models/pagination.rb",
    "lib/JAPI/models/preference.rb",
    "lib/JAPI/models/preference_option.rb",
    "lib/JAPI/models/source.rb",
    "lib/JAPI/models/source_preference.rb",
    "lib/JAPI/models/story.rb",
    "lib/JAPI/models/story_preference.rb",
    "lib/JAPI/models/topic.rb",
    "lib/JAPI/models/topic_preference.rb",
    "lib/JAPI/models/user.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{https://github.com/ohlhaver/JAPI}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{JAPI is ruby wrapper for Jurnalo RESTful API.}
  
  dependencies = { 
    'activesupport' => '>=2.3.4',
    'activeresource' => '>=2.3.4'
  }
  
  if s.respond_to?(:specification_version) && 
    Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0')
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2
    dependencies.each_pair do |gg, vv|
      s.add_runtime_dependency(gg, vv)
    end
  else
    dependencies.each_pair do |gg, vv|
      s.add_dependency(gg, vv)
    end
  end
end

