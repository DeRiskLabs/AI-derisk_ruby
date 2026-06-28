# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = 'ai-derisk_ruby'
  spec.version     = '0.1.0'
  spec.authors     = ['DeriskLabs']
  spec.email       = ['engineering@derisklabs.com']

  spec.summary     = 'General Ruby skills for AI coding agents.'
  spec.description = 'The derisk_ruby skill collection: SKILL.md documents covering Ruby ' \
                     'object design, testing standards, test-driven development, and ' \
                     'characterization testing. Data-only gem; nothing to require.'
  spec.homepage    = 'https://github.com/DeriskLabs/AI-derisk_ruby'
  spec.license     = 'MIT'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
  }

  spec.files = Dir['INDEX.md', 'GEMINI.md', 'LICENSE.txt', '*/**/*'].select { |f| File.file?(f) }

  spec.require_paths = ['.']

  spec.add_dependency 'ai-derisk_common', '~> 0.1'
  spec.add_dependency 'ai-derisk_foundations', '~> 0.1'
end
